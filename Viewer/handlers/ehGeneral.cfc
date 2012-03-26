<cfcomponent name="ehGeneral" extends="ehBase">
	
	<!----------------------------->
	<!--- App Event Handlers    --->
	<!----------------------------->
	<cffunction name="onApplicationStart" access="public" returntype="void">
		<cfset application.webReportsRoot = "/WebReports">
	</cffunction>

	<cffunction name="onRequestStart" access="public" returntype="void">
		<cfscript>
			var bSessionDatasourceOK = true;
			var bSessionReportOK = true;
			var currentEvent = getValue("event");
			var showDBDialog = false;
			var defaultDataProvider = getSetting("defaultDataProvider");

			setValue("allowedDatasources", getSetting("allowedDatasources") );
			setValue("versionTag", getSetting("versionTag"));
			setValue("debugMode", getSetting("debugMode"));
			setValue("logoImageURL", getSetting("logoImageURL"));
			setValue("logoLinkURL", getSetting("logoLinkURL"));

			// define default session params
			if(not structKeyExists(session,"oReport"))				session.oReport = 0;
			if(not structKeyExists(session,"oDataSourceBean"))		session.oDataSourceBean = 0;
			if(not structKeyExists(session,"exitURL"))				session.exitURL = "";
			if(not structKeyExists(session,"functionParameters"))	session.functionParameters = "";
			if(not structKeyExists(session,"dataProviderType"))		session.dataProviderType = "";

			
			// reset report if requested
			if(getValue("resetReport",false))  {
				session.oReport = 0;
				session.oDataSourceBean = 0;
			}
			 
			// make sure we have a datastore bean for this session
			if(isSimpleValue(session.oDataSourceBean)) {
				session.oDataSourceBean = createObject("Component","WebReports.Common.Components.datasource");
				bSessionDatasourceOK = false;
			}

			// make sure we have a report instance for this session
			if(isSimpleValue(session.oReport)) {
				session.oReport = createObject("Component","WebReports.Common.Components.Report").init();
				bSessionReportOK = false;
			}

			// if we had to create either a datasource or a report, 
			// or the datasource is empty then redirect to db setup page
			showDBDialog = (not bSessionDatasourceOK 
							or not bSessionReportOK 
							or getDatasourceBean().getName() eq "");

			// process incoming parameters
			if(getValue("exitURL") neq "") 				session.exitURL = getValue("exitURL");
			if(getValue("functionParameters") neq "") 	session.functionParameters = getValue("functionParameters");
			if(getValue("dataProviderType") neq "")		session.dataProviderType = getValue("dataProviderType");

			// check if we want to open a report 
			if(getValue("reportID") gt 0 or getValue("report") neq "" or getValue("reportID") neq "") {
				doOpenReport();
			}

			// at this point, we should have a report loaded
			if(currentEvent neq "ehGeneral.dspNoAccess" and getReport().getTableName() eq "") {
				getReport().clear();	
				setMessage("warning","No report to display");
				setNextEvent("ehGeneral.dspNoAccess");
			}

			setValue("showDBDialog",showDBDialog);
			setValue("datasourceBean", getDatasourceBean());
		</cfscript>
	</cffunction>

	<cffunction name="onRequestEnd" access="public" returntype="void">
		<!--- code to execute at the end of each request --->
	</cffunction>



	<!------------------------------>
	<!--- Display Event Handlers --->
	<!------------------------------>
	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			// set main view
			setView("vwMain");
			
			// pass report to view
			setValue("oReport",getReport());
		</cfscript>
	</cffunction>

	<cffunction name="dspDatabase" access="public" returntype="void">
		<cfscript>
			if(getSetting("allowedDatasources") eq "*") {
				setValue("lstDatasources", arrayToList(getDatasources()));
			} else if(getSetting("allowedDatasources") neq "") {
				setValue("lstDatasources", getSetting("allowedDatasources"));
			} else {
				setValue("lstDatasources", "");
			}
			
			setView("vwDatabase");
			setLayout("Layout.None");
			setValue("oDataSourceBean", getDatasourceBean());
		</cfscript>
	</cffunction>

	<cffunction name="dspNoAccess" access="public" returntype="void">
		<cfscript>
			setView("vwNoAccess");
			setLayout("Layout.None");
		</cfscript>
	</cffunction>

	<!------------------------------>
	<!--- Action Event Handlers  --->
	<!------------------------------>
	<cffunction name="doSetDatabase" access="public" returntype="void">
		<cfscript>
			var dsName = trim(getValue("name",""));
			var dsUsername = trim(getValue("username",""));
			var dsPassword = trim(getValue("password",""));
			var dsDBType = trim(getValue("dbtype",""));

			try {
				if(dsName eq "") throw("Please enter the name of the datasource.");
				
				// setup the datasourcebean
				getDatasourceBean().setName(dsName);
				getDatasourceBean().setUsername(dsUsername);
				getDatasourceBean().setPassword(dsPassword);
				getDatasourceBean().setDBType(dsDBType);

				setNextEvent("ehGeneral.dspMain");
			
			} catch(any e) {
				//getPlugin("logger").logError("Error setting database connection", e);
				// clear existing datasource
				if(structKeyExists(session,"oDataSourceBean")) structDelete(session,"oDataSourceBean");
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehGeneral.dspMain");
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="doOpenReport" access="public" returntype="void">
		<cfscript>
			var reportPath = "";
			var reportID = 0;
			var df = getService("DAOFactory");
			var oReportLibrary = 0;
			var qryReport = 0;
			var bComingFromPortal = false;
			var bIsAuthorized = true;
			
			var datasource = "";
			var username = "";
			var password = "";
			var dbtype = "";
			
			var portalAuthenticatorURL = "/WebReports/Portal/index.cfm?event=ehGeneral.doAuthReport";
						
			try {
				// reset environment
				getReport().clear();
				session.oDataSourceBean = createObject("Component","WebReports.Common.Components.datasource");
				session.exitURL = "";
				session.functionParameters = "";

				// check if user is coming from the portal
				// (we will only trust a userID value if coming from portal)
				bComingFromPortal = findNoCase("/WebReports/Portal/",cgi.http_referer)
									and findNoCase(cgi.http_host,cgi.http_referer);

				// check if a reportID has been passed
				reportID = val(getValue("reportID"));
				
				if(reportID gt 0) {
					// load report from library
					oReportLibrary = createObject("component","WebReports.Common.Components.portal.reportLibrary").init(df);
					qryReport = oReportLibrary.get(reportID);
					if(qryReport.recordCount eq 0) throw("Requested report was not found!");
					reportPath = qryReport.reportHREF;
					
					// set data connection properties
					if(not bComingFromPortal) {
						if(qryReport.storedConnectionID gt 0) {
							oStoredConnection = createObject("component","WebReports.Common.Components.portal.storedConnections").init(df);
							qryConn = oStoredConnection.get(qryReport.storedConnectionID);
							datasource = qryConn.datasource;
							username = qryConn.username;
							password = qryConn.password;
							dbtype = qryConn.dbtype;
						} else {
							datasource = qryReport.datasource;
							username = qryReport.username;
							password = qryReport.password;
							dbtype = qryReport.dbtype;
						}
					}

				} else {
					if(getSetting("allowOpenReportsByName")) {
						reportPath = getValue("report");
						datasource = getValue("datasource");
						username = getValue("username");
						password = getValue("password");
						dbtype = getValue("dbtype");
					} else {
						getReport().clear();	
						setMessage("warning","Opening reports by name is not allowed. All reports must exist on the report library.");
						setNextEvent("ehGeneral.dspNoAccess");
					}
				}

				// set data connection properties
				if(datasource neq "" and datasource neq "?") getDatasourceBean().setName(datasource);
				if(username neq "" and username neq "?") getDatasourceBean().setUsername(username);
				if(password neq "" and password neq "?") getDatasourceBean().setPassword(password);
				if(dbtype neq "") getDatasourceBean().setDBType(dbtype);
			
				// set exit url
				if(getValue("exitURL") neq "") 	session.exitURL = getValue("exitURL");

				// set function parameters
				if(getValue("functionParameters") neq "") 	session.functionParameters = getValue("functionParameters");
			
				// set data provider type
				if(getValue("dataProviderType") neq "")		
					session.dataProviderType = getValue("dataProviderType");
				else
					session.dataProviderType = getSetting("defaultDataProvider");
				
				// check that file exists
				if(Not fileExists(expandPath(reportPath))) 
					throw("The requested document does not exist.");
				
				
				// load report
				getReport().open(reportPath);

				
				try {
					if(not bComingFromPortal) {
						// check if this report has a custom authentication
						// we only check this if user is not coming from the Portal
						if(reportID gt 0 and getReport().getReportProperty("authenticationDelegate") eq "") {
							// report does not have a custom authentication, but it has a reportID,
							// so we can check for public/private access
							// Also, since we dont know where the user is coming from we wont trust any incoming userKry
							setValue("userKey","");
							bIsAuthorized = doRequestAuthentication(reportID,portalAuthenticatorURL);
						} else {
							bIsAuthorized = doRequestAuthentication(reportPath);
						}
						
					} else {
						// if user is coming from the portal then we will callback the portal
						// to verify user access and retrieve db info
						if(reportID gt 0) 
							bIsAuthorized = doRequestAuthentication(reportID,portalAuthenticatorURL);
					}
					
					if(not bIsAuthorized) {
						getReport().clear();	
						setMessage("warning","You are not authorized to view this report.");
						setNextEvent("ehGeneral.dspNoAccess");
					}
					
				} catch(any e) {
					getReport().clear();
					dump(e);
					abort();
					setMessage("error","An error ocurred while trying to authenticate access to this report. Error message: " & e.message);
					setNextEvent("ehGeneral.dspNoAccess");
				}
				
			} catch(any e) {
				setMessage("error", e.message);			
			}
			
			setNextEvent("ehGeneral.dspMain");
		</cfscript>
	</cffunction>
	
	
	<!------------------------------>
	<!--- Internal Methods		 --->
	<!------------------------------>
	<cffunction name="doRequestAuthentication" access="private" returntype="boolean">
		<cfargument name="reportPath" type="string" required="true">
		<cfargument name="AuthDelegate" type="string" required="false" default="">
		<cfset var userKey = getValue("userKey")>
		<cfset var authenticationDelegate = "">
		<cfset var protocol = "http">
		<cfset var httpResult = "">
		<cfset var timeOut = 15>
		<cfset var oAuthResponse = 0>
		<cfset var authenticationDelegateURL = "">
		<cfset var thisServer = cgi.server_name> 

		<!--- get internal server name --->
		<cfif getSetting("useLocalhostAsInternalServerName")>
			<cfset thisServer = "localhost">
		</cfif>

		<!--- check if we are using a custom authentication delegate --->
		<cfif arguments.authDelegate neq "">
			<cfset authenticationDelegate = arguments.authDelegate>
		<cfelse>
			<cfset authenticationDelegate = getReport().getReportProperty("authenticationDelegate")>
		</cfif>

		<!--- if there is no authenticationDelegate, then assume this is a public report --->
		<cfif authenticationDelegate eq "">
			<cfreturn true>
		</cfif>


		<!--- if authentication delegate has been passed as a relative url,
			then assume is the local server --->		
		<cfif left(authenticationDelegate,4) neq "http">
			<cfif cgi.SERVER_PORT_SECURE eq 1>
				<cfset protocol = "https">
			</cfif>
			<cfset authenticationDelegateURL = protocol & "://" & thisServer>
			<cfif cgi.SERVER_PORT neq 80>
				<cfset authenticationDelegateURL = authenticationDelegateURL & ":" & cgi.SERVER_PORT>
			</cfif>
			<cfif left(authenticationDelegate,1) neq "/">
				<cfset authenticationDelegate = "/" & authenticationDelegate>
			</cfif>
			
			<cfset authenticationDelegateURL = authenticationDelegateURL & authenticationDelegate>
		<cfelse>
			<cfset authenticationDelegateURL = authenticationDelegate>
		</cfif>

		<!--- call the authentication delegate --->
		<cfhttp url="#authenticationDelegateURL#" 
				method="post" 
				redirect="true" 
				throwonerror="false" 
				timeout="#timeOut#" 
				result="httpResult">
			<cfhttpparam name="userKey" type="formfield" value="#userKey#">
			<cfhttpparam name="reportURL" type="formfield" value="#arguments.reportPath#">
			<cfhttpparam name="referrer" type="formfield" value="#cgi.HTTP_REFERER#">
		</cfhttp>

		<!--- check that we got a good response --->
		<cfif left(httpResult.statusCode,3) neq "200">
			<cfthrow message="invalid response. #httpResult.statusCode#">
		</cfif>

		<!--- create a response object, this object is responsible for parsing the results of the http call --->
		<cfset oAuthResponse = createObject("component","WebReports.Common.Components.authResponse").init(httpResult.fileContent)>

		<!--- check if user is authorized to view the report --->
		<cfif oAuthResponse.getIsAuthorized()>
			<!--- user is authorized :) --->
			<!--- pass the datasource bean in case the reponse included db connection parameters --->
			<cfset oAuthResponse.setDatasourceBean( getDatasourceBean() )>
			
			<!--- check if the authResponse wants to change the dataprovider type
				(otherwise set the default dataprovider)
			 --->
			<cfif oAuthResponse.getDataProviderType() neq "">
				<cfset session.dataProviderType = oAuthResponse.getDataProviderType()>
			</cfif>
			<cfreturn true>
		<cfelse>
			<!--- user is not authorized :( --->
			<cfreturn false>
		</cfif>
	</cffunction>

</cfcomponent>