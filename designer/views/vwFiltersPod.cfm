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
	<form name="frmFilters" id="frmFilters" method="post" action="##" onsubmit="doFormEvent('ehFilters.doAddFilter','podFiltersContent',this);return false"
			style="margin:0px;padding:0px;border:1px solid silver;background-color:##fff;">
		<div style="margin:3px;">
				
				<cfif arrayLen(aFilters) gte 1>
					<div>
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
					</div>
				</cfif>	
				
				<div style="margin-top:5px;">	
					<strong>Column:</strong><br>
					<select name="FilterByColumn" style="width:150px;font-size:11px;" 
							onchange="doEvent('ehFilters.dspMain','podFiltersContent',{FilterByColumn:this.value});">
						<option />
						<cfloop from="1" to="#arrayLen(aColumns)#" index="i">
							<cfset thisSQLExpr = aColumns[i].SQLExpr>
							<cfset thisHeader = aColumns[i].Header>
				
							<cfif FilterByColumn is thisSQLExpr>
								<option value="#thisSQLExpr#" selected>#thisHeader#</option>
							<cfelse>		
								<option value="#thisSQLExpr#">#thisHeader#</option>
							</cfif>
						</cfloop>
					</select>	
				</div>
					
				<div style="margin-top:5px;">	
					<strong>Condition:</strong><br>	
					<select name="FilterByCondition" style="width:150px;font-size:11px;">
						<cfloop query="qryFilters">
							<option value="#qryFilters.operator#"
									<cfif FilterByCondition eq qryFilters.operator>selected</cfif>
										>#qryFilters.label#</option>
						</cfloop>
					</select>
				</div>
				
				<div style="margin-top:5px;">	
					<strong>Value:</strong><br>					
					<cfif filterByColumn neq "">
						
						<cfif showValues>
							<!--- Show a select list for the values of this column --->
							<select name="FilterByValue" onChange="AdjustDataType(this);" style="width:130px;font-size:11px;">
								<cfloop query="qryValues">
									<cfset tmpItem = qryValues.item>
									<cfif isdate(tmpItem) and Find(",",tmpItem) eq 0>
										<!--- Give proper format to columns with date values --->
										<cfset tmpItem = lsDateFormat(tmpItem) & " " & lsTimeFormat(tmpItem)>
									</cfif>
									<option value="#tmpItem#">#tmpItem#</option>
								</cfloop>
							</select>
							<a href="##"
								onclick="doEvent('ehFilters.dspMain','podFiltersContent',{FilterByColumn:'#FilterByColumn#',FilterByOperator:$('frmFilters').FilterByOperator.value,showValues:false})"
								><img src="images/edit-small.gif" border="0" alt="Type value" align="absmiddle"></a>
						<cfelse>
							<input type="text" name="FilterByValue" value="" style="width:130px;font-size:11px;">
							<a href="##"
								onclick="doEvent('ehFilters.dspMain','podFiltersContent',{FilterByColumn:'#FilterByColumn#',FilterByOperator:$('frmFilters').FilterByOperator.value,showValues:true})"
								><img src="images/dots.gif" border="0" alt="Select value from list" align="absmiddle"></a>
						</cfif>
					<cfelse>
						<input type="hidden" name="FilterByValue" value="">	
						<em>Select a column</em>
					</cfif>
				</div>
				
				<p align="center" style="margin-top:5px;">	
						<input type="hidden" name="FilterByOperator" value="#FilterByOperator#">
						<input type="hidden" name="FilterByType" value="Text">
						
						<cfif filterByColumn neq "">
							<input name="btnSaveWhere" src="images/addFilter.gif" type="image" value="Add Filter">
						</cfif>
				</p>
		</div>
	</form>

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
						<div style="width:155px;overflow:hidden;font-size:10px;">
							<cfif i neq 1>
								<strong style="color:darkblue;font-size:11px;">#stFilter.Operator#</strong>&nbsp;
							</cfif>
							#tmpThisLabel#&nbsp;
							#stFilter.Relation#&nbsp;
							'#stFilter.Value#'&nbsp;
						</div>
					</td>
					<td align="center">
						<a href="##" onclick="if(confirm('Remove Filter?')) doEvent('ehFilters.doRemoveFilter','podFiltersContent',{filterIndex:'#i#'});">
							<img src="../common/images/idelete.gif" border="0"></a>
					</td>
				</tr>
			</cfif>
		</cfloop>
		<cfif arrayLen(aFilters) eq 0>
			<tr><td colspan="4"><em><b>No filters</b></em></td></tr>
		</cfif>
	</table>

</cfoutput>		