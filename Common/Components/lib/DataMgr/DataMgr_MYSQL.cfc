<!--- 1.2 Build 50 --->
<!--- Last Updated: 2006-08-01 --->
<!--- Created by Steve Bryant 2004-12-08 --->
<cfcomponent extends="DataMgr" displayname="Data Manager for MySQL" hint="I manage data interactions with the MySQL database. I can be used/extended by a component to handle inserts/updates.">

<cffunction name="getDatabase" access="public" returntype="string" output="no" hint="I return the database platform being used (Access,MS SQL,MySQL etc).">
	<cfreturn "MySQL">
</cffunction>

<cffunction name="getDatabaseShortString" access="public" returntype="string" output="no" hint="I return the string that can be found in the driver or JDBC URL for the database platform being used.">
	<cfreturn "mysql">
</cffunction>

<cffunction name="getCreateSQL" access="public" returntype="string" output="no" hint="I return the SQL to create the given table.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfset var i = 0><!--- generic counter --->
	<cfset var arrFields = variables.tables[arguments.tablename]><!--- table structure --->
	<cfset var CreateSQL = ""><!--- sql to create table --->
	<cfset var pkfields = "">
	<cfset var thisField = "">
	
	<!--- Find Primary Key fields --->
	<cfloop index="i" from="1" to="#ArrayLen(arrFields)#" step="1">
		<cfif arrFields[i].PrimaryKey>
			<cfset pkfields = ListAppend(pkfields,arrFields[i].ColumnName)>
		</cfif>
	</cfloop>
	
	<!--- Create sql to create table --->
	<cfsavecontent variable="CreateSQL"><cfoutput>
	CREATE TABLE #arguments.tablename# (<cfloop index="i" from="1" to="#ArrayLen(arrFields)#" step="1">
		#arrFields[i].ColumnName# #getDBDataType(arrFields[i].CF_DataType)#<cfif isStringType(getDBDataType(arrFields[i].CF_DataType))> (<cfif StructKeyExists(arrFields[i],"Length") AND isNumeric(arrFields[i].Length) AND arrFields[i].Length gt 0>#arrFields[i].Length#<cfelse>50</cfif>)</cfif><cfif StructKeyExists(arrFields[i],"Increment") AND arrFields[i].Increment> AUTO_INCREMENT</cfif><cfif StructKeyExists(arrFields[i],"Default")> DEFAULT #arrFields[i].Default#</cfif> <cfif ListFindNoCase(pkfields,arrFields[i].ColumnName) OR Not arrFields[i].AllowNulls>NOT </cfif>NULL ,</cfloop>
		primary key (#pkfields#)
	)
	</cfoutput></cfsavecontent>
	
	<cfreturn CreateSQL>
</cffunction>

<cffunction name="escape" access="private" returntype="string" output="yes" hint="I return an escaped value for a table or field.">
	<cfargument name="name" type="string" required="yes">
	<cfreturn "`#arguments.name#`">
</cffunction>

<cffunction name="getDatabaseTables" access="public" returntype="string" output="yes" hint="I get a list of all tables in the current database.">

	<cfset var qTables = 0>
	<cfset var tables = "">

	<cfquery name="qTables" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SHOW TABLES
	</cfquery>

	<cfoutput query="qTables">
		<cfset tables = ListAppend(tables,qTables[ListFirst(qTables.ColumnList)][CurrentRow])>
	</cfoutput>
	
	<cfreturn tables>
</cffunction>

