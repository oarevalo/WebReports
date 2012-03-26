<cfcomponent name="ehSort" extends="ehBase">

	<!------------------------------>
	<!--- Display Event Handlers --->
	<!------------------------------>
	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var oDSBean = getDatasourceBean();
			var oReport = getReport();

			try {
				// check that we have setup a database connection and selected a data source object
				if(not oDSBean.validate()) setNextEvent("ehBase.dspDatabaseRequiredPod");
				if(oReport.getTableName() eq "") setNextEvent("ehBase.dspDatasourceRequiredPod");
	
				// pass the report
				setValue("oReport", oReport);
							
				setView("vwSortPod");
				setLayout("Layout.None");

			} catch(any e) {
				//getPlugin("logger").logError("Error displaying Sort pod", e);
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPod");
			}
		</cfscript>
	</cffunction>


	<!------------------------------>
	<!--- Action Event Handlers  --->
	<!------------------------------>
	<cffunction name="doAddSort" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			
			try {
				oReport = getReport();
				oReport.addSort(getValue("SortColumn",""), getValue("Direction","ASC"));

			} catch(any e) {
				//getPlugin("logger").logError("Error adding sort", e);
				setMessage("error", e.message & "<br>" & e.detail);
			}

			setNextEvent('ehSort.dspMain','refreshReport=1');
		</cfscript>
	</cffunction>

	<cffunction name="doRemoveSort" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			
			try {
				oReport = getReport();
				oReport.removeSort(getValue("SortColumn",""));

			} catch(any e) {
				//getPlugin("logger").logError("Error removing sort", e);
				setMessage("error", e.message & "<br>" & e.detail);
			}

			setNextEvent('ehSort.dspMain','refreshReport=1');
		</cfscript>
	</cffunction>

	<cffunction name="doSetDirection" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			
			try {
				oReport = getReport();
				oReport.setSortDirection(getValue("SortColumn",""), getValue("Direction","ASC"));

			} catch(any e) {
				//getPlugin("logger").logError("Error setting sort direction", e);
				setMessage("error", e.message & "<br>" & e.detail);
			}

			setNextEvent('ehSort.dspMain','refreshReport=1');
		</cfscript>
	</cffunction>



</cfcomponent>