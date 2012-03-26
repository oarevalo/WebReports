<cfparam name="request.requestState.oReport" default="">
<cfparam name="request.requestState.aFilters" default="">
<cfparam name="request.requestState.aColumns" default="">
<cfparam name="request.requestState.qryFilters" default="">
<cfparam name="request.requestState.qryValues" default="">

<cfparam name="request.requestState.filterByColumn" default="">
<cfparam name="request.requestState.filterByCondition" default="">
<cfparam name="request.requestState.FilterByOperator" default="">
<cfparam name="request.requestState.showValues" default="">

<cfscript>
	oReport = request.requestState.oReport;
	aFilters = request.requestState.aFilters;
	aColumns = request.requestState.aColumns;
	qryFilters = request.requestState.qryFilters;
	qryValues = request.requestState.qryValues;

	filterByColumn = request.requestState.filterByColumn;
	filterByCondition = request.requestState.filterByCondition;
	FilterByOperator = request.requestState.FilterByOperator;
	showValues = request.requestState.showValues;
</cfscript>

<cfoutput>
<div id="DialogPanelTitle">
	<a href="##" 
		onclick="closeDialogPanel()" 
		style="float:right;color:##fff;margin-right:10px;margin-top:3px;"><img 
		src="/WebReports/common/images/iclose.gif" 
		alt="Close Dialog" title="Close Dialog"
		border="0"></a>
	&nbsp;Filter Report
</div>

