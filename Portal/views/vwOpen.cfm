<cfparam name="request.requestState.qryReport" default="#queryNew("")#">
<cfparam name="request.requestState.reportID" default="">
<cfparam name="request.requestState.qryStoredConnections" default="#queryNew("")#">
<cfparam name="request.requestState.lstDatasources" default="">

<cfset qryReport = request.requestState.qryReport>
<cfset reportID = request.requestState.reportID>
<cfset qryStoredConnections = request.requestState.qryStoredConnections>
<cfset lstDatasources = request.requestState.lstDatasources>

<style type="text/css">
	.frmLogin {
		padding:30px;
		width:250px;
		margin:0 auto;
	}
	input, select {
		font-size:10px;
		border:1px solid black;
	}
	td input, td select {
		width:100px;
	}

	/* Show only to IE PC \*/
	* html .SectionTitle h2 {height: 1%;} /* For IE 5 PC */
	
	.Section {
		margin: 0 auto; /* center for now */
		/*width: 17em; *//* ems so it will grow */
		background: url(/WebReports/Portal/images/sbbody-r.gif) no-repeat bottom right;
		/*font-size: 100%;*/
		border:0px;
		font-size:11px;
		font-family:Arial, Helvetica, sans-serif;
	}
	.SectionTitle {
		background: url(/WebReports/Portal/images/sbhead-r.gif) no-repeat top right;
		margin: 0;
		padding: 0;
		text-align: left;
	}
	.SectionTitle h2 {
		text-align: left;
		background: url(/WebReports/Portal/images/sbhead-l.gif) no-repeat top left;
		margin: 0;
		padding: 22px 30px 5px;
		color: white; 
		font-weight: bold; 
		font-size: 1.2em; 
		line-height: 1em;
	}	
	.SectionBody {
		background: url(/WebReports/Portal/images/sbbody-l.gif) no-repeat bottom left;
		margin: 0;
		padding: 5px 30px 31px;
		padding-top:20px;
		text-align:left;
	}	
</style>

	
	<cfoutput>
		<form name="frm" action="index.cfm" method="post" class="frmLogin">
			<input type="hidden" name="event" value="ehGeneral.doOpenReport">
			<input type="hidden" name="reportID" value="#reportID#">
			<input type="hidden" name="fileName" value="#qryReport.reportName#">
	
			<div class="Section">
				<div class="SectionTitle"><h2>#qryReport.reportName#</h2></div>
				<div class="SectionBody">
					
					<table>
						<cfif qryReport.storedConnectionID eq "?">
							<tr>
								<td><b>Connection:</b></td>
								<td>
									<select name="_c">
										<cfloop query="qryStoredConnections">
											<option value="#qryStoredConnections.storedConnectionID#"
												>#qryStoredConnections.connectionName#</option>
										</cfloop>
									</select>						
								</td>
							</tr>
						</cfif>
						<cfif qryReport.datasource eq "?">
							<tr>
								<td><b>Datasource:</b></td>
								<td>
									<cfif lstDatasources neq "" and lstDatasources neq "*">
										<select name="_d">
											<cfloop list="#lstDatasources#" index="ds">
												<option value="#ds#">#ds#</option>
											</cfloop>
										</select>
									<cfelse>
										<input type="text" name="_d" value="">
									</cfif>								
								</td>
							</tr>
						</cfif>
						<cfif qryReport.username eq "?">
							<tr>
								<td><b>Username:</b></td>
								<td><input type="text" name="_u" value=""></td>
							</tr>
						</cfif>
						<cfif qryReport.password eq "?">
							<tr>
								<td><b>Password:</b></td>
								<td><input type="password" name="_p" value=""></td>
							</tr>
						</cfif>
					</table>
					
					<p align="center">
						<input type="submit" name="btn" value="Open">
						<input type="button" name="btn" value="Cancel" onclick="document.location='index.cfm'">
					</p>

				</div>
			</div>
		</form>
	</cfoutput>
