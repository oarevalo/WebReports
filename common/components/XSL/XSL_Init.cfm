

<cfscript>
	// Declare default values
	Default_Align = "left";
	Default_TotalAlign="Right";
	Default_MaskNumeric = "######,######,######,####0";
	Default_MaskDate = "%m/%d/%Y";
	Default_MaskString = "0";
	Default_Width = 0;
	Default_EMPTYLABEL = "NOLABEL";
	Default_EMPTYHREF = "NOHREF";
	Default_DataType = "String";

	// Declare and Initialize Variables
	Root = "report";
	maxSize = 500;
	TotalNames = "";
	TotalFunctions = "";
	TotalLabels = "";
	TotalMasks = "";
	TotalAligns = "";

	// Initialize arrays
	aColumnHeaders = ArrayNew(1);
	aColumnNames = ArrayNew(1);
	aColumnAligns = ArrayNew(1);
	aColumnWidths = ArrayNew(1);
	aColumnWraps = ArrayNew(1);
	aColumnMasks = ArrayNew(1);
	aColumnDataTypes = ArrayNew(1);
	aColumnHREFs = ArrayNew(1);

	aGroupNames = ArrayNew(1);
	aGroupTitles = ArrayNew(1);
	aGroupDataTypes = ArrayNew(1);
	aGroupMasks = ArrayNew(1);
	aGroupDisplayTotals = ArrayNew(1);

	aSortNames = ArrayNew(1);
	aSortOrder = ArrayNew(1);
	aSortDataTypes = ArrayNew(1);

	
	ArraySet(aColumnDataTypes,1,maxSize,"");
	ArraySet(aColumnMasks,1,maxSize,"");
	ArraySet(aColumnWraps,1,maxSize,"");
	ArraySet(aColumnHeaders,1,maxSize,"");
	ArraySet(aColumnNames,1,maxSize,"");
	ArraySet(aColumnAligns,1,maxSize,"");
	ArraySet(aColumnWidths,1,maxSize,"");
	ArraySet(aColumnHREFs,1,maxSize,"");

	ArraySet(aSortOrder,1,maxSize,"");
	ArraySet(aSortNames,1,maxSize,"");
	ArraySet(aSortDataTypes,1,maxSize,"");

	ArraySet(aGroupNames,1,maxSize,"");
	ArraySet(aGroupTitles,1,maxSize,"");
	ArraySet(aGroupDataTypes,1,maxSize,"");
	ArraySet(aGroupMasks,1,maxSize,"");
	ArraySet(aGroupDisplayTotals,1,maxSize,"");


	// this variables are needed to obtain the column alias used on the SQL query
	InvalidChars = " ,-,+,*,/,/,\,!,@,$,%,^,&,*,(,),=,?,;,:,[,],{,}";
	ReplaceInvalid = RepeatString("_,", ListLen(InvalidChars));
	ReplaceInvalid = Left(ReplaceInvalid,Len(ReplaceInvalid)-1);

	// Get report config from Report structure
	if(IsDefined("thisReport.ReportTagName"))
		RowName = thisReport.ReportTagName;
	else
		RowName = thisReport.TableName;

	//aColumns = StructFindKey(thisReport.Columns,"SQLExpr","ALL");
	aColumns = thisReport.Columns;

	// Obtain the default width for columns
	// that do not have an explicit width
	currentWidth = 0;
	numDisplayed = 0;
	numNoWidth = 0;
	for(i=1; i lte ArrayLen(aColumns); i=i+1) {
		// Make sure that the needed attributes exist
		myStruct = aColumns[i];
		if(Not structKeyExists(myStruct, "Width"))  aColumns[i].Width = 0;
		if(Not structKeyExists(myStruct, "Display"))  aColumns[i].Display = true;

		// get the total defined width of the report, and the
		// number of columns without witdth
		if(aColumns[i].Display eq "yes") {
			thisWidth = aColumns[i].Width;
			numDisplayed = numDisplayed + 1;
			
			if (IsNumeric(thisWidth) and thisWidth gt 0)  {
				currentWidth = currentWidth + thisWidth;
			} else {
				aColumns[i].Width =0;
				numNoWidth  = numNoWidth + 1;			
			}
 		}
	}
	
	
	// if the defined widh is greater than 100%, then scale each width down 
	// so that the total is a 100%
	if (currentWidth gt 100){
		for(i=1; i lte ArrayLen(aColumns); i=i+1) {
			if (aColumns[i].Display eq "yes") {
			    aColumns[i].Width = (aColumns[i].Width * 100) / currentWidth;
			}
		}
	}
	
	// if there are columns without width, then divide the available width
	// evenly among them.
	if (numNoWidth gt 0) {
		Default_Width = (100 - currentWidth) / numNoWidth;	
	}
	
