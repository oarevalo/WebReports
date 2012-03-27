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
			
			// check for exceptions to onRequestStart
			if(currentEvent eq "ehGeneral.dspNoAccess") return;
			
			// reset report if requested
			if(getValue("resetReport",false))  {
				structDelete(session,"oReport");
				structDelete(session,"oDataSourceBean");
			}

			// check that access to designer is OK
			if(Not StructKeyExists(Session,"isAuthorized") or not session.isAuthorized) {
				doRequestAuthentication();
			}
						 
			// make sure we have a datastore bean for this session
			if(Not StructKeyExists(Session,"oDataSourceBean")) {
				session.oDataSourceBean = createObject("Component","WebReports.common.components.datasource");
				bSessionDatasourceOK = false;
			}

			// make sure we have a report instance for this session
			if(Not StructKeyExists(Session,"oReport")) {
				session.oReport = createObject("Component","WebReports.common.components.Report").init();
				bSessionReportOK = false;
			}

			if(getValue("dataProviderType") neq "")		session.dataProviderType = getValue("dataProviderType");

			// define a default dataprovider
			if(not structKeyExists(session,"dataProviderType") or session.dataProviderType eq "") session.dataProviderType = defaultDataProvider;

			// if we had to create either a datasource or a report, 
			// or the datasource is empty then redirect to db setup page
			showDBDialog = (not bSessionDatasourceOK 
							or not bSessionReportOK 
							or not getDatasourceBean().validate());

			// check if we want to open a report 
			if(getValue("reportID") gt 0 or getValue("path") neq "" or getValue("reportID") neq "") {
				if(currentEvent neq "ehGeneral.doSaveReport") 	doOpenReport();
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
			setView("vwMain");
			setValue("oReport",getReport());
			setValue("sampleSize",250);
		</cfscript>
	</cffunction>

	<cffunction name="dspDatabase" access="public" returntype="void">
		<cfscript>
			if(getSetting("allowedDatasources") neq "") {
				setValue("lstDatasources", getSetting("allowedDatasources"));
			} else {
				setValue("lstDatasources", "");
			}
			
			setView("vwDatabase");
			setLayout("Layout.None");
			setValue("oDataSourceBean", getDatasourceBean());
			setValue("qryTypes", getDataProvider().getTypes());
		</cfscript>
	</cffunction>

	<cffunction name="dspSettings" access="public" returntype="void">
		<cfscript>
			setView("vwSettings");
			setValue("oReport",getReport());
			setLayout("Layout.None");
		</cfscript>
	</cffunction>

	<cffunction name="dspNoAccess" access="public" returntype="void">
		<cfscript>
			setView("vwNoAccess");
			setLayout("Layout.Clean");
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
			
				// initialize datamanager service
				initDatabase();
							
				setNextEvent("ehGeneral.dspMain");
			
			} catch(any e) {
				// clear existing datasource
				if(structKeyExists(session,"oDataSourceBean")) structDelete(session,"oDataSourceBean");
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehGeneral.dspMain");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doSetReportTitle" access="public" returntype="void">
		<cfscript>
			try {
				getReport().setTitle(getValue("title",""));
				setMessage("info", "Report title changed.");
				
			} catch(any e) {
				//getPlugin("logger").logError("Error setting report title", e);
				setMessage("error", e.message);
			}

			setNextEvent("ehBase.dspStatusBar");
		</cfscript>
	</cffunction>

	<cffunction name="doSetReportSubtitle" access="public" returntype="void">
		<cfscript>
			try {
				getReport().setSubtitle(getValue("subtitle",""));
				setMessage("info", "Report subtitle changed.");
				
			} catch(any e) {
				//getPlugin("logger").logError("Error setting report subtitle", e);
				setMessage("error", e.message);
			}

			setNextEvent("ehBase.dspStatusBar");
		</cfscript>
	</cffunction>
	
	<cffunction name="doOpenReport" access="public" returntype="void">
		<cfscript>
			var reportPath = getValue("path","");
			var reportID = getValue("reportID","");
			var df = getService("DAOFactory");
			var oReportLibrary = 0;
			var qryReport = 0;
						
			try {
				// reset current report
				getReport().clear();
				session.oDataSourceBean = createObject("Component","WebReports.common.components.datasource");
				session.functionParameters = "";
				
				// check if a reportID has been passed
				if(val(reportID) gt 0) {
					// load report from library
					oReportLibrary = createObject("component","WebReports.common.components.portal.reportLibrary").init(df);
					qryReport = oReportLibrary.get(reportID);
					if(qryReport.recordCount eq 0) throw("Requested report was not found!");
					reportPath = qryReport.reportHREF;
					
					// set data connection properties
					if(qryReport.datasource neq "" and qryReport.datasource neq "?") getDatasourceBean().setName(qryReport.datasource);
					if(qryReport.username neq "" and qryReport.username neq "?") getDatasourceBean().setUsername(qryReport.username);
					if(qryReport.password neq "" and qryReport.password neq "?") getDatasourceBean().setPassword(qryReport.password);
					if(qryReport.dbtype neq "") getDatasourceBean().setDBType(qryReport.dbtype);
				
				} else {
					if(reportPath eq "" or reportPath eq "null") 
						throw("Invalid document name");
				}
				
				// check that file exists
				if(Not fileExists(expandPath(reportPath))) 
					throw("The requested document does not exist.");
				
				// load report
				getReport().open(reportPath);

			} catch(any e) {
				//getPlugin("logger").logError("Error opening report", e);
				setMessage("error", e.message);			
			}
			
			setNextEvent("ehGeneral.dspMain");
		</cfscript>
	</cffunction>
	
	<cffunction name="doSaveReport" access="public" returntype="void">
		<cfscript>
			var reportPath = getValue("path","");
			var df = getService("DAOFactory");
			var oReportLibrary = 0;
			
			try {
				if(path eq "" or path eq "null") throw("Invalid document name");
				if(listLast(reportPath,".") neq "xml") reportPath = reportPath & ".xml";
				
				// save to file system
				getReport().save(expandPath(reportPath));
				
				// add to library
				oReportLibrary = createObject("component","WebReports.common.components.portal.reportLibrary").init(df);
				oReportLibrary.importReport(reportPath,
											getDatasourceBean().getName(),
											getDatasourceBean().getUsername(),
											getDatasourceBean().getPassword(),
											getDatasourceBean().getDBType() );
				
				setMessage("info", "Report saved");	
			
			} catch(lock e) {
				//getPlugin("logger").logError("Error opening report", e);
				setMessage("error", e.message);			
			}
			
			setNextEvent("ehGeneral.dspMain");
		</cfscript>
	</cffunction>

	<cffunction name="doSaveSettings" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			try {
				oReport = getReport();
				
				oReport.setReportProperty("authenticationDelegate", getValue("authenticationDelegate"));
				oReport.setReportProperty("displayGroupContents", getValue("displayGroupContents"));
				oReport.setReportProperty("doNotShowDuplicateRows", getValue("doNotShowDuplicateRows"));

				setMessage("info", "Report settings updated.");
				setLayout("Layout.None");
				setValue("refreshReport",true);
				
			} catch(any e) {
				//getPlugin("logger").logError("Error setting report title", e);
				setMessage("error", e.message);
			}
		</cfscript>	
	</cffunction>

	<cffunction name="doExit" access="public" returntype="void">
		<cfset structDelete(session,"oReport")>
		<cfset structDelete(session,"oDataSourceBean")>
		<cfset structDelete(session,"isAuthorized")>
		<cfset structDelete(session,"dataProviderType")>
		<cflocation url="#application.webReportsRoot#" addtoken="false">
	</cffunction>


	<!------------------------------>
	<!--- Private Methods	     --->
	<!------------------------------>	
	<cffunction name="getFiles" access="private" returntype="query">
		<cfargument name="path" required="yes">
		<cfset var qryFiles = QueryNew("")>
		<cfdirectory action="list" name="qryFiles" directory="#expandPath(arguments.path)#">
		<cfreturn qryFiles>
	</cffunction>

	<cffunction name="initDatabase" access="private" returntype="void">
		<cfscript>
			var tmp = "";
			
			// do a basic query to check that the db settings are ok
			try {
				tmp = getDataProvider().ping();			
			} catch(any e) {
				throw("Database login failed. Please check the connection settings and tried again.");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doRequestAuthentication" access="private" returntype="void">
		<cfset var userKey = getValue("userKey")>
		<cfset var authenticationDelegate = "/WebReports/portal/index.cfm?event=ehGeneral.doAuthDesigner">
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

		<!--- if we are not using managed reports, then there is no need
			to authenticate users --->
		<cfif not getSetting("useManagedReports")>
			<cfset session.isAuthorized = true>
			<cfreturn>
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
			<cfhttpparam name="referrer" type="formfield" value="#cgi.HTTP_REFERER#">
		</cfhttp>

		<!--- check that we got a good response --->
		<cfif left(httpResult.statusCode,3) neq "200">
			<cfthrow message="invalid response. #httpResult.statusCode#. Cannot connect to #authenticationDelegateURL#">
		</cfif>

		<!--- create a response object, this object is responsible for parsing the results of the http call --->
		<cfset oAuthResponse = createObject("component","WebReports.common.components.authResponse").init(httpResult.fileContent)>
		
		<!--- check if user is authorized to view the report --->
		<cfif oAuthResponse.getIsAuthorized()>
			<cfset session.isAuthorized = true>
		<cfelse>
			<!--- user is not authorized :( --->
			<cfset setNextEvent("ehGeneral.dspNoAccess")>
		</cfif>
	</cffunction>

</cfcomponent>