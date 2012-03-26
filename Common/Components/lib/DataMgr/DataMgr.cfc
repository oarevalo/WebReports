<!--- 1.2 Build 50 --->
<!--- Last Updated: 2006-08-01 --->
<!--- Created by Steve Bryant 2004-12-08 --->
<cfcomponent displayname="Data Manager" hint="I manage data interactions with the database. I can be used/extended by a component to handle inserts/updates.">

<cffunction name="init" access="public" returntype="DataMgr" output="no" hint="I instantiate and return this object.">
	<cfargument name="datasourceBean" type="any" required="no">
	<cfargument name="final" type="boolean" required="no" default="false">

	<cfif structKeyExists(arguments, "datasourceBean") and not isSimpleValue(arguments.datasourceBean)>
		<cfset variables.datasource = arguments.datasourceBean.getName()>
		<cfset variables.username = arguments.datasourceBean.getUsername()>
		<cfset variables.password = arguments.datasourceBean.getPassword()>

		<cfif not arguments.final>
			<cfset this = CreateObject("component","DataMgr_#arguments.datasourceBean.getDBType()#").init(arguments.datasourceBean, true)>
		</cfif>
	</cfif>
	<cfset variables.tables = StructNew()><!--- Used to internally keep track of tables used by DataMgr --->
	<cfset variables.nocomparetypes = "CF_SQL_LONGVARCHAR"><!--- Don't run comparisons against fields of these cf_datatypes for queries --->
	<cfset variables.dectypes = "CF_SQL_DECIMAL"><!--- Decimal types (shouldn't be rounded by DataMgr) --->
	
	<cfreturn this>
</cffunction>

<cffunction name="addColumn" access="public" returntype="any" output="no" hint="I add a column to the given table">
	<cfargument name="tablename" type="string" required="yes" hint="The name of the table to which a column will be added.">
	<cfargument name="columnname" type="string" required="yes" hint="The name of the column to add.">
	<cfargument name="CF_Datatype" type="string" required="yes" hint="The ColdFusion SQL Datatype of the column.">
	<cfargument name="Length" type="numeric" default="50" hint="The ColdFusion SQL Datatype of the column.">
	<cfargument name="Default" type="string" required="no" hint="The default value for the column.">
	
	<cfset var type = getDBDataType(arguments.CF_Datatype)>
	<cfset var sql = "">
	<cfset var FailedSQL = "">
	
	<cfif arguments.Length eq 0>
		<cfset arguments.Length = 50>
	</cfif>
	
	<cfsavecontent variable="sql"><cfoutput>ALTER TABLE #escape(arguments.tablename)# ADD #escape(arguments.columnname)# #type#<cfif isStringType(type)> (#arguments.Length#)</cfif></cfoutput></cfsavecontent>
	
	<cftry>
		<cfquery datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">#preserveSingleQuotes(sql)#</cfquery>
		<cfcatch>
			<cfset FailedSQL = ListAppend(FailedSQL,sql,";")>
		</cfcatch>
	</cftry>
	
	<cfsavecontent variable="sql"><cfoutput>UPDATE	#escape(arguments.tablename)#	SET	#escape(arguments.columnname)# = #arguments.Default#</cfoutput></cfsavecontent>
	
	<cftry>
		<cfquery datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">#preserveSingleQuotes(sql)#</cfquery>
		<cfcatch>
			<cfset FailedSQL = ListAppend(FailedSQL,sql,";")>
		</cfcatch>
	</cftry>
	
	<cfif Len(FailedSQL)>
		<cfthrow message="Failed to add Column (""#arguments.columnname#"")." type="DataMgr" detail="#FailedSQL#">
	</cfif>
	
</cffunction>

<cffunction name="clean" access="public" returntype="struct" output="no" hint="I return a clean version (stripped of MS-Word characters) of the given structure.">
	<cfargument name="Struct" type="struct" required="yes">
	
	<cfset var key = "">
	
	<cfscript>
	for (Key in Struct) {
		// Trim the field value.
		Struct[Key] = Trim(Struct[Key]);
		// Replace the special characters that Microsoft uses.
		Struct[Key] = Replace(Struct[Key], Chr(8217), Chr(39), "ALL");// apostrophe / single-quote
		Struct[Key] = Replace(Struct[Key], Chr(8216), Chr(39), "ALL");// apostrophe / single-quote
		Struct[Key] = Replace(Struct[Key], Chr(8220), Chr(34), "ALL");// quotes
		Struct[Key] = Replace(Struct[Key], Chr(8221), Chr(34), "ALL");// quotes
		Struct[Key] = Replace(Struct[Key], Chr(8211), "-", "ALL");// dashed
		Struct[Key] = Replace(Struct[Key], Chr(8212), "-", "ALL");// dashed
	}
	</cfscript>
	
	<cfreturn Struct>
</cffunction>

<cffunction name="createTable" access="public" returntype="string" output="no" hint="I take a table for which the structure has been loaded, and create the table in the database.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfset var CreateSQL = getCreateSQL(arguments.tablename)>
	
	<!--- try to create table --->
	<cftry>
		<cfquery datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">#preserveSingleQuotes(CreateSQL)#</cfquery>
		<cfcatch><!--- If the ceation fails, throw an error with the sql code used to create the database. --->
			<cfthrow message="SQL Error in Creation. Verify Datasource (#chr(34)##variables.datasource##chr(34)#) is valid." type="DataMgr" detail="#CreateSQL#" errorcode="CreateFailed">
		</cfcatch>
	</cftry>
	
	<cfreturn CreateSQL>
</cffunction>

<cffunction name="CreateTables" access="public" returntype="void" output="no" hint="I create any tables that I know should exist in the database but don't.">
	<cfargument name="tables" type="string" default="#variables.tables#" hint="I am a list of tables to create. If I am not provided createTables will try to create any table that has been loaded into it but does not exist in the database.">

	<cfset var table = "">
	<cfset var dbtables = "">
	<cfset var tablesExist = StructNew()>
	<cfset var qTest = 0>
	<cfset var FailedSQL = "">
	
	<cftry><!--- Try to get a list of tables load in DataMgr --->
		<cfset dbtables = getDatabaseTables()>
		<cfcatch>
		</cfcatch>
	</cftry>
	
	<cfif Len(dbtables)><!--- If we have tables loaded in DataMgr --->
		<cfloop index="table" list="#arguments.tables#">
			<cfif ListFindNoCase(dbtables, table)>
				<cfset tablesExist[table] = true>
			<cfelse>
				<cfset tablesExist[table] = false><!--- Creatare any table not already loaded in DataMgr --->
			</cfif>
		</cfloop>
	<cfelse><!--- If we don't have tables loaded in DataMgr --->
		<cfloop index="table" list="#arguments.tables#">
			<cfset tablesExist[table] = true>
			<cftry><!--- create any table on which a select statement errors --->
				<cfquery name="qTest" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">SELECT #escape(variables.tables[table][1].ColumnName)# FROM #escape(table)#</cfquery>
				<cfcatch>
					<cfset tablesExist[table] = false>
				</cfcatch>
			</cftry>
		</cfloop>
	</cfif>
	
	<cfloop index="table" list="#arguments.tables#">
		<!--- Create table if it doesn't exist --->
		<cfif NOT tablesExist[table]>
			<cftry>
				<cfset createTable(table)>
				<cfcatch type="DataMgr">
					<cfset FailedSQL = ListAppend(FailedSQL,CFCATCH.Detail,";")>
				</cfcatch>
			</cftry>
		</cfif>
	</cfloop>
	
	<cfif Len(FailedSQL)>
		<cfthrow message="SQL Error in Creation. Verify Datasource (#chr(34)##variables.datasource##chr(34)#) is valid." type="DataMgr" detail="#FailedSQL#" errorcode="CreateFailed">
	</cfif>
	
</cffunction>

<cffunction name="deleteRecord" access="public" returntype="void" output="no" hint="I delete the record with the given Primary Key(s).">
	<cfargument name="tablename" type="string" required="yes" hint="The name of the table from which to delete a record.">
	<cfargument name="data" type="struct" required="yes" hint="A structure indicating the record to delete. A key indicates a field. The structure should have a key for each primary key in the table.">
	
	<cfset var i = 0><!--- just a counter --->
	<cfset var bTable = checkTable(arguments.tablename)>
	<cfset var tabledata = variables.tables[arguments.tablename]><!--- The structure of this table --->
	<cfset var pkfields = getPKFields(arguments.tablename)><!--- the primary key fields for this table --->
	<cfset var in = arguments.data><!--- The incoming data structure --->
	
	<!--- Throw exception if any pkfields are missing from incoming data --->
	<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
		<cfif Not StructKeyExists(in,pkfields[i].ColumnName)>
			<cfthrow errorcode="RequiresAllPkFields" message="All Primary Key fields must be used when deleting a record." type="DataMgr">
		</cfif>
	</cfloop>
	
	<!--- Perform the delete --->
	<cfquery datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	DELETE
	FROM	#escape(arguments.tablename)#
	WHERE	1 = 1<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
		AND	#escape(pkfields[i].ColumnName)# = <cfswitch expression="#pkfields[i].CF_DataType#"><cfcase value="CF_SQL_BIT"><cfif in[pkfields[i].ColumnName]>1<cfelse>0</cfif></cfcase><cfcase value="CF_SQL_DATE">#CreateODBCDateTime(in[pkfields[i].ColumnName])#</cfcase><cfdefaultcase><cfif ListFindNoCase(variables.dectypes,pkfields[i].CF_DataType)>#Val(in[pkfields[i].ColumnName])#<cfelse><cfqueryparam value="#in[pkfields[i].ColumnName]#" cfsqltype="#pkfields[i].CF_DataType#"></cfif></cfdefaultcase></cfswitch>
	</cfloop>
	</cfquery>

</cffunction>

<cffunction name="escape" access="private" returntype="string" output="no" hint="I return an escaped value for a table or field.">
	<cfargument name="name" type="string" required="yes">
	<cfreturn "#arguments.name#">
</cffunction>

<cffunction name="getDatabase" access="public" returntype="string" output="no" hint="I return the database platform being used (Access,MS SQL,MySQL etc).">
	<cfreturn "unknown"><!--- This method will get overridden in database-specific DataMgr components --->
</cffunction>

<cffunction name="getDatabaseShortString" access="public" returntype="string" output="no" hint="I return the string that can be found in the driver or JDBC URL for the database platform being used.">
	<cfreturn "unknown"><!--- This method will get overridden in database-specific DataMgr components --->
</cffunction>

<cffunction name="getDatasource" access="public" returntype="string" output="no" hint="I return the datasource used by this Data Manager.">
	<cfreturn variables.datasource>
</cffunction>

<cffunction name="getDBFieldList" access="public" returntype="string" output="no" hint="I return a list of fields in the database for the given table.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfset var qFields = 0>
	
	<cfquery name="qFields" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT	#getMaxRowsPrefix(1)# *
	FROM	#arguments.tablename#
	#getMaxRowsSuffix(1)#
	</cfquery>
	
	<cfreturn qFields.ColumnList>
</cffunction>

<cffunction name="getFieldList" access="public" returntype="string" output="no" hint="I get a list of fields in the given table.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfset var i = 0>
	<cfset var fieldlist = "">
	<cfset var bTable = checkTable(arguments.tablename)>
	
	<!--- Loop over the fields in the table and make a list of them --->
	<cfif StructKeyExists(variables.tables,arguments.tablename)>
		<cfloop index="i" from="1" to="#ArrayLen(variables.tables[arguments.tablename])#" step="1">
			<cfset fieldlist = ListAppend(fieldlist, variables.tables[arguments.tablename][i].ColumnName)>
		</cfloop>
	</cfif>
	
	<cfreturn fieldlist>
</cffunction>

<cffunction name="getMaxRowsPrefix" access="public" returntype="string" output="no" hint="I get the SQL before the field list in the select statement to limit the number of rows.">
	<cfargument name="maxrows" type="numeric" required="yes">
	
	<cfreturn "TOP #arguments.maxrows# ">
</cffunction>

<cffunction name="getMaxRowsSuffix" access="public" returntype="string" output="no" hint="I get the SQL before the field list in the select statement to limit the number of rows.">
	<cfargument name="maxrows" type="numeric" required="yes">
	
	<cfreturn "">
</cffunction>

<cffunction name="getNewSortNum" access="public" returntype="numeric" output="no">
	<cfargument name="tablename" type="string" required="yes">
	<cfargument name="sortfield" type="string" required="yes" hint="The field holding the sort order.">
	
	<cfset var qLast = 0>
	<cfset var result = 0>
	
	<cfquery name="qLast" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#" maxrows="1">
	SELECT		#getMaxRowsPrefix(1)# #arguments.sortfield#
	FROM		#arguments.tablename#
	ORDER BY	#arguments.sortfield# DESC
	#getMaxRowsSuffix(1)#
	</cfquery>
	
	<cfif qLast.RecordCount and isNumeric(qLast[arguments.sortfield][1])>
		<cfset result = qLast[arguments.sortfield][1] + 1>
	<cfelse>
		<cfset result = 1>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getPKFields" access="public" returntype="array" output="no" hint="I return an array of primary key fields.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfset var i = 0><!--- counter --->
	<cfset var arrFields = ArrayNew(1)><!--- array of primarykey fields --->
	<cfset var bTable = checkTable(arguments.tablename)><!--- Check whether table is loaded --->
	
	<cfloop index="i" from="1" to="#ArrayLen(variables.tables[arguments.tablename])#" step="1">
		<cfif StructKeyExists(variables.tables[arguments.tablename][i],"PrimaryKey") AND variables.tables[arguments.tablename][i].PrimaryKey>
			<cfset ArrayAppend(arrFields, variables.tables[arguments.tablename][i])>
		</cfif>
	</cfloop>
	
	<cfreturn arrFields>
</cffunction>

<cffunction name="getPKFromData" access="public" returntype="string" output="no" hint="I get the primary key of the record matching the given data.">
	<cfargument name="tablename" type="string" required="yes" hint="The table from which to return a primary key.">
	<cfargument name="fielddata" type="struct" required="yes" hint="A structure with the data for the desired record. Each key/value indicates a value for the field matching that key.">
	
	<cfset var qPK = 0><!--- The query used to get the primary key --->
	<cfset var fields = getUpdateableFields(arguments.tablename)><!--- The (non-primarykey) fields for this table --->
	<cfset var pkfields = getPKFields(arguments.tablename)><!--- The primary key field(s) for this table --->
	<cfset var result = 0><!--- The result of this method --->
	<cfset var i = 0><!--- a counter --->
	<cfset var in = arguments.fielddata><!--- The incoming data on which to search --->
	
	<!--- This method is only to be used on fields with one pkfield --->
	<cfif ArrayLen(pkfields) neq 1>
		<cfthrow message="This method can only be used on tables with exactly one primary key field." type="DataMgr" errorcode="NeedOnePKField">
	</cfif>
	<!--- This method can only be used on tables with updateable fields --->
	<cfif Not ArrayLen(fields)>
		<cfthrow message="This method can only be used on tables with updateable fields." type="DataMgr" errorcode="NeedUpdateableField">
	</cfif>
	
	<cfquery name="qPK" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT	#escape(pkfields[1].ColumnName)# AS pkfield
	FROM	#escape(arguments.tablename)#
	WHERE	1 = 1
		<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1"><cfif useField(in,pkfields[i]) AND NOT ListFindNoCase(variables.nocomparetypes,pkfields[i].CF_DataType)>
		AND	#escape(pkfields[i].ColumnName)# = <cfswitch expression="#pkfields[i].CF_DataType#"><cfcase value="CF_SQL_BIT"><cfif in[pkfields[i].ColumnName]>1<cfelse>0</cfif></cfcase><cfcase value="CF_SQL_DATE">#CreateODBCDateTime(in[pkfields[i].ColumnName])#</cfcase><cfdefaultcase><cfif ListFindNoCase(variables.dectypes,pkfields[i].CF_DataType)>#Val(in[pkfields[i].ColumnName])#<cfelse><cfqueryparam value="#in[pkfields[i].ColumnName]#" cfsqltype="#pkfields[i].CF_DataType#"></cfif></cfdefaultcase></cfswitch>
		</cfif></cfloop>
		<cfloop index="i" from="1" to="#ArrayLen(fields)#" step="1"><cfif useField(in,fields[i]) AND NOT ListFindNoCase(variables.nocomparetypes,fields[i].CF_DataType)>
		AND	#escape(fields[i].ColumnName)# = <cfswitch expression="#fields[i].CF_DataType#"><cfcase value="CF_SQL_BIT"><cfif in[fields[i].ColumnName]>1<cfelse>0</cfif></cfcase><cfcase value="CF_SQL_DATE">#CreateODBCDateTime(in[fields[i].ColumnName])#</cfcase><cfdefaultcase><cfif ListFindNoCase(variables.dectypes,fields[i].CF_DataType)>#Val(in[fields[i].ColumnName])#<cfelse><cfqueryparam value="#in[fields[i].ColumnName]#" cfsqltype="#fields[i].CF_DataType#"></cfif></cfdefaultcase></cfswitch>
		</cfif></cfloop>
	</cfquery>
	<cfif qPK.RecordCount eq 1>
		<cfset result = qPK.pkfield>
	<cfelse>
		<cfthrow message="Data Manager: A unique record could not be identified from the given data." type="DataMgr" errorcode="NoUniqueRecord">
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getRecord" access="public" returntype="query" output="no" hint="I get a recordset based on the primary key value(s) given.">
	<cfargument name="tablename" type="string" required="yes" hint="The table from which to return a record.">
	<cfargument name="data" type="struct" required="yes" hint="A structure with the data for the desired record. Each key/value indicates a value for the field matching that key. Every primary key field should be included.">
	
	<cfset var qRecord = 0><!--- The record to return --->
	<cfset var fields = getUpdateableFields(arguments.tablename)>
	<cfset var pkfields = getPKFields(arguments.tablename)>
	<cfset var mypkfield = 0>
	<cfset var fieldcount = 0><!--- count of fields --->
	<cfset var i = 0><!--- A generic counter --->
	<cfset var in = arguments.data>
	<cfset var totalfields = 0><!--- count of fields --->
	
	<!--- Throw exception if any pkfields are missing from incoming data --->
	<!--- <cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
		<cfset mypkfield = pkfields[i].ColumnName>
		<cfif Not StructKeyExists(in,mypkfield)>
			<cfthrow message="All Primary Key fields must be used to retrieve a record." type="DataMgr" errorcode="AllPKFields">
		</cfif>
	</cfloop> --->
	<!--- <cfloop index="mypkfield" list="#pkfields#">
		<cfif Not StructKeyExists(in,mypkfield)>
			<cfthrow message="All Primary Key fields must be used to retrieve a record." type="DataMgr" errorcode="AllPKFields">
		</cfif>
	</cfloop> --->
	
	<!--- Figure count of fields --->
	<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
		<cfif StructKeyExists(in,pkfields[i].ColumnName) AND isOfType(in[pkfields[i].ColumnName],pkfields[i].CF_DataType)>
			<cfset totalfields = totalfields + 1>
		</cfif>
	</cfloop>
	<cfloop index="i" from="1" to="#ArrayLen(fields)#" step="1">
		<cfif StructKeyExists(in,fields[i].ColumnName) AND isOfType(in[fields[i].ColumnName],fields[i].CF_DataType)>
			<cfset totalfields = totalfields + 1>
		</cfif>
	</cfloop>
	
	<!--- Make sure at least one field is passed in --->
	<cfif totalfields eq 0>
		<cfthrow message="The data argument of getRecord must contain at least one field from the #arguments.tablename# table. To get all records, use the getRecords method." type="DataMgr" errorcode="NeedWhereFields">
	</cfif>
	
	<cfset qRecord = getRecords(arguments.tablename,in)>
	
	<cfreturn qRecord>
</cffunction>

<cffunction name="getRecords" access="public" returntype="query" output="no" hint="I get a recordset based on the data given.">
	<cfargument name="tablename" type="string" required="yes" hint="The table from which to return a record.">
	<cfargument name="data" type="struct" required="no" hint="A structure with the data for the desired record. Each key/value indicates a value for the field matching that key.">
	<cfargument name="orderBy" type="string" default="">
	<cfargument name="maxrows" type="numeric" required="no">
	
	<cfset var qRecords = 0><!--- The recordset to return --->
	<cfset var in = StructNew()><!--- holder for incoming data (just for readability) --->
	<cfset var fields = getUpdateableFields(arguments.tablename)><!--- non primary-key fields in table --->
	<cfset var pkfields = getPKFields(arguments.tablename)><!--- primary key fields in table --->
	<cfset var i = 0><!--- Generic counter --->
	
	<cfif StructKeyExists(arguments,"data")>
		<cfset in = arguments.data>
	</cfif>
	
	<cfquery name="qRecords" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT		<cfif StructKeyExists(arguments,"maxrows")>#getMaxRowsPrefix(arguments.maxrows)# </cfif><cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1"><cfif i gt 1>,</cfif>#escape(pkfields[i].ColumnName)#</cfloop>
				<cfloop index="i" from="1" to="#ArrayLen(fields)#" step="1"><cfif ArrayLen(pkfields) OR i gt 1>,</cfif>#escape(fields[i].ColumnName)#</cfloop>
	FROM		#escape(arguments.tablename)#
	WHERE		1 = 1
	<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
		<cfif StructKeyExists(in,pkfields[i].ColumnName) AND isOfType(in[pkfields[i].ColumnName],pkfields[i].CF_DataType)>
		AND		#escape(pkfields[i].ColumnName)# = <cfswitch expression="#pkfields[i].CF_DataType#"><cfcase value="CF_SQL_BIT"><cfif in[pkfields[i].ColumnName]>1<cfelse>0</cfif></cfcase><cfcase value="CF_SQL_DATE">#CreateODBCDate(in[pkfields[i].ColumnName])#</cfcase><cfdefaultcase><cfif ListFindNoCase(variables.dectypes,pkfields[i].CF_DataType)>#Val(in[pkfields[i].ColumnName])#<cfelse><cfqueryparam value="#in[pkfields[i].ColumnName]#" cfsqltype="#pkfields[i].CF_DataType#"></cfif></cfdefaultcase></cfswitch>
		</cfif>
	</cfloop>
	<cfloop index="i" from="1" to="#ArrayLen(fields)#" step="1">
		<cfif useField(in,fields[i]) AND NOT ListFindNoCase(variables.nocomparetypes,fields[i].CF_DataType)>
		AND		#escape(fields[i].ColumnName)# = <cfswitch expression="#fields[i].CF_DataType#"><cfcase value="CF_SQL_BIT"><cfif in[fields[i].ColumnName]>1<cfelse>0</cfif></cfcase><cfcase value="CF_SQL_DATE">#CreateODBCDateTime(in[fields[i].ColumnName])#</cfcase><cfdefaultcase><cfif ListFindNoCase(variables.dectypes,fields[i].CF_DataType)>#Val(in[fields[i].ColumnName])#<cfelse><cfqueryparam value="#in[fields[i].ColumnName]#" cfsqltype="#fields[i].CF_DataType#"></cfif></cfdefaultcase></cfswitch>
		</cfif>
	</cfloop>
	<cfif Len(arguments.orderBy)>
	ORDER BY	#arguments.orderBy#
	<cfelseif StructKeyExists(arguments,"maxrows")>
	ORDER BY	<cfif ArrayLen(pkfields) AND pkfields[1].CF_DataType eq "CF_SQL_INTEGER">#escape(pkfields[1].ColumnName)#<cfelse>#escape(fields[i].ColumnName)#</cfif>
	</cfif>
	<cfif StructKeyExists(arguments,"maxrows")>#getMaxRowsSuffix(arguments.maxrows)#</cfif>
	</cfquery>
	
	<cfreturn qRecords>
</cffunction>

<cffunction name="getStringTypes" access="public" returntype="string" output="no" hint="I return a list of datypes that hold strings / character values."><cfreturn ""></cffunction>

<cffunction name="getSupportedDatabases" access="public" returntype="query" output="no" hint="I return the databases supported by this install of DataMgr.">
	
	<cfset var qComponents = 0>
	<cfset var aComps = ArrayNew(1)>
	<cfset var i = 0>
	<cfset var qDatabases = QueryNew("Database,DatabaseName,shortstring")>
	
	<cfif StructKeyExists(variables,"databases") AND isQuery(variables.databases)>
		<cfset qDatabases = variables.databases>
	<cfelse>
		<cfdirectory action="LIST" directory="#GetDirectoryFromPath(GetCurrentTemplatePath())#" name="qComponents" filter="*.cfc">
		<cfloop query="qComponents">
			<cfif name CONTAINS "DataMgr_">
				<cfset ArrayAppend(aComps,CreateObject("component","#ListFirst(name,'.')#").init())>
				<cfset QueryAddRow(qDatabases)>
				<cfset QuerySetCell(qDatabases, "Database", ReplaceNoCase(ListFirst(name,"."),"DataMgr_","") )>
				<cfset QuerySetCell(qDatabases, "DatabaseName", aComps[ArrayLen(aComps)].getDatabase() )>
				<cfset QuerySetCell(qDatabases, "shortstring", aComps[ArrayLen(aComps)].getDatabaseShortString() )>
			</cfif>
		</cfloop>
		<cfset variables.databases = qDatabases>
	</cfif>

	<cfreturn qDatabases>
</cffunction>

<cffunction name="getTableData" access="public" returntype="struct" output="no" hint="I return information about all of the tables currently loaded into this Data Manager.">
	<cfreturn variables.tables>
</cffunction>

<cffunction name="getUpdateableFields" access="public" returntype="array" output="no" hint="I return an arry of fields that can be updated.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfset var i = 0><!--- counter --->
	<cfset var arrFields = ArrayNew(1)><!--- array of udateable fields --->
	<cfset var bTable = checkTable(arguments.tablename)><!--- Check whether table is loaded --->
	
	<cfloop index="i" from="1" to="#ArrayLen(variables.tables[arguments.tablename])#" step="1">
		<cfif NOT StructKeyExists(variables.tables[arguments.tablename][i],"PrimaryKey") OR NOT variables.tables[arguments.tablename][i].PrimaryKey>
			<cfset ArrayAppend(arrFields, variables.tables[arguments.tablename][i])>
		</cfif>
	</cfloop>
	
	<cfreturn arrFields>
</cffunction>

<cffunction name="insertRecord" access="public" returntype="string" output="no" hint="I insert a record into the given table with the provided data and do my best to return the primary key of the inserted record.">
	<cfargument name="tablename" type="string" required="yes" hint="The table in which to insert data.">
	<cfargument name="data" type="struct" required="yes" hint="A structure with the data for the desired record. Each key/value indicates a value for the field matching that key.">
	<cfargument name="OnExists" type="string" default="insert" hint="The action to take if a record with the given values exists. Possible values: insert (inserts another record), error (throws an error), update (updates the matching record), skip (performs no action).">
	
	<cfset var OnExistsValues = "insert,error,update,skip"><!--- possible values for OnExists argument --->
	<cfset var i = 0><!--- generic counter --->
	<cfset var bTable = checkTable(arguments.tablename)><!--- Check whether table is loaded --->
	<cfset var fieldcount = 0><!--- count of fields --->
	<cfset var tabledata = variables.tables[arguments.tablename]><!--- Get structure for this table --->
	<cfset var fields = getUpdateableFields(arguments.tablename)>
	<cfset var pkfields = getPKFields(arguments.tablename)>
	<cfset var in = StructCopy(arguments.data)><!--- holder for incoming data (just for readability) --->
	<cfset var inPK = StructNew()><!--- holder for incoming pk data (just for readability) --->
	<cfset var qGetRecords = QueryNew('none')>
	<cfset var result = ""><!--- will hold primary key --->
	<cfset var qCheckKey = 0><!--- Used to get primary key --->
	<cfset var bSetGuid = false><!--- Set GUID (SQL Server specific) --->
	<cfset var GuidVar = "GUID"><!--- var to create variable name for GUID (SQL Server specific) --->
	<cfset var inf = "">
	
	<!--- Create GUID for insert SQL Server where the table has on primary key field and it is a GUID --->
	<cfif ArrayLen(pkfields) eq 1 AND pkfields[1].CF_Datatype eq "CF_SQL_IDSTAMP" AND getDatabase() eq "MS SQL" AND NOT StructKeyExists(in,pkfields[1].ColumnName)>
		<cfset bSetGuid = true>
	</cfif>
	
	<!--- Create variable to hold GUID for SQL Server GUID inserts --->
	<cfif bSetGuid>
		<cflock timeout="30" throwontimeout="No" name="DataMgr_GuidNum" type="EXCLUSIVE">
			<!--- %%I cant figure out a way to safely increment the variable to make it unique for a transaction w/0 the use of request scope --->
			<cfif isDefined("request.DataMgr_GuidNum")>
				<cfset request.DataMgr_GuidNum = Val(request.DataMgr_GuidNum) + 1>
			<cfelse>
				<cfset request.DataMgr_GuidNum = 1>
			</cfif>
			<cfset GuidVar = "GUID#request.DataMgr_GuidNum#">
		</cflock>
	</cfif>
	
	<cflock timeout="30" throwontimeout="No" name="DataMgr_Insert_#arguments.tablename#" type="EXCLUSIVE">
		<!--- Check for existing records if an action other than insert should be take if one exists --->
		<cfif arguments.OnExists neq "insert">
			<cfset qGetRecords = getRecords(arguments.tablename,in)><!--- Try to get existing record with given data --->
			
			<!--- If no matching records by all fields, Check for existing record by primary keys --->
			<cfif qGetRecords.RecordCount eq 0>
				<cfif ArrayLen(pkfields)>
					<!--- Load up all primary key fields in temp structure --->
					<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
						<cfif StructKeyHasLen(in,pkfields[i].ColumnName)>
							<cfset inPK[pkfields[i].ColumnName] = in[pkfields[i].ColumnName]>
						</cfif>
					</cfloop>
					<!--- All all primary key fields exist, check for record --->
					<cfif StructCount(inPK) eq ArrayLen(pkfields)>
						<cfset qGetRecords = getRecord(arguments.tablename,inPK)>
					</cfif>
				</cfif>
			</cfif>
		</cfif>
		
		<!--- Check for existing records --->
		<cfif qGetRecords.RecordCount gt 0>
			<cfswitch expression="#arguments.OnExists#">
			<cfcase value="error">
				<cfthrow message="#arguments.tablename#: A record with these criteria already exists." type="DataMgr">
			</cfcase>
			<cfcase value="update">
				<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
					<cfset in[pkfields[i].ColumnName] = qGetRecords[pkfields[i].ColumnName][1]>
				</cfloop>
				<cfset result = updateRecord(arguments.tablename,in)>
				<cfreturn result>
			</cfcase>
			<cfcase value="skip">
				<cfreturn qGetRecords[pkfields[1].ColumnName][1]>
			</cfcase>
			</cfswitch>
		</cfif>
	
		<!--- Insert record --->
		<cfquery name="qCheckKey" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
		<cfif bSetGuid>DECLARE @#GuidVar# uniqueidentifier
		SET @#GuidVar# = NEWID()</cfif>
		INSERT INTO #escape(arguments.tablename)# (
		<!--- Loop through all updateable fields --->
		<cfloop index="i" from="1" to="#ArrayLen(fields)#" step="1">
			<cfif useField(in,fields[i]) OR (StructKeyExists(fields[i],"Default") AND Len(fields[i].Default) AND getDatabase() eq "Access")><!--- Include the field in SQL if it has appropriate data --->
				<cfset fieldcount = fieldcount + 1>
				<cfif fieldcount gt 1>,</cfif><!--- put a comma before every field after the first --->
				#escape(fields[i].ColumnName)#
			</cfif>
		</cfloop>
		<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
			<cfif ( useField(in,pkfields[i]) AND NOT isIdentityField(pkfields[i]) ) OR ( pkfields[i].CF_Datatype eq "CF_SQL_IDSTAMP" AND bSetGuid )><!--- Include the field in SQL if it has appropriate data --->
				<cfset fieldcount = fieldcount + 1>
				<cfif fieldcount gt 1>,</cfif><!--- put a comma before every field after the first --->
				#escape(pkfields[i].ColumnName)#
			</cfif>
		</cfloop>
		)
		VALUES (<cfset fieldcount = 0>
		<!--- Loop through all updateable fields --->
		<cfloop index="i" from="1" to="#ArrayLen(fields)#" step="1">
			<cfif useField(in,fields[i])><!--- Include the field in SQL if it has appropriate data --->
				<cfset checkLength(fields[i],in[fields[i].ColumnName])>
				<cfset fieldcount = fieldcount + 1>
				<cfif fieldcount gt 1>,</cfif><!--- put a comma before every field after the first --->
				<cfswitch expression="#fields[i].CF_DataType#"><cfcase value="CF_SQL_BIT"><cfif in[fields[i].ColumnName]>1<cfelse>0</cfif></cfcase><cfcase value="CF_SQL_DATE">#CreateODBCDateTime(in[fields[i].ColumnName])#</cfcase><cfdefaultcase><cfif ListFindNoCase(variables.dectypes,fields[i].CF_DataType)>#Val(in[fields[i].ColumnName])#<cfelse><cfqueryparam value="#in[fields[i].ColumnName]#" cfsqltype="#fields[i].CF_DataType#"></cfif></cfdefaultcase></cfswitch>
			<cfelseif StructKeyExists(fields[i],"Default") AND Len(fields[i].Default) AND getDatabase() eq "Access">
				<cfset fieldcount = fieldcount + 1>
				<cfif fieldcount gt 1>,</cfif><!--- put a comma before every field after the first --->
				#fields[i].Default#
			</cfif>
		</cfloop>
		<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
			<cfif useField(in,pkfields[i]) AND NOT isIdentityField(pkfields[i])><!--- Include the field in SQL if it has appropriate data --->
				<cfset checkLength(pkfields[i],in[pkfields[i].ColumnName])>
				<cfset fieldcount = fieldcount + 1>
				<cfif fieldcount gt 1>,</cfif><!--- put a comma before every field after the first --->
				<cfswitch expression="#pkfields[i].CF_DataType#"><cfcase value="CF_SQL_BIT"><cfif in[pkfields[i].ColumnName]>1<cfelse>0</cfif></cfcase><cfcase value="CF_SQL_DATE">#CreateODBCDateTime(in[pkfields[i].ColumnName])#</cfcase><cfdefaultcase><cfif ListFindNoCase(variables.dectypes,pkfields[i].CF_DataType)>#Val(in[pkfields[i].ColumnName])#<cfelse><cfqueryparam value="#in[pkfields[i].ColumnName]#" cfsqltype="#pkfields[i].CF_DataType#"></cfif></cfdefaultcase></cfswitch>
			<cfelseif pkfields[i].CF_Datatype eq "CF_SQL_IDSTAMP" AND bSetGuid>
				<cfset fieldcount = fieldcount + 1>
				<cfif fieldcount gt 1>,</cfif><!--- put a comma before every field after the first --->
				@#GuidVar#
			</cfif>
		</cfloop><cfif fieldcount eq 0><cfsavecontent variable="inf"><cfdump var="#in#"></cfsavecontent><cfthrow message="You must pass in at least one field that can be inserted into the database. Fields: #inf#" type="DataMgr" errorcode="NeedInsertFields"></cfif>
		);<cfif bSetGuid>
		SELECT @#GuidVar# AS NewID
		</cfif>
		</cfquery>
	</cflock>
	
	<cfif isDefined("qCheckKey") AND isQuery(qCheckKey) AND qCheckKey.RecordCount AND ListFindNoCase(qCheckKey.ColumnList,"NewID")>
		<cfset result = qCheckKey.NewID>
	</cfif>
	
	<!--- Get primary key --->
	<cfif Len(result) eq 0>
		<cfif ArrayLen(pkfields) AND StructKeyExists(pkfields[1],"Increment") AND isBoolean(pkfields[1].Increment) AND pkfields[1].Increment>
			<cfset result = getInsertedIdentity(arguments.tablename,pkfields[1].ColumnName)>
		<cfelse>
			<cftry>
				<cfset result = getPKFromData(arguments.tablename,in)>
				<cfcatch>
					<cfset result = "">
				</cfcatch>
			</cftry>
		</cfif>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="loadTable" access="public" returntype="void" output="no" hint="I load a table from the database into the DataMgr object.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfset var arrTableStruct = getDBTableStruct(arguments.tablename)>
	<cfset var i = 0>
	
	<cfloop index="i" from="1" to="#ArrayLen(arrTableStruct)#" step="1">
		<cfif StructKeyExists(arrTableStruct[i],"Default") AND Len(arrTableStruct[i]["Default"])>
			<cfset arrTableStruct[i]["Default"] = makeDefaultValue(arrTableStruct[i]["Default"],arrTableStruct[i].CF_DataType)>
		</cfif>
	</cfloop>
	
	<cfset addTable(arguments.tablename,arrTableStruct)>
	
