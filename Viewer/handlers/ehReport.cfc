<cfcomponent extends="ehBase">

	<cffunction name="dspSettings" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			
			try {
				oReport = getReport();
				
				setValue("oReport",oReport);
				setView("vwSettings");
				setLayout("Layout.None");

			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPanel");
			}
			
		</cfscript>
	</cffunction>

	<cffunction name="dspReportCriteria" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			var	aSorts = arrayNew(1);
			var	aGroups = arrayNew(1);
			var	aColumns = arrayNew(1);
			var aFilters = arrayNew(1);
			var i = 0;
			
			try {
				oReport = getReport();
				aColumns = oReport.getColumns();
				aFilters = oReport.getFilters();
				
				// Get the first sort field (the one with the smaller SortIndex)
				for(i=1;i lte arrayLen(aColumns);i=i+1) {
					if(StructKeyExists(aColumns[i],"SortIndex") 
						and aColumns[i].SortIndex is not 0 
						and isnumeric(aColumns[i].SortIndex)) {
							aSorts[aColumns[i].SortIndex] = " " & aColumns[i].Header;
					}
				}
			
				// Get the first group field (the one with the smaller SortIndex)
				for(i=1;i lte arrayLen(aColumns);i=i+1) {
					if(StructKeyExists(aColumns[i],"GroupIndex") and
						aColumns[i].GroupIndex is not 0 and
						isNumeric(aColumns[i].GroupIndex)) {
							aGroups[aColumns[i].GroupIndex] = " " & aColumns[i].Header;
					}
				}
				
				setValue("oReport",oReport);
				setValue("aSorts",aSorts);
				setValue("aGroups",aGroups);
				setValue("aFilters",aFilters);
				setView("vwReportCriteria");
				setLayout("Layout.None");

			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPanel");
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="doSaveSettings" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			var title = getValue("title");
			var subtitle = getValue("subtitle");
			var totalLabel = getValue("totalLabel");
			var PageOrientation = getValue("PageOrientation","portrait");

			try {
				oReport = getReport();
				oReport.setTitle(title);
				oReport.setSubtitle(subtitle);
				oReport.setTotalLabel(totalLabel);
				oReport.setPageOrientation(PageOrientation);

				setValue("refreshPage",true);
				setLayout("Layout.None");
				
			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPanel");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doSetReportProperty" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			var propName = getValue("propName");
			var propValue = getValue("propValue");
			var reload = getValue("reload","yes");

			try {
				oReport = getReport();
				oReport.setReportProperty(propName, propValue);

				setValue("refreshReport",reload);
				setLayout("Layout.None");
				
			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPanel");
			}
		</cfscript>
	</cffunction>
	
</cfcomponent>