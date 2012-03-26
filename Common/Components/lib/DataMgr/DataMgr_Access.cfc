<!--- 1.2 Build 50 --->
<!--- Last Updated: 2006-08-01 --->
<!--- Created by Steve Bryant 2004-12-08 --->
<cfcomponent extends="DataMgr" displayname="Data Manager for MS Access" hint="I manage data interactions with the MS Access database. I can be used/extended by a component to handle inserts/updates.">

<cffunction name="getDatabase" access="public" returntype="string" output="no" hint="I return the database platform being used (Access,MS SQL,MySQL etc).">
	<cfreturn "Access">
</cffunction>

<cffunction name="getDatabaseShortString" access="public" returntype="string" output="no" hint="I return the string that can be found in the driver or JDBC URL for the database platform being used.">
	<cfreturn "Access">
</cffunction>

<cffunction name="getCreateSQL" access="public" returntype="string" output="no" hint="I return the SQL to create the given table.">
	<cfargument name="tablename" type="string" required="yes" hint="The name of the table to create.">
	
	<cfset var i = 0><!--- generic counter --->
	<cfset var arrFields = variables.tables[arguments.tablename]><!--- structure of table --->
	<cfset var CreateSQL = ""><!--- holds sql used for creation, allows us to return it in an error --->
	<cfset var pkfields = ""><!--- primary key fields --->
	<cfset var thisField = ""><!--- current field holder --->
	
	<!--- Find Primary Key fields --->
	<cfloop index="i" from="1" to="#ArrayLen(arrFields)#" step="1">
		<cfif arrFields[i].PrimaryKey>
			<cfset pkfields = ListAppend(pkfields,arrFields[i].ColumnName)>
		</cfif>
	</cfloop>
	
	<!--- create the sql to create the table --->
	<cfsavecontent variable="CreateSQL"><cfoutput>
	CREATE TABLE #arguments.tablename# (<cfloop index="i" from="1" to="#ArrayLen(arrFields)#" step="1">
		#arrFields[i].ColumnName# <cfif StructKeyExists(arrFields[i],"Increment") AND arrFields[i].Increment>COUNTER<cfelse>#getDBDataType(arrFields[i].CF_DataType)#</cfif><cfif isStringType(getDBDataType(arrFields[i].CF_DataType))>(<cfif StructKeyExists(arrFields[i],"Length") AND isNumeric(arrFields[i].Length) AND arrFields[i].Length gt 0>#arrFields[i].Length#<cfelse>50</cfif>)</cfif> <cfif ListFindNoCase(pkfields,arrFields[i].ColumnName) OR Not arrFields[i].AllowNulls>NOT </cfif>NULL<cfif i lt ArrayLen(arrFields)> ,</cfif></cfloop>
		<cfif Len(pkfields)>,
		CONSTRAINT [PK_#tablename#] PRIMARY KEY 
		(<cfloop index="i" from="1" to="#ListLen(pkfields)#" step="1"><cfset thisField = ListGetAt(pkfields,i)>
			#thisField#<cfif i lt ListLen(pkfields)>,</cfif></cfloop>
		)
		</cfif>
	)<!--- <cfif Len(pkfields)> ON [PRIMARY]</cfif> --->
	</cfoutput></cfsavecontent>
	
	<cfreturn CreateSQL>
</cffunction>

<cffunction name="escape" access="private" returntype="string" output="yes" hint="I return an escaped value for a table or field.">
	<cfargument name="name" type="string" required="yes">
	<cfreturn "[#arguments.name#]">
</cffunction>

<cffunction name="getDatabaseTables" access="public" returntype="string" output="yes" hint="I get a list of all tables in the current database.">

	<cfset var qTables = 0>
	
	<cftry>
		<cfquery name="qTables" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
		SELECT	Name AS TableName
		FROM	MSysObjects
		WHERE	Type = 1
			AND	Flags = 0
		</cfquery>
		<cfcatch>
			<cfif cfcatch.detail CONTAINS "no read permission">
				<cfthrow message="Your Access database doesn't have appropriate permissions to use tables without loading them via loadXML()." type="DataMgr" detail="In order to allow this method, open your database using MS Access and check the 'System objects' box under Tools/Options/View. You may also need to make sure 'Read Data' is checked for every table in Tools/Security/User and Group Permissions.">
			<cfelse>
				<cfrethrow>
			</cfif>
		</cfcatch>
	</cftry>
	
	<cfreturn ValueList(qTables.TableName)>