</cfscript>


<!--- Define parameters  (for the entire report) --->	
<cfparam name="thisReport.Title" default="">
<cfparam name="thisReport.SubTitle" default="">
<cfparam name="thisReport.TotalLabel" default="">
<cfparam name="thisReport.Width" default="portrait">

<cfloop from="1" to="#ArrayLen(aColumns)#" index="i">
	<!--- Define parameters  (per column) --->	
	<cfparam name="aColumns[i].SQLExpr" default="">
	<cfparam name="aColumns[i].Display" default="yes">
	<cfparam name="aColumns[i].Header" default="#aColumns[i].SQLExpr#">
	<cfparam name="aColumns[i].DataType" default="#Default_DataType#">
	<cfparam name="aColumns[i].NumberFormat" default="">
	<cfparam name="aColumns[i].ReportIndex" default="">
	<cfparam name="aColumns[i].Align" default="Left">
	<cfparam name="aColumns[i].Wrap" default="Yes">
	<cfparam name="aColumns[i].Width" default="">
	<cfparam name="aColumns[i].href" default="">

	<cfparam name="aColumns[i].SortIndex" default="">
	<cfparam name="aColumns[i].SortDirection" default="">

	<cfparam name="aColumns[i].GroupIndex" default="">
	<cfparam name="aColumns[i].GroupTitles" default="Yes">
	<cfparam name="aColumns[i].GroupDisplayTotal" default="Yes">

	<cfparam name="aColumns[i].Total" default="">
	<cfparam name="aColumns[i].TotalLabel" default="">
	<cfparam name="aColumns[i].TotalAlign" default="#aColumns[i].Align#">
	<cfparam name="aColumns[i].TotalNumberFormat" default="#aColumns[i].NumberFormat#">

	<cfscript>
		// Obtain values for this column's parameters
		ReportIndex = aColumns[i].ReportIndex;
		GroupIndex = aColumns[i].GroupIndex;
		SortIndex =  aColumns[i].SortIndex;
		
		thisDataType = aColumns[i].DataType;
		thisMask = aColumns[i].NumberFormat;
		thisAlign = aColumns[i].Align;
		thisWidth = aColumns[i].Width;
		thisHeader = aColumns[i].Header;
		thisWrap = aColumns[i].Wrap;
		thisGroupTitle = aColumns[i].GroupTitles;
		thisGroupDisplayTotal = aColumns[i].GroupDisplayTotal;
		thisSortDirection = aColumns[i].SortDirection;
		thisTotal = aColumns[i].Total;
		thisTotalAlign = aColumns[i].TotalAlign;
		thisTotalLabel = aColumns[i].TotalLabel;
		thisTotalMask = aColumns[i].TotalNumberFormat;
		thisHREF = aColumns[i].href;

		// Remove illegal characters from column name
		ColumnAlias = ReplaceList(thisHeader, InvalidChars, ReplaceInvalid);
		

		// change data mask from coldfusion format to XSL format
		thisMask = ReplaceList(thisMask, "9,_", "##,##");
		thisTotalMask = ReplaceList(thisTotalMask, "9,_", "##,##");


		// Set default datamask depending on the datatype
		if(thisMask eq "")  {
			if (thisDataType eq "numeric")
				thisMask = Default_MaskNumeric;
			else if (thisDataType eq "datetime")
				thisMask = Default_MaskDate;
			else
				thisMask = Default_MaskString;
		}
		
		
		// set default values (in case of invalid parameters)
		if(Not IsNumeric(ReportIndex) or ReportIndex lte 0)  ReportIndex = ArrayLen(aColumnHeaders) - i;
		if(Not IsNumeric(GroupIndex) or GroupIndex lte 0)  GroupIndex = 0;
		if(Not IsNumeric(SortIndex) or SortIndex lte 0)  SortIndex = 0;
		if(Not IsNumeric(thisWidth) or thisWidth lte 0)  thisWidth = Default_Width;

		if(thisAlign eq "")  		thisAlign 		= Default_Align;
		if(thisTotalAlign eq "")  	thisTotalAlign 	= Default_TotalAlign;
		if(thisTotalMask eq "")		thisTotalMask	= thisMask;
		if(thisTotalLabel eq "") 	thisTotalLabel	= Default_EMPTYLABEL;
		if(thisDataType eq "")  	thisDataType 	= Default_DataType;
		if(thisHREF eq "")			thisHREF		= Default_EMPTYHREF;

		// Displayed Columns
		if(aColumns[i].Display eq "yes") {
			aColumnHeaders[ReportIndex] = thisHeader;
			aColumnNames[ReportIndex] = ColumnAlias;
			aColumnWraps[ReportIndex] = thisWrap;		
			aColumnMasks[ReportIndex] = thisMask;
			aColumnDataTypes[ReportIndex] = thisDataType;
			aColumnAligns[ReportIndex] = thisAlign;
			aColumnWidths[ReportIndex] = thisWidth;
			aColumnHREFs[ReportIndex] = thisHREF;
		}

		// Groups
		if(GroupIndex gt 0) {
			aGroupNames[GroupIndex] = ColumnAlias;
			aGroupTitles[GroupIndex] = thisGroupTitle;
			aGroupDataTypes[GroupIndex] = thisDataType;
			aGroupMasks[GroupIndex] = thisMask;
			aGroupDisplayTotals[GroupIndex] = thisGroupDisplayTotal;
		}				
	
		// Sorts
		if(SortIndex gt 0) {
			aSortNames[SortIndex] = ColumnAlias;
			aSortOrder[SortIndex] = thisSortDirection;
			aSortDataTypes[SortIndex] = thisDataType;
		}
	
		// Totals
		if(thisTotal neq "") {
			TotalNames = ListAppend(TotalNames, ColumnAlias);
			TotalFunctions = ListAppend(TotalFunctions, thisTotal);
			TotalLabels = ListAppend(TotalLabels, thisTotalLabel, "|");
			TotalAligns = ListAppend(TotalAligns, thisTotalAlign);
			TotalMasks = ListAppend(TotalMasks, thisTotalMask, "|");
		}
	</cfscript>
