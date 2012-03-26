<cfparam name="request.requestState.useManagedReports" default="false">
<cfparam name="request.requestState.hasReportDesigner" default="false">

<cfset useManagedReports = request.requestState.useManagedReports>
<cfset hasReportDesigner = request.requestState.hasReportDesigner>
<cfset userID = session.userID>
<cfset qryUser = session.qryUser>


<cfoutput>
	<table cellpadding="0" cellspacing="1" width="100%" id="ViewerMenuBar">
		<tr>
			<td align="left" id="menuButtons" style="height:30px;">
				<li><a href="index.cfm"><img src="/WebReports/common/images/home-icon5.gif" border="0" align="absmiddle" style="margin:0px;padding:0px;##margin-top:6px;"> Home</a></li>

				<cfif val(userID) gt 0>
					<cfif qryUser.isAdmin eq 1>
						<li><a href="?event=ehUsers.dspMain"><img src="images/group.png" border="0" align="absmiddle" style="margin:0px;padding:0px;##margin-top:5px;"> Users</a></li>
						<li><a href="?event=ehReportLibrary.dspMain"><img src="images/report.png" border="0" align="absmiddle" style="margin:0px;padding:0px;##margin-top:5px;"> Reports</a></li>
						<li><a href="?event=ehStoredConnections.dspMain"><img src="images/database.png" border="0" align="absmiddle" style="margin:0px;padding:0px;##margin-top:5px;"> Connections</a></li>
						<!---<li><a href="?event=ehSettings.dspMain"><b>General Settings</b></a></li>--->
					<cfelse>
						<li><a href="?event=ehUsers.dspChangePassword"><img src="images/group.png" border="0" align="absmiddle" style="margin:0px;padding:0px;##margin-top:5px;"> Change Password</a></li>
					</cfif>
				</cfif>

				<!--- <li><a href="?event=ehGeneral.dspAbout">Help</a></li> --->

				&nbsp;
			</td>
			
			<cfif useManagedReports>
				<td align="right" id="menuButtons">
					<cfif val(userID) gt 0>
						<li><a href="?event=ehGeneral.doLogout">Log Off</a></li>
					<cfelse>
						<li><a href="?event=ehGeneral.dspLogin">Login</a></li>
					</cfif>
				</td>
			</cfif>	
		</tr>
	</table>	
</cfoutput>
	
		