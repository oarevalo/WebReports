<cfparam name="selectedState" default="">
<cfscript>
	// get the report
	oReport = createObject("component","WebReports.common.components.Report").init();
	oReport.open("/WebReports/SampleReports/customerListing.xml");


	// if an state has been applied, then add it to the report as a filter
	if(selectedState neq "") {
		oReport.addFilter(ColumnName = "state",
							relation = "=",
							value = selectedState,
							type = "string");
	}

	
	// create datasource
	oDataSourceBean = createObject("component","WebReports.common.components.datasource").init();
	oDataSourceBean.setName("webreportsdemo");


	// create data provider
	oDataProvider = createObject("component","WebReports.common.components.DBDataProvider").init( oDataSourceBean );


	// get the available values for the 'State' column so that we can build our filter control
	qryStates = oDataProvider.getValuesByColumn("state", oReport.getTableName(), 999);
	

	// Create ReportRenderBean component
	oReportRenderBean = createObject("Component","WebReports.common.components.ReportRenderBean");
	oReportRenderBean.setScreenWidth(800);
	oReportRenderBean.setScreenHeight(400);


	// Create ReportRenderer component
	oReportRenderer = createObject("Component","WebReports.common.components.ReportRenderer");
	oReportRenderer.init(oReport, oReportRenderBean, oDataProvider);


	// put renderer on session scope so that it can be accessed by the renderXML and renderXSL templates	
	session.oReportRenderer = oReportRenderer;
</cfscript>

<html>
	<head>
		<title>WebReports :: Embedding Sample</title>
	</head>
	<body>
		<h1>ACME Company Reports Page</h1>
		
		<p>
			This example shows how you can display reports within existing applications
			without forcing your users to go into the WebReports Viewer.
		</p>

		<p align="center">
			Filter By State:
			<select name="state" onchange="document.location='index.cfm?selectedState='+this.value">
				<option value="">--- All ---</option>
				<cfoutput query="qryStates">
					<option value="#qryStates.item#" <cfif selectedState eq qryStates.item>selected</cfif>>#qryStates.item#</option>
				</cfoutput>
			</select><br><br>
			<iframe align="center" frameborder="1" src="reportXML.cfm" style="width:800px;height:400px;"></iframe>
		</p>
	</body>
</html>