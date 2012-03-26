<cfcomponent name="ehFilters" extends="ehBase">

	<!------------------------------>
	<!--- Display Event Handlers --->
	<!------------------------------>
	<cffunction name="dspMain" access="public" returntype="void">
		<cfscript>
			var oDSBean = getDatasourceBean();
			var oReport = getReport();
			var showValues = getValue("showValues",false);
			var filterByColumn = getValue("filterByColumn");
			var filterByCondition = getValue("filterByCondition");
			var FilterByOperator = getValue("FilterByOperator");
			var strSource = "";
			var qryValues = queryNew("Item,ItemDisplay");
			var oDataProvider = getDataProvider();

			try {
				// check that we have setup a database connection and selected a data source object
				if(not oDSBean.validate()) setNextEvent("ehBase.dspDatabaseRequiredPod");
				if(oReport.getTableName() eq "") setNextEvent("ehBase.dspDatasourceRequiredPod");
	
				aFilters = oReport.getFilters();
				aColumns = oReport.getColumns();
			
				qryFilters = QueryNew("label,operator");
				QueryAddRow(qryFilters,9);
				QuerySetCell(qryFilters,"label","is equal to",1); 		QuerySetCell(qryFilters,"operator","=",1);
				QuerySetCell(qryFilters,"label","is greater than",2);	QuerySetCell(qryFilters,"operator",">",2);
				QuerySetCell(qryFilters,"label","is less than",3);		QuerySetCell(qryFilters,"operator","<",3);
				QuerySetCell(qryFilters,"label","is different than",4);				QuerySetCell(qryFilters,"operator","<>",4);
				QuerySetCell(qryFilters,"label","is greater than or equal to",5);	QuerySetCell(qryFilters,"operator",">=",5);
				QuerySetCell(qryFilters,"label","is less than or equal to",6); 		QuerySetCell(qryFilters,"operator","<=",6);
				QuerySetCell(qryFilters,"label","has no value",7); 		QuerySetCell(qryFilters,"operator"," IS NULL ",7);
				QuerySetCell(qryFilters,"label","has a value",8); 		QuerySetCell(qryFilters,"operator"," IS NOT NULL ",8);
				QuerySetCell(qryFilters,"label","is like",9); 			QuerySetCell(qryFilters,"operator"," LIKE ",9);
			
				// Get the source view/table/function 
				if(oReport.getReport().IsFunction)
					strSource = GetToken(oReport.getTableName(),1,"(") & "(" & oReport.getReport().FunctionParameters & ")";
				else
					strSource = oReport.getTableName();
			
				
				// set default logic condition
				if(FilterByOperator eq "" and arrayLen(aFilters) gte 1)
					FilterByOperator = "And";
	
				if(FilterByColumn is not "" and showValues) {
					qryValues = oDataProvider.getValuesByColumn(filterByColumn, strSource, 501);
				}
				
				setValue("oReport",oReport);
				setValue("aFilters",aFilters);
				setValue("aColumns",aColumns);
				setValue("qryFilters",qryFilters);
				setValue("qryValues",qryValues);
				setValue("filterByColumn",filterByColumn);
				setValue("filterByCondition",filterByCondition);
				setValue("FilterByOperator",FilterByOperator);
				setValue("showValues",showValues);
							
				setView("vwFiltersPod");
				setLayout("Layout.None");

			} catch(any e) {
				//getPlugin("logger").logError("Error displaying Filters pod", e);
				setMessage("error", e.message & "<br>" & e.detail);
				setNextEvent("ehBase.dspErrorPod");
			}
		</cfscript>
	</cffunction>


	<!------------------------------>
	<!--- Action Event Handlers  --->
	<!------------------------------>
	<cffunction name="doAddFilter" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			
			try {
				oReport = getReport();
				oReport.addFilter(getValue("FilterByColumn",""),
								  getValue("FilterByCondition",""),
								  getValue("FilterByValue",""),
								  getValue("FilterByType",""),
								  getValue("FilterByOperator",""));

			} catch(any e) {
				//getPlugin("logger").logError("Error adding filter", e);
				setMessage("error", e.message & "<br>" & e.detail);
			}

			setNextEvent('ehFilters.dspMain','refreshReport=1');
		</cfscript>
	</cffunction>

	<cffunction name="doRemoveFilter" access="public" returntype="void">
		<cfscript>
			var oReport = 0;
			
			try {
				oReport = getReport();
				oReport.removeFilter(getValue("filterIndex",0));

			} catch(any e) {
				//getPlugin("logger").logError("Error removing filter", e);
				setMessage("error", e.message & "<br>" & e.detail);
			}

			setNextEvent('ehFilters.dspMain','refreshReport=1');
		</cfscript>
	</cffunction>


</cfcomponent>