</cffunction>

<cffunction name="loadXML" access="public" returntype="void" output="false" hint="I add table/tables from XML and optionally create tables/columns as needed (I can also load data to a table upon its creation).">
	<cfargument name="xmldata" type="string" required="yes" hint="XML data of tables to load into DataMgr follows. Schema: http://www.bryantwebconsulting.com/cfc/DataMgr.xsd">
	<cfargument name="docreate" type="boolean" default="false" hint="I indicate if the table should be created in the database if it doesn't already exist.">
	<cfargument name="addcolumns" type="boolean" default="false" hint="I indicate if missing columns should be be created.">
	
	<cfscript>
	var MyTables = StructNew();
	var varXML = XmlParse(arguments.xmldata,"no");
	var arrTables = varXML.XmlRoot.XmlChildren;
	var arrData = XmlSearch(varXML, "//data");
	
	var i = 0;
	var j = 0;
	var mytable = 0;
	var thisTable = 0;
	var thisTableName = 0;
	var thisField = 0;
	var tmpStruct = 0;
	
	var tables = "";
	var fields = "";
	var fieldlist = "";
	var qTest = 0;
	
	var colExists = false;
	var arrDbTable = 0;
	
	var FailedSQL = "";
	</cfscript>
	
	<cfscript>
	//  Loop over all root elements in XML
	for (i=1; i lte ArrayLen(arrTables);i=i+1) {
		//  If element is a table and has a name, add it to the data
		if ( arrTables[i].XmlName eq "table" AND StructKeyExists(arrTables[i].XmlAttributes,"name") ) {
			//temp variable to reference this table
			thisTable = arrTables[i];
			//table name
			thisTableName = thisTable.XmlAttributes["name"];
			//  Only add to struct if table doesn't exist or if cols should be altered
			if ( Not StructKeyExists(variables.tables,thisTableName) OR arguments.addcolumns ) {
				//Add to array of tables to add/alter
				MyTables[thisTableName] = ArrayNew(1);
				fields = "";
				//  Loop through fields in table
				for (j=1; j lte ArrayLen(thisTable.XmlChildren);j=j+1) {
					//  If this xml tag is a field
					if ( thisTable.XmlChildren[j].XmlName eq "field" ) {
						thisField = thisTable.XmlChildren[j].XmlAttributes;
						tmpStruct = StructNew();
						//Set ColumnName
						tmpStruct["ColumnName"] = thisField["ColumnName"];
						//Set CF_DataType
						tmpStruct["CF_DataType"] = thisField["CF_DataType"];
						//Set PrimaryKey (defaults to false)
						if ( StructKeyExists(thisField,"PrimaryKey") AND isBoolean(thisField["PrimaryKey"]) AND thisField["PrimaryKey"] ) {
							tmpStruct["PrimaryKey"] = true;
						} else {
							tmpStruct["PrimaryKey"] = false;
						}
						//Set AllowNulls (defaults to true)
						if ( StructKeyExists(thisField,"AllowNulls") AND isBoolean(thisField["AllowNulls"]) AND Not thisField["AllowNulls"] ) {
							tmpStruct["AllowNulls"] = false;
						} else {
							tmpStruct["AllowNulls"] = true;
						}
						//Set length (if it exists and isnumeric)
						if ( StructKeyExists(thisField,"Length") AND isNumeric(thisField["Length"]) AND NOT tmpStruct["CF_DataType"] eq "CF_SQL_LONGVARCHAR" ) {
							tmpStruct["Length"] = Val(thisField["Length"]);
						} else {
							tmpStruct["Length"] = 0;
						}
						//Set increment (if exists and true)
						if ( StructKeyExists(thisField,"Increment") AND isBoolean(thisField["Increment"]) AND thisField["Increment"] ) {
							tmpStruct["Increment"] = true;
						} else {
							tmpStruct["Increment"] = false;
						}
						//Set precision (if exists and true)
						if ( StructKeyExists(thisField,"Precision") AND isNumeric(thisField["Precision"]) ) {
							tmpStruct["Precision"] = Val(thisField["Precision"]);
						} else {
							tmpStruct["Precision"] = "";
						}
						//Set scale (if exists and true)
						if ( StructKeyExists(thisField,"Scale") AND isNumeric(thisField["Scale"]) ) {
							tmpStruct["Scale"] = Val(thisField["Scale"]);
						} else {
							tmpStruct["Scale"] = "";
						}
						//Set default (if exists)
						if ( StructKeyExists(thisField,"Default") AND Len(thisField["Default"]) ) {
							tmpStruct["Default"] = makeDefaultValue(thisField["Default"],tmpStruct["CF_DataType"]);
						}
						//Copy data set in temporary structure to result storage
						if ( NOT ListFindNoCase(fields, tmpStruct["ColumnName"]) ) {
							fields = ListAppend(fields,tmpStruct["ColumnName"]);
							ArrayAppend(MyTables[thisTableName], StructNew());
							MyTables[thisTableName][ArrayLen(MyTables[thisTableName])] = Duplicate(tmpStruct);
						}
					}// /If this xml tag is a field
				}// /Loop through fields in table
			}// /Only add to struct if table doesn't exist or if cols should be altered
		}// /If element is a table and has a name, add it to the data
	}// /Loop over all root elements in XML
	
	//Add tables to DataMgr
	for ( mytable in MyTables ) {
		addTable(mytable,MyTables[mytable]);
	}
	
	//Create tables if requested to do so.
	if ( arguments.docreate ) {
		//Loop over all root elements in XML
		for (i=1; i lte ArrayLen(arrTables);i=i+1) {
			if ( arrTables[i].XmlName eq "table" AND StructKeyExists(arrTables[i].XmlAttributes,"name") ) {
				//Add table to list
				tables = ListAppend(tables,arrTables[i].XmlAttributes["name"]);
			}// /if
		}// /for
		//Try to create the tables, if that fails we'll load up the failed SQL in a variable so it can be returned in a handy lump.
		try {
			CreateTables(tables);
		} catch (DataMgr exception) {
			FailedSQL = ListAppend(FailedSQL,exception.Detail,";");
		}
		
	}// if
	</cfscript>
	<cfif Len(FailedSQL)>
		<cfthrow message="LoadXML Failed" type="DataMgr" detail="#FailedSQL#" errorcode="LoadFailed">
	</cfif>
	<cfscript>
	//Add columns to tables as needed if requested to do so.
	if ( arguments.addcolumns ) {
		//Loop over tables (from XML)
		for ( mytable in MyTables ) {
			//Loop over fields (from XML)
			for ( i=1; i lte ArrayLen(MyTables[mytable]); i=i+1 ) {
				colExists = false;
				//Get tables struct (from DB)
				//arrDbTable = getDBTableStruct(mytable);
				// get list of fields in table
				fieldlist = getDBFieldList(mytable);
				//check for existence of this field
				if ( ListFindNoCase(fieldlist,MyTables[mytable][i].ColumnName) ) {
					colExists = true;
				}
				/*
				//Loop over columns (from DB) and check for existence
				for ( j=1; j lte ArrayLen(arrDbTable); j=j+1 ) {
					//See if field matches
					if ( MyTables[mytable][i].ColumnName eq arrDbTable[j].ColumnName ) {
						colExists = true;
					}
				}
				*/
				//If no match, add column
				if ( NOT colExists ) {
					try {
						if ( StructKeyExists(MyTables[mytable][i],"Default") AND Len(MyTables[mytable][i]["Default"]) ) {
							addColumn(mytable,MyTables[mytable][i].ColumnName,MyTables[mytable][i].CF_DataType,MyTables[mytable][i].Length,MyTables[mytable][i]["Default"]);
						} else {
							addColumn(mytable,MyTables[mytable][i].ColumnName,MyTables[mytable][i].CF_DataType,MyTables[mytable][i].Length);
						}
					} catch (DataMgr exception) {
						FailedSQL = ListAppend(FailedSQL,exception.Detail,";");
					}
				}
			}
		}
	}
	</cfscript>
	<cfif Len(FailedSQL)>
		<cfthrow message="LoadXML Failed" type="DataMgr" detail="#FailedSQL#" errorcode="LoadFailed">
	</cfif>
	<cfscript>
	if ( arguments.docreate ) {
		seedData(varXML,tables);
	}
	</cfscript>
	
