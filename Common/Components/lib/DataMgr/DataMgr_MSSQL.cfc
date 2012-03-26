<!--- 1.2 Build 50 --->
<!--- Last Updated: 2006-08-01 --->
<!--- Created by Steve Bryant 2004-12-08 --->
<cfcomponent extends="DataMgr" displayname="Data Manager for MS SQL Server" hint="I manage data interactions with the MS SQL Server database. I can be used/extended by a component to handle inserts/updates.">

<cffunction name="getDatabase" access="public" returntype="string" output="no" hint="I return the database platform being used (Access,MS SQL,MySQL etc).">
	<cfreturn "MS SQL">
</cffunction>

<cffunction name="getDatabaseShortString" access="public" returntype="string" output="no" hint="I return the string that can be found in the driver or JDBC URL for the database platform being used.">
	<cfreturn "sqlserver">
</cffunction>

<cffunction name="getCreateSQL" access="public" returntype="string" output="no" hint="I return the SQL to create the given table.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfset var i = 0><!--- generic counter --->
	<cfset var arrFields = variables.tables[arguments.tablename]><!--- table structure --->
	<cfset var CreateSQL = ""><!--- holds sql to create table --->
	<cfset var pkfields = "">
	<cfset var thisField = "">
	
	<!--- Find Primary Key fields --->
	<cfloop index="i" from="1" to="#ArrayLen(arrFields)#" step="1">
		<cfif arrFields[i].PrimaryKey>
			<cfset pkfields = ListAppend(pkfields,arrFields[i].ColumnName)>
		</cfif>
	</cfloop>
	
	<!--- create sql to create table --->
	<cfsavecontent variable="CreateSQL"><cfoutput>
	<!--- IF NOT EXISTS(SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = '#arguments.tablename#') --->
		CREATE TABLE #arguments.tablename# (<cfloop index="i" from="1" to="#ArrayLen(arrFields)#" step="1">
			#arrFields[i].ColumnName# #getDBDataType(arrFields[i].CF_DataType)#<cfif isStringType(getDBDataType(arrFields[i].CF_DataType))> (<cfif StructKeyExists(arrFields[i],"Length") AND isNumeric(arrFields[i].Length) AND arrFields[i].Length gt 0>#arrFields[i].Length#<cfelse>50</cfif>)</cfif><cfif StructKeyExists(arrFields[i],"Increment") AND arrFields[i].Increment> IDENTITY (1, 1)</cfif><cfif StructKeyExists(arrFields[i],"Default")> DEFAULT #arrFields[i].Default#</cfif> <cfif ListFindNoCase(pkfields,arrFields[i].ColumnName) OR Not arrFields[i].AllowNulls>NOT </cfif>NULL<cfif arrFields[i].PrimaryKey AND arrFields[i].CF_DataType eq "CF_SQL_IDSTAMP"> DEFAULT (newid())</cfif>,</cfloop>
			<cfif Len(pkfields)>
			CONSTRAINT [PK_#tablename#] PRIMARY KEY CLUSTERED 
			(<cfloop index="i" from="1" to="#ListLen(pkfields)#" step="1"><cfset thisField = ListGetAt(pkfields,i)>
				#thisField#<cfif i lt ListLen(pkfields)>,</cfif></cfloop>
			)  ON [PRIMARY]
			</cfif>
		)<cfif Len(pkfields)> ON [PRIMARY]</cfif>
	<!--- GO --->
	</cfoutput></cfsavecontent>
	
	<cfreturn CreateSQL>
</cffunction>

<cffunction name="escape" access="private" returntype="string" output="no" hint="I return an escaped value for a table or field.">
	<cfargument name="name" type="string" required="yes">
	<cfreturn "[#arguments.name#]">
</cffunction>

<cffunction name="getDatabaseTables" access="public" returntype="string" output="no" hint="I get a list of all tables in the current database.">

	<cfset var qTables = 0>

	<cfquery name="qTables" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT	Table_Name
	FROM	INFORMATION_SCHEMA.TABLES
	WHERE	Table_Type = 'BASE TABLE'
		AND	Table_Name <> 'dtproperties'
	</cfquery>
	
	<cfreturn ValueList(qTables.Table_Name)>
</cffunction>

