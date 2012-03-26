<cfparam name="request.requestState.oDataSourceBean" default="">
<cfparam name="request.requestState.qryTypes" default="">
<cfparam name="request.requestState.lstDatasources" default="">

<cfscript>
oDatasourceBean = request.requestState.oDataSourceBean;
qryTypes = request.requestState.qryTypes;
lstDatasources = request.requestState.lstDatasources;

pwd = oDatasourceBean.getPassword();
usr = oDatasourceBean.getUsername();
dsn = oDatasourceBean.getName();
</cfscript>

<cfoutput>
	<div id="DialogPanelTitle">
		<a href="##" 
			onclick="closeDialogPanel()" 
			style="float:right;color:##fff;margin-right:10px;margin-top:3px;"><img 
			src="/WebReports/common/images/iclose.gif" 
			alt="Close Dialog" title="Close Dialog"
			border="0"></a>
		&nbsp;Database Login
	</div>
		
	<form action="index.cfm" method="post" id="frmDatabase">
		<input type="hidden" name="event" value="ehGeneral.doSetDatabase">
		<table cellpadding="0" cellspacing="0" align="center" border="0" style="margin-top:5px;">
			<tr>
				<td width="90"><strong>Datasource:</strong></td>
				<td>
					<cfif lstDatasources neq "" and lstDatasources neq "*">
						<select name="name">
							<cfloop list="#lstDatasources#" index="ds">
								<option value="#ds#" <cfif ds eq dsn>selected</cfif>>#ds#</option>
							</cfloop>
						</select>
					<cfelse>
						<input type="text" name="name" value="#dsn#">
					</cfif>
				</td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<td><strong>Username:</strong></td>
				<td><input type="text" name="username" value="#usr#"></td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<td><strong>Password:</strong></td>
				<td><input type="password" name="password" value="#pwd#"></td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<td><strong>DB Type:</strong></td>
				<td>
					<select name="dbtype">
						<cfloop query="qryTypes">
							<option value="#qryTypes.type#" 
									<cfif qryTypes.type eq oDatasourceBean.getDBType()>selected</cfif>>#qryTypes.name#</option>
						</cfloop>
					</select>
				</td>
			</tr>
		</table>

		<p align="center">
			<input type="submit" value="Login" name="btnConnect">	&nbsp;&nbsp;
			<cfif dsn neq "">
				<input type="button" name="btnCancel" value="Cancel" onclick="document.location='index.cfm'">
			</cfif>
		</p>
	</form>
</cfoutput>