</cffunction>

<cffunction name="saveRecord" access="public" returntype="string" output="no" hint="I insert or update a record in the given table (update if a matching record is found) with the provided data and return the primary key of the updated record.">
	<cfargument name="tablename" type="string" required="yes" hint="The table on which to update data.">
	<cfargument name="data" type="struct" required="yes" hint="A structure with the data for the desired record. Each key/value indicates a value for the field matching that key.">
	
	<cfreturn insertRecord(arguments.tablename,arguments.data,"update")>
</cffunction>

<cffunction name="saveRelationList" access="public" returntype="void" output="no" hint="">
	<cfargument name="tablename" type="string" required="yes" hint="The table holding the many-to-many relationships.">
	<cfargument name="keyfield" type="string" required="yes" hint="The field holding our key value for relationships.">
	<cfargument name="keyvalue" type="string" required="yes" hint="The value of out primary field.">
	<cfargument name="multifield" type="string" required="yes" hint="The field holding our many relationships for the given key.">
	<cfargument name="multilist" type="string" required="yes" hint="The list of related values for our key.">
	
	<cfset var bTable = checkTable(arguments.tablename)><!--- Check whether table is loaded --->
	<cfset var getStruct = StructNew()>
	<cfset var setStruct = StructNew()>
	<cfset var qExistingRecords = 0>
	<cfset var item = "">
	<cfset var ExistingList = "">
	
	<!--- Get existing records --->
	<cfset getStruct[arguments.keyfield] = arguments.keyvalue>
	<cfset qExistingRecords = getRecords(arguments.tablename,getStruct)>
	
	<!--- Remove existing records not in list --->
	<cfoutput query="qExistingRecords">
		<cfset ExistingList = ListAppend(ExistingList,qExistingRecords[arguments.multifield][CurrentRow])>
		<cfif NOT ListFindNoCase(arguments.multilist,qExistingRecords[arguments.multifield][CurrentRow])>
			<cfset setStruct = StructNew()>
			<cfset setStruct[arguments.keyfield] = arguments.keyvalue>
			<cfset setStruct[arguments.multifield] = qExistingRecords[arguments.multifield][CurrentRow]>
			<cfset deleteRecord(arguments.tablename,setStruct)>
		</cfif>
	</cfoutput>
	
	<!--- Add records from list that don't exist --->
	<cfloop index="item" list="#arguments.multilist#">
		<cfif NOT ListFindNoCase(ExistingList,item)>
			<cfset setStruct = StructNew()>
			<cfset setStruct[arguments.keyfield] = arguments.keyvalue>
			<cfset setStruct[arguments.multifield] = item>
			<cfset insertRecord(arguments.tablename,setStruct,"skip")>
			<cfset ExistingList = ListAppend(ExistingList,item)><!--- in case list has one item more than once (4/26/06) --->
		</cfif>
	</cfloop>
	