</cfloop>


<cfscript>
	// Convert arrays into lists (this will create sorted lists based on their index)
	ColumnHeaders = ArrayToList(aColumnHeaders);
	ColumnNames = ArrayToList(aColumnNames);
	ColumnAligns = ArrayToList(aColumnAligns);
	ColumnWidths = ArrayToList(aColumnWidths);
	ColumnWraps = ArrayToList(aColumnWraps);
	ColumnMasks = ArrayToList(aColumnMasks,"|");
	ColumnDataTypes = ArrayToList(aColumnDataTypes);
	ColumnHREFs = ArrayToList(aColumnHREFs);
	
	GroupNames = ArrayToList(aGroupNames);
	GroupTitles = ArrayToList(aGroupTitles);
	GroupDataTypes = ArrayToList(aGroupDataTypes);
	GroupMasks = ArrayToList(aGroupMasks,"|");
	GroupDisplayTotals = ArrayToList(aGroupDisplayTotals);
	GroupDisplayContents = thisReport.displayGroupContents;
	
	SortNames = ArrayToList(aSortNames);
	SortOrder = ArrayToList(aSortOrder);
	SortDataTypes = ArrayToList(aSortDataTypes);
	
	aGroupNames = ListToArray(GroupNames);
	NumberOfColumns = ListLen(ColumnNames);

	
	// Label for single total
	TotalMainLabel = thisReport.TotalLabel;


	// Build Sort List
	for(i=1; i lte ListLen(GroupNames); i=i+1) {
		tmpPos = ListFindNoCase(SortNames,ListGetAt(GroupNames,i));
		if(tmpPos gt 0) {
			SortNames	 = ListDeleteAt(SortNames, tmpPos);
			SortOrder = ListDeleteAt(SortOrder, tmpPos);
			SortDataTypes = ListDeleteAt(SortDataTypes, tmpPos);
		}
	}

	SortNames = ListPrepend(SortNames, GroupNames);
	SortOrder = ListPrepend(SortOrder, RepeatString("ASC,",ListLen(GroupNames)));
	SortDataTypes = ListPrepend(SortDataTypes, GroupDataTypes);

	SortOrder = ReplaceList(SortOrder, "ASC,DESC", "ascending,descending");
	SortDataTypes = UCase(SortDataTypes);
	SortDataTypes = ReplaceList(SortDataTypes, "NUMERIC,DATETIME,STRING", "number,text,text");
</cfscript>
