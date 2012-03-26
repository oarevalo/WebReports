<cfparam name="request.requestState.fieldName" default="">
<cfparam name="request.requestState.oReport" default="0">

<cfscript>
	fieldName = request.requestState.fieldName;
	oReport = request.requestState.oReport;
	
	stColumn = oReport.getColumn(fieldName);
	
	oTypeFactory = createObject("component","WebReports.common.components.typeFactory");
	qryAlignTypes = oTypeFactory.getValues("align");
	qryDataTypeTypes = oTypeFactory.getValues("dataType");
	qryAggregateTypes = oTypeFactory.getValues("aggregate");
	
	numColumns = listLen( oReport.getColumnList() );
</cfscript>

<cfoutput>
	<div id="DialogPanelTitle">
		<a href="##" 
			onclick="closeEditColumnPanel()" 
			style="float:right;color:##fff;margin-right:10px;margin-top:3px;"><img 
			src="/WebReports/common/images/iclose.gif" 
			alt="Close Dialog" title="Close Dialog"
			border="0"></a>
		&nbsp;Edit Column Properties (#fieldName#)
	</div>
	<form name="frmColumnProperties" id="frmColumnProperties" action="index.cfm" method="post" onsubmit="doFormEvent('ehColumns.doSave','DialogPanelContainer',this);return false;">
	<table style="margin:5px;" cellpadding="0" cellspacing="0">
		<tr valign="top">
			<td>
				<input type="hidden" name="fieldName" value="#fieldName#">			
				<table>
					<tr><th colspan="2">General:</th></tr>
					<tr>
						<td align="right"><strong>Header:</strong></td>
						<td><input type="text" name="header" value="#stColumn.header#"></td>
					</tr>
					<tr valign="top">
						<td align="right"><strong>Position:</strong></td>
						<td>
							<select name="reportIndex" style="width:75px;">
								<option value="" <cfif val(stColumn.reportIndex) eq 0>selected</cfif>></option>
								<cfloop from="1" to="#numColumns#" index="i">
									<option value="#i#" <cfif val(stColumn.reportIndex) eq i>selected</cfif>>#i#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right"><strong>Align:</strong></td>
						<td>
							<select name="align">
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
							<select name="dataType">
								<cfloop query="qryDataTypeTypes">
									<option value="#qryDataTypeTypes.value#"
											<cfif qryDataTypeTypes.value eq stColumn.dataType>selected</cfif>>#qryDataTypeTypes.label#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right"><strong>Format:</strong></td>
						<td><input type="text" name="numberFormat" value="#stColumn.numberFormat#"></td>
					</tr>
					<tr>
						<td align="right"><strong>Width(%):</strong></td>
						<td>
							<select name="width" style="width:75px;">
								<option value="" <cfif val(stColumn.width) eq 0>selected</cfif>>- Auto -</option>
								<cfloop from="1" to="100" index="i">
									<option value="#i#" <cfif val(stColumn.width) eq i>selected</cfif>>#i#</option>
								</cfloop>
							</select>
						</td>
					</tr>
					<tr>
						<td align="right"><strong>HREF:</strong></td>
						<td><input type="text" name="href" value="#stColumn.href#"></td>
					</tr>
				</table>
			
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
					<tr><th colspan="2">Totals:</th></tr>
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
					<tr>
						<td colspan="2" align="right" style="padding-top:30px;">
							<input type="image" src="images/apply-small.gif" alt="Apply">
						</td>
					</tr>
				</table>
			</td>
		</tr>
	</table>
	</form>
</cfoutput>
