<cfparam name="username" default="">
<cfparam name="password" default="">

<cfif isDefined("btnLogin")>
	<cfif username eq "admin" and password eq "admin"
			or username eq "sales" and password eq "sales">

		<!--- initialize authenticated session for this user --->
		<cfset session.username = username>
		<cfset session.userKey = createUUID()>
		<cfif username eq "admin">
			<cfset session.role = "manager">	
		<cfelseif username eq "sales">
			<cfset session.role = "sales">	
		<cfelse>
			<cfset session.role = "">	
		</cfif>

		<!--- keep a registry of the authorized sessions on the application scope for easy access --->
		<cfset application.currentSessions[session.userKey] = structNew()>
		<cfset application.currentSessions[session.userKey].username = session.username>
		<cfset application.currentSessions[session.userKey].role = session.role>
		<cfset application.currentSessions[session.userKey].loginTime = now()>
		
		<!--- redirect to main page --->
		<cflocation url="index.cfm" addtoken="true">
	<cfelse>
		<b style="color:red;">Invalid username/password!</b>
	</cfif>
</cfif>


<html>
	<head>
		<title>WebReports :: App Integration Sample</title>
	</head>
	<body>
		<h1>ACME Company Reports Page</h1>
		
		<p>
			Please enter your username and password
		</p>
		<form name="frmLogin" action="login.cfm" method="post">
			<cfoutput>
				Username: <input type="text" name="username" value="#username#"> <br />
				Password: <input type="password" name="password" value="#password#"> <br />
			</cfoutput>
			<br />
			<input type="submit" name="btnLogin" value="Login">
			<br><br>
			<strong>Hint:</strong> <br>
				Manager: username is <b>admin</b>, password is <b>admin</b><br>
				Sales: username is <b>sales</b>, password is <b>sales</b><br>
		</form>
	</body>
</html>
