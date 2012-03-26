<cfparam name="request.requestState.oReport" default="">
<cfparam name="request.requestState.qryAlignTypes" default="">
<cfparam name="request.requestState.qryDataTypeTypes" default="">
<cfparam name="request.requestState.qryAggregateTypes" default="">

<cfscript>
	oReport = request.requestState.oReport;
	qryAlignTypes = request.requestState.qryAlignTypes;
	qryDataTypeTypes = request.requestState.qryDataTypeTypes;
	qryAggregateTypes = request.requestState.qryAggregateTypes;
	aColumns = session.oReport.getColumns();
</cfscript>

<cfoutput>
	<div id="DialogPanelTitle">
		<a href="##" 
			onclick="closeDialogPanel()" 
			style="float:right;color:##fff;margin-right:10px;margin-top:3px;"><img 
			src="/WebReports/Common/Images/iclose.gif" 
			alt="Close Dialog" title="Close Dialog"
			border="0"></a>
		&nbsp;Report Columns
	</div>

	<form name="frmSelColumns" id="frmSelColumns" method="post" action="##" onsubmit="doFormEvent('ehColumns.doSelect','DialogPanelContainer',this);return false;">
		
		<div style="line-height:20px;font-weight:bold;">&nbsp;
			<a href="javascript:column_selectAll();">Select All</a> &nbsp;&nbsp;&nbsp;
			<a href="javascript:column_clearAll();">Clear All</a>
		</div>
	
		<!--- <cfset SortedFields = ArrayToList(StructSort(stColumns,"text","asc","Header"))> --->
		
		<div style="height:215px;overflow:auto;border-top:1px solid black;border-bottom:1px solid black;">
		<table border="0" cellpadding="2" cellspacing="0" style="width:100%;" id="selectColumnsTbl">
			<tr>
				<th>Column</th>
				<th>Index</th>
				<th>Align</th>
				<th>Total</th>
				<th>Format</th>
			</tr>
			<cfloop from="1" to="#arrayLen(aColumns)#" index="i">
				<cfset rowStyle="background-color : #iif(i mod 2,de("####ececec"),de("####FFFFFF"))#;">
				
				<cfif aColumns[i].Display is "yes">
					<cfset chkDisplay = "Checked">
				<cfelse>
					<cfset chkDisplay = "">
				</cfif>
				<input type="hidden" name="cSQLExpr_#i#" value="#aColumns[i].sqlexpr#" />
			
				<tr style="#rowStyle#">
					<td>
						<input type="checkbox" name="cDisplay_#i#" value="1" #chkDisplay# style="border:0px;">
						<a href="javascript:reportEditColumn('#jsStringFormat(aColumns[i].header)#')">#aColumns[i].header#</a>
					</td>
					<td align="center" style="width:20px;"><input type="text" name="cReportIndex_#i#" value="#aColumns[i].ReportIndex#" style="width:20px;padding:2px;" /></td>
					<td align="center" style="width:80px;">
						<select name="cAlign_#i#" style="width:80px;">
							<cfloop query="qryAlignTypes">
								<option value="#qryAlignTypes.value#"
								<cfif qryAlignTypes.value eq aColumns[i].align>selected</cfif>>#qryAlignTypes.label#</option>
							</cfloop>
						</select>
					</td>
					<td align="center" style="width:80px;">
						<select name="cTotal_#i#">
							<option value=""></option>
							<cfloop query="qryAggregateTypes">
								<option value="#qryAggregateTypes.value#"
										<cfif qryAggregateTypes.value eq aColumns[i].total>selected</cfif>>#qryAggregateTypes.label#</option>
							</cfloop>
						</select>							

						<!--- 
						<select name="cDataType_#i#" style="width:80px;">
							<cfloop query="qryDataTypeTypes">
								<option value="#qryDataTypeTypes.value#"
										<cfif qryDataTypeTypes.value eq aColumns[i].dataType>selected</cfif>>#qryDataTypeTypes.label#</option>
							</cfloop>
						</select>
						 --->
					</td>
					<td align="center" style="width:80px;"><input type="text" name="cNumberFormat_#i#" value="#aColumns[i].NumberFormat#" style="width:80px;" /></td>
				</tr>
			</cfloop>
		</table>
		</div>

		<table style="width:100%;margin-top:5px;">
			<tr valign="middle">
				<td style="font-size:9px;">Click on column name for more properties</td>	
				<td align="right">
					<input type="image" src="images/apply-small.gif" alt="Apply" style="margin-left:20px;border:0px;" align="absmiddle">
				</td>
			</tr>
		</table>
	</form>

</cfoutput>	