<cfparam name="request.requestState.storedConnectionID" default="">
<cfparam name="request.requestState.qryData" default="">
<cfparam name="request.requestState.lstDatasources" default="">

<cfset storedConnectionID = request.requestState.storedConnectionID>
<cfset qryData = request.requestState.qryData>
<cfset lstDatasources = request.requestState.lstDatasources>

<cfoutput>
<script type="text/javascript">
	function setDefaultConnName(name) {
		fld = document.frm.connectionName;
		fld.value = name;
		//if(fld.value=="") fld.value = name;
	}
</script>

<a href="?event=ehStoredConnections.dspMain">Go Back</a>

<h2 class="pageTitle"><img src="images/database.png" border="0" align="absmiddle"> Add/Edit Stored Connections</h2>

<form name="frm" action="index.cfm" method="post">
	<input type="hidden" name="event" value="ehStoredConnections.doSave">
	<input type="hidden" name="storedConnectionID" value="#storedConnectionID#">
	
<table>
	<tr>
		<td><strong>Datasource:</strong></td>
		<td>
			<cfif lstDatasources neq "" and lstDatasources neq "*">
				<select name="Datasource" onchange="setDefaultConnName(this.value)" class="formField" style="width:200px;">
					<option value=""></option>
					<cfloop list="#lstDatasources#" index="ds">
						<option value="#ds#" <cfif qryData.Datasource eq ds>selected</cfif>>#ds#</option>
					</cfloop>
				</select>
			<cfelse>
				<input type="text" name="Datasource" value="#qryData.Datasource#" onblur="setDefaultConnName(this.value)" size="50" class="formField">
			</cfif>								
		</td>
	</tr>
	<tr>
		<td><strong>Connection Name:</strong></td>
		<td><input type="text" name="connectionName" value="#qryData.connectionName#" size="50" class="formField"></td>
	</tr>
	<tr><td colspan="2">&nbsp;</td></tr>
	<tr>
		<td>Username:</td>
		<td><input type="text" name="Username" value="#qryData.Username#" size="50" class="formField"></td>
	</tr>
	<tr>
		<td>Password:</td>
		<td><input type="text" name="Password" value="#qryData.Password#" size="50" class="formField"></td>
	</tr>
	<tr valign="top">
		<td>Description:</td>
		<td><textarea name="description" rows="5" cols="50" class="formField">#qryData.description#</textarea></td>
	</tr>
</table>
<br>
<input type="submit" name="btn" value="Apply Changes">
<span style="font-size:11px;margin-left:20px;">* Fields in <b>BOLD</b> are required.</span>
</form>
</cfoutput>
