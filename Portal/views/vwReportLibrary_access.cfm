<cfparam name="request.requestState.reportID" default="">
<cfparam name="request.requestState.qryReport" default="">
<cfparam name="request.requestState.qryReportUsers" default="">
<cfparam name="request.requestState.qryReportGroups" default="">
<cfparam name="request.requestState.qryGroups" default="">
<cfparam name="request.requestState.qryUsers" default="">

<cfset reportID = request.requestState.reportID>
<cfset qryReport = request.requestState.qryReport>
<cfset qryReportUsers = request.requestState.qryReportUsers>
<cfset qryReportGroups = request.requestState.qryReportGroups>
<cfset qryGroups = request.requestState.qryGroups>
<cfset qryUsers = request.requestState.qryUsers>
<cfset lstReportGroups = ValueList(qryReportGroups.groupID)>
<cfset lstReportUsers = ValueList(qryReportUsers.userID)>

<cfoutput>
<a href="?event=ehReportLibrary.dspMain">Go Back</a>

<h2 class="pageTitle"><img src="images/report.png" border="0" align="absmiddle"> Set Report Access</h2>

<form name="frm" action="index.cfm" method="post">
	<input type="hidden" name="event" value="ehReportLibrary.doSaveAccess">
	<input type="hidden" name="reportID" value="#reportID#">
	

<strong>Report:</strong> <a href="index.cfm?event=ehReportLibrary.dspEdit&reportID=#reportID#">#qryReport.reportName#</a>
<br><br>
Select from the lists below the users and/or groups which will be granted access to this report.
<br><br>

<table class="browseTable" style="margin-top:10px;border:1px solid ##ccc;width:440px;">
	<tr valign="top">
		<th>Groups:</th>
		<td style="width:20px;border-top:0;border-bottom:0;">&nbsp;</td>
		<th>Users:</th>
	</tr>
	<tr valign="top">
		<td align="center" style="border:1px solid ##ccc;">
			<cfif qryGroups.recordCount gt 0>
				<select name="lstReportGroups" size="10" multiple="true" style="width:200px;">
					<cfloop query="qryGroups">
						<option value="#qryGroups.groupID#" <cfif listFind(lstReportGroups,qryGroups.groupID)>selected</cfif>>#qryGroups.groupName#</option>
					</cfloop>
				</select>
			<cfelse>
				<em>There are no groups defined. <br /><br />
				<a href="?event=ehGroups.dspMain">Click Here to create user groups.</a></em>
			</cfif>
		</td>
		<td style="width:20px;border-top:0;border-bottom:0;">&nbsp;</td>
		<td align="center" style="border:1px solid ##ccc;">
			<cfif qryUsers.recordCount gt 0>
				<select name="lstReportUsers" size="10" multiple="true" style="width:200px;">
					<cfloop query="qryUsers">
						<option value="#qryUsers.userID#" 
								<cfif listFind(lstReportUsers,qryUsers.userID)>selected</cfif>
								><cfif qryUsers.lastName neq "">#qryUsers.lastName#,</cfif> #qryUsers.firstName# (#qryUsers.username#)</option>
					</cfloop>
				</select>
			<cfelse>
				<em>There no users defined. <br /><br />
				<a href="?event=ehUsers.dspMain">Click Here to create user users.</a></em>
			</cfif>
		</td>
	</tr>
</table>
<br>
<input type="submit" name="btn" value="Apply Changes">
</form>	

</cfoutput>