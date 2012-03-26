<cfoutput>
<cfset BaseFontSize = "11">
<cfset FontSizeUnit = "px">

<style type="text/css">
	<!--- include the base style definitions --->
	<cfinclude template="/WebReports/Common/Styles/report_print.css">
	
	thead##ReportHeader th {
		font-size : #Evaluate(BaseFontSize)##FontSizeUnit#;
	}	

	td	{
		font-size : #BaseFontSize##FontSizeUnit#;
		line-height:#BaseFontSize*1.5##FontSizeUnit#;
	}
	
	/*td:last-child {padding-right: 20px;} prevent Mozilla scrollbar from hiding cell content*/

	.GroupHeader_1, .GroupHeader_2,
	.GroupHeader_3, .GroupHeader_4,
	.GroupHeader_5, .GroupHeader_6,
	.GroupHeader_7, .GroupHeader_8 {
		font-size : #Evaluate(BaseFontSize)##FontSizeUnit#;
	}
	
	.GrandTotal {
		font-size : #Evaluate(BaseFontSize+1)##FontSizeUnit#; 
	}

	.GroupTable {
		width: 100%;
		border-collapse:collapse;
	}
	
	.emptyCell {
		height:5px;
		border:0px !important;
	}
	
	/* styles for individual columns */
	<cfloop from="1" to="#ListLen(ColumnNames)#" index="i">
		<cfset tmpCSSWidth = ListGetAt(ColumnWidths,i) & "%">
		.ReportCell_#i# {
			/*width: #Evaluate(ListGetAt(ColumnWidths,i)*(ScreenWidth/100))##ScreenWidthUnit#;*/
			overflow: hidden;
			text-overflow: ellipsis;
			text-align: #ListGetAt(ColumnAligns,i)#;
			<cfif ListGetAt(ColumnWraps,i) is "no">white-space: nowrap;</cfif>
			margin:0px;
			padding:0px;
			margin-left:2px;
			font-family:verdana !important;
		}
		.ReportTableCell_#i# {
			width: #tmpCSSWidth#;
			text-align: #ListGetAt(ColumnAligns,i)#;
			border: solid 1px ##d8d8d8;
		}
		##ReportHeaderCell_#i# {
			/*width: #Evaluate(ListGetAt(ColumnWidths,i)*ScreenWidth/100)##ScreenWidthUnit#;*/
			width: #tmpCSSWidth#;
		}
		.ReportGroupTotalCell_#i# {
			/*width: #Evaluate(ListGetAt(ColumnWidths,i)*ScreenWidth/100)##ScreenWidthUnit#;*/
			width: #tmpCSSWidth#;
			text-align: #ListGetAt(ColumnAligns,i)#;
			overflow: hidden;
			font-weight : bold; 
			text-overflow: ellipsis;
			font-size : #Evaluate(BaseFontSize)##FontSizeUnit#;
		}
		.ReportTotalCell_#i# {
			/*width: #Evaluate(ListGetAt(ColumnWidths,i)*ScreenWidth/100)##ScreenWidthUnit#;*/
			width: #tmpCSSWidth#;
			text-align: #ListGetAt(ColumnAligns,i)#;
			overflow: hidden;
			font-weight : bold; 
			text-overflow: ellipsis;
			font-size : #Evaluate(BaseFontSize+1)##FontSizeUnit#;
		}
	</cfloop>	
	
	</style>

</cfoutput>
