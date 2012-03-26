<cfcomponent name="ehReportLibrary" extends="eventHandler">

	<cffunction name="dspMain" access="public" returntype="void">
		<cfset var df = getService("DAOFactory")>
		<cfset var obj = createObject("component","WebReports.common.components.portal.reportLibrary").init(df)>
		<cfset var qry = obj.getAll()>
		<cfset setValue("qryData",qry)>
		<cfset setView("vwReportLibrary_main")>
	</cffunction>

	<cffunction name="dspEdit" access="public" returntype="void">
		<cfset var df = getService("DAOFactory")>
		<cfset var reportID = getValue("reportID",0)>
		<cfset var obj = createObject("component","WebReports.common.components.portal.reportLibrary").init(df)>
		<cfset var qry = obj.get(reportID)>

		<cfset obj = createObject("component","WebReports.common.components.portal.storedConnections").init(df)>
		<cfset qryConn = obj.getAll()>

		<cfif getSetting("allowedDatasources") neq "">
			<cfset setValue("lstDatasources", getSetting("allowedDatasources"))>
		<cfelse>
			<cfset setValue("lstDatasources", "")>
		</cfif>

		<cfset setValue("qryData",qry)>
		<cfset setValue("qryStoredConnections",qryConn)>

		<cfset setView("vwReportLibrary_edit")>
	</cffunction>

	<cffunction name="dspAccess" access="public" returntype="void">
		<cfscript>
			var df = getService("DAOFactory");
			var reportID = getValue("reportID",0);
			
			obj = createObject("component","WebReports.common.components.portal.reportLibrary").init(df);
			qryReport = obj.get(reportID);
			qryReportGroups = obj.getReportGroups(reportID);
			qryReportUsers = obj.getReportUsers(reportID);
			
			obj = createObject("component","WebReports.common.components.portal.groups").init(df);
			qryGroups = obj.getAll();		

			obj = createObject("component","WebReports.common.components.portal.users").init(df);
			qryUsers = obj.searchUsers();		

			setValue("qryReport",qryReport);
			setValue("qryReportGroups",qryReportGroups);
			setValue("qryReportUsers",qryReportUsers);
			setValue("qryGroups",qryGroups);
			setValue("qryUsers",qryUsers);
			
			setView("vwReportLibrary_access");
		</cfscript>
	</cffunction>

	<cffunction name="doSave" access="public" returnType="void">
		<cfscript>
			var df = getService("DAOFactory");
			
			try {
				reportID = getValue("reportID",0);
				reportName = getValue("reportName","");
				reportHREF = getValue("reportHREF","");
				description = getValue("description","");
				storedConnectionID = getValue("storedConnectionID","");
				datasource = getValue("datasource","");
				username = getValue("username","");
				password = getValue("password","");
				storedConnection_p = getValue("storedConnectionID_p",0);
				datasource_p = getValue("datasource_p",0);
				username_p = getValue("username_p",0);
				password_p = getValue("password_p",0);
				isPublic = getValue("isPublic",false);
				dbtype = getValue("dbtype","");
				
				obj = createObject("component","WebReports.common.components.portal.reportLibrary").init(df);
				
				if(storedConnection_p) storedConnectionID = "?";
				if(datasource_p) datasource = "?";
				if(username_p) username = "?";
				if(password_p) password = "?";
				
				// save report
				if(reportID eq "") 
					storedConnectionID = obj.insertRecord(reportName, reportHREF, description, storedConnectionID, datasource, username, password, dbtype, isPublic);	
				else
					obj.updateRecord(reportID, reportName, reportHREF, description, storedConnectionID, datasource, username, password, dbtype, isPublic);
				
				setNextEvent("ehReportLibrary.dspMain");

			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("ehReportLibrary.dspEdit");

			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehReportLibrary.dspEdit");
			}
		</cfscript>		
	</cffunction>

	<cffunction name="doDelete" access="public" returntype="void">
		<cfset var df = getService("DAOFactory")>
		<cfset var reportID = getValue("reportID",0)>
		<cfset var deleteFile = getValue("deleteFile",true)>
		<cfset var obj = createObject("component","WebReports.common.components.portal.reportLibrary").init(df)>
		<cfset obj.deleteReport(reportID, (isBoolean(deleteFile) and deleteFile))>
		<cfset setNextEvent("ehReportLibrary.dspMain")>
	</cffunction>

	<cffunction name="doSaveAccess" access="public" returntype="void">
		<cfscript>
			var df = getService("DAOFactory");
			var reportID = getValue("reportID",0);
			var lstReportGroups = getValue("lstReportGroups","");
			var lstReportUsers = getValue("lstReportUsers","");
			
			obj = createObject("component","WebReports.common.components.portal.reportLibrary").init(df);
			
			obj.setReportGroups(reportID, lstReportGroups);
			obj.setReportUsers(reportID, lstReportUsers);
			
			setNextEvent("ehReportLibrary.dspMain");
		</cfscript>
	</cffunction>

	<cffunction name="doSyncRepo" access="public" returntype="void">
		<cfscript>
			var df = getService("DAOFactory");
			var repoPath = getSetting("reportRepositoryPath");
			var obj = createObject("component","WebReports.common.components.portal.reportLibrary").init(df);
			var num = obj.importDir(repoPath);
			
			if(num gt 0)
				setMessage("info","#num# reports added to library");
			else
				setMessage("info","No new reports found");

			setNextEvent("ehReportLibrary.dspMain");
		</cfscript>
	</cffunction>
	
</cfcomponent>