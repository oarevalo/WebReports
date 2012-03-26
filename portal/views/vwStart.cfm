<cfparam name="request.requestState.useManagedReports" default="false">
<cfparam name="request.requestState.qryReports" default="#queryNew("")#">
<cfparam name="request.requestState.hasReportDesigner" default="false">
<cfparam name="request.requestState.showDesignReport" default="false">
<cfparam name="request.requestState.qryUser" default="#queryNew("")#">
<cfparam name="request.requestState.searchTerm" default="">
<cfparam name="request.requestState.startRow" default="1">

<cfset useManagedReports = request.requestState.useManagedReports>
<cfset qryReports = request.requestState.qryReports>
<cfset hasReportDesigner = request.requestState.hasReportDesigner>
<cfset showDesignReport = request.requestState.showDesignReport>
<cfset qryUser = request.requestState.qryUser>
<cfset searchTerm = request.requestState.searchTerm>
<cfset startRow = request.requestState.startRow>

<cfset rowsPerPage = 10>

<cfset designerURL = "/WebReports/designer/?userKey=#session.userKey#">

<cfquery name="qryReports" dbtype="query">
	SELECT *
		FROM qryReports
		<cfif not useManagedReports>
			ORDER BY Type, Name
		<cfelse>
			ORDER BY reportName
		</cfif>
</cfquery>

<table width="100%">
	<tr valign="top">
		<td>
			<div style="margin:10px;">
				
				<cfif searchTerm neq "">
					<cfoutput>
						<b>Found #qryReports.recordCount# match(es) for '#searchTerm#'</b>
						<span style="font-size:9px;">( <a href="index.cfm">Clear Results</a> )</span>
						<br /><br />
					</cfoutput>
				</cfif>
			
		
				<!--- New Report --->
				<cfif showDesignReport>
					<cfoutput>
						<div style="margin-bottom:10px;">
							<div style="width:40px;text-align:center;float:left;">
								<a href="#designerURL#&resetReport=true"><img src="/WebReports/common/images/page_new.gif" border="0"></a><br>
							</div>
							<div style="float:left;">
								<a href="#designerURL#&resetReport=true"><strong>Create New Report</strong></a><br />
								<div style="color:##999;margin-top:4px;">
									Open Report Designer to create a new report.
								</div>
							</div>
							<br style="clear:both;" />
						</div>
						<div style="border-bottom:1px solid ##ebebeb;padding-bottom:10px;margin-bottom:20px;"></div>
					</cfoutput>
				</cfif>
			
			
				<!--- Reports List --->
				<cfif useManagedReports>
					<cfoutput query="qryReports" startrow="#startRow#" maxrows="#rowsPerPage#">
						<div style="margin-bottom:10px;">
							<div style="width:40px;text-align:center;float:left;">
								<a href="?event=ehGeneral.doOpenReport&reportID=#qryReports.reportID#"><img src="/WebReports/common/images/doc01.gif" border="0"></a><br>
							</div>
							<div style="float:left;">
								<a href="?event=ehGeneral.doOpenReport&reportID=#qryReports.reportID#">#qryReports.reportName#</a>
								<br />
								<div style="color:##999;font-size:9px;">
									&bull;&nbsp;Created on #lsDateFormat(qryReports.createdOn)#
								</div>
							
								<div style="color:##999;margin-top:4px;">
									#qryReports.description#
								</div>
								
								<cfif showDesignReport>
									<div style="font-size:9px;margin-top:4px;">
										<img src="images/bullet_go.png" align="absmiddle"><a 
											href="#designerURL#&event=ehGeneral.doOpenReport&reportID=#qryReports.reportID#"
											>Open in Designer</a>
											
										<cfif qryUser.isAdmin>
											&nbsp;|&nbsp;
											<img src="images/bullet_wrench.png" align="absmiddle"><a 
												href="?event=ehReportLibrary.dspEdit&reportID=#qryReports.reportID#"
												>Report Details</a>
										</cfif>	
									</div>
								</cfif>
							</div>
							<br style="clear:both;" />
						</div>
						<div style="border-bottom:1px solid ##ebebeb;padding-bottom:10px;margin-bottom:20px;"></div>
					</cfoutput>
					
					<cfoutput>
						<cfif qryReports.recordCount gt rowsPerPage>
							<span style="color:##999;">
								Displaying reports #startRow# to #startRow+rowsPerPage-1# of #qryReports.recordCount#
								&nbsp;&nbsp;&nbsp;&bull;&nbsp;
							</span>
							<cfif startRow gt 1>
								<a href="index.cfm?searchTerm=#searchTerm#&startRow=#startRow-rowsPerPage#">Previous Page</a>
							</cfif>
							&nbsp;
							<cfif qryReports.recordCount gte startRow+rowsPerPage>
								<a href="index.cfm?searchTerm=#searchTerm#&startRow=#startRow+rowsPerPage#">Next Page</a>
							</cfif>
						</cfif>
					</cfoutput>
				<cfelse>
					<cfoutput query="qryReports">
						<cfif right(name,4) eq ".xml">
							<cfset tmpReportFile = getSetting("reportRepositoryPath") & "/" & reportFileName>
							<div style="margin-bottom:20px;border-bottom:1px solid ##ebebeb;padding-bottom:20px;">
								<div style="width:40px;text-align:center;float:left;">
									<a href="?event=ehGeneral.doOpenReport&filename=#name#"><img src="/WebReports/common/images/doc01.gif" border="0"></a><br>
								</div>
								<div style="float:left;">
									<a href="?event=ehGeneral.doOpenReport&filename=#name#">#name#</a>
									<cfif showDesignReport>
										<div style="font-size:9px;margin-top:5px;">
											<img src="images/bullet_go.png" align="absmiddle"><a 
												href="#designerURL#&event=ehGeneral.doOpenReport&path=#tmpReportFile#">[DESIGN]</a>
										</div>
									</cfif>
								</div>
								<br style="clear:both;" />
							</div>
						</cfif>
					</cfoutput>
				</cfif>
			</div>

		</td>
		<td style="width:250px;">
			<cfinclude template="../includes/searchReports.cfm">
		</td>
	</tr>
</table>

	

<!---<h1>Recently Opened</h1>--->