</cffunction>

<cffunction name="getDBTableStruct" access="public" returntype="array" output="no" hint="I return the structure of the given table in the database.">
	<cfargument name="tablename" type="string" required="yes">
	
	<cfscript>
	var qRawFetch = 0;
	var arrStructure = 0;
	var tmpStruct = StructNew();
	var i = 0;

	var PrimaryKeys = 0;
	var TableData = ArrayNew(1);
	</cfscript>
	
	<cfquery name="qRawFetch" datasource="#variables.datasource#" username="#variables.username#" password="#variables.password#">
	SELECT	TOP 1 *
	FROM	#arguments.tablename#
	</cfquery>
	<cfset arrStructure = getMetaData(qRawFetch)>
	
	<cfif isArray(arrStructure)>
		<cfloop index="i" from="1" to="#ArrayLen(arrStructure)#" step="1">
			<cfset tmpStruct = StructNew()>
			<cfset tmpStruct["ColumnName"] = arrStructure[i].Name>
			<cfset tmpStruct["CF_DataType"] = getCFDataType(arrStructure[i].TypeName)>
			<!--- %% Ugly guess --->
			<cfif arrStructure[i].TypeName eq "COUNTER" OR ( i eq 1 AND arrStructure[i].TypeName eq "INT" AND Right(arrStructure[i].Name,2) eq "ID" )>
				<cfset tmpStruct["PrimaryKey"] = true>
				<cfset tmpStruct["Increment"] = true>
				<cfset tmpStruct["AllowNulls"] = false>
			<cfelse>
				<cfset tmpStruct["PrimaryKey"] = false>
				<cfset tmpStruct["Increment"] = false>
				<cfset tmpStruct["AllowNulls"] = true>
			</cfif>
			<!--- %% Ugly guess --->
			<cfif isStringType(arrStructure[i].TypeName) AND NOT tmpStruct["CF_DataType"] eq "CF_SQL_LONGVARCHAR">
				<cfset tmpStruct["length"] = 255>
			</cfif>
			
			<cfset ArrayAppend(TableData,StructCopy(tmpStruct))>
		</cfloop>
	<cfelse>
		<cfthrow message="DataMgr can currently only support MS Access on ColdFusion MX 7 and above unless tables are loaded using loadXML(). Sorry for the trouble." type="DataMgr" detail="NoMSAccesSupport">
	</cfif>
	
	<cfreturn TableData>
</cffunction>

<cffunction name="getCFDataType" access="public" returntype="string" output="no" hint="I return the cfqueryparam datatype from the database datatype.">
	<cfargument name="type" type="string" required="yes" hint="The database data type.">
	
	<cfset var result = "">
	
	<cfswitch expression="#arguments.type#">
		<cfcase value="binary,image"><cfthrow message="DataMgr object cannot handle this data type." type="DataMgr" detail="DataMgr cannot handle data type '#arguments.type#'" errorcode="InvalidDataType"></cfcase>
		<cfcase value="bit"><cfset result = "CF_SQL_BIT"></cfcase>
		<cfcase value="char,varchar"><cfset result = "CF_SQL_VARCHAR"></cfcase>
		<cfcase value="counter"><cfset result = "CF_SQL_INTEGER"></cfcase>
		<cfcase value="datetime"><cfset result = "CF_SQL_DATE"></cfcase>
		<cfcase value="decimal"><cfset result = "CF_SQL_DECIMAL"></cfcase>
		<cfcase value="float"><cfset result = "CF_SQL_FLOAT"></cfcase>
		<cfcase value="int,integer"><cfset result = "CF_SQL_INTEGER"></cfcase>
		<cfcase value="longchar"><cfset result = "CF_SQL_LONGVARCHAR"></cfcase>
		<cfcase value="money"><cfset result = "CF_SQL_MONEY"></cfcase>
		<cfcase value="real"><cfset result = "CF_SQL_REAL"></cfcase>
		<cfcase value="smallint"><cfset result = "CF_SQL_SMALLINT"></cfcase>
		<cfcase value="text"><cfset result = "CF_SQL_CLOB"></cfcase>
		<cfcase value="tinyint"><cfset result = "CF_SQL_TINYINT"></cfcase>
		<cfcase value="uniqueidentifier"><cfset result = "CF_SQL_IDSTAMP"></cfcase>
		<cfdefaultcase><cfset result = "UNKNOWN"></cfdefaultcase>
	</cfswitch>
	
	<cfreturn result>
