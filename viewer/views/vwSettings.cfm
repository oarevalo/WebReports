<cfparam name="request.requestState.oReport" default="">
<cfscript>
	oReport = request.requestState.oReport;
	title = oReport.getTitle();
	subtitle = oReport.getSubtitle();
	totalLabel = oReport.getTotalLabel();
	pageOrientation = oReport.getPageOrientation();
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

	<form name="frmSettings" method="post" action="##" 
			onsubmit="doFormEvent('ehReport.doSaveSettings','DialogPanelContainer',this);return false;">
		<table width="100%" align="center">
			<tr><th colspan="2">General:</th></tr>
			<tr>
				<td align="right"><strong>Title:</strong></td>
				<td><input type="text" name="title" value="#title#" style="padding:1px;width:350px;"></td>
			</tr>
			<tr>
				<td align="right"><strong>Subtitle:</strong></td>
				<td><input type="text" name="subtitle" value="#subtitle#" style="padding:1px;width:350px;"></td>
			</tr>
			<tr><td colspan="2">&nbsp;</td></tr>
			<tr><th colspan="2">Totals:</th></tr>
			<tr>
				<td align="right"><strong>Totals:</strong></td>
				<td><input type="text" name="totalLabel" value="#totalLabel#" style="padding:1px;width:350px;"></td>
			</tr>
			<tr>
				<td>&nbsp;</td>
				<td>
					<div style="font-size:10px;text-align:left;margin-top:5px;">
						Label to display on the first column when computing sums, averages or counts. This label will
						only be displayed if the column being totalled is not the first one.
						<div style="margin-top:10px;">
							You may use the following tokens:<br>
							<strong>%G </strong>: group name
						</div>
					</div>
				</td>
			</tr>
		</table>
				
		<p align="center">
			<input type="image" name="btnSubmit" value="Apply Changes" 
					style="border:0px;" align="absmiddle"
					src="images/apply-small.gif">
		</p>
	</form>
</cfoutput>
