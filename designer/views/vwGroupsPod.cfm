<cfparam name="request.requestState.oReport" default="0">

<cfscript>
	oReport = request.requestState.oReport;
	aColumns = oReport.getColumns();
	
	// maxIndex will give us the highest value of SortIndex 
	maxIndex = 0;
	for(i=1;i lte arrayLen(aColumns);i=i+1) {
		if(StructKeyExists(aColumns[i],"GroupIndex") and aColumns[i].GroupIndex gt maxIndex) 
			maxIndex = aColumns[i].GroupIndex;			
	}
</cfscript>

<cfoutput>
	<form name="frmGroup" id="frmGroup" action="index.cfm" method="post" style="margin:0px;padding:0px;">
		<input type="hidden" name="event" value="ehSort.doAddSort">
		<table border="0" width="100%" cellpadding="1" cellspacing="0">
			<tr>
				<td align="left" style="border-bottom:1px solid black;">
					<a href="##" onclick="doFormEvent('ehGroups.doAddGroup','podGroupsContent',$('frmGroup'))"><img src="images/add-small.gif" border="0" alt="Add Column" title="Add Column" style="float:right;"></a>
					<select name="field" class="SmallText" style="width:130px;font-size:11px;">
						<option />
						<cfloop from="1" to="#arrayLen(aColumns)#" index="i">
							<cfif not StructKeyExists(aColumns[i],"GroupIndex")
								or aColumns[i].GroupIndex is "">
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
						<th>Group By</th>
						<th>&nbsp;</th>
					</tr>
				
					<!--- Display what has been selected so far (sorted by SortIndex)--->
					<cfset counter=1>
					<cfset a=1>
					<cfloop index="i" from="1" to="#maxIndex#">
						<cfset a=a*(-1)>
						<cfset rowStyle="background-color : #iif(counter mod 2,de("####ececec"),de("####FFFFFF"))#;">
						<cfloop from="1" to="#arrayLen(aColumns)#" index="j">
							<cfif StructKeyExists(aColumns[j],"GroupIndex") and aColumns[j].GroupIndex is i>
								<tr style="#rowStyle#">
									<td align="left" nowrap>
										<strong>#counter#.</strong> 
										#aColumns[j].Header#
									</td>
									<td align="right" style="#rowStyle#">
										<!---
										<cfif StructKeyExists(aColumns[j],"GroupTitles")>
											<cfif aColumns[j].GroupTitles>
												<img src="../common/images/active_icon.gif" alt="Yes">
											<cfelse>
												<img src="../common/images/inactive_icon.gif" alt="No">
											</cfif>
										<cfelse><img src="../common/images/active_icon.gif" alt="Yes"></cfif>
										<cfif StructKeyExists(aColumns[j],"GroupDisplayTotal")>
											<cfif aColumns[j].GroupDisplayTotal>
												<img src="../common/images/active_icon.gif" alt="Yes">
											<cfelse>
												<img src="../common/images/inactive_icon.gif" alt="No">
											</cfif>
										<cfelse><img src="../common/images/active_icon.gif" alt="Yes"></cfif>
										--->
										<a href="##" onclick="if(confirm('Remove Group?')) doEvent('ehGroups.doRemoveGroup','podGroupsContent',{field:'#aColumns[j].Header#'});">
											<img src="../common/images/idelete.gif" border="0"></a>
									</td>
								</tr>
								<cfset counter=counter + 1>
							</cfif>
						</cfloop>
					</cfloop>
					<cfif counter eq 1>
						<tr><td colspan="4"><em><b>No groups selected</b></em></td></tr>
					</cfif>
				</table>
			
							
				</td>
			
			</tr>
		</table>
	</form>
</cfoutput>
