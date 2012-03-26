<cfcomponent name="ehGroups" extends="eventHandler">
	
	<cffunction name="dspMain" access="public" returntype="void">
		<cfset var df = getService("DAOFactory")>
		<cfset var obj = createObject("component","WebReports.common.components.portal.groups").init(df)>
		<cfset var qry = obj.getAll()>
		<cfset setValue("qryGroups",qry)>
		<cfset setView("vwGroups_main")>
	</cffunction>

	<cffunction name="dspEdit" access="public" returntype="void">
		<cfset var df = getService("DAOFactory")>
		<cfset var groupID = getValue("groupID","")>
		<cfset var obj = createObject("component","WebReports.common.components.portal.groups").init(df)>
		<cfset var qry = obj.get(groupID)>
		<cfset setValue("qryGroup",qry)>
		<cfset setView("vwGroups_edit")>
	</cffunction>

	<cffunction name="doSave" access="public" returnType="void">
		<cfscript>
			var df = getService("DAOFactory");
			var groupID = getValue("groupID","");
			var groupName = getValue("groupName","");
			var description = getValue("description","");
			
			var obj = createObject("component","WebReports.common.components.portal.groups").init(df);
			
			// save group
			if(groupID eq "") 
				groupID = obj.insertRecord(groupName, description);	
			else
				obj.updateRecord(groupID, groupName, description);
			
			setNextEvent("ehGroups.dspMain");
		</cfscript>		
	</cffunction>

	<cffunction name="doDelete" access="public" returntype="void">
		<cfset var df = getService("DAOFactory")>
		<cfset var groupID = getValue("groupID","")>
		<cfset var obj = createObject("component","WebReports.common.components.portal.groups").init(df)>
		<cfset obj.deleteRecord(groupID)>
		<cfset setNextEvent("ehGroups.dspMain")>
	</cffunction>

</cfcomponent>