<cffunction name="getDBTableStruct" access="public" returntype="array" output="no" hint="I return the structure of the given table in the database.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfscript>
	var qTable = 0;
	var qFields = 0;
	var qPrimaryKeys = 0;
	var PrimaryKeys = 0;
	var TableData = ArrayNew(1);
	var tmpStruct = StructNew();
	</cfscript>
	
	<cfquery name="qTable" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SHOW TABLES LIKE '#arguments.tablename#'
	</cfquery>
	<cfif qTable.RecordCount eq 0>
		<cfthrow message="Data Manager: No such table. Trying to load a table that doesn't exist." type="DataMgr">
	</cfif>
	<cfquery name="qFields" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SHOW COLUMNS FROM #arguments.tablename#
	</cfquery>
	<cfoutput query="qFields">
		<cfif Key eq "PRI">
			<cfset PrimaryKeys = ListAppend(PrimaryKeys,"field")>
		</cfif>
	</cfoutput>
	
	<cfoutput query="qFields">
		<cfset tmpStruct = StructNew()>
		<cfset tmpStruct["ColumnName"] = Field>
		<cfset tmpStruct["CF_DataType"] = getCFDataType(Trim(ListFirst(type,"(")))>
		<cfif Extra eq "auto_increment">
			<cfset tmpStruct["Increment"] = True>
		</cfif>
		<cfif Key eq "PRI">
			<cfset tmpStruct["PrimaryKey"] = true>
		</cfif>
		<cfif isStringType(type) AND NOT tmpStruct["CF_DataType"] eq "CF_SQL_LONGVARCHAR">
			<cfset tmpStruct["length"] = getLength(type)>
		</cfif>
		<cfif NULL eq "Yes">
			<cfset tmpStruct["AllowNulls"] = true>
		<cfelse>
			<cfset tmpStruct["AllowNulls"] = false>
		</cfif>
		<cfif Len(Default)>
			<cfset tmpStruct["Default"] = Default>
		</cfif>
		<cfset tmpStruct["Precision"] = "">
		<cfset tmpStruct["Scale"] = "">
		
		<cfset ArrayAppend(TableData,StructCopy(tmpStruct))>
	</cfoutput>
	
	<cfreturn TableData>
</cffunction>

<cffunction name="getCFDataType" access="public" returntype="string" output="no" hint="I return the cfqueryparam datatype from the database datatype.">
	<cfargument name="type" type="string" required="yes" hint="The database data type.">
	
	<cfset var result = "">
	<cfif FindNoCase(arguments.type,"(")>
		<cfset arguments.type = Left(arguments.type,FindNoCase(arguments.type,"("))>
	</cfif>
	
	<cfswitch expression="#arguments.type#">
		<cfcase value="bigint"><cfset result = "CF_SQL_BIGINT"></cfcase>
		<cfcase value="binary,image,sql_variant,sysname,varbinary"><cfthrow message="DataMgr object cannot handle this data type." type="DataMgr" detail="DataMgr cannot handle data type '#arguments.type#'" errorcode="InvalidDataType"></cfcase>
		<cfcase value="bit"><cfset result = "CF_SQL_BIT"></cfcase>
		<cfcase value="char"><cfset result = "CF_SQL_CHAR"></cfcase>
		<cfcase value="datetime"><cfset result = "CF_SQL_DATE"></cfcase>
		<cfcase value="decimal"><cfset result = "CF_SQL_DECIMAL"></cfcase>
		<cfcase value="float"><cfset result = "CF_SQL_FLOAT"></cfcase>
		<cfcase value="int"><cfset result = "CF_SQL_INTEGER"></cfcase>
		<cfcase value="mediumint"><cfset result = "CF_SQL_INTEGER"></cfcase>
		<cfcase value="money"><cfset result = "CF_SQL_MONEY"></cfcase>
		<cfcase value="nchar"><cfset result = "CF_SQL_CHAR"></cfcase>
		<cfcase value="ntext"><cfset result = "CF_SQL_LONGVARCHAR"></cfcase>
		<cfcase value="numeric"><cfset result = "CF_SQL_NUMERIC"></cfcase>
		<cfcase value="nvarchar"><cfset result = "CF_SQL_VARCHAR"></cfcase>
		<cfcase value="real"><cfset result = "CF_SQL_REAL"></cfcase>
		<cfcase value="smalldatetime"><cfset result = "CF_SQL_DATE"></cfcase>
		<cfcase value="smallint"><cfset result = "CF_SQL_SMALLINT"></cfcase>
		<cfcase value="smallmoney"><cfset result = "CF_SQL_MONEY4"></cfcase>
		<cfcase value="text"><cfset result = "CF_SQL_LONGVARCHAR"></cfcase>
		<cfcase value="timestamp"><cfset result = "CF_SQL_TIMESTAMP"></cfcase>
		<cfcase value="tinyint"><cfset result = "CF_SQL_TINYINT"></cfcase>
		<cfcase value="uniqueidentifier"><cfset result = "CF_SQL_IDSTAMP"></cfcase>
		<cfcase value="varchar"><cfset result = "CF_SQL_VARCHAR"></cfcase>
		<cfdefaultcase><cfset result = "UNKNOWN"></cfdefaultcase>
	</cfswitch>
	
	<cfreturn result>
</cffunction>