<form name="frm" id="frmFilter" method="post" action="##" onsubmit="doFormEvent('ehFilters.doSave','DialogPanelContainer',this);return false">

	<table border="0" width="100%" align="center" cellspacing="0">
		<tr valign="top">
			<td style="width:200px;">
			
				<cfif FilterByOperator eq "" and arrayLen(aFilters) gte 1>
					<cfset FilterByOperator = "And">
				</cfif>
				<input type="hidden" name="FilterByOperator" value="#FilterByOperator#">
				
				<table width="100%" style="margin:3px;border:1px solid silver;background-color:##fff;" cellpadding="4">
				<cfif arrayLen(aFilters) gte 1>
					<tr>
						<td>
							<input type="radio" name="FilterByOperatorSelector" 
									value="And" 
									<cfif FilterByOperator eq "And">checked</cfif>
									style="border:0px;" 
									onclick="this.form.FilterByOperator.value=this.value">&nbsp;And&nbsp;&nbsp;
							<input type="radio" name="FilterByOperatorSelector" 
									value="Or" 
									<cfif FilterByOperator eq "Or">checked</cfif>
									style="border:0px;" 
									onclick="this.form.FilterByOperator.value=this.value">&nbsp;Or
						</td>
					</tr>
				</cfif>	
				
				<tr>
					<td>	
					<strong>Column:</strong><br>
					<!--- <cfset SortedFields = ArrayToList(StructSort(stColumns,"text","asc","Header"))> --->
					<select name="FilterByColumn" class="SmallText" onchange="doEvent('ehFilters.dspMain','DialogPanelContainer',{FilterByColumn:this.value,FilterByOperator:this.form.FilterByOperator.value});" style="width:120px;">
						<option />
						<cfloop from="1" to="#arrayLen(aColumns)#" index="i">
							<cfset thisSQLExpr = aColumns[i].SQLExpr>
							<cfset thisHeader = aColumns[i].Header>
				
							<cfif isdefined("FilterByColumn") and FilterByColumn is thisSQLExpr>
								<option value="#thisSQLExpr#" selected>#thisHeader#</option>
							<cfelse>		
								<option value="#thisSQLExpr#">#thisHeader#</option>
							</cfif>
						</cfloop>
					</select>	
					</td>
				</tr>
					
				<tr>
					<td>	
					<strong>Condition:</strong><br>	
					<select name="FilterByCondition" class="SmallText" style="width:120px;">
						<cfloop query="qryFilters">
							<option value="#qryFilters.operator#"
									<cfif FilterByCondition eq qryFilters.operator>selected</cfif>
										>#qryFilters.label#</option>
						</cfloop>
					</select>
					</td>
				</tr>
				
				<tr>
					<td>			
					<strong>Value:</strong><br>					
					<cfif filterByColumn neq "">
						
						<cfif showValues>
							<!--- Show a select list for the values of this column --->
							<select name="FilterByValue" onChange="AdjustDataType(this);" style="width:120px;">
								<cfloop query="qryValues">
									<cfset tmpItem = qryValues.item>
									<cfif isdate(tmpItem) and Find(",",tmpItem) eq 0>
										<!--- Give proper format to columns with date values --->
										<cfset tmpItem = lsDateFormat(tmpItem) & " " & lsTimeFormat(tmpItem)>
									</cfif>
									<option value="#tmpItem#">#tmpItem#</option>
								</cfloop>
							</select>
							<a href="javascript:doEvent('ehFilters.dspMain','DialogPanelContainer',{FilterByColumn:'#FilterByColumn#',FilterByOperator:$('frmFilter').FilterByOperator.value,showValues:false})"
								><img src="images/edit-small.gif" border="0" alt="Type value" align="absmiddle"></a>
						<cfelse>
							<input type="text" name="FilterByValue" value="" style="width:120px;">
							<a href="javascript:doEvent('ehFilters.dspMain','DialogPanelContainer',{FilterByColumn:'#FilterByColumn#',FilterByOperator:$('frmFilter').FilterByOperator.value,showValues:true})"
								><img src="images/dots.gif" border="0" alt="Select value from list" align="absmiddle"></a>
						</cfif>
					<cfelse>
						<input type="hidden" name="FilterByValue" value="">	
						<em>Select a column</em>
					</cfif>
					</td>
				</tr>
				
				<tr>
					<td colspan="2">	
						<input type="hidden" name="FilterByType" value="Text">
						<input class="SmallText" name="btnSaveWhere"
								<cfif filterByColumn eq "">disabled</cfif>
								 type="submit" value="Add Filter" style="width:120px;">
					</td>
				</tr>
				
				</table>
				
			</td>
			
			<td>
				<table border="0" width="100%" cellspacing="0" style="border:1px solid silver;">
					<tr>
						<th style="border-bottom:1px solid black;">Filters</th>
						<th style="border-bottom:1px solid black;">&nbsp;</th>
					</tr>
				
					<cfloop from="1" to="#arrayLen(aFilters)#" index="i">
						<cfset stFilter = aFilters[i]>
						<cfif StructKeyExists(stFilter, "Column")>
							<cfset rowStyle="background-color : #iif(i mod 2,de("####ececec"),de("####FFFFFF"))#;">
				
							<!---- get the label of this column  (oarevalo 11/26/03) ---->
							<cfloop from="1" to="#arrayLen(aColumns)#" index="j">
								<cfif aColumns[j].sqlExpr eq stFilter.Column>
									<cfset tmpThisLabel = aColumns[j].header>
									<cfbreak>
								</cfif>
							</cfloop>
				
							<tr style="#rowStyle#">
								<td>
									<div style="width:160px;overflow:hidden;font-size:10px;">
										<cfif i neq 1>
											<strong style="color:darkblue;font-size:11px;">#stFilter.Operator#</strong>&nbsp;
										</cfif>
										#tmpThisLabel#&nbsp;
										#stFilter.Relation#&nbsp;
										'#stFilter.Value#'&nbsp;
									</div>
								</td>
								<td align="center">
									<a href="##" onclick="if(confirm('Remove Filter?')) doEvent('ehFilters.doDelete','DialogPanelContainer',{index:#i#});">
										<img src="../common/images/idelete.gif" border="0"></a>
								</td>
							</tr>
						</cfif>
					</cfloop>
					<cfif arrayLen(aFilters) eq 0>
						<tr><td colspan="4"><em><b>No filters</b></em></td></tr>
					</cfif>
				</table>			

				<div style="border:1px solid silver;background-color:##ebebeb;padding:5px;line-height:15px;margin-top:10px;">
					<img src="images/bullet_go.png" align="absmiddle"><a href="index.cfm">Click Here to Reload report</a><br />
				</div>

			</td>
		</tr>
	</table>
</form>
</cfoutput>
