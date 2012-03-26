<cfcomponent name="ehParameters" extends="ehBase">

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
				
				setView("vwParametersPod");
				setLayout("Layout.None");

			} catch(any e) {
				//getPlugin("logger").logError("Error displaying Parameters pod", e);
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPod");
			}
		</cfscript>
	</cffunction>


	<!------------------------------>
	<!--- Action Event Handlers  --->
	<!------------------------------>


</cfcomponent>