</cffunction>

<cffunction name="saveSortOrder" access="public" returntype="void" output="no">
	<cfargument name="tablename" type="string" required="yes" hint="The table on which to update data.">
	<cfargument name="sortfield" type="string" required="yes" hint="The field holding the sort order.">
	<cfargument name="sortlist" type="string" required="yes" hint="The list of primary key field values in sort order.">
	<cfargument name="PrecedingRecords" type="numeric" default="0" hint="The number of records preceding those being sorted.">
	
	<cfset var bTable = checkTable(arguments.tablename)><!--- Check whether table is loaded --->
	<cfset var pkfields = getPKFields(arguments.tablename)>
	<cfset var i = 0>
	<cfset var keyval = 0>
	
	<cfset arguments.PrecedingRecords = Int(arguments.PrecedingRecords)>
	<cfif arguments.PrecedingRecords lt 0>
		<cfset arguments.PrecedingRecords = 0>
	</cfif>
	
	<cfif ArrayLen(pkfields) neq 1>
		<cfthrow message="This method can only be used on tables with exactly one primary key field." type="DataMgr" errorcode="SortWithOneKey">
	</cfif>
	
	<cfloop index="i" from="1" to="#ListLen(arguments.sortlist)#" step="1">
		<cfset keyval = ListGetAt(arguments.sortlist,i)>
		<cfquery datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
		UPDATE	#escape(arguments.tablename)#
		SET		#escape(arguments.sortfield)# = #Val(i)+arguments.PrecedingRecords#
		WHERE	#escape(pkfields[1].ColumnName)# = <cfswitch expression="#pkfields[1].CF_DataType#"><cfcase value="CF_SQL_BIT"><cfif keyval>1<cfelse>0</cfif></cfcase><cfcase value="CF_SQL_DATE">#CreateODBCDateTime(keyval)#</cfcase><cfdefaultcase><cfif ListFindNoCase(variables.dectypes,pkfields[1].CF_DataType)>#Val(keyval)#<cfelse><cfqueryparam value="#keyval#" cfsqltype="#pkfields[1].CF_DataType#"></cfif></cfdefaultcase></cfswitch>
		</cfquery>
	</cfloop>
	
