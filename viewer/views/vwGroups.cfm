<cfparam name="request.requestState.oReport" default="">
<cfparam name="request.requestState.aColumns" default="">
<cfparam name="request.requestState.maxIndex" default="">

<cfscript>
	oReport = request.requestState.oReport;
	aColumns = request.requestState.aColumns;
	maxIndex = request.requestState.maxIndex;
</cfscript>

<cfoutput>
<div id="DialogPanelTitle">
	<a href="##" 
		onclick="closeDialogPanel()" 
		style="float:right;color:##fff;margin-right:10px;margin-top:3px;"><img 
		src="/WebReports/common/images/iclose.gif" 
		alt="Close Dialog" title="Close Dialog"
		border="0"></a>
	&nbsp;Group Report
</div>

<form name="frm" method="post" action="##" onsubmit="doFormEvent('ehGroups.doSave','DialogPanelContainer',this);return false">

	<table border="0" width="100%" align="center" cellspacing="0">
		<tr valign="top">
			<td style="width:200px;">
				
				<table width="100%" style="margin:3px;border:1px solid silver;background-color:##fff;" cellpadding="4">
					<tr>
						<td nowrap>
							<b>Group Report On:</b><br>
							<select name="groupByColumn" class="SmallText" style="width:120px;">
								<option />
								<cfloop from="1" to="#arrayLen(aColumns)#" index="i">
									<cfif not StructKeyExists(aColumns[i],"GroupIndex")
										or aColumns[i].GroupIndex is "">
										<option value="#aColumns[i].Header#">#aColumns[i].Header#</option>
									</cfif>
								</cfloop>
							</select>
							<input class="SmallText" name="btnSaveGroup" type="image" value="Add" src="images/add-small.gif" align="absmiddle" style="border:0px;">
						</td>
					</tr>
					<tr>
						<td>
							<input type="Checkbox" name="showTitle" value="Yes" checked  style="border:0px;"> Show Group Titles<br>
							<input type="Checkbox" name="showTotal" value="Yes" checked  style="border:0px;"> Show Group Totals
						</td>
					</tr>
				</table>
			
				<div style="margin:3px;border:1px solid silver;background-color:##ffffcc;">
					<div style="margin:3px;line-height:15px;">
						Select column(s) by which to group report. <br><br>
						<b>Show Group Titles:</b> Displays the heading for each group.<br><br>
						<b>Show Group Totals:</b> When calculating totals (sums, averages, counts), 
							displays the result for each group.
					</div>
				</div>
			</td>
			
			<td>
				<table border="0" width="100%" align="center" cellspacing="0" style="border:1px solid silver;">
					<tr>
						<th>Group By</th>
						<th>Group<br>Titles?</th>
						<th>Group<br>Totals?</th>
						<th>&nbsp;</th>
					</tr>
				
					<!--- Display what has been selected so far (sorted by GroupIndex)--->
					<cfset counter=1>
					<cfset a=1>
					<cfloop index="i" from="1" to="#maxIndex#">
						<cfset a=a*(-1)>
						<cfset rowStyle="background-color : #iif(a gt 0,de("####ececec"),de("####FFFFFF"))#;">
						<cfloop from="1" to="#arrayLen(aColumns)#" index="j">
							<cfif StructKeyExists(aColumns[j],"GroupIndex")
								and aColumns[j].GroupIndex is i>
								<tr>
									<td align="left" nowrap style="#rowStyle#"><strong>#counter#.</strong> #aColumns[j].Header#&nbsp;</td>
									<td align="center" style="#rowStyle#">
										<cfif StructKeyExists(aColumns[j],"GroupTitles")>
											<cfif aColumns[j].GroupTitles>
												<img src="../common/images/active_icon.gif" alt="Yes">
											<cfelse>
												<img src="../common/images/inactive_icon.gif" alt="No">
											</cfif>
										<cfelse><img src="../common/images/active_icon.gif" alt="Yes"></cfif>
									</td>
									<td align="center" style="#rowStyle#">
										<cfif StructKeyExists(aColumns[j],"GroupDisplayTotal")>
											<cfif aColumns[j].GroupDisplayTotal>
												<img src="../common/images/active_icon.gif" alt="Yes">
											<cfelse>
												<img src="../common/images/inactive_icon.gif" alt="No">
											</cfif>
										<cfelse><img src="../common/images/active_icon.gif" alt="Yes"></cfif>
									</td>
									<td align="center" style="#rowStyle#">
										<a href="##" onclick="if(confirm('Remove Group?')) doEvent('ehGroups.doDelete','DialogPanelContainer',{index:'#aColumns[j].header#'});">
											<img src="../common/images/idelete.gif" border="0" alt="Delete group" title="Delete group"></a>
									</td>
								</tr>
								<cfset counter=counter + 1>
							</cfif>
						</cfloop>
					</cfloop>
					<cfif counter eq 1>
						<tr><td colspan="4"><em><b>No groups</b></em></td></tr>
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