<cffunction name="getDBDataType" access="public" returntype="string" output="no" hint="I return the database datatype from the cfqueryparam datatype.">
	<cfargument name="CF_Datatype" type="string" required="yes">
	
	<cfset var result = "">
	
	<cfswitch expression="#arguments.CF_Datatype#">
		<cfcase value="CF_SQL_BIGINT"><cfset result = "bigint"></cfcase>
		<cfcase value="CF_SQL_BIT"><cfset result = "bit"></cfcase>
		<cfcase value="CF_SQL_CHAR"><cfset result = "char"></cfcase>
		<cfcase value="CF_SQL_DATE"><cfset result = "datetime"></cfcase>
		<cfcase value="CF_SQL_DECIMAL"><cfset result = "decimal"></cfcase>
		<cfcase value="CF_SQL_FLOAT"><cfset result = "float"></cfcase>
		<cfcase value="CF_SQL_IDSTAMP"><cfset result = "uniqueidentifier"></cfcase>
		<cfcase value="CF_SQL_INTEGER"><cfset result = "int"></cfcase>
		<cfcase value="CF_SQL_LONGVARCHAR"><cfset result = "text"></cfcase>
		<cfcase value="CF_SQL_MONEY"><cfset result = "money"></cfcase>
		<cfcase value="CF_SQL_MONEY4"><cfset result = "smallmoney"></cfcase>
		<cfcase value="CF_SQL_NUMERIC"><cfset result = "numeric"></cfcase>
		<cfcase value="CF_SQL_REAL"><cfset result = "real"></cfcase>
		<cfcase value="CF_SQL_SMALLINT"><cfset result = "smallint"></cfcase>
		<cfcase value="CF_SQL_TIMESTAMP"><cfset result = "timestamp"></cfcase>
		<cfcase value="CF_SQL_TINYINT"><cfset result = "tinyint"></cfcase>
		<cfcase value="CF_SQL_VARCHAR"><cfset result = "varchar"></cfcase>
		<cfdefaultcase><cfthrow message="DataMgr object cannot handle this data type." type="DataMgr" detail="DataMgr cannot handle data type '#arguments.CF_Datatype#'" errorcode="InvalidDataType"></cfdefaultcase>
	</cfswitch>
	
	<cfreturn result>
</cffunction>

<cffunction name="getMaxRowsPrefix" access="public" returntype="string" output="no" hint="I get the SQL before the field list in the select statement to limit the number of rows.">
	<cfargument name="maxrows" type="numeric" required="yes">
	
	<cfreturn "">
</cffunction>

<cffunction name="getMaxRowsSuffix" access="public" returntype="string" output="no" hint="I get the SQL before the field list in the select statement to limit the number of rows.">
	<cfargument name="maxrows" type="numeric" required="yes">
	
	<cfreturn " LIMIT #arguments.maxrows#">
</cffunction>

<cffunction name="checkTable" access="private" returntype="boolean" output="no" hint="I check to see if the given table exists in the Datamgr.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfif NOT StructKeyExists(variables.tables,arguments.tablename)>
		<cfset loadTable(arguments.tablename)>
	</cfif>
	
	<cfreturn true>
</cffunction>

<cffunction name="getInsertedIdentity" access="private" returntype="numeric" output="no" hint="I get the value of the identity field that was just inserted into the given table.">
	<cfargument name="tablename" type="string" required="yes">
	<cfargument name="identfield" type="string" required="yes">
	
	<cfset var qCheckKey = 0>
	<cfset var result = 0>
	
	<cfquery name="qCheckKey" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT	LAST_INSERT_ID() AS NewID
	</cfquery>
	<cfset result = qCheckKey.NewID>
	
	<cfreturn result>
</cffunction>

<cffunction name="getLength" access="private" returntype="string" output="no">
	<cfargument name="type" type="string" required="yes">
	
	<cfset var result = "">
	<cfset var parens1 = "(">
	<cfset var parens2 = ")">
	<cfset var fparens1 = FindNoCase(parens1,arguments.type)>
	<cfset var fparens2 = FindNoCase(parens2,arguments.type)>
	
	<cfif fparens1 AND fparens2>
		<cfset result = Mid(arguments.type,fparens1+1,fparens2-(fparens1+1))>
	</cfif>
	
	<cfreturn result>
</cffunction>

<cffunction name="isStringType" access="private" returntype="boolean" output="no" hint="I indicate if the given datatype is valid for string data.">
	<cfargument name="type" type="string">

	<cfset var strtypes = "char,nchar,nvarchar,varchar">
	<cfset var result = false>
	<cfif ListFindNoCase(strtypes,arguments.type)>
		<cfset result = true>
	</cfif>
	
	<cfreturn result>
</cffunction>

</cfcomponent>