</cffunction>

<cffunction name="truncate" access="public" returntype="struct" output="no" hint="I return the structure with the values truncated to the limit of the fields in the table.">
	<cfargument name="tablename" type="string" required="yes" hint="The table for which to truncate data.">
	<cfargument name="data" type="struct" required="yes" hint="A structure with the data for the desired record. Each key/value indicates a value for the field matching that key.">
	
	<cfscript>
	var sTables = getTableData();
	var aColumns = sTables[arguments.tablename];
	var i = 0;
	
	for ( i=1; i lte ArrayLen(aColumns); i=i+1 ) {
		if ( StructKeyExists(arguments.data,aColumns[i].ColumnName) ) {
			if ( StructKeyExists(aColumns[i],"Length") AND aColumns[i].Length AND aColumns[i].CF_DataType neq "CF_SQL_LONGVARCHAR" ) {
				arguments.data[aColumns[i].ColumnName] = Left(arguments.data[aColumns[i].ColumnName],aColumns[i].Length);
			}
		}
	}
	</cfscript>
	
	<cfreturn arguments.data>
</cffunction>

<cffunction name="updateRecord" access="public" returntype="string" output="no" hint="I update a record in the given table with the provided data and return the primary key of the updated record.">
	<cfargument name="tablename" type="string" required="yes" hint="The table on which to update data.">
	<cfargument name="data" type="struct" required="yes" hint="A structure with the data for the desired record. Each key/value indicates a value for the field matching that key.">
	
	<cfset var i = 0><!--- generic counter --->
	<cfset var fieldcount = 0><!--- number of fields --->
	<cfset var bTable = checkTable(arguments.tablename)><!--- check if table is loaded --->
	<cfset var tabledata = variables.tables[arguments.tablename]><!--- get structure for this table --->
	<cfset var fields = getUpdateableFields(arguments.tablename)>
	<cfset var pkfields = getPKFields(arguments.tablename)>
	<cfset var in = arguments.data><!--- holds incoming data for ease of use --->
	<cfset var qGetUpdateRecord = 0><!--- used to check for existing record --->
	<cfset var temp = "">
	
	<!--- This method is only to be used on fields with one pkfield --->
	<cfif Not ArrayLen(pkfields)>
		<cfthrow message="This method can only be used on tables with at least one primary key field." type="DataMgr" errorcode="NeedPKField">
	</cfif>
	<!--- Throw exception on any attempt to update a table with no updateable fields --->
	<cfif Not ArrayLen(fields)>
		<cfthrow errorcode="NoUpdateableFields" message="This table does not have any updateable fields." type="DataMgr">
	</cfif>
	<!--- Throw exception if any pkfields are missing from incoming data --->
	<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
		<cfif Not StructKeyExists(in,pkfields[i].ColumnName)>
			<cfthrow errorcode="RequiresAllPkFields" message="All Primary Key fields must be used when updating a record." type="DataMgr">
		</cfif>
	</cfloop>
	
	<!--- Check for existing record --->
	<cfquery name="qGetUpdateRecord" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT	#escape(pkfields[1].ColumnName)#
	FROM	#escape(arguments.tablename)#
	WHERE	1 = 1
	<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
		AND	#escape(pkfields[i].ColumnName)# = <cfswitch expression="#pkfields[i].CF_DataType#"><cfcase value="CF_SQL_BIT"><cfif in[pkfields[i].ColumnName]>1<cfelse>0</cfif></cfcase><cfcase value="CF_SQL_DATE">#CreateODBCDateTime(in[pkfields[i].ColumnName])#</cfcase><cfdefaultcase><cfif ListFindNoCase(variables.dectypes,pkfields[i].CF_DataType)>#Val(in[pkfields[i].ColumnName])#<cfelse><cfqueryparam value="#in[pkfields[i].ColumnName]#" cfsqltype="#pkfields[i].CF_DataType#"></cfif></cfdefaultcase></cfswitch>
	</cfloop>
	</cfquery>
	
	<cfif qGetUpdateRecord.RecordCount eq 0>
		<cfset temp = "">
		<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
			<cfset temp = ListAppend(temp,"#escape(pkfields[i].ColumnName)#=#in[pkfields[i].ColumnName]#")>
		</cfloop>
		<cfthrow errorcode="NoUpdateRecord" message="No record exists for update criteria (#temp#)." type="DataMgr">
	</cfif>

	<cfquery datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	UPDATE	#escape(arguments.tablename)#
		SET
	<cfloop index="i" from="1" to="#ArrayLen(fields)#" step="1">
		<cfif useField(in,fields[i])><!--- Include update if this is valid data --->
			<cfset checkLength(fields[i],in[fields[i].ColumnName])>
			<cfset fieldcount = fieldcount + 1><cfif fieldcount gt 1>,</cfif>
			#escape(fields[i].ColumnName)# = <cfswitch expression="#fields[i].CF_DataType#"><cfcase value="CF_SQL_BIT"><cfif in[fields[i].ColumnName]>1<cfelse>0</cfif></cfcase><cfcase value="CF_SQL_DATE">#CreateODBCDateTime(in[fields[i].ColumnName])#</cfcase><cfdefaultcase><cfif ListFindNoCase(variables.dectypes,fields[i].CF_DataType)>#Val(in[fields[i].ColumnName])#<cfelse><cfqueryparam value="#in[fields[i].ColumnName]#" cfsqltype="#fields[i].CF_DataType#"></cfif></cfdefaultcase></cfswitch>
		<cfelseif isBlankValue(in,fields[i])><!--- Or if it is passed in as empty value and null are allowed --->
			<cfset fieldcount = fieldcount + 1><cfif fieldcount gt 1>,</cfif>
			#escape(fields[i].ColumnName)# = NULL
		</cfif>
	</cfloop><cfif fieldcount eq 0><cfthrow message="You must include at least one field to be updated." type="DataMgr"></cfif><cfset fieldcount = 0>
	WHERE	1 = 1
	<cfloop index="i" from="1" to="#ArrayLen(pkfields)#" step="1">
		AND	#escape(pkfields[i].ColumnName)# = <cfswitch expression="#pkfields[i].CF_DataType#"><cfcase value="CF_SQL_BIT"><cfif in[pkfields[i].ColumnName]>1<cfelse>0</cfif></cfcase><cfcase value="CF_SQL_DATE">#CreateODBCDateTime(in[pkfields[i].ColumnName])#</cfcase><cfdefaultcase><cfif ListFindNoCase(variables.dectypes,pkfields[i].CF_DataType)>#Val(in[pkfields[i].ColumnName])#<cfelse><cfqueryparam value="#in[pkfields[i].ColumnName]#" cfsqltype="#pkfields[i].CF_DataType#"></cfif></cfdefaultcase></cfswitch>
	</cfloop>
	</cfquery>
	
	<cfreturn qGetUpdateRecord[pkfields[1].ColumnName][1]>
