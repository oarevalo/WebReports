<!--- 1.2 Build 50 --->
<!--- Last Updated: 2006-08-01 --->
<!--- Created by Steve Bryant 2004-12-08 --->
<cfcomponent extends="DataMgr" displayname="Data Manager for PostGreSQL" hint="I manage data interactions with the PostGreSQL database. I can be used/extended by a component to handle inserts/updates.">

<cffunction name="getDatabase" access="public" returntype="string" output="no" hint="I return the database platform being used (Access,MS SQL,MySQL etc).">
	<cfreturn "PostGreSQL">
</cffunction>

<cffunction name="getDatabaseShortString" access="public" returntype="string" output="no" hint="I return the string that can be found in the driver or JDBC URL for the database platform being used.">
	<cfreturn "postgre">
</cffunction>

<cffunction name="getCreateSQL" access="public" returntype="string" output="no" hint="I return the SQL to create the given table.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfset var i = 0>
	<cfset var arrFields = variables.tables[arguments.tablename]>
	<cfset var CreateSQL = "">
	<cfset var pkfields = "">
	<cfset var thisField = "">
	
	<!--- Find Primary Key fields --->
	<cfloop index="i" from="1" to="#ArrayLen(arrFields)#" step="1">
		<cfif arrFields[i].PrimaryKey>
			<cfset pkfields = ListAppend(pkfields,arrFields[i].ColumnName)>
		</cfif>
	</cfloop>
	
	<cfsavecontent variable="CreateSQL"><cfoutput>
	CREATE TABLE #escape(arguments.tablename)# (<cfloop index="i" from="1" to="#ArrayLen(arrFields)#" step="1">
		#escape(arrFields[i].ColumnName)#<cfif StructKeyExists(arrFields[i],"Increment") AND arrFields[i].Increment> SERIAL<cfelse> #getDBDataType(arrFields[i].CF_DataType)#<cfif isStringType(getDBDataType(arrFields[i].CF_DataType))> (<cfif StructKeyExists(arrFields[i],"Length") AND isNumeric(arrFields[i].Length) AND arrFields[i].Length gt 0>#arrFields[i].Length#<cfelse>50</cfif>)</cfif></cfif><cfif StructKeyExists(arrFields[i],"Default")> DEFAULT #arrFields[i].Default#</cfif> <cfif ListFindNoCase(pkfields,arrFields[i].ColumnName) OR Not arrFields[i].AllowNulls>NOT </cfif>NULL <cfif StructKeyExists(arrFields[i],"PrimaryKey") AND arrFields[i].PrimaryKey>PRIMARY KEY</cfif><cfif i lt ArrayLen(arrFields)>,</cfif></cfloop>
	)
	</cfoutput></cfsavecontent>
	
	<cfreturn CreateSQL>
</cffunction>

<cffunction name="escape" access="private" returntype="string" output="yes" hint="I return an escaped value for a table or field.">
	<cfargument name="name" type="string" required="yes">
	<cfreturn "#chr(34)##arguments.name##chr(34)#">
</cffunction>

<cffunction name="getDatabaseTables" access="public" returntype="string" output="yes" hint="I get a list of all tables in the current database.">

	<cfset var qTables = 0>

	<cfquery name="qTables" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT	tablename
	FROM	pg_tables
	WHERE	tableowner = current_user
	</cfquery>
	
	<cfreturn ValueList(qTables.tablename)>
</cffunction>

