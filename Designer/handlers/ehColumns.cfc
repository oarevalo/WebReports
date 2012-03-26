<cfcomponent name="ehColumns" extends="ehBase">

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
	
				// get the fields for this table
				setValue("aFields", getDataProvider().getTableColumns( oReport.getTableName()));
	
				// pass the report
				setValue("oReport", oReport);
							
				setView("vwColumnsPod");
				setLayout("Layout.None");

			} catch(any e) {
			//	getPlugin("logger").logError("Error displaying Columns pod", e);
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPod");
			}
		</cfscript>
	</cffunction>

	<cffunction name="dspEdit" access="public" returntype="void">
		<cfscript>
			var oDSBean = getDatasourceBean();
			var oReport = getReport();

			try {
				// check that we have setup a database connection and selected a data source object
				if(not oDSBean.validate()) setNextEvent("ehBase.dspDatabaseRequiredPod");
				if(oReport.getTableName() eq "") setNextEvent("ehBase.dspDatasourceRequiredPod");
	
				// pass the report
				setValue("oReport", oReport);
											
				setView("vwEditColumn");
				setLayout("Layout.None");

			} catch(any e) {
				//getPlugin("logger").logError("Error displaying Edit Column pod", e);
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPod");
			}
		</cfscript>
	</cffunction>

	<!------------------------------>
	<!--- Action Event Handlers  --->
	<!------------------------------>
	<cffunction name="doSetColumns" access="public" returntype="void">
		<cfscript>
			var aColumns = 0;
			var i = 0;
			var bColumnVisible = false;
			var aTableColumns = 0;
			var fldName = "";
			var oReport = 0;
			var fld = "";
			var oDSBean = getDatasourceBean();

			try {
				oReport = getReport();
				aColumns = oReport.getColumns();

				// get list with all fields on the data source object
				aTableColumns = getDataProvider().getTableColumns( oReport.getTableName());

				// check if we need to add/remove columns
				for (i=1;i lte arrayLen(aTableColumns);i=i+1) {
					fldName = aTableColumns[i];
					
					isEnabled = getValue("fldEnable_#fldName#",false);
					isVisible = getValue("fldVisible_#fldName#",false);
					
					if(isEnabled) {
						// add column
						oReport.addColumn(fldName, isVisible);
					} else {
						// remove column
						oReport.removeColumn(fldName);
					}
					
				}

				setNextEvent('ehColumns.dspMain','refreshReport=1&refreshPods=1');
				
			} catch(any e) {
				//getPlugin("logger").logError("Error selecting columns", e);
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehGeneral.dspMain");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doSave" access="public" returntype="void">
		<cfscript>
			var aColumns = 0;
			var i = 0;
			var oReport = 0;
			var fieldName = getValue("fieldName","");
			var lstProperties = "header,align,datatype,numberFormat,width,description,groupNumberFormat,groupDataType,total,totalNumberFormat,totalAlign,reportIndex,href";

			try {
				oReport = getReport();

				for(i=1;i lte listLen(lstProperties);i=i+1) {
					prop = listGetAt(lstProperties,i);
					oReport.setColumnProperty(fieldName, prop, getValue(prop,""));
				}

				setNextEvent('ehColumns.dspEdit','refreshReport=1&fieldName=#fieldName#');

			} catch(any e) {
				//getPlugin("logger").logError("Error savin column properties", e);
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent();
			}
		</cfscript>	
	</cffunction>

</cfcomponent>