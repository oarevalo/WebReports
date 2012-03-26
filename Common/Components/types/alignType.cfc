<cfcomponent extends="type">
	
	<cffunction name="init" returntype="any" hint="Initializes the component">
		<cfscript>
			setDescription("Controls the alignment of values within a column");
			addValue("left");
			addValue("center");
			addValue("right");
		</cfscript>
		<cfreturn this>
	</cffunction>
	
</cfcomponent>