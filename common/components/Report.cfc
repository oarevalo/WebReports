<cfcomponent name="Report">

	<cffunction name="init" access="public" returntype="Report"
				hint="This is the constructor. Creates an empty report.">
		<cfscript>
			variables.defaultColumnStruct = structNew();
			
			// initialize default column struct
			initDefaultColumnStruct();
			
			// create empty report
			Clear();
		</cfscript>
		<cfreturn this>
	</cffunction>

	<cffunction name="create" access="public" returnType="void"
				hint="Populates report attributes for a new report">
		<cfargument name="TableName" type="string" required="true">
		<cfargument name="Title" type="string" required="true">
		<cfargument name="Subtitle" type="string" required="true">
		<cfargument name="ReportName" type="string" required="true">
		<cfargument name="Columns" type="array" required="true">
		<cfargument name="Width" type="string" required="true">
		<cfargument name="PageNumber" type="boolean" required="true">
		<cfargument name="Date" type="boolean" required="true">
		<cfargument name="IsFunction" type="boolean" required="true">
		<cfargument name="FunctionParameters" type="string" required="true">
		<cfargument name="DoNotShowDuplicateRows" type="boolean" required="true">
		
		<cfscript>
			// clear existing report
			Clear();

			// Set report info
			variables.report.name = arguments.reportName;
			variables.report.tableName = arguments.tableName;
			variables.report.title = arguments.title;
			variables.report.subtitle = arguments.subtitle;
			variables.report.Columns = duplicate(attributes.Columns);
			variables.report.width = arguments.width;
			variables.report.pageNumber = arguments.pageNumber;
			variables.report.Date = arguments.Date;
			variables.report.IsFunction = arguments.IsFunction;
			variables.report.FunctionParameters = arguments.FunctionParameters;
			variables.report.DoNotShowDuplicateRows = arguments.DoNotShowDuplicateRows;
		</cfscript>
	</cffunction>

	<cffunction name="clear" access="public" returntype="void"
				hint="Clears all report attributes">
		<cfscript>
			variables.report = structNew();
			variables.report.name = "";
			variables.report.tableName = "";
			variables.report.title = "";
			variables.report.subtitle = "";
			variables.report.width = "";
			variables.report.pageNumber = true;
			variables.report.Date = true;
			variables.report.isFunction = false;
			variables.report.functionParameters = "";
			variables.report.DoNotShowDuplicateRows = true;
			variables.report.displayGroupContents = true;
			variables.report.authenticationDelegate = "";
			variables.report.totalLabel = "";

			variables.report.Columns = ArrayNew(1);
			variables.report.Where = ArrayNew(1);
		</cfscript>
	</cffunction>

	<cffunction name="open" access="public" returnType="string"
				hint="Opens a report from a file">
		<cfargument name="reportHREF" type="string" required="true">			
		
		<cfscript>
			var xmlDoc = 0;
			var stReport = StructNew();
			var selectedElements = 0;
			var i = 0;
			var j = 0;
			var k = 0;
			var tmp = 0;
			var aColumns = 0;
			var aFilters = 0;
			
			// if the report path starts with a "/" then assume
			// it is a relative path
			if(left(arguments.reportHREF,1) eq "/")
				arguments.reportHREF = ExpandPath(arguments.reportHREF);

			// read file
			xmlDoc = xmlParse(arguments.reportHREF);	
			
			// Get a fresh and clean Report structure 
			Clear();
			
			// loop through all elements on the xml and assign them to the struct
			aElements = xmlDoc.xmlRoot.XmlChildren;
			for(i=1; i lte ArrayLen(aElements); i=i+1){
			
				switch(aElements[i].xmlName) {
					
					case "COLUMNS": 	
						variables.report.columns = arrayNew(1);

						aColumns = aElements[i].XmlChildren;
						for(j=1; j lte ArrayLen(aColumns); j=j+1){
	
							aColumn = aColumns[j].XmlChildren;
							stColumn = structNew();
							for(k=1; k lte ArrayLen(aColumn); k=k+1) {
								stColumn[aColumn[k].xmlName] = aColumn[k].XmlText;
							}		
							arrayAppend(variables.report.columns, stColumn);
						}
						break;
				
					case "WHERE":
						variables.report.where = arrayNew(1);
						
						aFilters = aElements[i].XmlChildren;
						for(j=1; j lte ArrayLen(aFilters); j=j+1){
	
							aFilter = aFilters[j].XmlChildren;
							stFilter = structNew();
							for(k=1; k lte ArrayLen(aFilter); k=k+1) {
								stFilter[aFilter[k].xmlName] = aFilter[k].XmlText;
							}		
							arrayAppend(variables.report.where, stFilter);
						}

						break;
						
					default:
						variables.report[aElements[i].xmlName] = aElements[i].XmlText;
			
				}
			}
		</cfscript>
	
	</cffunction>

	<cffunction name="getReport" access="public" returnType="struct"
				hint="Returns the report structure">
		<cfreturn variables.report>		
	</cffunction>

	<cffunction name="toXML" access="public" returntype="xml" hint="Converts the report into an XML document">
		<cfscript>
			var xmlDoc = xmlNew();
			var aColumns = variables.report.columns;
			var aFilters = variables.report.where;
			var e = "";
			var e1 = "";
			var i=0;
			var tmpNode=0;
			var tmpNode1=0;
			
			// create root element
			xmlDoc.xmlroot = xmlElemNew(xmlDoc,"report");
			xmlDoc.xmlRoot.xmlAttributes["version"] = "1.0b";
			
			for(e in variables.report) {
			
				switch(e) {
					
					case "COLUMNS": 
						arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc,"COLUMNS"));
						
						for(i=1; i lte ArrayLen(aColumns); i=i+1){
							tmpNode = xmlElemNew(xmlDoc,"column");
							for(e1 in aColumns[i]) {
								tmpNode1 = xmlElemNew(xmlDoc,e1);
								tmpNode1.xmlText = aColumns[i][e1];
								arrayAppend(tmpNode.xmlChildren, tmpNode1);
							}
							arrayAppend(xmlDoc.xmlRoot.COLUMNS.xmlChildren, tmpNode);
						}
						
						break;
						
					case "WHERE":
						arrayAppend(xmlDoc.xmlRoot.xmlChildren, xmlElemNew(xmlDoc,"WHERE"));

						for(i=1; i lte ArrayLen(aFilters); i=i+1){
							tmpNode = xmlElemNew(xmlDoc,"filter");
							for(e1 in aFilters[i]) {
								tmpNode1 = xmlElemNew(xmlDoc,e1);
								tmpNode1.xmlText = aFilters[i][e1];
								arrayAppend(tmpNode.xmlChildren, tmpNode1);
							}
							arrayAppend(xmlDoc.xmlRoot.WHERE.xmlChildren, tmpNode);
						}

						break;
						
					default:
						tmpNode = xmlElemNew(xmlDoc,e);
						tmpNode.xmlText = variables.report[e];
						arrayAppend(xmlDoc.xmlRoot.xmlChildren, tmpNode);
				
				}
			
			}
			
			
	
		</cfscript>
		<cfreturn xmlDoc>
	</cffunction>

	<cffunction name="save" access="public" returnType="string"
				hint="Saves the current report to a file">
		<cfargument name="reportPath" type="string" required="true">	
		<cfset var txtXML = toString(toXML())>
		<cffile action="write" file="#arguments.reportPath#" output="#txtXML#">		
	</cffunction>
	
	<cffunction name="setFunctionParameters" access="public"
				hint="Sets the function parameters, used when the report source is a SQL user-defined function">
		<cfargument name="functionParameters" type="string" required="true">
		<cfset variables.report.functionParameters = arguments.functionParameters>
	</cffunction>

	<cffunction name="renderSQL" access="public" returnType="struct"
				hint="Returns a structure with SQL string used to obtain the data for the report">

		<cfscript>
			var rtn = structNew();
			var crlf = chr(10) & Chr(13) & Chr(10) & Chr(13);
			var stWhereSQL = structNew();
			
			// Initialize return structure
			rtn.sql = "";
			rtn.source = variables.Report.TableName;
			rtn.columnList = "";
			rtn.where = "";
			rtn.distinct = "";

			aColumns = variables.Report.Columns;

			for(i=1; i lte ArrayLen(aColumns); i=i+1) {
				thisCol = aColumns[i];
		
				if(Not structKeyExists(thisCol, "SortIndex")) thisCol.SortIndex = "";
				if(Not structKeyExists(thisCol, "GroupIndex")) thisCol.GroupIndex = "";
		
				// only add column to column list if it is displayed or used for a sort or a group
				if(thisCol.Display or thisCol.SortIndex neq "" or thisCol.GroupIndex neq "") {

					// create the column alias by removing all invalid characters
					thisColAlias = getSafeColumnName(thisCol.Header);
					thisExp = thisCol.SQLExpr;

					if(thisColAlias neq thisCol.SQLExpr)
						thisExp = thisExp & " AS '" & thisColAlias & "' ";

					// append to columns list
					rtn.columnList = ListAppend(rtn.columnList, thisExp);
				}
			}
			
			// get filters SQL
			rtn.where = renderFiltersSQL().sql;

			// Get the source view/table/function
			if(variables.Report.IsFunction) {
				rtn.source = GetToken(variables.Report.TableName,1,"(") 
							& "(" & variables.Report.FunctionParameters & ")";
			}		
				
			// Check if we only want DISTINCT rows 
			if(variables.Report.DoNotShowDuplicateRows) 
				rtn.distinct = "DISTINCT";
				
			// Build Query string
			rtn.sql = "SELECT " & rtn.distinct & " ";
			
			// Add select columns to query
			rtn.sql = rtn.sql & rtn.columnList & crlf;
								
			// Append the source view/table		
			rtn.sql = rtn.sql & " FROM " & rtn.source  & crlf;
		
			// Append WHERE clause
			if (rtn.where neq "")	
				rtn.sql = rtn.sql & " WHERE " & rtn.where & crlf; 
		
			return duplicate(rtn);
		</cfscript>
	</cffunction>

	<cffunction name="renderFiltersSQL" access="public" returntype="struct"
				hint="Returns a structure with the SQL fragment for the WHERE clause">
		<cfscript>
			var tmpSQL = "";
			var tmpSQL_Labels = "";
			var aFilters = variables.report.where;
			var stWhereSQL = structNew();
			var stFilter = structNew();
			var stColumn = 0;
			var filter = "";
			var tmpThisFilter = "";
			var tmpEnclosing = "'";
			var aColumns = variables.report.Columns;
			var i = 0;
			
			for(i=1;i lte arrayLen(aFilters);i=i+1) {
				tmpThisFilter = "";
				tmpEnclosing = "'";

				// get a struct with this filter attributes
				stFilter = aFilters[i];
				stFilter.label = "";
				stFilter.dataType = "";
				
				// find the column structure for this filter
				for(j=1;j lte arrayLen(aColumns);j=j+1) {
					if(stFilter.column eq aColumns[j].SQLExpr) {
						stColumn = aColumns[j];
						break;
					}
				}

				if(IsStruct(stColumn)) {
					// get the column data type (if defined)
					if(structKeyExists(stColumn,"DataType")) 
						stFilter.dataType = stColumn.DataType;

					// get the label of the column to show filter criteria using 
					// the column labels instead of the column names
					stFilter.label = stColumn.Header; 
			
					// The encolosing character depends on the column data type (oarevalo 9-9-03)
					if(stFilter.dataType eq "Numeric" and stFilter.value neq "") tmpEnclosing = "";
			
					tmpThisFilter =  stFilter.column & " " & stFilter.relation & " ";
			
					// build filter criteria using the column labels instead of the column names
					tmpThisFilter_Labels = stFilter.label & " " & ReplaceList(stFilter.relation, "IS NULL,IS NOT NULL", "Has No Value,Has Any Value") & " ";
					
					if(Not FindNoCase("NULL",stFilter.relation)) {
						tmpThisFilter = tmpThisFilter & tmpEnclosing & stFilter.value & tmpEnclosing;	 
						tmpThisFilter_Labels = tmpThisFilter_Labels & tmpEnclosing & stFilter.value & tmpEnclosing;	 
						if(stFilter.value eq "")  {
							if (stFilter.relation eq "=") 	{
								tmpThisFilter = tmpThisFilter & " OR " & stFilter.column & " IS NULL";
								tmpThisFilter_Labels = tmpThisFilter_Labels & " OR " & stFilter.column & " Has No Value ";
							}	 
							if (stFilter.relation eq "!=")  {
								tmpThisFilter = tmpThisFilter & " OR " & stFilter.column & " IS NOT NULL";	 
								tmpThisFilter_Labels = tmpThisFilter_Labels & " OR " & stFilter.column & " Has Any Value ";	 
							}
						}
					}
					tmpSQL = tmpSQL & stFilter.operator & " (" & tmpThisFilter & ") ";
					tmpSQL_Labels = tmpSQL_Labels & stFilter.operator & " (" & tmpThisFilter_Labels & ") ";
				}
			} 
		
			/* make sure the WHERE clause does not start with a logical operator */
			if(tmpSQL neq "") {
				tmpFirstWord = ListGetAt(tmpSQL, 1, " ");
				if(tmpFirstWord eq "And" or tmpFirstWord eq "Or") {
					tmpSQL = ListRest(tmpSQL, " ");
					tmpSQL_Labels = ListRest(tmpSQL_Labels, " ");
				}
			}
			
			stWhereSQL.sql = tmpSQL;
			stWhereSQL.labels = tmpSQL_Labels;
		</cfscript>
		<cfreturn stWhereSQL>
	</cffunction>

	<cffunction name="addGroup" access="public" returnType="void">
		<cfargument name="ColumnName" type="string" required="true" hint="this is the header for the column">
		<cfargument name="ShowTitle" type="boolean" required="false" default="true">
		<cfargument name="ShowTotals" type="boolean" required="false" default="true">

		<cfscript>
			var aColumns = variables.report.Columns;
			var maxIndex = 0;
			var selIndex = 0;
			var i = 0;
			
			for(i=1;i lte arrayLen(aColumns);i=i+1) {
				// This will get the max n index on the group index
				// so that i can later use it to assign the index to the new group field
				if(StructKeyExists(aColumns[i],"GroupIndex") and aColumns[i].GroupIndex gt maxIndex) 
					maxIndex = aColumns[i].GroupIndex;
					
				if(aColumns[i].header eq arguments.ColumnName)	selIndex = i; 	
			}
	
			// find the key for this column and SortIndex of this column
			if(selIndex gt 0) {
				aColumns[selIndex].GroupIndex = maxIndex + 1;
				aColumns[selIndex].GroupTitles = arguments.showTitle;
				aColumns[selIndex].GroupDisplayTotal = arguments.ShowTotals;
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="removeGroup" access="public" returnType="void">
		<cfargument name="ColumnName" type="string" required="true" hint="this is the header for the column">
		<cfscript>
			var aColumns = variables.report.Columns;
			var i = 0;		
			
			for(i=1;i lte arrayLen(aColumns);i=i+1) {
				if(aColumns[i].header eq arguments.ColumnName) {
					aColumns[i].GroupIndex = "";
					aColumns[i].GroupTitles = "";
					aColumns[i].GroupDisplayTotal = "";
					return;
				}
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="clearGroup" access="public" returnType="void" hint="clears all groups from report">
		<cfscript>
			var aColumns = variables.report.Columns;
			var i = 0;		
			
			for(i=1;i lte arrayLen(aColumns);i=i+1) {
				aColumns[i].GroupIndex = "";
				aColumns[i].GroupTitles = "";
				aColumns[i].GroupDisplayTotal = "";
			}
		</cfscript>
	</cffunction>	
	
	<cffunction name="addSort" access="public" returnType="void">
		<cfargument name="ColumnName" type="string" required="true" hint="this is the header for the column">
		<cfargument name="direction" type="string" required="false" default="ASC" hint="Sort direction: ASC | DESC">

		<cfscript>
			var aColumns = variables.report.Columns;
			var maxIndex = 0;
			var selIndex = 0;
			var i = 0;
			
			for(i=1;i lte arrayLen(aColumns);i=i+1) {
				// This will get the max n index on the group index
				// so that i can later use it to assign the index to the new sort field
				if(StructKeyExists(aColumns[i],"SortIndex") and aColumns[i].SortIndex gt maxIndex) 
					maxIndex = aColumns[i].SortIndex;
					
				if(aColumns[i].header eq arguments.ColumnName)	selIndex = i; 	
			}
	
			// find the key for this column and SortIndex of this column
			if(selIndex gt 0) {
				aColumns[selIndex].SortIndex = maxIndex + 1;
				aColumns[selIndex].SortDirection = arguments.direction;
			}
		</cfscript>
	</cffunction>

	<cffunction name="removeSort" access="public" returnType="void">
		<cfargument name="ColumnName" type="string" required="true" hint="this is the header for the column">
		<cfscript>
			var aColumns = variables.report.Columns;
			var i = 0;		
			
			for(i=1;i lte arrayLen(aColumns);i=i+1) {
				if(aColumns[i].header eq arguments.ColumnName) {
					aColumns[i].SortIndex = "";
					aColumns[i].SortDirection = "";
					return;
				}
			}
		</cfscript>
	</cffunction>

	<cffunction name="setSortDirection" access="public" returnType="void">
		<cfargument name="ColumnName" type="string" required="true" hint="this is the header for the column">
		<cfargument name="direction" type="string" required="false" default="ASC" hint="Sort direction: ASC | DESC">
		<cfscript>
			var aColumns = variables.report.Columns;
			var i = 0;		
			
			for(i=1;i lte arrayLen(aColumns);i=i+1) {
				if(aColumns[i].header eq arguments.ColumnName) {
					aColumns[i].SortDirection = arguments.direction;
					return;
				}
			}
		</cfscript>
		<cfthrow message="not found">
	</cffunction>
		
	<cffunction name="clearSort" access="public" returnType="void" hint="Removes all sorting from report">
		<cfscript>
			var aColumns = variables.report.Columns;
			var i = 0;		
			
			for(i=1;i lte arrayLen(aColumns);i=i+1) {
				aColumns[i].SortIndex = "";
				aColumns[i].SortDirection = "";
			}
		</cfscript>
	</cffunction>		
		
		
	<cffunction name="addFilter" access="public" returnType="void">
		<cfargument name="ColumnName" type="string" required="true" hint="this is the header for the column">
		<cfargument name="relation" type="string" required="true">
		<cfargument name="value" type="string" required="true">
		<cfargument name="type" type="string" required="true">
		<cfargument name="operator" type="string" required="false" hint="Logical connector: AND|OR" default=""> 

		<cfscript>
			var stNewFilter = structNew();
			
			// Insert the new filter
			stNewFilter.operator = arguments.operator;
			stNewFilter.column = arguments.ColumnName;
			stNewFilter.relation = arguments.relation;
			stNewFilter.value = arguments.value;
			stNewFilter.type = arguments.type;
			
			arrayAppend(variables.report.where, stNewFilter);
		</cfscript>

	</cffunction>	
		
	<cffunction name="removeFilter" access="public" returnType="void">
		<cfargument name="filterIndex" type="string" required="true">
		<cfscript>
			arrayDeleteAt(variables.report.Where, arguments.filterIndex);
		</cfscript>
	</cffunction>	

	<cffunction name="getFilters" access="public" returntype="array">
		<cfreturn variables.report.Where>
	</cffunction>



	<cffunction name="setReportAttributes" access="public" returnType="void">
		<cfargument name="ReportAttributesStruct" type="struct" required="true">
		<cfscript>
			var attr = "";
			for(attr in ReportAttributesStruct) {
				variables.report[attr] = ReportAttributesStruct[attr];
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="setReportProperty" access="public" returnType="void">
		<cfargument name="propertyName" type="string" required="true">
		<cfargument name="propertyValue" type="string" required="true">
		<cfscript>
			if(structKeyExists(variables.report,arguments.propertyName)) {
				variables.report[arguments.propertyName] = arguments.propertyValue;
			}
		</cfscript>
	</cffunction>	

	<cffunction name="getReportProperty" access="public" returnType="string">
		<cfargument name="propertyName" type="string" required="true">
		<cfscript>
			var rtn = "";
			if(structKeyExists(variables.report,arguments.propertyName)) {
				rtn = variables.report[arguments.propertyName];
			} else {
				rtn = "";
			}
			return rtn;
		</cfscript>
	</cffunction>	

	<cffunction name="getTableName" access="public" returntype="string">
		<cfreturn variables.report.tableName>
	</cffunction>

	<cffunction name="setTableName" access="public">
		<cfargument name="tableName" type="string" required="true">
		<cfset variables.report.tableName = trim(arguments.tableName)>
	</cffunction>


	<cffunction name="getColumns" access="public" returntype="array">
		<cfreturn variables.report.Columns>
	</cffunction>
	
	<cffunction name="addColumn" access="public" returnType="void">
		<cfargument name="columnName" type="string" required="true">
		<cfargument name="visible" type="boolean" required="false" default="true">
		<cfscript>
			var aColumns = variables.report.Columns;
			var i = 1;
			var columnIndex = 0;
			var stColumn = structNew();
			
			// check if the column exists on the report
			for(i=1;i lte arrayLen(aColumns);i=i+1) {
				if(aColumns[i].SQLExpr eq arguments.columnName) {
					columnIndex = i;
					break;
				}
			}
			
			// if not exists then add it
			if(columnIndex eq 0) {
				stColumn = getColumnStruct();
				stColumn.SQLExpr = arguments.columnName;
				stColumn.Header = arguments.columnName;
				stColumn.display = arguments.visible;
				ArrayAppend(variables.report.Columns, stColumn);
			} else {
				variables.report.Columns[columnIndex].display = arguments.visible;
			}
		</cfscript>
	</cffunction>

	<cffunction name="removeColumn" access="public" returnType="void">
		<cfargument name="columnName" type="string" required="true">
		<cfscript>
			var aColumns = variables.report.Columns;
			var i = 1;
			var bColumnExist = false;
			var stColumn = structNew();
			
			// check if the column exists on the report
			for(i=1;i lte arrayLen(aColumns);i=i+1) {
				if(aColumns[i].SQLExpr eq arguments.columnName) {
					arrayDeleteAt(variables.report.Columns, i);
					break;
				}
			}
		</cfscript>		
	</cffunction>

	<cffunction name="getColumnList" access="public" returntype="string">
		<cfargument name="onlyForSelect" type="boolean" required="false" default="false">
		<cfscript>
			var lstColumns = "";
			var aColumns = variables.report.Columns;
			
			for(i=1;i lte arrayLen(aColumns);i=i+1) {
				if(Not arguments.onlyForSelect 
					or (aColumns[i].Display or aColumns[i].SortIndex neq "" or aColumns[i].GroupIndex neq ""))
				lstColumns = ListAppend(lstColumns, getSafeColumnName(aColumns[i].header));
			}
		</cfscript>
		<cfreturn lstColumns>
	</cffunction>
	
	<cffunction name="getColumn" access="public" returntype="struct">
		<cfargument name="columnName" type="string" required="true">
		<cfscript>
			var aColumns = variables.report.Columns;
			var i = 1;
			var columnIndex = 0;
			var stColumn = structNew();
			
			// check if the column exists on the report
			for(i=1;i lte arrayLen(aColumns);i=i+1) {
				if(aColumns[i].SQLExpr eq arguments.columnName) {
					columnIndex = i;
					break;
				}
			}
			
			// if not exists then add it
			if(columnIndex gt 0) {
				stColumn = variables.report.Columns[columnIndex];
			}
		</cfscript>
		<cfreturn stColumn>
	</cffunction>

	<cffunction name="getColumnByHeader" access="public" returntype="struct">
		<cfargument name="columnHeader" type="string" required="true">
		<cfscript>
			var aColumns = variables.report.Columns;
			var i = 1;
			var columnIndex = 0;
			var stColumn = structNew();
			
			// check if the column exists on the report
			for(i=1;i lte arrayLen(aColumns);i=i+1) {
				if(aColumns[i].header eq arguments.columnHeader) {
					columnIndex = i;
					break;
				}
			}
			
			// if not exists then add it
			if(columnIndex gt 0) {
				stColumn = variables.report.Columns[columnIndex];
			}
		</cfscript>
		<cfreturn stColumn>
	</cffunction>

	
	<cffunction name="setColumnProperty" access="public" returntype="void">
		<cfargument name="columnName" type="string" required="true">
		<cfargument name="property" type="string" required="true">
		<cfargument name="value" type="string" required="true">
		<cfscript>
			var aColumns = variables.report.Columns;
			var i = 1;
			var columnIndex = 0;
			
			// check if the column exists on the report
			for(i=1;i lte arrayLen(aColumns);i=i+1) {
				if(aColumns[i].SQLExpr eq arguments.columnName) {
					columnIndex = i;
					break;
				}
			}
			
			// if not exists then add it
			if(columnIndex gt 0) {
				variables.report.Columns[columnIndex][arguments.property] = arguments.value;
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="getTitle" access="public" returntype="string">
		<cfreturn variables.report.title> 
	</cffunction>

	<cffunction name="getSubtitle" access="public" returntype="string">
		<cfreturn variables.report.subtitle> 
	</cffunction>

	<cffunction name="setTitle" access="public" returntype="string">
		<cfargument name="data" type="string" required="true">
		<cfset variables.report.title = arguments.data> 
	</cffunction>

	<cffunction name="setSubtitle" access="public" returntype="string">
		<cfargument name="data" type="string" required="true">
		<cfset variables.report.subtitle = arguments.data> 
	</cffunction>

	<cffunction name="getPageOrientation" access="public" returntype="string">
		<cfreturn variables.report.Width> 
	</cffunction>

	<cffunction name="setPageOrientation" access="public" returntype="string">
		<cfargument name="data" type="string" required="true">
		<cfset variables.report.Width = arguments.data> 
	</cffunction>

	<cffunction name="getTotalLabel" access="public" returntype="string">
		<cfreturn variables.report.TotalLabel> 
	</cffunction>

	<cffunction name="setTotalLabel" access="public" returntype="string">
		<cfargument name="data" type="string" required="true">
		<cfset variables.report.TotalLabel = arguments.data> 
	</cffunction>
	
	
	<cffunction name="getColumnStruct" access="private" returntype="struct">
		<cfreturn duplicate(variables.defaultColumnStruct)>
	</cffunction>
	
	<cffunction name="initDefaultColumnStruct" access="private" returntype="void">
		<cfscript>
			var stData = structNew();

			stData.SQLExpr = "";
			stData.Header = "";
			stData.ReportIndex = "";
			stData.Display = true;
			stData.Wrap = true;
			stData.Align = "left";
			stData.Width = "";
			stData.SortIndex = "";
			stData.SortDirection = "";
			stData.GroupIndex = "";
			stData.GroupTitles = true;
			stData.GroupDisplayTotal = true;
			stData.GroupDataType = "";
			stData.GroupDataMask = "";
			stData.DataType = "string";
			stData.NumberFormat = "";
			stData.Total = "";
			stData.TotalLabel = "";
			stData.TotalAlign = "right";
			stData.TotalNumberFormat = "";
			stData.Description = "";
			stData.HREF = "";
			
			variables.defaultColumnStruct = duplicate(stData);
		</cfscript>
	</cffunction>
	
	<cffunction name="getSafeColumnName" access="private" returntype="string">
		<cfargument name="columnName" type="string" required="true">
		<cfscript>
			var InvalidChars = " ,-,+,*,/,/,\,!,@,$,%,^,&,*,(,),=,?,;,:,[,],{,}";
			var rtn = "";		
			var ReplaceInvalid = "";

			// create a list of "_" characters
			ReplaceInvalid = RepeatString("_,", ListLen(InvalidChars));
			ReplaceInvalid = Left(ReplaceInvalid,Len(ReplaceInvalid)-1);

			rtn = replacelist(arguments.columnName, InvalidChars, ReplaceInvalid);
		</cfscript>
		<cfreturn rtn>
	</cffunction>
	
	<cffunction name="dump">
		<cfargument name="data" type="any">
		<cfdump var="#arguments.data#">
	</cffunction>
</cfcomponent>