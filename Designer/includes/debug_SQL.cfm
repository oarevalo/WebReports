<!--- ViewerMain_SQL
	This page displays the SQL statement used 
	to obtain the data
--->


<!--- Avoid caching this page --->
<cfoutput>
	<cfheader name="Expires" value="#now()#">
	<cfheader name="cache-control" value="no-cache, no-store, must-revalidate">
	<cfheader name="Pragma" value="no-cache">
</cfoutput>	
	
	
<cftry>
<!--- Get the report struct from a shared scope --->
<cfset oReport = session.oReport>

<!--- Generate the SQL statement to obtain the report --->
<cfset stReportSQL = oReport.renderSQL()>
<cfset strSQL = stReportSQL.sql>

<cfoutput>
	<html>
		<head>
			<title>WebReports Viewer</title>
		</head>
		
		<body>
			#ParagraphFormat(ReplaceList(strSQL,
				"GROUPING,SELECT,DISTINCT,FROM,WHERE,GROUP,BY,ORDER,WITH,CUBE,ROLLUP,HAVING,UNION",
				"<strong>GROUPING</strong>,<strong>SELECT</strong>,<strong>DISTINCT</strong>, 
				<strong>FROM</strong>,<strong>WHERE</strong>, 
				<strong>GROUP</strong>,<strong>BY</strong>,
				<strong>ORDER</strong>,<strong>WITH</strong>,
				<strong>CUBE</strong>,<strong>ROLLUP</strong>,
				<strong>HAVING</strong>,<strong>UNION</strong>"))#
		</body>
	</html>	
</cfoutput> 
<cfcatch type="any">
	<cfinclude template="error.cfm">
</cfcatch>
</cftry>

