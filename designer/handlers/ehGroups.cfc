<cfcomponent name="ehGroups" extends="ehBase">

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
							
				setView("vwGroupsPod");
				setLayout("Layout.None");

			} catch(any e) {
				//getPlugin("logger").logError("Error displaying Groups pod", e);
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPod");
			}
		</cfscript>
	</cffunction>


	<!------------------------------>
	<!--- Action Event Handlers  --->
	<!------------------------------>
	<cffunction name="doAddGroup" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			
			try {
				oReport = getReport();
				oReport.addGroup(getValue("field",""), true, true);

			} catch(any e) {
			//	getPlugin("logger").logError("Error adding group", e);
				setMessage("error", e.message & "<br>" & e.detail);
			}

			setNextEvent('ehGroups.dspMain','refreshReport=1');
		</cfscript>
	</cffunction>

	<cffunction name="doRemoveGroup" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			
			try {
				oReport = getReport();
				oReport.removeGroup(getValue("field",""));

			} catch(any e) {
				//getPlugin("logger").logError("Error removing group", e);
				setMessage("error", e.message & "<br>" & e.detail);
			}

			setNextEvent('ehGroups.dspMain','refreshReport=1');
		</cfscript>
	</cffunction>


</cfcomponent>