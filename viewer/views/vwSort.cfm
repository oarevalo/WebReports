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
	&nbsp;Sort Report
</div>

<form name="frm" method="post" action="##" onsubmit="doFormEvent('ehSort.doSave','DialogPanelContainer',this);return false">

	<table border="0" width="100%" align="center" cellspacing="0">
		<tr valign="top">
			<td style="width:200px;">
				
				<table width="100%" style="margin:3px;border:1px solid silver;background-color:##fff;" cellpadding="4">
					<tr>
						<td>
							<b>Sort Report On:</b><br>
							<select name="sortByColumn" class="SmallText" style="width:120px;">
								<option />
								<cfloop from="1" to="#arrayLen(aColumns)#" index="i">
									<cfif not StructKeyExists(aColumns[i],"SortIndex")
										or aColumns[i].SortIndex is "">
										<option value="#aColumns[i].header#">#aColumns[i].Header#</option>
									</cfif>
								</cfloop>
							</select>
							<input class="SmallText" name="btnSaveSort" type="image" value="Add" src="images/add-small.gif" align="absmiddle" style="border:0px;">
						</td>
					</tr>
					<tr>
						<td>
							<strong>Direction:</strong><br>
							<select name="sortByDirection" class="SmallText" style="width:120px;">
								<option value="ASC" selected>Ascending</option>
								<option value="DESC">Descending</option>
							</select> 
						</td>
					</tr>
				</table>

				<div style="margin:3px;border:1px solid silver;background-color:##ffffcc;">
					<div style="margin:3px;line-height:15px;">
						Select column(s) by which to sort the report. You may choose any number
						of columns as you wish.<br><br>
						<b>Direction:</b> Determines the sorting direction to apply Ascending (0-9,A-Z) or Descending (9-0,Z-A)
						<br><br>
					</div>
				</div>				
			</td>
			
			<td>
				<table border="0" width="100%" align="center" cellspacing="0" style="border:1px solid silver;">
					<tr>
						<th>Sort By</th>
						<th>&nbsp;</th>
					</tr>
				
					<!--- Display what has been selected so far (sorted by SortIndex)--->
					<cfset counter=1>
					<cfset a=1>
					<cfloop index="i" from="1" to="#maxIndex#">
						<cfset a=a*(-1)>
						<cfset rowStyle="background-color : #iif(counter mod 2,de("####ececec"),de("####FFFFFF"))#;">
						<cfloop from="1" to="#arrayLen(aColumns)#" index="j">
							<cfset tmpDir = aColumns[j].SortDirection>
							<cfset imgDir = ReplaceList(tmpDir,"ASC,DESC","arrow-up.gif,arrow-down.gif")>
							<cfif StructKeyExists(aColumns[j],"SortIndex") and aColumns[j].SortIndex is i>
								<tr style="#rowStyle#">
									<td align="left" nowrap>
										<strong>#counter#.</strong> 
										<img src="images/#imgDir#">
										#aColumns[j].Header#
									</td>
									<td align="center" style="#rowStyle#">
										<a href="##" onclick="if(confirm('Remove Sort?')) doEvent('ehSort.doDelete','DialogPanelContainer',{index:'#aColumns[j].Header#'});">
											<img src="../common/images/idelete.gif" border="0"></a>
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
				<div style="border:1px solid silver;background-color:##ebebeb;padding:5px;line-height:15px;margin-top:10px;">
					<img src="images/bullet_go.png" align="absmiddle"><a href="index.cfm">Click Here to Reload report</a><br />
				</div>

			</td>
		</tr>
	</table>
</form>
</cfoutput>