</cffunction>

<cffunction name="addTable" access="private" returntype="boolean" output="no" hint="I add a table to the Data Manager.">
	<cfargument name="tablename" type="string" required="yes">
	<cfargument name="fielddata" type="array" required="yes">
	
	<cfset var isTableAdded = false>
	<cfset var i = 0>
	<cfset var j = 0>
	<cfset var hasField = false>
	
	<cfif StructKeyExists(variables.tables,arguments.tablename)>
		<cfloop index="i" from="1" to="#ArrayLen(fielddata)#" step="1">
			<cfset hasField = false>
			<cfloop index="j" from="1" to="#ArrayLen(variables.tables[arguments.tablename])#" step="1">
				<cfif fielddata[i]["ColumnName"] eq variables.tables[arguments.tablename][j]["ColumnName"]>
					<cfset hasField = true>
					<cfset variables.tables[arguments.tablename][j] = fielddata[i]>
				</cfif>
			</cfloop>
			<cfif NOT hasField>
				<cfset ArrayAppend(variables.tables[arguments.tablename],fielddata[i])>
			</cfif>
		</cfloop>
	<cfelse>
		<cfset variables.tables[arguments.tablename] = arguments.fielddata>
	</cfif>
	
	<cfset isTableAdded = true>
	
	<cfreturn isTableAdded>
