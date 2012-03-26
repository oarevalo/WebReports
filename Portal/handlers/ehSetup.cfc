<cfcomponent extends="eventHandler">
	
	<cffunction name="dspCreateAdmin" access="public" returntype="void">
		<cfset session.userID = 0>
		<cfset session.qryUser = queryNew("")>
		<cfset setView("vwCreateAdmin")>
	</cffunction>

	<cffunction name="doCreateAdmin" access="public" returntype="void">
		<cfscript>
			var userID = 0;
			var df = getService("DAOFactory");
			var userName = getValue("username","");
			var firstName = getValue("firstname","");
			var middlename = getValue("middlename","");
			var lastname = getValue("lastname","");
			var password = getValue("password","");
			var password2 = getValue("password","");

			var obj = createObject("component","WebReports.Common.Components.portal.users").init(df);

			try {
				// do some basic validation
				if(password neq password2) throw("validation","Passwords do not match");
	
				// create user			
				userID = obj.createUser(username, password, firstname, "", lastname, 1, 1);	
				
				// set this user as the logged in user
				if(userID gt 0) {
					qryUser = obj.checkLogin(username, password);
					session.userID = qryUser.userID;
					session.qryUser = qryUser;
					session.userKey = createUUID();

					// keep a registry of the authorized sessions on the application scope for easy access
					application.currentSessions[session.userKey] = structNew();
					application.currentSessions[session.userKey].userID = qryUser.userID;
					application.currentSessions[session.userKey].loginTime = now();
				} else {
					throw("error","User could not be created!");
				}

				// do a sync with the repo dir (most likely this is the first use)
				if( getSetting("reportRepositoryPath") neq "" ) {
					obj = createObject("component","WebReports.Common.Components.portal.reportLibrary").init(df);
					obj.importDir( getSetting("reportRepositoryPath") );				
				}

				setMessage("info","Administrator user created!");
				setNextEvent("ehGeneral.dspStart");
			
			} catch(validation e) {
				setMessage("warning",e.message);
				setNextEvent("ehSetup.dspCreateAdmin");

			} catch(any e) {
				setMessage("error",e.message);
				setNextEvent("ehSetup.dspCreateAdmin");
			}

		</cfscript>		

	</cffunction>
	
</cfcomponent>