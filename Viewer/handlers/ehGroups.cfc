<cfcomponent extends="ehBase">

	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			var aColumns = 0;
			var maxIndex = 0;
			var i = 0;
			
			try {
				oReport = getReport();
				aColumns = oReport.getColumns();

				// maxIndex will give us the highest value of GroupIndex 
				for(i=1;i lte arrayLen(aColumns);i=i+1) {
					if(StructKeyExists(aColumns[i],"GroupIndex") and aColumns[i].GroupIndex gt maxIndex) 
						maxIndex = aColumns[i].GroupIndex;			
				}
					
				setValue("oReport",oReport);
				setValue("aColumns",aColumns);
				setValue("maxIndex",maxIndex);
				setView("vwGroups");
				setLayout("Layout.None");

			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPanel");
			}
			
		</cfscript>
	</cffunction>

	<cffunction name="doSave" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			var groupByColumn = getValue("groupByColumn");
			var showTitle = getValue("showTitle",false);
			var showTotal = getValue("showTotal",false);

			try {
				oReport = getReport();
				oReport.addGroup(groupByColumn, showTitle, showTotal);
				
				setNextEvent("ehGroups.dspMain");
				
			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPanel");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doDelete" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			var index = getValue("index");

			try {
				oReport = getReport();
				oReport.removeGroup(index);
				
				setNextEvent("ehGroups.dspMain");
				
			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPanel");
			}
		</cfscript>
	</cffunction>

</cfcomponent>