</cffunction>

<cffunction name="checkLength" access="private" returntype="void" output="no" hint="I check the length of incoming data to see if it can fit in the designated field (making for a more developer-friendly error messages).">
	<cfargument name="field" type="struct" required="yes">
	<cfargument name="data" type="string" required="yes">
	
	<cfif StructKeyExists(field,"Length") AND isNumeric(field.Length) AND field.Length gt 0 AND Len(data) gt field.Length>
		<cfthrow message="The data for '#field.ColumnName#' must be no more than #field.Length# characters in length." type="DataMgr">
	</cfif>
	
</cffunction>

<cffunction name="checkTable" access="private" returntype="boolean" output="no" hint="I check to see if the given table exists in the Datamgr.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfif NOT StructKeyExists(variables.tables,arguments.tablename)>
		<cfthrow message="The table #arguments.tablename# must be loaded into DataMgr before you can use it." type="Datamgr">
	</cfif>
	
	<cfreturn true>
</cffunction>

<cffunction name="getInsertedIdentity" access="private" returntype="numeric" output="no" hint="I get the value of the identity field that was just inserted into the given table.">
	<cfargument name="tablename" type="string" required="yes">
	<cfargument name="identfield" type="string" required="yes">
	
	<cfset var qCheckKey = 0>
	<cfset var result = 0>
	
	<cfquery name="qCheckKey" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT		#getMaxRowsPrefix(1)# #escape(identfield)# AS NewID
	FROM		#escape(arguments.tablename)#
	ORDER BY	#escape(identfield)# DESC
	#getMaxRowsSuffix(1)#
	</cfquery>
	<cfset result = qCheckKey.NewID>
	
	<cfreturn result>
</cffunction>

<cffunction name="isBlankValue" access="private" returntype="boolean" output="no" hint="I see if the given field is passed in as blank and is a nullable field.">
	<cfargument name="Struct" type="struct" required="yes">
	<cfargument name="Field" type="struct" required="yes">
	
	<cfset var Key = arguments.Field.ColumnName>
	<cfset var result = false>
	
	<cfif StructKeyExists(arguments.Struct,Key) AND Field.AllowNulls AND Not Len(arguments.Struct[Key])>
		<cfset result = true>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="isIdentityField" access="private" returntype="boolean" output="no">
	<cfargument name="Field" type="struct" required="yes">
	
	<cfset var result = false>
	
	<cfif StructKeyExists(Field,"Increment") AND Field.Increment>
		<cfset result = true>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="isOfType" access="private" returntype="boolean" output="no" hint="I check if the given value is of the given data type.">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="CF_DataType" type="string" required="yes">
	
	<cfset var datum = arguments.value>
	<cfset var isOK = false>
	
	<cfswitch expression="#arguments.CF_DataType#">
	<cfcase value="CF_SQL_BIT">
		<cfset isOK = isBoolean(datum)>
	</cfcase>
	<cfcase value="CF_SQL_BIGINT,CF_SQL_INTEGER,CF_SQL_DECIMAL,CF_SQL_DOUBLE,CF_SQL_FLOAT,CF_SQL_NUMERIC,CF_SQL_SMALLINT,CF_SQL_TINYINT">
		<cfset isOK = isNumeric(datum)>
	</cfcase>
	<cfcase value="CF_SQL_DATE">
		<cfset isOK = isDate(datum)>
	</cfcase>
	<cfdefaultcase>
		<cfset isOK = true>
	</cfdefaultcase>
	</cfswitch>
	
	<cfreturn isOK>
</cffunction>

<cffunction name="makeDefaultValue" access="private" returntype="string" output="no" hint="I return the value of the default for the given datatype and raw value.">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="CF_DataType" type="string" required="yes">
	
	<cfset var result = Trim(arguments.value)>
	<cfset var type = getDBDataType(arguments.CF_DataType)>
	<cfset var isFunction = true>
	
	<!--- If default isn't a string and is in parens, remove it from parens --->
	<cfif Left(result,1) eq "(" AND Right(result,1) eq ")">
		<cfset result = Mid(result,2,Len(result)-2)>
	</cfif>
	
	<!--- If default is in single quotes, remove it from single quotes --->
	<cfif Left(result,1) eq "'" AND Right(result,1) eq "'">
		<cfset result = Mid(result,2,Len(result)-2)>
		<cfset isFunction = false><!--- Functions aren't in single quotes --->
	</cfif>
	
	<!--- Functions must have an opening paren and end with a closing paren --->
	<cfif isFunction AND NOT (FindNoCase("(", result) AND Right(result,1) eq ")")>
		<cfset isFunction = false>
	</cfif>
	<!--- Functions don't start with a paren --->
	<cfif isFunction AND Left(result,1) eq "(">
		<cfset isFunction = false>
	</cfif>
	
	<!--- boolean values should be stored as one or zero --->
	<cfif arguments.CF_DataType eq "CF_SQL_BIT">
		<cfif isBoolean(result) AND result>
			<cfset result = "1">
		<cfelse>
			<cfset result = "0">
		</cfif>
	</cfif>
	
	<!--- string values that aren't functions, should be in single quotes. --->
	<cfif isStringType(type) AND NOT isFunction>
		<cfset result = ReplaceNoCase(result, "'", "''", "ALL")>
		<cfset result = "'#result#'">
	</cfif>
	
	<cfreturn result>
</cffunction>

<!--- <cffunction name="scale" access="private" returntype="string" output="no">
	<cfargument name="scale" type="string" required="yes">
	
	<cfif isNumeric(arguments.scale)>
		<cfset arguments.scale = Val(arguments.scale)>
		<cfif NOT arguments.scale gt 0>
			<cfset arguments.scale = "">
		</cfif>
	<cfelse>
		<cfset arguments.scale = "">
	</cfif>
	
	
	<cfreturn arguments.scale>
</cffunction> --->

