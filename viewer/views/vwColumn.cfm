<cfparam name="request.requestState.oReport" default="">
<cfparam name="request.requestState.fieldName" default="">
<cfparam name="request.requestState.fieldTitle" default="">
<cfparam name="request.requestState.stColumn" default="">
<cfparam name="request.requestState.qryAlignTypes" default="">
<cfparam name="request.requestState.qryDataTypeTypes" default="">
<cfparam name="request.requestState.qryAggregateTypes" default="">

<cfscript>
	oReport = request.requestState.oReport;
	fieldName = request.requestState.fieldName;
	fieldTitle = request.requestState.fieldTitle;
	stColumn = request.requestState.stColumn;
	qryAlignTypes = request.requestState.qryAlignTypes;
	qryDataTypeTypes = request.requestState.qryDataTypeTypes;
	qryAggregateTypes = request.requestState.qryAggregateTypes;
</cfscript>

<cfoutput>
	<div id="DialogPanelTitle">
		<a href="##" 
			onclick="closeDialogPanel()" 
			style="float:right;color:##fff;margin-right:10px;margin-top:3px;"><img 
			src="/WebReports/common/images/iclose.gif" 
			alt="Close Dialog" title="Close Dialog"
			border="0"></a>
		&nbsp;Edit Column Properties (#stColumn.SQLExpr#)
	</div>

	<form name="frmSelColumns" id="frmSelColumns" method="post" action="##" onsubmit="doFormEvent('ehColumns.doSave','DialogPanelContainer',this);return false">
	
	<div style="height:230px;">
	<table style="margin:5px;" cellpadding="0" cellspacing="0">
		<tr valign="top">
			<td>
				<input type="hidden" name="fieldName" value="#stColumn.SQLExpr#">			
				<table>
					<tr><th colspan="2">General:</th></tr>
					<tr>
						<td align="right"><strong>Label:</strong></td>
						<td><input type="text" name="header" value="#stColumn.header#" style="width:150px;"></td>
					</tr>
					<tr>
						<td align="right"><strong>Align:</strong></td>
						<td>
							<select name="align" style="width:150px;">
								<cfloop query="qryAlignTypes">
									<option value="#qryAlignTypes.value#"
											<cfif qryAlignTypes.value eq stColumn.align>selected</cfif>>#qryAlignTypes.label#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right"><strong>Data Type:</strong></td>
						<td>
							<select name="dataType" style="width:150px;">
								<cfloop query="qryDataTypeTypes">
									<option value="#qryDataTypeTypes.value#"
											<cfif qryDataTypeTypes.value eq stColumn.dataType>selected</cfif>>#qryDataTypeTypes.label#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right"><strong>Format:</strong></td>
						<td><input type="text" name="numberFormat" value="#stColumn.numberFormat#" style="width:150px;"></td>
					</tr>
					<tr>
						<td align="right"><strong>Width (%):</strong></td>
						<td>
							<select name="width">
								<option value="" <cfif val(stColumn.width) eq 0>selected</cfif>>- Auto -</option>
								<cfloop from="1" to="100" index="i">
									<option value="#i#" <cfif val(stColumn.width) eq i>selected</cfif>>#i#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</table>
				<br>
				<div style="border:1px solid silver;background-color:##ebebeb;padding:10px;line-height:20px;">
					<img src="images/bullet_go.png" align="absmiddle"><a href="index.cfm?event=ehColumns.doQuickSort&fieldName=#stColumn.SQLExpr#">Quick <strong>sort</strong> by this column</a><br />
					<img src="images/bullet_go.png" align="absmiddle"><a href="index.cfm?event=ehColumns.doQuickGroup&fieldName=#stColumn.SQLExpr#">Quick <strong>group</strong> by this column</a>
				</div>
			</td>
			<td style="width:30px;">&nbsp;</td>
			<td>
				<table>
					<tr><th colspan="2">Groups:</th></tr>
					<tr>
						<td align="right"><strong>Format:</strong></td>
						<td><input type="text" name="GroupDataMask" value="#stColumn.GroupDataMask#"></td>
					</tr>
					<tr>
						<td align="right"><strong>Data Type:</strong></td>
						<td>
							<select name="GroupDataType">
								<cfloop query="qryDataTypeTypes">
									<option value="#qryDataTypeTypes.value#"
											<cfif qryDataTypeTypes.value eq stColumn.GroupDataType>selected</cfif>>#qryDataTypeTypes.label#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr><td colspan="2">&nbsp;</td></tr>
					<tr><th colspan="2">Calculate Totals:</th></tr>
					<tr>
						<td align="right"><strong>Function:</strong></td>
						<td>
							<select name="total">
								<option value=""></option>
								<cfloop query="qryAggregateTypes">
									<option value="#qryAggregateTypes.value#"
											<cfif qryAggregateTypes.value eq stColumn.total>selected</cfif>>#qryAggregateTypes.label#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right"><strong>Format:</strong></td>
						<td><input type="text" name="TotalNumberFormat" value="#stColumn.TotalNumberFormat#"></td>
					</tr>
					<tr>
						<td align="right"><strong>Align:</strong></td>
						<td>
							<select name="totalAlign">
								<cfloop query="qryAlignTypes">
									<option value="#qryAlignTypes.value#"
											<cfif qryAlignTypes.value eq stColumn.totalAlign>selected</cfif>>#qryAlignTypes.label#</option>
								</cfloop>
							</select>
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	</div>
	<p align="right" style="padding-right:10px;">
		<a href="##" onclick="doEvent('ehColumns.dspMain','DialogPanelContainer');"><img src="images/cancel-small.gif" border="0" alt="Cancel"></a>
		&nbsp;
		<input type="image" src="images/apply-small.gif" alt="Apply" style="border:0px;">
	</p>
	</form>
</cfoutput>
