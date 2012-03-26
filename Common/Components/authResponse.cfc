<cfcomponent>

	<cfset variables.instance = structNew()>
	<cfset variables.instance.responseContent = "">
	<cfset variables.instance.userKey = "">
	<cfset variables.instance.isAuthorized = false>
	<cfset variables.instance.datasource = "">
	<cfset variables.instance.username = "">
	<cfset variables.instance.password = "">
	<cfset variables.instance.dbtype = "">
	<cfset variables.instance.dataProviderType = "">

	<cffunction name="init" access="public" returntype="authResponse">
		<cfargument name="responseContent" type="string" required="false" default="">
		<cfif trim(arguments.responseContent) neq "">
			<cfset parseResponse(arguments.responseContent)>
		</cfif>
		<cfreturn this>
	</cffunction>

	<cffunction name="parseResponse" access="public" returntype="void">
		<cfargument name="responseContent" type="string" required="true">
		<cfset var xmlDoc = 0>
		<cfset arguments.responseContent = trim(arguments.responseContent)>
		<cfset xmlDoc = xmlParse(arguments.responseContent)>
		<cfset setResponseContent(arguments.responseContent)>
		<cfset setUserKey(xmlDoc.xmlRoot.userKey.xmlText)>
		<cfset setIsAuthorized(xmlDoc.xmlRoot.isAuthorized.xmlText)>
		<cfset setDatasource(xmlDoc.xmlRoot.datasource.xmlText)>
		<cfset setUsername(xmlDoc.xmlRoot.username.xmlText)>
		<cfset setPassword(xmlDoc.xmlRoot.password.xmlText)>
		<cfset setDBType(xmlDoc.xmlRoot.dbtype.xmlText)>
		<cfset setDataProviderType(xmlDoc.xmlRoot.dataProviderType.xmlText)>
	</cffunction>
	
	<cffunction name="toXML" access="public" returntype="xml">
		<cfscript>
			var xmlDoc = xmlNew();
			var xmlNode = 0;
			
			xmlDoc.xmlRoot = xmlElemNew(xmlDoc,"authResponse");

			xmlNode = xmlElemNew(xmlDoc,"userKey");
			xmlNode.xmlText = getUserKey();
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);

			xmlNode = xmlElemNew(xmlDoc,"isAuthorized");
			xmlNode.xmlText = getIsAuthorized();
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);

			xmlNode = xmlElemNew(xmlDoc,"datasource");
			xmlNode.xmlText = getDatasource();
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);

			xmlNode = xmlElemNew(xmlDoc,"username");
			xmlNode.xmlText = getUsername();
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);

			xmlNode = xmlElemNew(xmlDoc,"password");
			xmlNode.xmlText = getPassword();
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);

			xmlNode = xmlElemNew(xmlDoc,"dbtype");
			xmlNode.xmlText = getDBType();
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);
			
			xmlNode = xmlElemNew(xmlDoc,"dataProviderType");
			xmlNode.xmlText = getDataProviderType();
			arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlNode);

			return xmlDoc;
		</cfscript>
	</cffunction>
	
	<cffunction name="setDatasourceBean" access="public" returntype="datasource">
		<cfargument name="ds" type="datasource" required="true">
		<cfscript>
			if(getDatasource() neq "") arguments.ds.setName( getDatasource() );
			if(getUsername() neq "") arguments.ds.setUsername( getUsername() );
			if(getPassword() neq "") arguments.ds.setPassword( getPassword() );
			if(getDBType() neq "") arguments.ds.setDBType( getDBType() );
			return arguments.ds;
		</cfscript>
	</cffunction>
	
	<cffunction name="getResponseContent" access="public" returntype="string">
		<cfreturn variables.instance.ResponseContent>
	</cffunction>

	<cffunction name="setResponseContent" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.ResponseContent = arguments.data>
	</cffunction>

	<cffunction name="getUserKey" access="public" returntype="string">
		<cfreturn variables.instance.UserKey>
	</cffunction>

	<cffunction name="setUserKey" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.UserKey = arguments.data>
	</cffunction>

	<cffunction name="getIsAuthorized" access="public" returntype="boolean">
		<cfreturn variables.instance.IsAuthorized>
	</cffunction>

	<cffunction name="setIsAuthorized" access="public" returntype="void">
		<cfargument name="data" type="boolean" required="true">
		<cfset variables.instance.IsAuthorized = arguments.data>
	</cffunction>

	<cffunction name="getDatasource" access="public" returntype="string">
		<cfreturn variables.instance.Datasource>
	</cffunction>

	<cffunction name="setDatasource" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.Datasource = arguments.data>
	</cffunction>

	<cffunction name="getUsername" access="public" returntype="string">
		<cfreturn variables.instance.Username>
	</cffunction>

	<cffunction name="setUsername" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.Username = arguments.data>
	</cffunction>
	
	<cffunction name="getPassword" access="public" returntype="string">
		<cfreturn variables.instance.Password>
	</cffunction>

	<cffunction name="setPassword" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.Password = arguments.data>
	</cffunction>

	<cffunction name="getDBType" access="public" returntype="string">
		<cfreturn variables.instance.dbtype>
	</cffunction>

	<cffunction name="setDBType" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.dbtype = arguments.data>
	</cffunction>
		
	<cffunction name="getDataProviderType" access="public" returntype="string">
		<cfreturn variables.instance.dataProviderType>
	</cffunction>

	<cffunction name="setDataProviderType" access="public" returntype="void">
		<cfargument name="data" type="string" required="true">
		<cfset variables.instance.dataProviderType = arguments.data>
	</cffunction>
	
	
</cfcomponent>