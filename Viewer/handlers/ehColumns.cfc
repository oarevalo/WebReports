<cfcomponent extends="ehBase">

	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var oTypeFactory = 0;
			var oReport = 0;
			
			try {
				oReport = getReport();
				
				oTypeFactory = createObject("component","WebReports.Common.Components.typeFactory");

				setValue("qryAlignTypes", oTypeFactory.getValues("align"));
				setValue("qryDataTypeTypes", oTypeFactory.getValues("dataType"));
				setValue("qryAggregateTypes", oTypeFactory.getValues("aggregate"));
				setValue("oReport",oReport);

				setView("vwColumns");
				setLayout("Layout.None");

			} catch(any e) {
				//getPlugin("logger").logError("Error displaying Datasource pod", e);
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPanel");
			}
			
		</cfscript>
	</cffunction>

	<cffunction name="dspColumn" access="public" returntype="void">
		<cfscript>
			var fieldName = getValue("fieldName");
			var fieldTitle = getValue("fieldTitle");
			var stColumn = structNew();
			var oTypeFactory = 0;
			var oReport = 0;
			
			try {
				oReport = getReport();
				
				if(fieldName neq "") 
					stColumn = oReport.getColumn(fieldName);
				else if(fieldTitle neq "") 
					stColumn = oReport.getColumnByHeader(fieldTitle);
				else
					throw("Column missing.");

				oTypeFactory = createObject("component","WebReports.Common.Components.typeFactory");

				setValue("qryAlignTypes", oTypeFactory.getValues("align"));
				setValue("qryDataTypeTypes", oTypeFactory.getValues("dataType"));
				setValue("qryAggregateTypes", oTypeFactory.getValues("aggregate"));
				setValue("stColumn",stColumn);
				setValue("oReport",oReport);

				setView("vwColumn");
				setLayout("Layout.None");

			} catch(any e) {
				//getPlugin("logger").logError("Error displaying Datasource pod", e);
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPanel");
			}
			
		</cfscript>
	</cffunction>

	<cffunction name="doSave" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			var i = 0;
			var lstProperties = "header,align,datatype,numberFormat,width,groupNumberFormat,groupDataType,total,totalNumberFormat,totalAlign";
			var prop = "";
			var propValue = "";
			var fieldName = getValue("fieldName");

			try {
				oReport = getReport();

				for(i=1;i lte listLen(lstProperties);i=i+1) {
					prop = listGetAt(lstProperties,i);
					if(getValue(prop,-1) neq -1) 
						propValue = getValue(prop);
					else
						propValue = "";
					oReport.setColumnProperty(fieldName, prop, propValue);
				}

				setValue("refreshReport",true);
				setLayout("Layout.None");
				
			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPanel");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doSelect" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			var aColumns = 0;
			var i = 0;
			var j = 0;
			var lstProperties = "reportIndex,display,align,total,numberFormat";
			var prop = "";
			var propValue = "";
			var colFieldName = "";
			var propFieldName = "";

			try {
				oReport = getReport();
				aColumns = oReport.getColumns();

				for(i=1;i lte arrayLen(aColumns);i=i+1) {
					for(j=1;j lte listLen(lstProperties);j=j+1) {
						prop = listGetAt(lstProperties,j);
						propValue = "";
						
						colFieldName = "cSQLExpr_" & i;
						propFieldName = "c" & prop & "_" & i;
						if(getValue(propFieldName,-1) neq -1) propValue = getValue(propFieldName);
	
						if(prop eq "display" and propValue eq "") propValue = false;
				
						oReport.setColumnProperty(getValue(colFieldName), prop, propValue);
					}
				}
				
				setValue("refreshReport",true);
				setLayout("Layout.None");
				
			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPanel");
			}
		</cfscript>
	</cffunction>

	<cffunction name="doQuickSort" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			var fieldName = getValue("fieldName");
			var direction = getValue("direction","ASC");

			try {
				oReport = getReport();
				oReport.clearSort();
				oReport.addSort(fieldName, direction);

				setNextEvent("ehGeneral.dspMain");
				
			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPanel");
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="doQuickGroup" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			var fieldName = getValue("fieldName");
			var showTitle = getValue("showTitle","Yes");
			var showTotal = getValue("showTotal","Yes");

			try {
				oReport = getReport();
				oReport.clearGroup();
				oReport.addGroup(fieldName, showTitle, showTotal);

				setNextEvent("ehGeneral.dspMain");
				
			} catch(any e) {
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPanel");
			}
		</cfscript>
	</cffunction>	
	
</cfcomponent>