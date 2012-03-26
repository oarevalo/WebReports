<cfcomponent name="ehStoredConnections" extends="eventHandler">

	<cffunction name="dspMain" access="public" returntype="void">
		<cfset var df = getService("DAOFactory")>
		<cfset var obj = createObject("component","WebReports.Common.Components.portal.storedConnections").init(df)>
		<cfset var qry = obj.getAll()>
		<cfset setValue("qryData",qry)>
		<cfset setView("vwStoredConnections_main")>
	</cffunction>

	<cffunction name="dspEdit" access="public" returntype="void">
		<cfset var df = getService("DAOFactory")>
		<cfset var storedConnectionID = getValue("storedConnectionID","")>
		<cfset var obj = createObject("component","WebReports.Common.Components.portal.storedConnections").init(df)>
		<cfset var qry = obj.get(storedConnectionID)>
		
		<cfif getSetting("allowedDatasources") eq "*">
			<cfset setValue("lstDatasources", arrayToList(getDatasources()))>

		<cfelseif getSetting("allowedDatasources") neq "">
			<cfset setValue("lstDatasources", getSetting("allowedDatasources"))>
		<cfelse>
			<cfset setValue("lstDatasources", "")>
		</cfif>
		
		<cfset setValue("qryData",qry)>
		<cfset setView("vwStoredConnections_edit")>
	</cffunction>

	<cffunction name="doSave" access="public" returnType="void">
		<cfscript>
			var df = getService("DAOFactory");
			storedConnectionID = getValue("storedConnectionID","");
			connectionName = getValue("connectionName","");
			datasource = getValue("datasource","");
			username = getValue("username","");
			password = getValue("password","");
			description = getValue("description","");
			
			obj = createObject("component","WebReports.Common.Components.portal.storedConnections").init(df);
			
			// save stored connection
			if(storedConnectionID eq "") 
				storedConnectionID = obj.insertRecord(connectionName, datasource, username, password, description);	
			else
				obj.updateRecord(storedConnectionID, connectionName, datasource, username, password, description);
			
			setNextEvent("ehStoredConnections.dspMain");
		</cfscript>		
	</cffunction>

	<cffunction name="doDelete" access="public" returntype="void">
		<cfset var df = getService("DAOFactory")>
		<cfset storedConnectionID = getValue("storedConnectionID","")>
		<cfset obj = createObject("component","WebReports.Common.Components.portal.storedConnections").init(df)>
		<cfset obj.deleteRecord(storedConnectionID)>
		<cfset setNextEvent("ehStoredConnections.dspMain")>
	</cffunction>

	<cffunction name="getDatasources" access="private" returntype="any">
		<cfset var oFactory = CreateObject("java", "coldfusion.server.ServiceFactory")>
		<cfset var stDS = oFactory.DataSourceService.getDatasources()>
		<cfset var aRet = StructKeyArray(stDS)>
		<cfset ArraySort(aRet, "textnocase", "asc")>
		<cfreturn aRet>
	</cffunction>

</cfcomponent>