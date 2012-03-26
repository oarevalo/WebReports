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
			
				// maxIndex will give us the highest value of SortIndex 
				for(i=1;i lte arrayLen(aColumns);i=i+1) {
					if(StructKeyExists(aColumns[i],"SortIndex") and aColumns[i].SortIndex gt maxIndex) 
						maxIndex = aColumns[i].SortIndex;			
				}
					
				setValue("oReport",oReport);
				setValue("aColumns",aColumns);
				setValue("maxIndex",maxIndex);
				setView("vwSort");
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
			var sortByColumn = getValue("sortByColumn");
			var sortByDirection = getValue("sortByDirection");

			try {
				oReport = getReport();
				oReport.addSort(sortByColumn, sortByDirection);
				
				setNextEvent("ehSort.dspMain");
				
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
				oReport.removeSort(index);
				
				setNextEvent("ehSort.dspMain");
				
			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPanel");
			}
		</cfscript>
	</cffunction>

</cfcomponent>