<cffunction name="seedData" access="private" returntype="void" output="no">
	<cfargument name="xmldata" type="any" required="yes" hint="XML data of tables to load into DataMgr follows. Schema: http://www.bryantwebconsulting.com/cfc/DataMgr.xsd">
	<cfargument name="CreatedTables" type="string" required="yes">
	
	<cfset var varXML = arguments.xmldata>
	<cfset var arrData = XmlSearch(varXML, "//data")>
	<cfset var stcData = StructNew()>
	<cfset var tables = "">
	
	<cfset var i = 0>
	<cfset var table = "">
	<cfset var j = 0>
	<cfset var rowElement = 0>
	<cfset var rowdata = 0>
	<cfset var att = "">
	<cfset var k = 0>
	<cfset var fieldElement = 0>
	<cfset var fieldatts = 0>
	<cfset var reldata = 0>
	<cfset var m = 0>
	<cfset var relfieldElement = 0>
	
	<cfset var data = 0>
	<cfset var col = "">
	<cfset var qRecord = 0>
	<cfset var qRecords = 0>
	
	
	<cfif ArrayLen(arrData)>
		<cfscript>
		//  Loop through data elements
		for ( i=1; i lte ArrayLen(arrData); i=i+1 ) {
			//  Get table name
			if ( StructKeyExists(arrData[i].XmlAttributes,"table") ) {
				table = arrData[i].XmlAttributes["table"];
			} else {
				if ( arrData[i].XmlParent.XmlName eq "table" AND StructKeyExists(arrData[i].XmlParent.XmlAttributes,"name") ) {
					table = arrData[i].XmlParent.XmlAttributes["name"];
				}
			}
			if ( NOT ( StructKeyExists(arrData[i].XmlAttributes,"permanentRows") AND isBoolean(arrData[i].XmlAttributes["permanentRows"]) ) ) {
				arrData[i].XmlAttributes["permanentRows"] = false;
			}
			// /Get table name
			if ( ListFindNoCase(arguments.CreatedTables,table) OR arrData[i].XmlAttributes["permanentRows"] ) {
				//  Make sure structure exists for this table
				if ( NOT StructKeyExists(stcData,table) ) {
					stcData[table] = ArrayNew(1);
					tables = ListAppend(tables,table);
				}
				// /Make sure structure exists for this table
				//  Loop through rows
				for ( j=1; j lte ArrayLen(arrData[i].XmlChildren); j=j+1 ) {
					//  Make sure this element is a row
					if ( arrData[i].XmlChildren[j].XmlName eq "row" ) {
						rowElement = arrData[i].XmlChildren[j];
						rowdata = StructNew();
						//  Loop through fields in row tag
						for ( att in rowElement.XmlAttributes ) {
							rowdata[att] = rowElement.XmlAttributes[att];
						}
						// /Loop through fields in row tag
						//  Loop through field tags
						if ( StructKeyExists(rowElement,"XmlChildren") AND ArrayLen(rowElement.XmlChildren) ) {
							//  Loop through field tags
							for ( k=1; k lte ArrayLen(rowElement.XmlChildren); k=k+1 ) {
								fieldElement = rowElement.XmlChildren[k];
								//  Make sure this element is a field
								if ( fieldElement.XmlName eq "field" ) {
									fieldatts = "name,value,reltable,relfield";
									reldata = StructNew();
									//  If this field has a name
									if ( StructKeyExists(fieldElement.XmlAttributes,"name") ) {
										if ( StructKeyExists(fieldElement.XmlAttributes,"value") ) {
											rowdata[fieldElement.XmlAttributes["name"]] = fieldElement.XmlAttributes["value"];
										} else if ( StructKeyExists(fieldElement.XmlAttributes,"reltable") ) {
											if ( NOT StructKeyExists(fieldElement.XmlAttributes,"relfield") ) {
												fieldElement.XmlAttributes["relfield"] = fieldElement.XmlAttributes["name"];
											}
											//  Loop through attributes for related fields
											for ( att in fieldElement.XmlAttributes ) {
												if ( NOT ListFindNoCase(fieldatts,att) ) {
													reldata[att] = fieldElement.XmlAttributes[att];
												}
											}
											// /Loop through attributes for related fields
											if ( ArrayLen(fieldElement.XmlChildren) ) {
												//  Loop through relfield elements
												for ( m=1; m lte ArrayLen(fieldElement.XmlChildren); m=m+1 ) {
													relfieldElement = fieldElement.XmlChildren[m];
													if ( relfieldElement.XmlName eq "relfield" AND StructKeyExists(relfieldElement.XmlAttributes,"name") AND StructKeyExists(relfieldElement.XmlAttributes,"value") ) {
														reldata[relfieldElement.XmlAttributes["name"]] = relfieldElement.XmlAttributes["value"];
													}
												}
												// /Loop through relfield elements
											}
											rowdata[fieldElement.XmlAttributes["name"]] = StructNew();
											rowdata[fieldElement.XmlAttributes["name"]]["reltable"] = fieldElement.XmlAttributes["reltable"];
											rowdata[fieldElement.XmlAttributes["name"]]["relfield"] = fieldElement.XmlAttributes["relfield"];
											rowdata[fieldElement.XmlAttributes["name"]]["reldata"] = reldata;
										}
									}
									// /If this field has a name
								}
								// /Make sure this element is a field
							}
							// /Loop through field tags
						}
						// /Loop through field tags
						ArrayAppend(stcData[table], rowdata);
					}
					// /Make sure this element is a row
				}
				// /Loop through rows
			}
		}
		// /Loop through data elements
		if ( Len(tables) ) {
			//  Loop through tables
			for ( i=1; i lte ListLen(tables); i=i+1 ) {
				table = ListGetAt(tables,i);
				qRecords = getRecords(table);
				//  If table has seed records
				if ( ArrayLen(stcData[table]) AND NOT qRecords.RecordCount ) {
					data = StructNew();
					//  Loop through seed records
					for ( j=1; j lte ArrayLen(stcData[table]); j=j+1 ) {
						//  Loop through fields in table
						for ( col in stcData[table][j] ) {
							//  Simple val?
							if ( isSimpleValue(stcData[table][j][col]) ) {
								data[col] = stcData[table][j][col];
							} else {
								//  Struct?
								if ( isStruct(stcData[table][j][col]) ) {
									//  Get record of related data
									qRecord = getRecords(stcData[table][j][col]["reltable"],stcData[table][j][col]["reldata"]);
									if ( qRecord.RecordCount eq 1 AND ListFindNoCase(qRecord.ColumnList,stcData[table][j][col]["relfield"]) ) {
										data[col] = qRecord[stcData[table][j][col]["relfield"]][1];
									}
								}
								// /Struct?
							}
							// /Simple val?
						}
						// /Loop through fields in table
						if ( StructCount(data) ) {
							insertRecord(table,data,'skip');	
						}
					}
					// /Loop through seed records
				}
				//  If table has seed records
			}
			// /Loop through tables
		}
		</cfscript>
	</cfif>
	
</cffunction>

<cffunction name="StructKeyHasLen" access="private" returntype="numeric" output="no" hint="I check to see if the given key of the given structure exists and has a value with any length.">
	<cfargument name="Struct" type="struct" required="yes">
	<cfargument name="Key" type="string" required="yes">
	
	<cfset var result = false>
	
	<cfif StructKeyExists(arguments.Struct,arguments.Key) AND Len(arguments.Struct[arguments.Key])>
		<cfset result = true>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="useField" access="private" returntype="boolean" output="no" hint="I check to see if the given field should be used in the SQL statement.">
	<cfargument name="Struct" type="struct" required="yes">
	<cfargument name="Field" type="struct" required="yes">
	
	<cfset var result = false>
	
	<cfif StructKeyHasLen(Struct,Field.ColumnName) AND isOfType(Struct[Field.ColumnName],Field.CF_DataType)>
		<cfset result = true>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="getXML" access="public" returntype="string" output="no" hint="I return the XML for the given table or for all loaded tables if none given.">
	<cfargument name="tablename" type="string" required="no">
	
	<cfset var result = "">
	
	<cfset var table = "">
	<cfset var i = 0>
	
	<cfif StructKeyExists(arguments,"tablename")>
		<cfset checkTable(arguments.tablename)><!--- Check whether table is loaded --->
	</cfif>

<cfsavecontent variable="result"><cfoutput>
<tables><cfloop collection="#variables.tables#" item="table"><cfif (StructKeyExists(arguments,"tablename") AND table eq arguments.tablename) OR NOT StructKeyExists(arguments,"tablename")>
	<table name="#table#"><cfloop index="i" from="1" to="#ArrayLen(variables.tables[table])#" step="1">
		<field ColumnName="#variables.tables[table][i].ColumnName#" CF_DataType="#variables.tables[table][i].CF_DataType#"<cfif StructKeyExists(variables.tables[table][i],"PrimaryKey") AND isBoolean(variables.tables[table][i].PrimaryKey) AND variables.tables[table][i].PrimaryKey> PrimaryKey="true"</cfif><cfif StructKeyExists(variables.tables[table][i],"Increment") AND isBoolean(variables.tables[table][i].Increment) AND variables.tables[table][i].Increment> Increment="true"</cfif><cfif StructKeyExists(variables.tables[table][i],"Length") AND isNumeric(variables.tables[table][i].Length) AND variables.tables[table][i].Length gt 0> Length="#Int(variables.tables[table][i].Length)#"</cfif><cfif StructKeyExists(variables.tables[table][i],"Default") AND Len(variables.tables[table][i].Default)> Default="#variables.tables[table][i].Default#"</cfif><cfif StructKeyExists(variables.tables[table][i],"Precision") AND isNumeric(variables.tables[table][i]["Precision"])> Precision="#variables.tables[table][i]["Precision"]#"</cfif><cfif StructKeyExists(variables.tables[table][i],"Scale") AND isNumeric(variables.tables[table][i]["Scale"])> Scale="#variables.tables[table][i]["Scale"]#"</cfif> /></cfloop>
	</table></cfif></cfloop>
</tables>
</cfoutput></cfsavecontent>
	
	<cfreturn result>
</cffunction>

</cfcomponent>