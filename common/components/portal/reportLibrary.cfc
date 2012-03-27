<cfcomponent name="reportLibrary" extends="layerSuperType">
	<cfset variables.REPORT_EXTENSION = "xml">
	
	<cffunction name="getAll" access="public" returnType="query">
		<cfreturn getDAOFactory().getDAO("reportLibrary").getAll()>
	</cffunction>

	<cffunction name="get" access="public" returnType="query">
		<cfargument name="reportID" type="numeric" required="true">
		<cfreturn getDAOFactory().getDAO("reportLibrary").get(arguments.reportID)>
	</cffunction>
	
	<cffunction name="insertRecord" access="public" returnType="string">
		<cfargument name="reportName" type="string" required="true">
		<cfargument name="reportHREF" type="string" required="true">
		<cfargument name="description" type="string" required="false" default="">
		<cfargument name="storedConnectionID" type="string" required="false" default="">
		<cfargument name="datasource" type="string" required="false" default="">
		<cfargument name="username" type="string" required="false" default="">
		<cfargument name="password" type="string" required="false" default="">
		<cfargument name="dbtype" type="string" required="false" default="">
		<cfargument name="isPublic" type="boolean" required="false" default="1">
		
		<cfscript>
			if(arguments.reportName eq "") throw("Report name cannot be empty","validation.invalidReportName");
			if(arguments.reportHREF eq "") throw("Report HREF cannot be empty","validation.invalidReportHREF");
			if(storedConnectionID eq "" and datasource eq "") throw("You must select either a datasource or stored connection for the report","validation.noConnection");
			if(storedConnectionID neq "" and datasource neq "") throw("You must select either a datasource or stored connection for the report","validation.noConnection");
			
			arguments.createdOn = now();
			
			return getDAOFactory().getDAO("reportLibrary").save(argumentCollection = arguments);
		</cfscript>
	</cffunction>

	<cffunction name="updateRecord" access="public">
		<cfargument name="reportID" type="numeric" required="true">
		<cfargument name="reportName" type="string" required="true">
		<cfargument name="reportHREF" type="string" required="true">
		<cfargument name="description" type="string" required="false" default="">
		<cfargument name="storedConnectionID" type="string" required="false" default="">
		<cfargument name="datasource" type="string" required="false" default="">
		<cfargument name="username" type="string" required="false" default="">
		<cfargument name="password" type="string" required="false" default="">
		<cfargument name="dbtype" type="string" required="false" default="">
		<cfargument name="isPublic" type="boolean" required="false" default="1">
		<cfscript>
			arguments.id = arguments.reportID;

			if(arguments.reportName eq "") throw("Report name cannot be empty","validation.invalidReportName");
			if(arguments.reportHREF eq "") throw("Report HREF cannot be empty","validation.invalidReportHREF");
			
			getDAOFactory().getDAO("reportLibrary").save(argumentCollection = arguments);
		</cfscript>
	</cffunction>	

	<cffunction name="deleteRecord" access="public">
		<cfargument name="reportID" datatype="string" required="true">
		<cfset getDAOFactory().getDAO("reportLibrary").delete(arguments.reportID)>
	</cffunction>		

	<cffunction name="deleteReport" access="public">
		<cfargument name="reportID" datatype="string" required="true">
		<cfargument name="deleteFile" datatype="boolean" required="false" default="true">
		
		<cfset var qryReport = get(arguments.reportID)>
		
		<cfif qryReport.recordCount>
			<!--- delete report file --->
			<cfif fileExists(expandPath(qryReport.reportHREF))>
				<cffile action="delete" file="#expandPath(qryReport.reportHREF)#">
			</cfif>
			
			<!--- delete record --->
			<cfset deleteRecord(arguments.reportID)>
		</cfif>
	</cffunction>	

	<cffunction name="setReportGroups" access="public">
		<cfargument name="reportID" type="string" required="true">
		<cfargument name="lstGroupID" type="string" required="true">

		<cfset var reportGroupsDAO = 0>
		<cfset var qryReportGroups = 0>
		<cfset var groupID = 0>
		
		<cfset reportGroupsDAO = getDAOFactory().getDAO("reportGroups")>
		<cfset qryReportGroups = reportGroupsDAO.search(reportID = arguments.reportID)>
		
		<cfloop query="qryReportGroups">
			<cfset reportGroupsDAO.delete(qryReportGroups.reportGroupID)>
		</cfloop>
		
		<cfloop list="#arguments.lstGroupID#" index="groupID">
			<cfset reportGroupsDAO.save(reportID = arguments.reportID,
										groupID = groupID)>
		</cfloop>
	</cffunction>
	
	<cffunction name="setReportUsers" access="public">
		<cfargument name="reportID" type="string" required="true">
		<cfargument name="lstUserID" type="string" required="true">

		<cfset var reportUsersDAO = 0>
		<cfset var qryReportUsers = 0>
		<cfset var userID = 0>

		<cfset reportUsersDAO = getDAOFactory().getDAO("reportUsers")>
		<cfset qryReportUsers = reportUsersDAO.search(reportID = arguments.reportID)>
		
		<cfloop query="qryReportUsers">
			<cfset reportUsersDAO.delete(qryReportUsers.reportUserID)>
		</cfloop>
		
		<cfloop list="#arguments.lstUserID#" index="userID">
			<cfset reportUsersDAO.save(reportID = arguments.reportID,
										userID = userID)>
		</cfloop>
	</cffunction>	
	
	<cffunction name="getReportGroups" access="public" returnType="query">
		<cfargument name="reportID" type="string" required="true">	
		<cfset var qry = 0>
		<cfset var qryReportGroups = 0>
		<cfset var qryGroups = 0>
		
		<cfset qryReportGroups = getDAOFactory().getDAO("reportGroups").search(reportID = arguments.reportID)>
		<cfset qryGroups = getDAOFactory().getDAO("groups").getAll()>
		
		<cfquery name="qry" dbtype="query">
			SELECT qryGroups.*
				FROM qryReportGroups, qryGroups
				WHERE qryReportGroups.groupID = qryGroups.GroupID
		</cfquery>
		
		<cfreturn qry>
	</cffunction>

	<cffunction name="getReportUsers" access="public" returnType="query">
		<cfargument name="reportID" type="string" required="true">
		<cfset var qry = 0>
		<cfset var qryReportUsers = 0>
		<cfset var qryUsers = 0>
		
		<cfset qryReportUsers = getDAOFactory().getDAO("reportUsers").search(reportID = arguments.reportID)>
		<cfset qryUsers = getDAOFactory().getDAO("users").getAll()>
		
		<cfquery name="qry" dbtype="query">
			SELECT qryUsers.*
				FROM qryReportUsers, qryUsers 
				WHERE qryReportUsers.userID = qryUsers.userID
		</cfquery>
		
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getUserReports" access="public" returntype="query">
		<cfargument name="userID" type="string" required="true">
		
		<cfset var lstReportID = 0>
		<cfset var qry = 0>

		<!--- get all public reports --->
		<cfset qry = getPublicReports()>
		<cfset lstReportID = listAppend(lstReportID, valueList(qry.reportID))>
		
		<!--- get all reports explicitly assigned to this particular user --->
		<cfset qry = getDAOFactory().getDAO("reportUsers").search(userID = arguments.userID)>
		<cfset lstReportID = listAppend(lstReportID, valueList(qry.reportID))>
		
		<!--- get all reports assigned to a group to which this user belongs --->
		<cfset qryReportGroups = getDAOFactory().getDAO("reportGroups").getAll()>
		<cfset qryUserGroups = getDAOFactory().getDAO("userGroups").search(userID = arguments.userID)>
		<cfquery name="qry" dbtype="query">
			SELECT qryReportGroups.reportID
				FROM qryReportGroups, qryUserGroups
				WHERE qryReportGroups.groupID = qryUserGroups.GroupID
		</cfquery>
		<cfset lstReportID = listAppend(lstReportID, valueList(qry.reportID))>

		<cfset qryReports = getDAOFactory().getDAO("reportLibrary").getAll()>
		
		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM qryReports
				WHERE reportID IN (<cfqueryparam cfsqltype="cf_sql_numeric" list="true" value="#lstReportID#">)
		</cfquery>
				
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getPublicReports" access="public" returntype="query">
		<cfreturn getDAOFactory().getDAO("reportLibrary").search(isPublic = 1)>
	</cffunction>	
	
	<cffunction name="importDir" access="public" returntype="numeric" description="imports all reports on the given path">
		<cfargument name="href" type="string" required="true" hint="relative path to the directory in which the reports to import are located">
		<cfset var qryDir = 0>
		<cfset var oDAO = 0>
		<cfset var numAdded = 0>

		<cfif right(arguments.href,1) neq "/">
			<cfset arguments.href = arguments.href & "/">
		</cfif>
		
		<cfdirectory action="list" directory="#expandPath(arguments.href)#" name="qryDir" filter="*.#variables.REPORT_EXTENSION#" />

		<cfset oDAO = getDAOFactory().getDAO("reportLibrary")>
		
		<cfloop query="qryDir">
			<cfif qryDir.type eq "file">
				<cfset thisPath = arguments.href & qryDir.name>
				<cfset qryReport = oDAO.search(reportHREF = thisPath)>
				<cfif not qryReport.recordCount>
					<cfset importReport(thisPath,"?","?","?")>
					<cfset numAdded = numAdded + 1>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfreturn numAdded>
	</cffunction>
	
	<cffunction name="importReport" access="public" returntype="void" description="Imports a report from the file system">
		<cfargument name="href" type="string" required="true" hint="relative path to the report xml file">
		<cfargument name="datasource" type="string" required="false" default="">
		<cfargument name="username" type="string" required="false" default="">
		<cfargument name="password" type="string" required="false" default="">
		<cfargument name="dbtype" type="string" required="false" default="">
		<cfscript>
			var xmlDoc = 0;
			var oDAO = 0;
			
			if(not fileExists(expandPath(arguments.href)))
				throw("File not found!","fileNotFoundException");
			
			xmlDoc = xmlParse(expandPath(arguments.href));
		
			oDAO = getDAOFactory().getDAO("reportLibrary");
			
			oDAO.save(reportName = xmlDoc.xmlRoot.title.xmlText,
						reportHREF = arguments.href,
						description = xmlDoc.xmlRoot.subtitle.xmlText,
						datasource = arguments.datasource,
						username = arguments.username,
						password = arguments.password,
						dbtype = arguments.dbtype,
						isPublic = 1,
						createdOn = now());
		</cfscript>
	</cffunction>
	
	<cffunction name="isUserAuthorized" access="public" returntype="boolean" description="Checks whether the given userID is authorized to view a report">
		<cfargument name="reportID" type="numeric" required="true">	
		<cfargument name="userID" type="numeric" required="true">	
		<cfscript>
			var qryUserReports = getUserReports(arguments.userID);
			return listFind(valueList(qryUserReports.reportID), arguments.reportID);
		</cfscript>
	</cffunction>
	
</cfcomponent>