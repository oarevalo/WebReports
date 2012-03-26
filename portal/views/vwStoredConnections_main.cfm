<cfparam name="request.requestState.qryData" default="">
<cfparam name="request.requestState.startRow" default="1">

<cfset qryData = request.requestState.qryData>
<cfset startRow = request.requestState.startRow>
<cfset rowsPerPage = 20>

<h2 class="pageTitle"><img src="images/database.png" border="0" align="absmiddle"> Stored Connections</h2>
										
<table width="100%" cellpadding="0" cellspacing="0">
	<tr valign="top">
		<td>
			<div style="margin-top:10px;border:1px solid #ccc;height:400px;overflow:auto;">	
				<table class="browseTable" style="width:100%">	
					<tr>
						<th width="10">No.</th>
						<th>Name</th>
						<th>Datasouce</th>
						<th>Username</th>
						<th width="70">Action</th>
					</tr>
					<cfoutput query="qryData" startrow="#startRow#" maxrows="#rowsPerPage#">
						<tr <cfif qryData.currentRow mod 2>class="altRow"</cfif>>
							<td><strong>#qryData.currentRow#.</strong></td>
							<td><a href="?event=ehStoredConnections.dspEdit&storedConnectionID=#storedConnectionID#">#connectionName#</a></td>
							<td>#Datasource#</td>
							<td>#Username#</td>
							<td align="center">
								<a href="?event=ehStoredConnections.dspEdit&storedConnectionID=#storedConnectionID#"><img src="images/database_edit.png" align="absmiddle" border="0" alt="Edit Connection" title="Edit Connection"></a> &nbsp;
								<a href="?event=ehStoredConnections.doDelete&storedConnectionID=#storedConnectionID#"
									onclick="return (confirm('Delete connection?'))"><img src="images/database_delete.png" align="absmiddle" border="0" alt="Delete Connection" title="Delete Connection"></a>
							</td>
						</tr>
					</cfoutput>
					<cfif qryData.recordCount eq 0>
						<tr><td colspan="5"><em>There are no stored connections.</em></td></tr>
					</cfif>
				</table>
			</div>	

			<p>
				<input type="button" 
						name="btnCreate" 
						value="Create New Connection" 
						onClick="document.location='?event=ehStoredConnections.dspEdit'">
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

				<b>Legend:</b> &nbsp;&nbsp;
				<img src="images/database_edit.png" align="absmiddle" border="0" alt="Edit Connection" title="Edit Connection"> Edit Connection Info &nbsp;&nbsp;
				<img src="images/database_delete.png" align="absmiddle" border="0" alt="Delete Connection" title="Delete Connection"> Delete Connection&nbsp;&nbsp;
			</p>
		</td>
		
		<td width="200">
			<div class="cp_sectionBox helpBox"  style="margin:10px;margin-right:0px;margin-bottom:0px;height:400px;line-height:18px;">
				<div style="margin:10px;">
					<h2>Stored Connections</h2>
					<p>
						This screen allows you to manage all Stored Connections. 
						From here you can add, delete and edit information about saved
						connections to the database. <br /><br />
						These connections are used to give
						a name to a particular datsource/username/password combination
						so that it is easier to use/reuse across reports.
					</p>
				</div>
			</div>
		</td>
	</tr>
</table>


