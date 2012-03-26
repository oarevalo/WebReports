<cfcomponent displayname="ReportRenderer" hint="I know how to render a report">

	<cfscript>
		variables.oReport = 0;
		variables.oReportRenderBean = 0;
		variables.oDataProvider = 0;
	</cfscript>


	<!----------------------------------->
	<!---	Init					  --->
	<!----------------------------------->
	<cffunction name="init" access="public" returntype="any">
		<cfargument name="report" type="Report" required="true">
		<cfargument name="reportRenderBean" type="ReportRenderBean" required="true">
		<cfargument name="dataProvider" type="dataProvider" required="true">
		<cfset variables.oReport = arguments.report>
		<cfset variables.oReportRenderBean = arguments.reportRenderBean>
		<cfset variables.oDataProvider = arguments.dataProvider>
		<cfreturn this>
	</cffunction>



	<!----------------------------------->
	<!---	renderXML				  --->
	<!----------------------------------->
	<cffunction name="renderXML" access="public" returntype="xml">
		<cfargument name="xslHREF" type="string" required="no" default="">
		
		<cfset var qryReport = 0>
		<cfset var xmlString = "">
		<cfset var xmlDoc = 0>
				
		<!--- get report data as a query --->
		<cfset qryReport = variables.oDataProvider.getData(variables.oReport,
															variables.oReportRenderBean.getMaxRows())>
		
		<!--- Convert query with into an XML string --->
		<cfset xmlString = query2XMLString(qryReport, 
											variables.oReport.getTableName(), 
											variables.oReport.getColumnList(true))>
		
		<!---- Create final xml document --->
		<cfif xslHREF eq "">
			<cfset xmlString = "<?xml version=""1.0"" encoding=""ISO-8859-1""?><report source=""database"">#xmlString#</report>">
		<cfelse>
			<cfset xmlString = "<?xml version=""1.0"" encoding=""ISO-8859-1""?>" & 
								"<?xml-stylesheet type=""text/xsl"" href=""#arguments.xslHREF#""?>" & 
								"<report source=""database"">#xmlString#</report>">
		</cfif>
		<cfset xmlDoc = xmlParse(xmlString)>
		
		<cfreturn xmlDoc>
	</cffunction>



	<!----------------------------------->
	<!---	renderHTML				  --->
	<!----------------------------------->
	<cffunction name="renderHTML" access="public" returntype="string">
		<cfscript>
			var xsl = "";
			var xml = "";
			var out = "";
			
			// if the report is being exported to another format, 
			// then render it as a page based report
			if(variables.oReportRenderBean.getExportTo() neq "")
				variables.oReportRenderBean.setReportMode("Page");

			// Set flag to tell that XSL trasformation is being applied on the server
			variables.oReportRenderBean.setServerSide(true);
		
			// generate XSL document
			xsl = renderXSL();
			
			// generate data in XML format
			xml = renderXML();
			
			// Transform xml data
			out = XmlTransform(xml, xsl);			
		</cfscript>
		<cfreturn out>
	</cffunction>



	<!----------------------------------->
	<!---	renderXSL				  --->
	<!----------------------------------->
	<cffunction name="renderXSL" access="public" returntype="xml">
		<cfset var xmlDoc = xmlNew()>
		<cfset var txtDoc = "">
		<cfset var oReport = 0>
		<cfset var thisReport = 0>
		
		<cfsavecontent variable="txtDoc">
			<cfinclude template="XSL/XSL_Main.cfm">
		</cfsavecontent>
		<cfset xmlDoc = xmlParse(trim(txtDoc))>
		
		<cfreturn xmlDoc>
	</cffunction>



	<!----------------------------------->
	<!---	query2XMLString			  --->
	<!----------------------------------->
	<cffunction name="query2XMLString" access="private" returntype="string">
		<cfargument name="qry" type="query" required="true">
		<cfargument name="recordNodeName" type="string" required="true">
		<cfargument name="fieldNames" type="string" required="true">
	
		<cfscript>
			var oStringBuffer = 0;
			var aColNames = listToArray(arguments.fieldNames);
			var i = 0;
			var j = 0;
			var tmpValue = "";
			 
			// this function transforms an xml returned from SQL into a string
			// create Java StingBuffer Object to optimize string concatentation
			oStringBuffer = createObject("java", "java.lang.StringBuffer");
	
			for(i=1; i lte qry.RecordCount; i=i+1) {
				oStringBuffer.append("<" & arguments.recordNodeName & ">" );
				for(j=1; j lte arrayLen(aColNames);j=j+1) {	
					tmpValue = "<" & aColNames[j] & ">" & xmlFormat(qry[aColNames[j]][i]) & "</" & aColNames[j] & ">";
					oStringBuffer.append(javacast("string",tmpValue));
				}
				oStringBuffer.append("</" & arguments.recordNodeName & ">" );
			}
			
			return oStringBuffer.toString();
		</cfscript>
	</cffunction>
	
</cfcomponent>