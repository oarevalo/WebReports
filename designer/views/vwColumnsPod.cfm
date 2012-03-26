<cfparam name="request.requestState.aFields" default="#arrayNew(1)#">
<cfparam name="request.requestState.oReport" default="0">

<cfset aFields = request.requestState.aFields>
<cfset oReport = request.requestState.oReport>
<cfset aColumns = oReport.getColumns()>

<cfset arraySort(aFields,"textnocase")>

<cfoutput>
	<form name="frmColumns" id="frmColumns" action="index.cfm" method="post" style="margin:0px;padding:0px;">
		<table border="0" width="100%" cellpadding="1" cellspacing="0">
			<tr>
			 <td align="left" >
				&nbsp;<img src="../common/images/add.jpg" alt="Use Column" />&nbsp;
				<img src="../common/images/eye.jpg" alt="Show Value" />
			</td>
			
			</tr>
			<tr>
				 <td align="left" style="border-bottom:1px solid black;">
					<a href="##" onclick="doFormEvent('ehColumns.doSetColumns','podColumnsContent',$('frmColumns'))"><img src="images/apply-small.gif" border="0" alt="Apply Changes" title="Apply Changes" style="float:right;"></a>
					<input type="checkbox" name="chkEnableAll" style="border:0;" onclick="toggleCheckboxes(this.form, 'chkEnable', this)"> 
					<input type="checkbox" name="chkViewAll" style="border:0;" onclick="toggleCheckboxes(this.form, 'chkVisible', this)"> 
				</td>
			</tr>
			<cfset index=1>
			<cfloop from="1" to="#arrayLen(aFields)#" index="j">
				<cfset field = aFields[j]>
				<cfset IsSelected = "">
				<cfset IsVisible = "">
				<cfloop from="1" to="#arrayLen(aColumns)#" index="i">
					<cfif aColumns[i].SQLExpr eq field>
						<cfset IsSelected = "checked">
						<cfif aColumns[i].display>
							<cfset IsVisible = "checked">
						</cfif>
						<cfbreak>
					</cfif>
				</cfloop>
				<tr <cfif index mod 2>style="background-color:##fff;"</cfif>>
					<td nowrap align="left">
						<input type="checkbox" name="fldEnable_#field#" id="fldEnable_#field#" style="border:0;" value="true" #IsSelected# class="chkEnable"
								onclick="enableColumn(this,'#field#');">
						<input type="checkbox" name="fldVisible_#field#" id="fldVisible_#field#" style="border:0;" value="true" #IsVisible# class="chkVisible"
								<cfif isSelected eq "">disabled</cfif>>
						<span id="ColumnsText" style="font-size:10px">&nbsp;
							<cfif IsSelected eq "checked">
								<a href="##" onclick="openEditColumnPanel('#field#')">#field#</a>
							<cfelse>
								#field#
							</cfif>
						</span>
					</td>
				</tr>
				<cfset index = index + 1>
			</cfloop>		
		</table>
	</form>
</cfoutput>
