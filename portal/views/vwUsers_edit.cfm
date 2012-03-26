<cfparam name="request.requestState.userID" default="">
<cfparam name="request.requestState.qryUser" default="">
<cfparam name="request.requestState.qryGroups" default="">
<cfparam name="request.requestState.qryUserGroups" default="">

<cfset userID = request.requestState.userID>
<cfset qryUser = request.requestState.qryUser>
<cfset qryGroups = request.requestState.qryGroups>
<cfset qryUserGroups = request.requestState.qryUserGroups>
<cfset lstUserGroups = ValueList(qryUserGroups.groupID)>


<cfoutput>
<a href="?event=ehUsers.dspMain">Go Back</a>

<h2 class="pageTitle"><img src="images/group.png" border="0" align="absmiddle"> Add/Edit User</h2>

<form name="frm" action="index.cfm" method="post">
	<input type="hidden" name="event" value="ehUsers.doSave">
	<input type="hidden" name="userID" value="#userID#">
	
<table>
	<cfif userID eq "" or userID eq 0>
		<tr>
			<td><strong>Username:</strong></td>
			<td><input type="text" name="username" value="" size="50" class="formField"></td>
		</tr>
		<tr>
			<td><strong>Password:</strong></td>
			<td><input type="password" name="password" value="" size="50" class="formField"></td>
		</tr>
		<tr>
			<td><strong>Confirm Password:</strong></td>
			<td><input type="password" name="password2" value="" size="50" class="formField"></td>
		</tr>
	<cfelse>
		<tr>
			<td>Username:</td>
			<td><strong>#qryUser.username#</strong></td>
		</tr>
	</cfif>
	<tr>
		<td>First Name:</td>
		<td><input type="text" name="firstname" value="#qryUser.firstName#" size="50" class="formField"></td>
	</tr>
	<tr>
		<td>Middle Name:</td>
		<td><input type="text" name="middlename" value="#qryUser.middlename#" size="50" class="formField"></td>
	</tr>
	<tr>
		<td>Last Name:</td>
		<td><input type="text" name="lastname" value="#qryUser.lastname#" size="50" class="formField"></td>
	</tr>
	<cfif userID gt 0>
		<tr>
			<td><strong>Password:</strong></td>
			<td><input type="text" name="password" value="#qryUser.password#" size="50" class="formField"></td>
		</tr>
	</cfif>
	<tr><td colspan="2">&nbsp;</td></tr>
	<tr>
		<td colspan="2">
			<input type="checkbox" name="isadmin" value="1" <Cfif qryUser.isAdmin eq 1>checked</Cfif>> Administrator Access
		</td>
	</tr>
	<tr>
		<td colspan="2">
			<input type="checkbox" name="isdeveloper" value="1" <Cfif qryUser.isDeveloper eq 1>checked</Cfif>> Access to Report Designer
		</td>
	</tr>
	<cfif not(userID eq "" or userID eq 0)>
		<tr><td colspan="2">&nbsp;</td></tr>
		<tr valign="top">
			<td>Groups:</td>
			<td>
				<cfif qryGroups.recordCount gt 0>
					<select name="lstGroups" size="10" multiple="true" style="width:200px;" class="formField">
						<cfloop query="qryGroups">
							<option value="#qryGroups.groupID#" <cfif listFind(lstUserGroups,qryGroups.groupID)>selected</cfif>>#qryGroups.groupName#</option>
						</cfloop>
					</select>
				<cfelse>
					<em><a href="?event=ehGroups.dspMain">Click Here to create user groups.</a></em>
				</cfif>
			</td>
		</tr>
	</cfif>
</table>
<br>
<input type="submit" name="btn" value="Apply Changes">
<span style="font-size:11px;margin-left:20px;">* Fields in <b>BOLD</b> are required.</span>
</form>
</cfoutput>
