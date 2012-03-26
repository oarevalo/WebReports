<cfparam name="request.requestState.oReport" default="0">

<cfscript>
	oReport = request.requestState.oReport;
	
	authenticationDelegate = oReport.getReportProperty("authenticationDelegate");
	displayGroupContents = oReport.getReportProperty("displayGroupContents");
	functionParameters = oReport.getReportProperty("functionParameters");
	doNotShowDuplicateRows = oReport.getReportProperty("doNotShowDuplicateRows");
	
	displayGroupContents = isBoolean(displayGroupContents) and displayGroupContents;
	doNotShowDuplicateRows = isBoolean(doNotShowDuplicateRows) and doNotShowDuplicateRows;
</cfscript>

<cfoutput>
	<div id="DialogPanelTitle">
		<a href="##" 
			onclick="closeDialogPanel()" 
			style="float:right;color:##fff;margin-right:10px;margin-top:3px;"><img 
			src="/WebReports/common/images/iclose.gif" 
			alt="Close Dialog" title="Close Dialog"
			border="0"></a>
		&nbsp;Report Settings
	</div>
	
	<form name="frmColumnProperties" id="frmColumnProperties" action="index.cfm" method="post" 
			style="height:auto;"
			onsubmit="doFormEvent('ehGeneral.doSaveSettings','DialogPanelContainer',this);return false;">
		<table style="margin:5px;width:380px;">
			<tr>
				<td align="right"><b>Display Group Contents?</b></td>
				<td>
					&nbsp;&nbsp;
					<input type="radio" name="displayGroupContents" value="true" <cfif displayGroupContents>checked</cfif>> Yes &nbsp;&nbsp;
					<input type="radio" name="displayGroupContents" value="false" <cfif not displayGroupContents>checked</cfif>> No
				</td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<td align="right"><b>Do Not Show Duplicate Rows:</b></td>
				<td>
					&nbsp;&nbsp;
					<input type="radio" name="doNotShowDuplicateRows" value="true" <cfif doNotShowDuplicateRows>checked</cfif>> Yes &nbsp;&nbsp;
					<input type="radio" name="doNotShowDuplicateRows" value="false" <cfif not doNotShowDuplicateRows>checked</cfif>> No
				</td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr>
				<td colspan="2" style="font-weight:bold;color:##999;">
					Custom Integration:
				</td>
			</tr>
			<tr>
				<td align="right"><b>Authentication Delegate:</b></td>
				<td>&nbsp;&nbsp;<input type="text" name="authenticationDelegate" value="#authenticationDelegate#"></td>
			</tr>
			<tr>
				<td colspan="2" align="right" style="padding-top:30px;">
					<input type="image" src="images/apply-small.gif" alt="Apply">
				</td>
			</tr>
		</table>
	</form>	
</cfoutput>