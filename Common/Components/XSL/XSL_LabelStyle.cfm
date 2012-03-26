<cfscript>
	// Initialize values

	// Define page
	Page = StructNew();
	Page.Name = "Letter";
	Page.Height = 11;
	Page.Width = 8.5;
	
	// Define label
	Label = StructNew();
	Label.Name = "Avery5160";
	Label.Columns = 3;
	Label.Rows = 10;
	Label.LabelsPerPage = Label.Columns * Label.Rows;
	Label.Width = 2.63;
	Label.Height = 1;
	Label.LeftMargin =  0.125; 
	Label.RightMargin = 0.125 ;
	Label.TopMargin = 0.093;
	Label.BottomMargin = 0.093;
	Label.TopEdge = 0.3;
	Label.LeftEdge = 0;
	Label.ColSpace = 0.125;
	Label.RowSpace = 0;

	/* NOTE:
	On the browser., the page margins should be:
	Left / Right : 0.25 inches
	Top / Bottom: 0.2 inches
	*/	
</cfscript>

<cfoutput>
	<!--- use DHTML to define page and labels --->
	<style type="text/css">
		body  {
			font-family : arial;
			margin: 0px;
			padding: 0px;
		}
	
		.Label {
			border:0pt solid blue;
			width:#Label.Width# in;
			height:#Label.Height# in;
			margin: 0in;
			padding-left:#Label.LeftMargin# in;
			padding-right:#Label.RightMargin# in;
			padding-top:#Label.TopMargin# in;
			padding-bottom:#Label.BottomMargin# in;
			margin-right:#Label.ColSpace# in;
			overflow: hidden;
			font:10pt Arial;
			display:inline;
			}
			
		.Page {
			width:#Page.Width# in;
			height:#Page.Height# in;
			border:0pt solid red;
			padding-left:#Label.LeftEdge# in;
			padding-top:#Label.TopEdge# in;
			}
	</style>
</cfoutput>
