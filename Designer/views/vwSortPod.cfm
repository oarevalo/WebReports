<cfparam name="request.requestState.oReport" default="0">

<cfscript>
	oReport = request.requestState.oReport;
	aColumns = oReport.getColumns();
	
	// maxIndex will give us the highest value of SortIndex 
	maxIndex = 0;
	for(i=1;i lte arrayLen(aColumns);i=i+1) {
		if(StructKeyExists(aColumns[i],"SortIndex") and aColumns[i].SortIndex gt maxIndex) 
			maxIndex = aColumns[i].SortIndex;			
	}
</cfscript>

<cfoutput>
	<form name="frmSort" id="frmSort" action="index.cfm" method="post" style="margin:0px;padding:0px;">
		<input type="hidden" name="event" value="ehSort.doAddSort">
		<table border="0" width="100%" cellpadding="1" cellspacing="0">
			<tr>
				<td align="left" style="border-bottom:1px solid black;">
					<a href="##" onclick="doFormEvent('ehSort.doAddSort','podSortContent',$('frmSort'))"><img src="images/add-small.gif" border="0" alt="Add Column" title="Add Column" style="float:right;"></a>
					<select name="SortColumn" class="SmallText" style="width:130px;font-size:11px;">
						<option />
						<cfloop from="1" to="#arrayLen(aColumns)#" index="i">
							<cfif not StructKeyExists(aColumns[i],"SortIndex")
								or aColumns[i].SortIndex is "">
								<option value="#aColumns[i].header#">#aColumns[i].Header#</option>
							</cfif>
						</cfloop>
					</select>
				</td>
			</tr>
			<tr>
				<td>
				
				<table border="0" width="100%" align="center" cellspacing="0" style="border:1px solid silver;">
					<tr>
						<th colspan="2">
							Sort By
							<cfif maxIndex gt 0>
								<br><span style="font-weight:bold;font-size:10px;"> [Click arrow to change direction]</span>
							</cfif>
						</th>
					</tr>
				
					<!--- Display what has been selected so far (sorted by SortIndex)--->
					<cfset counter=1>
					<cfset a=1>
					<cfloop index="i" from="1" to="#maxIndex#">
						<cfset a=a*(-1)>
						<cfset rowStyle="background-color : #iif(counter mod 2,de("####ececec"),de("####FFFFFF"))#;">
						<cfloop from="1" to="#arrayLen(aColumns)#" index="j">
							<cfset tmpDir = aColumns[j].SortDirection>
							<cfif tmpDir eq "ASC">
								<cfset imgDir = "arrow-up.gif">
								<cfset tmpDirOp = "DESC">
							<cfelse>
								<cfset imgDir = "arrow-down.gif">
								<cfset tmpDirOp = "ASC">
							</cfif>
							
							<cfif StructKeyExists(aColumns[j],"SortIndex") and aColumns[j].SortIndex is i>
								<tr style="#rowStyle#">
									<td align="left" nowrap>
										<strong>#counter#.</strong> 
										<a href="javascript:doEvent('ehSort.doSetDirection','podSortContent',{SortColumn:'#aColumns[j].Header#',Direction:'#tmpDirOp#'});"
											><img src="images/#imgDir#" border="0" alt="Click to change direction"></a>
										#aColumns[j].Header#
									</td>
									<td align="center" style="#rowStyle#">
										<a href="##" onclick="if(confirm('Remove Sort?')) doEvent('ehSort.doRemoveSort','podSortContent',{SortColumn:'#aColumns[j].Header#'});">
											<img src="../Common/Images/idelete.gif" border="0"></a>
									</td>
								</tr>
								<cfset counter=counter + 1>
							</cfif>
						</cfloop>
					</cfloop>
					<cfif counter eq 1>
						<tr><td colspan="4"><em><b>No sort columns</b></em></td></tr>
					</cfif>
				</table>
			
							
				</td>
			
			</tr>
		</table>
	</form>
</cfoutput>