<cffunction name="getDBTableStruct" access="public" returntype="array" output="no" hint="I return the structure of the given table in the database.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfscript>
	var qTable = 0;
	var qFields = 0;
	var qPrimaryKeys = 0;
	var qSequences = 0;
	var PrimaryKeys = "";
	var Sequences = "";
	var TableData = ArrayNew(1);
	var tmpStruct = StructNew();
	</cfscript>
	
	<cfquery name="qTable" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT	tablename
	FROM	pg_tables
	WHERE	tableowner = current_user
		AND	tablename = '#arguments.tablename#'
	</cfquery>
	<cfif qTable.RecordCount eq 0>
		<cfthrow message="Data Manager: No such table ('#arguments.tablename#'). Trying to load a table that doesn't exist." type="DataMgr">
	</cfif>
	<!--- <cfquery name="qFields" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT	attnum,attname AS Field
	FROM	pg_class, pg_attribute
	WHERE	relname = '#arguments.tablename#'
 		AND	pg_class.oid = attrelid
		AND	attnum > 0
	</cfquery> --->
	<cfquery name="qFields" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT		a.attnum, a.attname AS Field, t.typname AS Type,
				a.attlen AS Length, a.atttypmod, a.attnotnull AS NotNull, a.atthasdef,
				d.adsrc AS #escape("Default")#
	FROM		pg_class as c
	INNER JOIN	pg_attribute a
		ON		c.oid = a.attrelid
	INNER JOIN	pg_type t
		ON		a.atttypid = t.oid
	LEFT JOIN	pg_attrdef d
		ON		c.oid = d.adrelid
			AND	d.adnum = a.attnum
	WHERE		a.attnum > 0
		AND		c.relname = 'cmsPages'
	ORDER BY	a.attnum
	</cfquery>
	<cfquery name="qPrimaryKeys" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT	conkey
	FROM	pg_constraint
	JOIN	pg_class
		ON	pg_class.oid=conrelid 
	WHERE	contype='p'
		AND	relname = '#arguments.tablename#'
	</cfquery>
	<cfset PrimaryKeys = ValueList(qPrimaryKeys.conkey)>
	<cfquery name="qSequences" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT	relname
	FROM	pg_class
	WHERE	relkind = 'S'
		AND	relname LIKE '#arguments.tablename#%'
	</cfquery>
	<cfoutput query="qSequences">
		<cfset Sequences = ListAppend(Sequences,ReplaceNoCase(ReplaceNoCase(relname, "#arguments.tablename#_", ""), "_seq", "") )>
	</cfoutput>
	

	<cfoutput query="qFields">
		<cfset tmpStruct = StructNew()>
		<cfset tmpStruct["ColumnName"] = Field>
		<cfset tmpStruct["CF_DataType"] = getCFDataType(type)>
		<cfif ListFindNoCase(Sequences,Field)>
			<cfset tmpStruct["Increment"] = True>
		</cfif>
		<cfif ListFindNoCase(PrimaryKeys,Field)>
			<cfset tmpStruct["PrimaryKey"] = True>
		</cfif>
		<cfif isStringType(type) AND NOT tmpStruct["CF_DataType"] eq "CF_SQL_LONGVARCHAR">
			<cfset tmpStruct["length"] = getLength(type)>
		</cfif>
		<cfif isBoolean(NotNull)>
			<cfset tmpStruct["AllowNulls"] = NotNull>
		<cfelse>
			<cfset tmpStruct["AllowNulls"] = true>
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
		<cfcase value="bit,boolean"><cfset result = "CF_SQL_BIT"></cfcase>
		<cfcase value="char"><cfset result = "CF_SQL_CHAR"></cfcase>
		<cfcase value="date"><cfset result = "CF_SQL_DATE"></cfcase>
		<cfcase value="decimal"><cfset result = "CF_SQL_DECIMAL"></cfcase>
		<cfcase value="float"><cfset result = "CF_SQL_FLOAT"></cfcase>
		<cfcase value="int"><cfset result = "CF_SQL_INTEGER"></cfcase>
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
		<cfcase value="CF_SQL_BIT"><cfset result = "boolean"></cfcase>
		<cfcase value="CF_SQL_CHAR"><cfset result = "char"></cfcase>
		<cfcase value="CF_SQL_DATE"><cfset result = "date"></cfcase>
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
	SELECT		TOP 1 #identfield# AS NewID
	FROM		#arguments.tablename#
	ORDER BY	#identfield# DESC
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

<cffunction name="makeDefaultValue" access="private" returntype="string" output="no" hint="I return the value of the default for the given datatype and raw value.">
	<cfargument name="value" type="string" required="yes">
	<cfargument name="CF_DataType" type="string" required="yes">
	
	<cfset var result = super.makeDefaultValue(arguments.value,arguments.CF_DataType)>
	<cfset var type = getDBDataType(arguments.CF_DataType)>
	
	<cfif type eq "boolean">
		<cfif isBoolean(result) AND result>
			<cfset result = "true">
		<cfelse>
			<cfset result = "false">
		</cfif>
	</cfif>
	
	<cfreturn result>
</cffunction>

</cfcomponent>