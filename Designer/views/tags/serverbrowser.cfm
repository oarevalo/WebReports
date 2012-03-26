<cfparam name="request.requestState.qryDir" default="">
<cfparam name="request.requestState.currentRoot" default="">
<cfparam name="request.requestState.xehBrowser" default="">
<cfparam name="request.requestState.xehNewFolder" default="">
<cfparam name="request.requestState.repoRoot" default="">

<cfset qryDir = request.requestState.qryDir>
<cfset currentRoot = request.requestState.currentRoot>
<cfset xehBrowser = request.requestState.xehBrowser>
<cfset xehNewFolder = request.requestState.xehNewFolder>
<cfset repoRoot = request.requestState.repoRoot>

<cfset selectedFilename = "">
<cfif session.callbackItem eq "saveReport">
	<cfset selectedFilename = session.oReport.getTitle() & ".xml">
	<cfset tmpTitle = "Save Report">
<cfelse>
	<cfset tmpTitle = "Open Report">
</cfif>

<cfoutput>
	<div class="podTitle" style="line-height:20px;">
		<a href="##" 
			onclick="closeBrowser()" 
			style="float:right;color:##fff;margin-right:10px;margin-top:3px;"><img 
			src="/WebReports/Common/Images/iclose.gif" 
			alt="Close Dialog" title="Close Dialog"
			border="0"></a>
		&nbsp;#tmpTitle#
	</div>	
<div id="FileBrowser">
<form name="fileviewer" id="fileviewer" method="post" action="index.cfm">
<div style="width: 550px;margin: 10px; border:1px outset ##ddd;margin-left:auto;margin-right:auto;background-color: ##FFFFFF">
	
	<div style="border-bottom:1px solid ##ddd; background-color: ##f5f5f5;padding: 5px;font-weight:bold;">
	   <a href="javascript:doEvent('#xehBrowser#', 'DialogPanelContainer',{dir:'#jsstringFormat(currentroot)#'})" title="Refresh Listing"><img src="images/arrow_refresh.png" align="absmiddle" border="0" title="Refresh Listing."></a>
		You are Here: #currentRoot#</div>
	
	<div style="line-height:20px;padding:3px;overflow:auto;height: 230px;font-weight:bold">
	    <cfinclude template="../../includes/message.cfm">
		<cfif listlen(currentroot,"/") gte 1 and currentRoot neq repoRoot>
			<cfset tmpHREF = "javascript:doEvent('#xehBrowser#','DialogPanelContainer',{dir:'#JSStringFormat(session.oldRoot)#'})">
			<a href="#tmpHREF#"><img src="images/folder.png" border="0" align="absmiddle" alt="Folder"></a>
			<a href="#tmpHREF#">..</a><br>
		</cfif>
		<cfloop query="qryDir">
			<cfset vURL = "#currentRoot##iif(currentroot eq "/","''","'/'")##urlEncodedFormat(qryDir.name)#">

			<cfif qryDir.type eq "Dir">
				<cfset tmpHREF = "javascript:doEvent('#xehBrowser#','DialogPanelContainer',{dir:'#JSStringFormat(vURL)#'})">
				<div id="#JSStringFormat(qryDir.name)#" 
						onClick="selectItem('#jsstringFormat(qrydir.name)#','#JSStringFormat(vURL)#','dir')" 
						style="cursor: pointer;" 
						onDblclick="#tmpHREF#">
					<a href="#tmpHREF#"><img src="images/folder.png" border="0" align="absmiddle" alt="Folder"></a>
					#qryDir.name#
				</div>
			<cfelse>
				<cfset tmpHREF = "javascript:selectItem('#jsstringFormat(qrydir.name)#','#JSStringFormat(vURL)#','file')">
				<div id="#JSStringFormat(qryDir.name)#" onClick="#tmpHREF#" style="cursor: pointer;" onDblclick="chooseFolder('#session.callbackItem#')">
					<a href="#tmpHREF#"><img src="images/page_white.png" border="0" align="absmiddle" alt="Document"></a>
					#qryDir.name#
				</div>
			</cfif>
		</cfloop>
	</div>
	
	<div style="font-size:9px;background-color:fffff0;padding:3px;border-top:1px solid ##ddd"><strong>Selected:&nbsp;</strong><span id="span_selectedfolder"></span></div>
	
	<div style="border-top:1px solid ##ddd; background-color: ##f5f5f5;padding: 5px;font-weight:bold; text-align:right">
	<input type="hidden" name="selecteddir" id="selecteddir" value="#currentRoot#" style="width:300px;font-size:10px;">
	<input type="hidden" name="currentroot" id="currentroot" value="#currentRoot#">

	<strong>File name:</strong> <input type="text" name="filename" id="selectedFilename" value="#selectedFilename#" style="width:230px;font-size:10px;" onkeyup="$('selectdir_btn').disabled=(this.value=='')">
	<input type="button" id="cancel_btn" value="Cancel" style="font-size: 9xp" onClick="closeBrowser()"> &nbsp;
	<input type="button" id="createdir_btn" value="New Folder" style="font-size: 9xp" onClick="newFolder('#xehNewFolder#','#JSStringFormat(currentRoot)#')"> &nbsp;
	<input type="button" id="selectdir_btn" value="Choose" <cfif selectedFilename eq "">disabled="true"</cfif> style="font-size: 9xp" onClick="chooseFile('#session.callbackItem#')">
	</div>
	
</div>
</form>
</div>
</cfoutput>