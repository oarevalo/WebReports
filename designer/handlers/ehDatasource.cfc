<cfcomponent name="ehDatasource" extends="ehBase">

	<!------------------------------>
	<!--- Display Event Handlers --->
	<!------------------------------>
	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var oDSBean = getDatasourceBean();
			
			try {
				// check that we have setup a database connection
				if(not oDSBean.validate()) setNextEvent("ehBase.dspDatabaseRequiredPod");
	
				// get the tables for this database
				setValue("aTables", getDataProvider().getTables());
	
				// pass the report
				setValue("oReport",getReport());
	
				// set view 
				setView("vwDatasourcePod");
				setLayout("Layout.None");

			} catch(any e) {
				//getPlugin("logger").logError("Error displaying Datasource pod", e);
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPod");
			}
		</cfscript>
	</cffunction>


	<!------------------------------>
	<!--- Action Event Handlers  --->
	<!------------------------------>
	<cffunction name="doSetDatasource" access="public" returntype="void">
		<cfscript>
			var name = getValue("name","");
			var type = getValue("type","table");
			var aFields = 0;
			
			try {
				// clear the report structure
				getReport().clear();
				
				// set report title
				getReport().setTitle(name);
				
				// set the table name
				getReport().setTableName(name);
				
				// add all fields
				aFields = getDataProvider().getTableColumns(name);
				for (i=1;i lte arrayLen(aFields);i=i+1) {
					getReport().addColumn(aFields[i], true);
				}
			
			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
			}
			
			setNextEvent("ehGeneral.dspMain");
		</cfscript>
	</cffunction>

</cfcomponent>