<cfcomponent extends="dataProvider">

	<cffunction name="get" access="public" returntype="query">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		<cfset var qry = 0>
		<cfset var dsn = variables.oConfigBean.getDSN()>
		<cfset var username = variables.oConfigBean.getUsername()>
		<cfset var password = variables.oConfigBean.getPassword()>
		<cfset var tableName = arguments._mapTableInfo.tableName>
		<cfset var pkName = arguments._mapTableInfo.PKName>
		<cfset var pkType = arguments._mapTableInfo.PKType>
		
		<cfquery name="qry" datasource="#DSN#" username="#username#" password="#password#">
			SELECT *
				FROM `#tableName#`
				WHERE #PKName# = <cfqueryparam cfsqltype="#PKType#" value="#arguments.id#">
		</cfquery>
		<cfreturn qry>
	</cffunction>
	
	<cffunction name="getAll" access="public" returntype="query">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		<cfset var qry = 0>
		<cfset var dsn = variables.oConfigBean.getDSN()>
		<cfset var username = variables.oConfigBean.getUsername()>
		<cfset var password = variables.oConfigBean.getPassword()>
		<cfset var tableName = arguments._mapTableInfo.tableName>

		<cfquery name="qry" datasource="#DSN#" username="#username#" password="#password#">
			SELECT *
				FROM `#tableName#`
		</cfquery>
		
		<cfreturn qry>
	</cffunction>

	<cffunction name="delete" access="public" returntype="void">
		<cfargument name="id" type="numeric" required="true">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		<cfset var qry = 0>
		<cfset var dsn = variables.oConfigBean.getDSN()>
		<cfset var username = variables.oConfigBean.getUsername()>
		<cfset var password = variables.oConfigBean.getPassword()>
		<cfset var tableName = arguments._mapTableInfo.tableName>
		<cfset var pkName = arguments._mapTableInfo.PKName>
		<cfset var pkType = arguments._mapTableInfo.PKType>
		
		<cfquery name="qry" datasource="#DSN#" username="#username#" password="#password#">
			DELETE FROM `#tableName#`
				WHERE #PKName# = <cfqueryparam cfsqltype="#PKType#" value="#arguments.id#">
		</cfquery>
	</cffunction>
				
	<cffunction name="save" access="public" returntype="any">
		<cfargument name="id" type="any" required="false" default="0">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">

		<cfscript>
			var stTblColumns = arguments._mapColumns;
			var stTableInfo = arguments._mapTableInfo;
			var stColumns = structNew();
			var arg = "";
			var theID = arguments.id;
			var pkName = arguments._mapTableInfo.PKName;

			structDelete(arguments, pkName, false);
			structDelete(arguments, "_mapTableInfo", false);
			structDelete(arguments, "_mapColumns", false);

			for(arg in arguments) {
				if(structKeyExists(stTblColumns,arg)) {
					stColumns[arg] = duplicate(stTblColumns[arg]);
					stColumns[arg].value = arguments[arg];
				} 
			}

			if(val(theID) eq 0)
				theID = _insert(stColumns, stTableInfo);
			else
				_update(theID, stColumns, stTableInfo);
		</cfscript>		

		<cfreturn theID>
	</cffunction>
	
	<cffunction name="search" returntype="query" access="public">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		<cfargument name="_mapColumns" type="struct" required="true">
		<cfset var qry = 0>		
		<cfset var key = "">
		<cfset var dsn = variables.oConfigBean.getDSN()>
		<cfset var username = variables.oConfigBean.getUsername()>
		<cfset var password = variables.oConfigBean.getPassword()>
		<cfset var tableName = arguments._mapTableInfo.tableName>
		<cfset var stColumns = arguments._mapColumns>
	
		<cfquery name="qry" datasource="#DSN#" username="#username#" password="#password#">
			SELECT *
			FROM `#tableName#`
			WHERE (1=1)
				<cfloop collection="#arguments#" item="key">
					<cfif structKeyExists(stColumns,key)>
						<cfif stColumns[key].cfsqltype eq "cf_sql_varchar">
							and #key# LIKE <cfqueryparam cfsqltype="#stColumns[key].cfsqltype#" value="#arguments[key]#">
						<cfelse>
							and #key# = <cfqueryparam cfsqltype="#stColumns[key].cfsqltype#" value="#arguments[key]#">
						</cfif>
					</cfif>
				</cfloop>
		</cfquery>

		<cfreturn qry>
	</cffunction>


	<!---- Private Methods ---->			
	<cffunction name="_insert" access="private" returntype="any">
		<cfargument name="columns" required="true" type="struct">
		<cfargument name="_mapTableInfo" type="struct" required="true">

		<cfset var qry = 0>
		<cfset var i = 1>
		<cfset var col = "">
		<cfset var dsn = variables.oConfigBean.getDSN()>
		<cfset var username = variables.oConfigBean.getUsername()>
		<cfset var password = variables.oConfigBean.getPassword()>
		<cfset var dbtype = variables.oConfigBean.getDBType()>
		<cfset var lstFields = structKeyList(arguments.columns)>
		<cfset var tableName = arguments._mapTableInfo.tableName>
		<cfset var isCF8 = (
								findNoCase(server.ColdFusion.ProductName, "ColdFusion")
								and left(server.ColdFusion.ProductVersion,1) eq "8"
							)>

		<cfquery name="qry" datasource="#DSN#" username="#username#" password="#password#">
			INSERT INTO `#tableName#` (#lstFields#)
				VALUES (
					<cfloop list="#lstFields#" index="col">
						<cfqueryparam cfsqltype="#arguments.columns[col].cfsqltype#" 
										value="#arguments.columns[col].value#" 
										null="#arguments.columns[col].isNull#">
						<cfif i neq listLen(lstFields)>,</cfif>
						<cfset i = i + 1>
					</cfloop>
				)
		</cfquery>		

		<cfif not isCF8>
			<cfquery name="qry" datasource="#DSN#" username="#username#" password="#password#" result="qryInfo">
				<cfswitch expression="#dbtype#">
					<cfcase value="mysql">
						SELECT LAST_INSERT_ID() AS lastID
					</cfcase>
					<cfcase value="mssql">
						SELECT SCOPE_IDENTITY() AS lastID
					</cfcase>
				</cfswitch>
			</cfquery>		
		<cfelse>
			<cfswitch expression="#dbtype#">
				<cfcase value="mysql">
					<cfset newID = qryInfo.generated_key>
				</cfcase>
				<cfcase value="mssql">
					<cfset newID = qryInfo.identitycol>
				</cfcase>		
			</cfswitch>		
		</cfif>
		
		<cfreturn qry.lastID>
	</cffunction>			

	<cffunction name="_update" access="private">
		<cfargument name="id" type="any" required="true">
		<cfargument name="columns" required="true" type="struct">
		<cfargument name="_mapTableInfo" type="struct" required="true">
		
		<cfset var i = 1>
		<cfset var qry = 0>
		<cfset var dsn = variables.oConfigBean.getDSN()>
		<cfset var username = variables.oConfigBean.getUsername()>
		<cfset var password = variables.oConfigBean.getPassword()>
		<cfset var dbtype = variables.oConfigBean.getDBType()>
		<cfset var lstFields = structKeyList(arguments.columns)>
		<cfset var tableName = arguments._mapTableInfo.tableName>
		<cfset var pkName = arguments._mapTableInfo.PKName>
		<cfset var pkType = arguments._mapTableInfo.PKType>
		
		<cfquery name="qry" datasource="#DSN#" username="#username#" password="#password#">
			UPDATE `#tableName#`
				SET
					<cfloop collection="#arguments.columns#" item="col">
						#col# = <cfqueryparam cfsqltype="#arguments.columns[col].cfsqltype#" value="#arguments.columns[col].value#" null="#arguments.columns[col].isNull#">
						<cfif i neq listLen(lstFields)>,</cfif>
						<cfset i = i + 1>
					</cfloop>
				WHERE
					 #PKName# = <cfqueryparam cfsqltype="#PKType#" value="#arguments.id#">			
		</cfquery>
	</cffunction>			
					
	
</cfcomponent>