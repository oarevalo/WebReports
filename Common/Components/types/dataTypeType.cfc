<cfcomponent extends="type">
	
	<cffunction name="init" returntype="any" hint="Initializes the component">
		<cfscript>
			setDescription("Possible data types for a column");
			addValue("String");
			addValue("Numeric");
			addValue("DateTime","Date / Time");
		</cfscript>
		<cfreturn this>
	</cffunction>
	
</cfcomponent>