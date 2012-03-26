<cfcomponent name="ehUsers" extends="eventHandler">

	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var df = getService("DAOFactory");
			var obj = 0;
			var qryUsers = 0;

			try {
				obj = createObject("component","WebReports.Common.Components.portal.users").init(df);
				qryUsers = obj.searchUsers();
				setValue("qryUsers",qryUsers);
				setView("vwUsers_main");

			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehGeneral.dspStart");
			}
		</cfscript>
	</cffunction>

	<cffunction name="dspEdit" access="public" returntype="void">
		<cfscript>
			var df = getService("DAOFactory");
			var userID = getValue("userID",0);
			var obj = 0;
			var qryUser = 0;
			var qryUserGroups = 0;
			
			try {
				obj = createObject("component","WebReports.Common.Components.portal.users").init(df);
				qryUser = obj.searchUsers(userID);
				qryUserGroups = obj.getUserGroups(userID);

				obj = createObject("component","WebReports.Common.Components.portal.groups").init(df);
				qryGroups = obj.getAll();
				
				setValue("qryUser",qryUser);
				setValue("qryUserGroups",qryUserGroups);
				setValue("qryGroups",qryGroups);
	
				setView("vwUsers_edit");
			
			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehUsers.dspMain");
			}
		</cfscript>
	</cffunction>

	<cffunction name="dspChangePassword" access="public" returntype="void">
		<cfscript>
			var df = getService("DAOFactory");
			var obj = 0;
			var qryUser = getValue("qryUser");
			
			try {
				obj = createObject("component","WebReports.Common.Components.portal.users").init(df);
				qryUser = obj.searchUsers(qryUser.userID);

				setValue("qryUser",qryUser);
				setView("vwChangePassword");
			
			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehGeneral.dspStart");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doSave" access="public" returnType="void">
		<cfscript>
			var df = getService("DAOFactory");
			var userID = getValue("userID","");
			var userName = getValue("username","");
			var firstName = getValue("firstname","");
			var middlename = getValue("middlename","");
			var lastname = getValue("lastname","");
			var password = getValue("password","");
			var isDeveloper = getValue("isDeveloper",false);
			var isAdmin = getValue("isAdmin",false);
			var lstGroups = getValue("lstGroups","");
			
			try {
				obj = createObject("component","WebReports.Common.Components.portal.users").init(df);
				
				// save user
				if(userID eq "") 
					userID = obj.createUser(username, password, firstname, middlename, lastname, isDeveloper, isAdmin);	
				else
					obj.updateUser(userID, firstname, middlename, lastname, isDeveloper, isAdmin, password);
				
				// save groups
				obj.setUserGroups(userID, lstGroups);
				
				setNextEvent("ehUsers.dspMain");
			
			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("ehUsers.dspEdit","userID=#userID#");

			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehUsers.dspEdit","userID=#userID#");
			}
		</cfscript>		
	</cffunction>

	<cffunction name="doDelete" access="public" returntype="void">
		<cfscript>
			var df = getService("DAOFactory");
			var userID = getValue("userID","");
			var obj = 0;
			
			try {
				obj = createObject("component","WebReports.Common.Components.portal.users").init(df);
				obj.deleteUser(userID);
				setNextEvent("ehUsers.dspMain");
				
			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("ehUsers.dspMain");

			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehUsers.dspMain");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doChangePassword" access="public" returntype="void">
		<cfscript>
			var df = getService("DAOFactory");
			var qryUser = getValue("qryUser");
			var oldPassword = getValue("oldPassword","");
			var newPassword = getValue("newPassword","");
			var newPassword2 = getValue("newPassword2","");
			var obj = 0;
			
			try {
				if(newPassword neq newPassword2) throw("Passwords do not match");
				
				obj = createObject("component","WebReports.Common.Components.portal.users").init(df);
				obj.changePassword(qryUser.userID, oldPassword, newPassword);
				setMessage("info", "Your password has been changed");
				setNextEvent("ehGeneral.dspStart");
			
			} catch(validation e) {
				setMessage("warning", e.message);
				setNextEvent("ehUsers.dspChangePassword");

			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehUsers.dspChangePassword");
			}
		</cfscript>
	</cffunction>
</cfcomponent>