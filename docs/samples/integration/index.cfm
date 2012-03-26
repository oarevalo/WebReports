
<!--- do a very basic check to see if the user has logged in --->
<cfif not StructKeyExists(session,"username") or session.username  eq "">
	<cflocation url="login.cfm" addtoken="false">
</cfif>

<html>
	<head>
		<title>WebReports :: App Integration Sample</title>
	</head>
	<body>
		<h1>ACME Company Reports Page</h1>
		
		<p>
			<cfoutput>
				Welcome <strong>#session.username#</strong>,<br>
				You are logged in with user type: <strong>#session.role#</strong>.
			</cfoutput>
		</p>
		
		<p>
			The following are the reports you are authorized to see. Please select from the list
			to open the report.
		</p>
		<ul>
			<li><a href="openReport.cfm?report=sales.xml">Sales 2006</a> <cfif session.role eq "sales">(not authorized)</cfif></li>
			<li><a href="openReport.cfm?report=sales.xml">Sales 2007</a> <cfif session.role eq "sales">(not authorized)</cfif></li>
			<li><a href="openReport.cfm?report=sales.xml">Sales 2008</a> <cfif session.role eq "sales">(not authorized)</cfif></li>
			<li><a href="openReport.cfm?report=customerListing.xml">Customer Listing</a></li>
		</ul>
		<br><br>
		<a href="logout.cfm">Logout</a>
	</body>
</html>