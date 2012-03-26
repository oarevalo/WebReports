<cfparam name="request.requestState.qryData" default="">

<cfset qryData = request.requestState.qryData>
<cfset qryUser = session.qryUser>
<cfset hasReportDesigner = request.requestState.hasReportDesigner>

<h2 class="pageTitle"><img src="images/report.png" border="0" align="absmiddle"> Report Library</h2>
										
<table width="100%" cellpadding="0" cellspacing="0">
	<tr valign="top">
		<td>
			<div style="margin-top:10px;border:1px solid #ccc;height:400px;overflow:auto;">	
				<table class="browseTable" style="width:100%">	
					<tr>
						<th width="10">No.</th>
						<th>Name</th>
						<th>HREF</th>
						<th width="70">Public?</th>
						<th width="70">Action</th>
					</tr>
					<cfoutput query="qryData">
						<tr <cfif qryData.currentRow mod 2>class="altRow"</cfif>>
							<td><strong>#qryData.currentRow#.</strong></td>
							<td><a href="?event=ehReportLibrary.dspEdit&reportID=#reportID#">#reportName#</a></td>
							<td>#reportHREF#</td>
							<td align="center" width="70">
								<cfif isBoolean(isPublic) and isPublic>
									<img src="../common/images/active_icon.gif" alt="Yes">
								<cfelse>
									<img src="../common/images/inactive_icon.gif" alt="No">								
								</cfif>
							</td>
							<td align="center">
								<a href="?event=ehReportLibrary.dspEdit&reportID=#reportID#"><img src="images/page_edit.png" align="absmiddle" border="0" alt="Edit Report" title="Edit Report"></a> &nbsp;
								<a href="?event=ehReportLibrary.doDelete&reportID=#reportID#"
									onclick="return (confirm('Delete report?'))"><img src="images/page_delete.png" align="absmiddle" border="0" alt="Delete Report" title="Delete Report"></a> &nbsp;
								<cfif isBoolean(isPublic) and not isPublic>
									<a href="?event=ehReportLibrary.dspAccess&reportID=#reportID#"><img src="images/page_lightning.png" align="absmiddle" border="0" alt="Report Access" title="Report Access"></a>
								</cfif>
							</td>
						</tr>
					</cfoutput>
					<cfif qryData.recordCount eq 0>
						<tr><td colspan="5"><em>There are no reports in the library.</em></td></tr>
					</cfif>
				</table>
			</div>	

			<p>
				<cfif hasReportDesigner and (qryUser.isDeveloper eq 1 or qryUser.isAdmin eq 1)>
					<input type="button" 
							name="btnCreate" 
							value="Create Report" 
							onClick="document.location='../designer/?ExitURL=/WebReports/portal/'">
					&nbsp;&nbsp;&nbsp;&nbsp;
				</cfif>
				<input type="button" 
						name="btnSync" 
						value="Sync Reports" 
						onClick="document.location='?event=ehReportLibrary.doSyncRepo'">
				&nbsp;&nbsp;&nbsp;&nbsp;

				<b>Legend:</b> &nbsp;&nbsp;
				<img src="images/page_edit.png" align="absmiddle" border="0" alt="Edit Report" title="Edit Report"> Edit Report Info &nbsp;&nbsp;
				<img src="images/page_delete.png" align="absmiddle" border="0" alt="Delete Report" title="Delete Report"> Delete Report &nbsp;&nbsp;
				<img src="images/page_lightning.png" align="absmiddle" border="0" alt="Report Access" title="Report Access"> Report Access
			</p>
		</td>
		
		<td width="200">
			<div class="cp_sectionBox helpBox"  style="margin:10px;margin-right:0px;margin-bottom:0px;height:400px;line-height:18px;">
				<div style="margin:10px;">
					<h2>Report Library</h2>
					<p>
						This screen allows you to manage all reports in the library. 
						From here you can add, delete and edit report information.
					</p>
				</div>
			</div>
		</td>
	</tr>
</table>


