<cfcomponent name="users" extends="layerSuperType">
	
	<cffunction name="checkLogin" access="public" returnType="query">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">

		<cfreturn getDAOFactory().getDAO("users").search(username = arguments.username,
															password = arguments.password)>
	</cffunction>

	<cffunction name="searchUsers" access="public" returnType="query">
		<cfargument name="userID" type="string" required="false" default="">
		<cfargument name="username" type="string" required="false" default="">
		<cfargument name="lastname" type="string" required="false" default="">
		
		<cfset var qry = 0>
		
		<cfif arguments.userID gt 0>
			<cfset qry = getDAOFactory().getDAO("users").get(arguments.userID)>
		<cfelse>
			<cfset qry = getDAOFactory().getDAO("users").search(username = "%" & arguments.username & "%",
																lastname = "%" & arguments.lastname & "%")>
		</cfif>

		<cfquery name="qry" dbtype="query">
			SELECT *
				FROM qry
				ORDER BY lastName, userName
		</cfquery>

		<cfreturn qry>
	</cffunction>
		
	<cffunction name="createUser" access="public" returnType="string">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfargument name="firstName" type="string" required="true">
		<cfargument name="middleName" type="string" required="true">
		<cfargument name="lastName" type="string" required="true">
		<cfargument name="isDeveloper" type="string" required="true">
		<cfargument name="isAdmin" type="string" required="true">
		
		<cfif trim(arguments.username) eq "">
			<cfthrow message="Username cannot be blank" type="validation.blankUsername">
		</cfif>
		<cfset validatePassword(arguments.password)>
		
		<cfset arguments.createdDate = now()>
		<cfreturn getDAOFactory().getDAO("users").save(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="updateUser" access="public">
		<cfargument name="userID" type="string" required="true">
		<cfargument name="firstName" type="string" required="true">
		<cfargument name="middleName" type="string" required="true">
		<cfargument name="lastName" type="string" required="true">
		<cfargument name="isDeveloper" type="string" required="true">
		<cfargument name="isAdmin" type="string" required="true">
		<cfargument name="password" type="string" required="true">
		<cfset arguments.id = arguments.userID>
		<cfset validatePassword(arguments.password)>
		<cfset getDAOFactory().getDAO("users").save(argumentCollection = arguments)>
	</cffunction>

	<cffunction name="deleteUser" access="public">
		<cfargument name="userID" type="string" required="true">
		<cfset getDAOFactory().getDAO("users").delete(arguments.userID)>
	</cffunction>

	<cffunction name="changePassword" access="public">
		<cfargument name="userID" type="string" required="true">
		<cfargument name="oldPassword" type="string" required="true">
		<cfargument name="newPassword" type="string" required="true">
		
		<cfset var qry = getDAOFactory().getDAO("users").search(userID = arguments.userID,
																password = arguments.oldPassword)>
		
		<cfif qry.recordCount gt 0>

			<cfif trim(arguments.newPassword) eq "">
				<cfthrow message="Password cannot be blank" type="validation.blankPassword">
			</cfif>
			<cfif len(trim(arguments.newPassword)) lt 5>
				<cfthrow message="Password must be at least 5 characters long" type="validation.invalidPassword">
			</cfif>

			<cfset getDAOFactory().getDAO("users").save(id = arguments.userID,
														password = arguments.newPassword)>
		<cfelse>
			<cfthrow message="Incorrect password" type="webReports.portal.invalidPassword">
		</cfif>													
	</cffunction>

	<cffunction name="setUserGroups" access="public">
		<cfargument name="userID" type="string" required="true">
		<cfargument name="lstGroupID" type="string" required="true">
		
		<cfset var userGroupsDAO = 0>
		<cfset var qryUserGroups = 0>
		<cfset var groupID = 0>

		<cfset userGroupsDAO = getDAOFactory().getDAO("userGroups")>
		<cfset qryUserGroups = userGroupsDAO.search(userID = arguments.userID)>
		
		<cfloop query="qryUserGroups">
			<cfset userGroupsDAO.delete(qryUserGroups.userGroupID)>
		</cfloop>
		
		<cfloop list="#arguments.lstGroupID#" index="groupID">
			<cfset userGroupsDAO.save(userID = arguments.userID,
										groupID = groupID)>
		</cfloop>
	</cffunction>
	
	<cffunction name="getUserGroups" access="public" returnType="query">
		<cfargument name="userID" type="string" required="true">
		<cfset var qry = 0>
		<cfset var qryUserGroups = 0>
		<cfset var qryGroups = 0>
		
		<cfset qryUserGroups = getDAOFactory().getDAO("userGroups").search(userID = arguments.userID)>
		<cfset qryGroups = getDAOFactory().getDAO("groups").getAll()>
		
		<cfquery name="qry" dbtype="query">
			SELECT qryGroups.*
				FROM qryUserGroups, qryGroups
				WHERE qryUserGroups.groupID = qryGroups.GroupID
		</cfquery>
		
		<cfreturn qry>
	</cffunction>

	<cffunction name="validatePassword" access="private" returntype="boolean">
		<cfargument name="password" type="string" required="true">
		<cfif trim(arguments.password) eq "">
			<cfthrow message="Password cannot be blank" type="validation.blankPassword">
		</cfif>
		<cfif len(trim(arguments.password)) lt 5>
			<cfthrow message="Password must be at least 5 characters long" type="validation.invalidPassword">
		</cfif>
		<cfreturn true>
	</cffunction>
</cfcomponent>