<cfparam name="request.requestState.reportID" default="">
<cfparam name="request.requestState.qryData" default="">
<cfparam name="request.requestState.lstDatasources" default="">

<cfset reportID = request.requestState.reportID>
<cfset qryData = request.requestState.qryData>
<cfset qryStoredConnections = request.requestState.qryStoredConnections>
<cfset lstDatasources = request.requestState.lstDatasources>
<cfset qryUser = session.qryUser>
<cfset hasReportDesigner = request.requestState.hasReportDesigner>

<cfoutput>
<script type="text/javascript">
	function setPromptUserField(fld,ischecked) {
		fld = document.frm[fld];
		fld.disabled = ischecked;
	}
	function setStoredConnField(name) {
		if(name != "") {
			document.frm.Datasource.disabled = true;
			document.frm.Username.disabled = true;
			document.frm.Password.disabled = true;
			document.frm.Datasource_p.checked = false;
			document.frm.Username_p.checked = false;
			document.frm.Password_p.checked = false;
		} else {
			document.frm.Datasource.disabled = false;
			document.frm.Username.disabled = false;
			document.frm.Password.disabled = false;
		}
	}
</script>	
	
<a href="?event=ehReportLibrary.dspMain">Go Back</a>

<h2 class="pageTitle"><img src="images/report.png" border="0" align="absmiddle"> Report Details</h2>

<form name="frm" action="index.cfm" method="post">
	<input type="hidden" name="event" value="ehReportLibrary.doSave">
	<input type="hidden" name="reportID" value="#reportID#">
	<input type="hidden" name="dbtype" value="#qryData.dbtype#">
	
	<cfif val(reportID) neq 0>
		<input type="hidden" name="reportHREF" value="#qryData.reportHREF#">
	</cfif>
	
	<table cellpadding="3">
	<cfif val(reportID) neq 0>
	<tr>
		<td colspan="2">
			<div style="background-color:##ffffcc;border:1px solid black;padding:5px;">
				<img src="images/bullet_go.png" align="absmiddle">
				<b>Quick Link:</b>&nbsp;
				<cfset tempURL = "http://#cgi.server_name#/WebReports/viewer/?reportID=#reportID#">
				<a href="#tempURL#">#tempURL#</a>
			</div>
		</td>
	</tr>
	</cfif>
	
	<tr>
		<td><strong>Report Name:</strong></td>
		<td><input type="text" name="reportName" value="#qryData.reportName#" size="50" class="formField"></td>
	</tr>
	<cfif val(reportID) eq 0>
		<tr>
			<td>Report HREF:</td>
			<td><input type="text" name="reportHREF" value="#qryData.reportHREF#" size="50" class="formField"></td>
		</tr>
		<tr><td colspan="2">&nbsp;</td></tr>
	</cfif>
	<tr valign="top">
		<td>Description:</td>
		<td><textarea name="description" rows="3" cols="50" class="formField">#qryData.description#</textarea></td>
	</tr>
	<tr><td colspan="2">&nbsp;</td></tr>
	<tr><td colspan="2" style="font-size:14px;font-weight:bold;"><u>Database Connection:</u></td></tr>
	<tr>
		<td><strong>Stored Connection:</strong></td>
		<td>
			<cfif qryStoredConnections.recordCount gt 0>
				<select name="storedConnectionID" style="width:200px;" class="formField"
						onchange="setStoredConnField(this.value)"
						<cfif qryData.storedConnectionID eq "?">disabled</cfif>>
					<option value=""></option>
					<cfloop query="qryStoredConnections">
						<option value="#qryStoredConnections.storedConnectionID#"
								<cfif qryStoredConnections.storedConnectionID eq qryData.storedConnectionID>selected</cfif>
							>#qryStoredConnections.connectionName#</option>
					</cfloop>
				</select>
				&nbsp;<input type="checkbox" name="storedConnectionID_p" value="1" 
							onclick="setPromptUserField('storedConnectionID',this.checked)"
							<cfif qryData.storedConnectionID eq "?">checked</cfif>> 
				<span style="font-size:11px;">Prompt User</span>
			<cfelse>
				<input type="hidden" name="storedConnectionID" value="">
				<em>No stored connections found!</em>
			</cfif>
		</td>
	</tr>
	<tr>
		<td><strong>Datasource:</strong></td>
		<td>
			<cfif lstDatasources neq "" and lstDatasources neq "*">
				<select name="Datasource" style="width:200px;" class="formField"
						<cfif qryData.Datasource eq "?">disabled</cfif>>
					<option value=""></option>
					<cfloop list="#lstDatasources#" index="ds">
						<option value="#ds#" <cfif qryData.Datasource eq ds>selected</cfif>>#ds#</option>
					</cfloop>
				</select>
			<cfelse>
				<input type="text" name="Datasource" value="#qryData.Datasource#" style="width:195px;" class="formField"
						<cfif qryData.Datasource eq "?">disabled</cfif>>
			</cfif>					
			
			&nbsp;<input type="checkbox" name="Datasource_p" value="1"  
							onclick="setPromptUserField('Datasource',this.checked)"
							<cfif qryData.Datasource eq "?">checked</cfif>> 
			<span style="font-size:11px;">Prompt User</span>
		</td>
	</tr>
	<tr>
		<td>Username:</td>
		<td>
			<input type="text" name="Username" value="#qryData.Username#" style="width:195px;" class="formField"
					<cfif qryData.Username eq "?">disabled</cfif>>
			&nbsp;<input type="checkbox" name="Username_p" value="1" 
						onclick="setPromptUserField('Username',this.checked)"
						<cfif qryData.Username eq "?">checked</cfif>> 
			<span style="font-size:11px;">Prompt User</span>
		</td>
	</tr>
	<tr>
		<td>Password:</td>
		<td>
			<input type="text" name="Password" value="#qryData.Password#" style="width:195px;" class="formField"
					<cfif qryData.Password eq "?">disabled</cfif>>
			&nbsp;<input type="checkbox" name="Password_p" value="1" 
						onclick="setPromptUserField('Password',this.checked)"
						<cfif qryData.Password eq "?">checked</cfif>> 
			<span style="font-size:11px;">Prompt User</span>
		</td>
	</tr>
	<tr><td colspan="2">&nbsp;</td></tr>
	<tr><td colspan="2" style="font-size:14px;font-weight:bold;"><u>Report Visibility:</u></td></tr>
	<tr>
		<td colspan="2">
				<input type="radio" name="isPublic" value="1" <cfif isBoolean(qryData.isPublic) and qryData.isPublic>checked</cfif>>
				Report is visible to everyone (public)<br /><br />
				<input type="radio" name="isPublic" value="0" <cfif not isBoolean(qryData.isPublic) or not qryData.isPublic>checked</cfif>>
				Report is only visible to restricted users.
				<a href="?event=ehReportLibrary.dspAccess&reportID=#reportID#">Click Here to view/edit report access</a>
		</td>
	</tr>
	<tr><td colspan="2">&nbsp;</td></tr>	
</table>

<input type="submit" name="btn" value="Apply Changes">&nbsp;&nbsp;

<cfif val(reportID) gt 0>
	<cfif hasReportDesigner and (qryUser.isDeveloper eq 1 or qryUser.isAdmin eq 1)>
		<input type="button" 
				name="btnEdit" 
				value="Open in Report Designer" 
				onClick="document.location='../designer/index.cfm?event=ehGeneral.doOpenReport&exitURL=/WebReports/portal/&reportID=#reportID#'">
		&nbsp;&nbsp;
	</cfif>
</cfif>

</form>
</cfoutput>

