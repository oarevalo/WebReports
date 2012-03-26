<cfparam name="request.requestState.qryUsers" default="">

<cfset qryUsers = request.requestState.qryUsers>

<h2 class="pageTitle"><img src="images/group.png" border="0" align="absmiddle"> User Management</h2>
										
<table width="100%" cellpadding="0" cellspacing="0">
	<tr valign="top">
		<td>
			<div style="margin-top:10px;border:1px solid #ccc;height:400px;overflow:auto;">	
				<table class="browseTable" style="width:100%">	
					<tr>
						<th width="20">No</th>
						<th width="150">Username</th>
						<th>Full Name</th>
						<th width="90">Administrator?</th>
						<th width="90">Developer?</th>
						<th width="70">Action</th>
					</tr>
					<cfoutput query="qryUsers">
						<tr <cfif qryUsers.currentRow mod 2>class="altRow"</cfif>>
							<td>#qryUsers.currentRow#</td>
							<td><a href="index.cfm?event=ehUsers.dspEdit&userID=#qryUsers.userID#">#qryUsers.username#</a></td>
							<td>#qryUsers.lastname#, #qryUsers.firstname#</td></td>
							<td align="center" width="100">
								<cfif isBoolean(isadmin) and isadmin>
									<img src="../Common/Images/active_icon.gif" alt="Yes">
								<cfelse>
									<img src="../Common/Images/inactive_icon.gif" alt="No">								
								</cfif>
							</td>
							<td align="center" width="100">
								<cfif isBoolean(isdeveloper) and isdeveloper>
									<img src="../Common/Images/active_icon.gif" alt="Yes">
								<cfelse>
									<img src="../Common/Images/inactive_icon.gif" alt="No">								
								</cfif>
							</td>
							<td align="center">
								<a href="index.cfm?event=ehUsers.dspEdit&userID=#qryUsers.userID#"><img src="images/user_edit.png" align="absmiddle" border="0" alt="Edit User" title="Edit User"></a>
								<a href="index.cfm?event=ehUsers.doDelete&userID=#qryUsers.userID#" onclick="return (confirm('Delete user?'))"><img src="images/user_delete.png" align="absmiddle" border="0" alt="Delete User" title="Delete User"></a>
							</td>
						</tr>
					</cfoutput>
					<cfif qryUsers.recordCount eq 0>
						<tr><td colspan="5"><em>No records found!</em></td></tr>
					</cfif>
				</table>
			</div>	

			<p>
				<input type="button" 
						name="btnCreate" 
						value="Create New User" 
						onClick="document.location='?event=ehUsers.dspEdit'">
				&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="button" 
						name="btnGroups" 
						value="Manage Groups" 
						onClick="document.location='?event=ehGroups.dspMain'">
				&nbsp;&nbsp;&nbsp;&nbsp;

				<b>Legend:</b> &nbsp;&nbsp;
				<img src="images/user_edit.png" align="absmiddle" border="0" alt="Edit User" title="Edit User"> Edit User Info &nbsp;&nbsp;
				<img src="images/user_delete.png" align="absmiddle" border="0" alt="Delete User" title="Delete User"> Delete User&nbsp;&nbsp;
			</p>
		</td>
		
		<td width="200">
			<div class="cp_sectionBox helpBox"  style="margin:10px;margin-right:0px;margin-bottom:0px;height:400px;line-height:18px;">
				<div style="margin:10px;">
					<h2>WebReports Users</h2>
					<p>
						This screen allows you to manage all WebReports users. 
						From here you can add, delete and edit user information.<br /><br />
						<b>Administrators</b> have unrestricted access to
						manage the report library.<br /><br />
						<b>Developers</b> are users allowed to access the Report Designer.
					</p>
				</div>
			</div>
		</td>
	</tr>
</table>
			