<cffunction name="getDBTableStruct" access="public" returntype="array" output="no" hint="I return the structure of the given table in the database.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfscript>
	var qStructure = 0;
	var qPrimaryKeys = 0;
	var qIndices = 0;
	var TableData = ArrayNew(1);
	var tmpStruct = StructNew();
	var PrimaryKeys = "";
	</cfscript>
	
	<cfquery name="qStructure" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT		COLUMN_NAME AS Field,
				DATA_TYPE AS Type,
				CHARACTER_MAXIMUM_LENGTH AS MaxLength,
				IS_NULLABLE AS AllowNulls,
				ColumnProperty( Object_ID('#arguments.tablename#'),COLUMN_NAME,'IsIdentity') AS IsIdentity,
				Column_Default as #escape("Default")#,
				NUMERIC_PRECISION AS [Precision],
				NUMERIC_SCALE AS Scale
	FROM		INFORMATION_SCHEMA.COLUMNS
	WHERE		table_name = '#arguments.tablename#'
	ORDER BY	Ordinal_Position
	</cfquery>
	<cfif qStructure.RecordCount eq 0>
		<cfthrow message="Data Manager: No such table (#arguments.tablename#). Trying to load a table that doesn't exist." type="DataMgr">
	</cfif>

	<cfquery name="qPrimaryKeys" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT		Column_Name
	FROM		INFORMATION_SCHEMA.TABLE_CONSTRAINTS
	INNER JOIN	INFORMATION_SCHEMA.KEY_COLUMN_USAGE
		ON		INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CONSTRAINT_NAME = INFORMATION_SCHEMA.KEY_COLUMN_USAGE.CONSTRAINT_NAME
	WHERE		INFORMATION_SCHEMA.TABLE_CONSTRAINTS.Table_Name = '#arguments.tablename#'
		AND		CONSTRAINT_TYPE = 'PRIMARY KEY'
	</cfquery>
	<cfif qPrimaryKeys.RecordCount>
		<cfset PrimaryKeys = ValueList(qPrimaryKeys.Column_Name)>
	</cfif>
	
	<cfoutput query="qStructure">
		<cfset tmpStruct = StructNew()>
		<cfset tmpStruct["ColumnName"] = Field>
		<cfset tmpStruct["CF_DataType"] = getCFDataType(Type)>
		<cfif ListFindNoCase(PrimaryKeys,Field)>
			<cfset tmpStruct["PrimaryKey"] = true>
		<cfelse>
			<cfset tmpStruct["PrimaryKey"] = false>
		</cfif>
		<cfif isBoolean(Trim(IsIdentity))>
			<cfset tmpStruct["Increment"] = IsIdentity>
		<cfelse>
			<cfset tmpStruct["Increment"] = false>
		</cfif>
		<cfif Len(MaxLength) AND isNumeric(MaxLength) AND NOT tmpStruct["CF_DataType"] eq "CF_SQL_LONGVARCHAR">
			<cfset tmpStruct["length"] = MaxLength>
		</cfif>
		<cfif isBoolean(Trim(AllowNulls))>
			<cfset tmpStruct["AllowNulls"] = Trim(AllowNulls)>
		<cfelse>
			<cfset tmpStruct["AllowNulls"] = true>
		</cfif>
		<cfset tmpStruct["Precision"] = Precision>
		<cfset tmpStruct["Scale"] = Scale>
		<cfif Len(Default)>
			<cfset tmpStruct["Default"] = Default>
		</cfif>
		
		<cfset ArrayAppend(TableData,StructCopy(tmpStruct))>
	</cfoutput>
	
	<cfreturn TableData>
</cffunction>

<cffunction name="getCFDataType" access="public" returntype="string" output="no" hint="I return the cfqueryparam datatype from the database datatype.">
	<cfargument name="type" type="string" required="yes" hint="The database data type.">
	
	<cfset var result = "">
	
	<cfswitch expression="#arguments.type#">
		<cfcase value="bigint"><cfset result = "CF_SQL_BIGINT"></cfcase>
		<cfcase value="binary,image,sql_variant,sysname,varbinary"><cfthrow message="DataMgr object cannot handle this data type." type="DataMgr" detail="DataMgr cannot handle data type '#arguments.type#'" errorcode="InvalidDataType"></cfcase>
		<cfcase value="bit"><cfset result = "CF_SQL_BIT"></cfcase>
		<cfcase value="char"><cfset result = "CF_SQL_CHAR"></cfcase>
		<cfcase value="datetime"><cfset result = "CF_SQL_DATE"></cfcase>
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
	SELECT	IDENT_CURRENT ('#arguments.tablename#') AS NewID
	</cfquery>
	<cfset result = qCheckKey.NewID>
	
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