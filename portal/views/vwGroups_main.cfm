<cfparam name="request.requestState.qryGroups" default="">
<cfparam name="request.requestState.startRow" default="1">

<cfset qryGroups = request.requestState.qryGroups>
<cfset startRow = request.requestState.startRow>
<cfset rowsPerPage = 20>

<a href="?event=ehUsers.dspMain">Go Back</a>

<h2 class="pageTitle"><img src="images/group.png" border="0" align="absmiddle"> Groups Management</h2>
										
<table width="100%" cellpadding="0" cellspacing="0">
	<tr valign="top">
		<td>
			<div style="margin-top:10px;border:1px solid #ccc;height:400px;overflow:auto;">	
				<table class="browseTable" style="width:100%">	
					<tr>
						<th width="10">No.</th>
						<th>Group Name</th>
						<th>Description</th>
						<th width="70">Action</th>
					</tr>
					<cfoutput query="qryGroups">
						<tr <cfif qryGroups.currentRow mod 2>class="altRow"</cfif>>
							<td><strong>#qryGroups.currentRow#.</strong></td>
							<td><a href="?event=ehGroups.dspEdit&groupID=#groupID#">#groupname#</a></td>
							<td>#Description#</td>
							<td align="center">
								<a href="?event=ehGroups.dspEdit&groupID=#groupID#"><img src="images/group_edit.png" align="absmiddle" border="0" alt="Edit Group" title="Edit Group"></a> &nbsp;
								<a href="?event=ehGroups.doDelete&groupID=#groupID#"
									onclick="return (confirm('Delete group?'))"><img src="images/group_delete.png" align="absmiddle" border="0" alt="Delete Group" title="Delete Group"></a>
							</td>
						</tr>
					</cfoutput>
					<cfif qryGroups.recordCount eq 0>
						<tr><td colspan="4"><em>There are no groups.</em></td></tr>
					</cfif>
				</table>
			</div>	

			<p>
				<input type="button" 
						name="btnCreate" 
						value="Create New Group" 
						onClick="document.location='?event=ehGroups.dspEdit'">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

				<b>Legend:</b> &nbsp;&nbsp;
				<img src="images/group_edit.png" align="absmiddle" border="0" alt="Edit Group" title="Edit Group"> Edit Group Info &nbsp;&nbsp;
				<img src="images/group_delete.png" align="absmiddle" border="0" alt="Delete Group" title="Delete Group"> Delete Group&nbsp;&nbsp;
			</p>
		</td>
		
		<td width="200">
			<div class="cp_sectionBox helpBox"  style="margin:10px;margin-right:0px;margin-bottom:0px;height:400px;line-height:18px;">
				<div style="margin:10px;">
					<h2>WebReports Groups</h2>
					<p>
						This screen allows you to manage all WebReports user groups. From here you can add, delete and edit group information.
					</p>
				</div>
			</div>
		</td>
	</tr>
</table>
			