</cffunction>

<cffunction name="getDBDataType" access="public" returntype="string" output="no" hint="I return the database datatype from the cfqueryparam datatype.">
	<cfargument name="CF_Datatype" type="string" required="yes">
	
	<cfset var result = "">
	
	<cfswitch expression="#arguments.CF_Datatype#">
		<cfcase value="CF_SQL_BIGINT"><cfset result = "integer"></cfcase>
		<cfcase value="CF_SQL_BIT"><cfset result = "bit"></cfcase>
		<cfcase value="CF_SQL_CHAR"><cfset result = "char"></cfcase>
		<cfcase value="CF_SQL_DATE"><cfset result = "datetime"></cfcase>
		<cfcase value="CF_SQL_DECIMAL"><cfset result = "decimal"></cfcase>
		<cfcase value="CF_SQL_FLOAT"><cfset result = "float"></cfcase>
		<cfcase value="CF_SQL_IDSTAMP"><cfset result = "uniqueidentifier"></cfcase>
		<cfcase value="CF_SQL_INTEGER"><cfset result = "integer"></cfcase>
		<cfcase value="CF_SQL_CLOB,CF_SQL_LONGVARCHAR"><cfset result = "text"></cfcase>
		<cfcase value="CF_SQL_MONEY"><cfset result = "money"></cfcase>
		<cfcase value="CF_SQL_MONEY4"><cfset result = "money"></cfcase>
		<cfcase value="CF_SQL_NUMERIC"><cfset result = "float"></cfcase>
		<cfcase value="CF_SQL_REAL"><cfset result = "real"></cfcase>
		<cfcase value="CF_SQL_SMALLINT"><cfset result = "smallint"></cfcase>
		<cfcase value="CF_SQL_TINYINT"><cfset result = "tinyint"></cfcase>
		<cfcase value="CF_SQL_VARCHAR"><cfset result = "char"></cfcase>
		<cfdefaultcase><cfthrow message="DataMgr object cannot handle this data type." type="DataMgr" detail="DataMgr cannot handle data type '#arguments.CF_Datatype#'" errorcode="InvalidDataType"></cfdefaultcase>
	</cfswitch>
	
	<cfreturn result>
</cffunction>

<cffunction name="loadXML" access="public" returntype="void" output="false" hint="I add table/tables from XML and optionally create tables/columns as needed (I can also load data to a table upon its creation).">
	<cfargument name="xmldata" type="string" required="yes" hint="XML data of tables to load into DataMgr follows. Schema: http://www.bryantwebconsulting.com/cfc/DataMgr.xsd">
	<cfargument name="docreate" type="boolean" default="false" hint="I indicate if the table should be created in the database if it doesn't already exist.">
	<cfargument name="addcolumns" type="boolean" default="false" hint="I indicate if missing columns should be be created.">
	
	<cfset var table = "">
	<cfset var i = 0>
	<cfset var tabledata = 0>
	
	<cfset super.loadXML(xmldata,docreate,addcolumns)>
	
	<cfset tabledata = getTableData()>
	
	<cfloop collection="#tabledata#" item="table">
		<cfloop index="i" from="1" to="#ArrayLen(tabledata[table])#" step="1">
			<cfif tabledata[table][i]["CF_DataType"] eq "CF_SQL_LONGVARCHAR">
				<cfset variables.tables[table][i]["CF_DataType"] = "CF_SQL_CLOB">
			</cfif>
		</cfloop>
	</cfloop>
	
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