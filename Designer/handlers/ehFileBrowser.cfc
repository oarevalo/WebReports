<cfcomponent name="ehFileBrowser" extends="eventHandler">

	<cffunction name="dspBrowser" access="public" returntype="void">
		<!--- EXIT HANDLERS: --->
		<cfset xehBrowser = "ehFileBrowser.dspBrowser">
		<cfset xehNewFolder = "ehFileBrowser.doNewFolder">
		
		<cfset repoRoot = getSetting("reportRepositoryPath")>
		
		<cfif getValue("callbackItem",-1) neq -1>
			<cfset session.callBackItem = getvalue("callbackItem")>
		<cfelseif not structKeyExists(session, "callBackItem")>
			<cfdump var="You need a callBackItem in order to use the browser chooser">
			<cfaborT>
		</cfif>
		
		<cfif getValue("dir","") eq "" and structKeyExists(session,"currentRoot")>
			<cfset setvalue("dir",session.currentRoot)>
		</cfif>
		
		
		<!--- Test for dir param,else set to / --->
		<cfif getValue("dir",-1) eq -1>
			<cfset setValue("dir",repoRoot)>
		</cfif>
		<cfif getValue("dir") eq "">
			<cfset setvalue("dir",repoRoot)>
		</cfif>
		<!--- Init Options --->
		<cfif getvalue("dir") eq repoRoot>
			<cfset currentRoot = repoRoot>
			<cfset session.oldRoot = repoRoot>
			<cfset session.currentRoot = repoRoot>
		<cfelse>
			<cfset currentRoot = getValue("dir")>
			<cfset session.oldRoot = listdeleteAt(currentRoot, listlen(currentRoot,"/"), "/")>
			<cfif session.oldRoot eq "">
				<cfset session.oldRoot = repoRoot>
			</cfif>
			<cfset session.currentRoot = currentRoot>
		</cfif>
		
		<cfdirectory action="list" directory="#expandPath(currentRoot)#" name="qryDir" sort="asc">
		<cfquery name="qryDir" dbtype="query">
			SELECT *
				FROM qryDir
				ORDER BY Type,Name
		</cfquery>

		<cfset setValue("qryDir",qryDir)>
		<cfset setValue("repoRoot",repoRoot)>
		<cfset setValue("currentRoot",currentRoot)>
		<cfset setValue("xehBrowser",xehBrowser)>
		<cfset setValue("xehNewFolder",xehNewFolder)>
		<cfset setView("tags/serverbrowser")>
		<cfset setLayout("Layout.None")>
	</cffunction>
	
	<!--- ************************************************************* --->
	
	<cffunction name="doNewFolder" access="public" returntype="void">
		<cfset var newDir = "">
		<!--- Check for incoming params --->
		<cfif len(trim(getValue("newFolder",""))) eq 0>
			<cfset setMessage("warning", "Please enter a valid folder name.")>
		<cfelse>
		    <cfset newDir = getValue("dir") & "/" & getvalue("NewFolder")>
			<cfdirectory action="create" directory="#ExpandPath(newDir)#">
			<cfset setMessage("info", "Folder Created Successfully")>
		</cfif>
		
		<!--- Set the next event --->
		<cfset setNextEvent("ehFileBrowser.dspBrowser","dir=#getvalue("dir")#")>
	</cffunction>
	
	<!--- ************************************************************* --->
</cfcomponent>