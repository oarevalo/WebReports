<cfoutput>
<cfset BaseFontSize = "11">
<cfset FontSizeUnit = "px">

<style type="text/css">
	<!--- include the base style definitions --->
	<cfinclude template="/WebReports/common/styles/report.css">
	
	div.reportView {
		width: 100%;		/* table width will be 99% of this*/
		height: #ScreenHeight#px; 	/* must be greater than tbody*/
		overflow: auto;
		margin: 0 auto;
	}

	table.ViewerTable {
		width: 99%;		/*100% of container produces horiz. scroll in Mozilla*/
		border: none;
	}
		
	table.ViewerTable>tbody	{  /* child selector syntax which IE6 and older do not support*/
		overflow: auto; 
		height: #ScreenHeight-45#px;
		overflow-x: hidden;
		}
		
	thead##ReportHeader tr	{
		position:relative; 
		top: expression(offsetParent.scrollTop); /*IE5+ only*/
		}
		
	thead##ReportHeader td, thead##ReportHeader th {
		padding-top:3px;
		padding-bottom:3px;
	}	

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
	
	.lastRow {
		height: auto;
	}
	
	/* styles for individual columns */
	<cfloop from="1" to="#ListLen(ColumnNames)#" index="i">
		<cfset tmpCSSWidth = ListGetAt(ColumnWidths,i) & "%">
		.ReportCell_#i# {
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
		}
		##ReportHeaderCell_#i# {
			width: #tmpCSSWidth#;
		}
		.ReportGroupTotalCell_#i# {
			width: #tmpCSSWidth#;
			text-align: #ListGetAt(ColumnAligns,i)#;
			overflow: hidden;
			font-weight : bold; 
			text-overflow: ellipsis;
			font-size : #Evaluate(BaseFontSize)##FontSizeUnit#;
			border-top:1px solid black !important;
		}
		.ReportTotalCell_#i# {
			text-align: #ListGetAt(ColumnAligns,i)#;
			overflow: hidden;
			font-weight : bold; 
			text-overflow: ellipsis;
			font-size : #Evaluate(BaseFontSize+1)##FontSizeUnit#;
		}
	</cfloop>	
	</style>
</cfoutput>
