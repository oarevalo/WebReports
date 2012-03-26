<cfparam name="request.requestState.groupID" default="">
<cfparam name="request.requestState.qryGroup">

<cfset groupID = request.requestState.groupID>
<cfset qryGroup = request.requestState.qryGroup>

<cfoutput>
<a href="?event=ehGroups.dspMain">Go Back</a>

<h2 class="pageTitle"><img src="images/group.png" border="0" align="absmiddle"> Add/Edit User Group</h2>

<form name="frm" action="index.cfm" method="post">
	<input type="hidden" name="event" value="ehGroups.doSave">
	<input type="hidden" name="groupID" value="#groupID#">
	
<table>
	<tr>
		<td><strong>Group Name:</strong></td>
		<td><input type="text" name="groupName" value="#qryGroup.groupName#" size="50" class="formField"></td>
	</tr>
	<tr valign="top">
		<td>Description:</td>
		<td><textarea name="description" rows="5" cols="50" class="formField">#qryGroup.description#</textarea></td>
	</tr>
</table>
<br>
<input type="submit" name="btn" value="Apply Changes">
<span style="font-size:11px;margin-left:20px;">* Fields in <b>BOLD</b> are required.</span>
</form>
</cfoutput>
