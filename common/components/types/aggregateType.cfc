<cfcomponent extends="type">
	
	<cffunction name="init" returntype="any" hint="Initializes the component">
		<cfscript>
			setDescription("Supported functions to calculate aggregate values within a column");
			addValue("COUNT","Count");
			addValue("AVG","Average");
			addValue("SUM","Sum");
		</cfscript>
		<cfreturn this>
	</cffunction>
	
</cfcomponent>