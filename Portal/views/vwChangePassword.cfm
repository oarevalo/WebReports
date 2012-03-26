<cfparam name="request.requestState.userID" default="">
<cfparam name="request.requestState.qryUser" default="">

<cfset userID = request.requestState.userID>
<cfset qryUser = request.requestState.qryUser>

<cfoutput>
<h2 class="pageTitle"><img src="images/group.png" border="0" align="absmiddle"> Change Password</h2>

<form name="frm" action="index.cfm" method="post">
	<input type="hidden" name="event" value="ehUsers.doChangePassword">
	
<table>
	<tr>
		<td><strong>Username:</strong></td>
		<td><strong>#qryUser.username#</strong></td>
	</tr>
	<tr>
		<td><strong>Current Password:</strong></td>
		<td><input type="password" name="oldPassword" value="" size="50" class="formField"></td>
	</tr>
	<tr>
		<td><strong>New Password:</strong></td>
		<td><input type="password" name="newPassword" value="" size="50" class="formField"></td>
	</tr>
	<tr>
		<td><strong>Confirm Password:</strong></td>
		<td><input type="password" name="newPassword2" value="" size="50" class="formField"></td>
	</tr>
</table>
<br>
<input type="submit" name="btn" value="Apply Changes">
<span style="font-size:11px;margin-left:20px;">* Fields in <b>BOLD</b> are required.</span>
</form>
</cfoutput>
