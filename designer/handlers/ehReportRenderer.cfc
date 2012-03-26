<cfcomponent name="ehReportRenderer" extends="ehBase">

	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var oDataSourceBean = getDatasourceBean();
			var oReport = getReport();
			var oReportRenderBean = 0;
			var oReportRenderer = 0;
			var oDataProvider = 0;
			var targetExtension = "";
			var targetContentType = "";
			var out = "";
			var xslHREF = "";
			var exportFileName = "";
			var lstInvalidChars = " ,.,!,@,##,$,%,^,&,*,(,)";

			// These paramenters are used to control the rendering of the report
			var exportTo = getValue("ExportTo","");
			var serverSide = getValue("ServerSide",false);
			var useXSL = getValue("useXSL",true);
			var reportMode = getValue("reportMode","Display");
			var screenWidth = getValue("w",600);
			var screenHeight = getValue("h",400);
			var maxRows = getValue("maxRows",250);
			
			
			try {
				// create the dataProvider object
				// this will be responsible for obtaining the report data
				oDataProvider = getDataProvider();
				
				// Create ReportRenderBean component
				// this bean will store settings used to render the report
				oReportRenderBean = createObject("Component","WebReports.common.components.ReportRenderBean");
				oReportRenderBean.setReportMode( reportMode );
				oReportRenderBean.setExportTo( exportTo );
				oReportRenderBean.setServerSide( serverSide );
				oReportRenderBean.setScreenWidth( screenWidth );
				oReportRenderBean.setScreenHeight( screenHeight );
				oReportRenderBean.setMaxRows( maxRows );


				// Select the apropriate Content Type for the generated output 
				switch(ExportTo) {
					case "Excel":
						TargetExtension = "xls";
						TargetContentType="application/vnd.ms-excel";
						oReportRenderBean.setServerSide(true);
						break;
						
					case "Word":
						TargetExtension = "doc";
						TargetContentType="application/msword";
						oReportRenderBean.setServerSide(true);
						break;
					
					default:
						TargetExtension = "";
						if(serverSide) 
							TargetContentType="text/html";
						else
							TargetContentType="text/xml";
				}
				

				// Create ReportRenderer component
				oReportRenderer = createObject("Component","WebReports.common.components.ReportRenderer");
				oReportRenderer.init(oReport, oReportRenderBean, oDataProvider);


				// generate output
				if(oReportRenderBean.getServerSide())
					out = oReportRenderer.renderHTML();
					
				else {
					if(useXSL) {
						// This is the URL for the XSL document that will
						// transform the data into the report
						xslHREF = "index.cfm?event=ehReportRenderer.dspXSL";
						
						// Copy ReportRenderer object to session so that the XSL 
						// page can use it when called from the browser	
						session.reportRenderer = oReportRenderer;
						
					}
					out = oReportRenderer.renderXML(xslHREF);
				
				}			
				
				

				//  If we are exporting to another file type then set the 
				//	http header to tell the browser to treat the generated
				//	content as an attachment to prompt user to save/open the file --->
				if(ExportTo neq "") {
					exportFileName = ReplaceList(oReport.getTitle(),lstInvalidChars,"");
					exportFileName = exportFileName & "." & TargetExtension;
				}
			
				
				// pass values to view
				setValue("out", trim(out));
				setValue("contentType", targetContentType);
				setValue("exportFileName", exportFileName);
				
					
				// set view
				setLayout("Layout.Clean");
				setView("Report/vwMain");
					
			
			} catch(any e) {
				//getPlugin("logger").logError("Error rendering report HTML", e);
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehReportRenderer.dspError");
			}			
		</cfscript>
	</cffunction>


	<cffunction name="dspXSL" access="public" returntype="void">
		<cfscript>
			var oReportRenderer = 0;
			var out = "";
			
			try {	
				// Get the report renderer from a shared scope
				oReportRenderer = session.reportRenderer;			

				// get output
				out = oReportRenderer.renderXSL();			

				// pass values to view
				setValue("out", trim(out));
					
				// set view
				setLayout("Layout.Clean");
				setView("Report/vwXSL");
								
			} catch(any e) {
				//getPlugin("logger").logError("Error rendering report XSL", e);
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehReportRenderer.dspError");
			}					
		</cfscript>
	</cffunction>


	<cffunction name="dspError" access="public" returntype="void">
		<cfset setLayout("Layout.Clean")>
		<cfset setView("Report/vwError")>
	</cffunction>

</cfcomponent>