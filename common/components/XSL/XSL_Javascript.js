

function Init_Display() {
	// fix column headers to the top of the screen
	var fxTable = new FixedTable("reportView", "header");
	if(!document.readyState) document.readyState = "complete";
}

function Init_Page(PageOrientation) {
	// Provide the user some indications on how to print this report
	alert("This report has been formatted as " + PageOrientation + ". \nPlease set your browser accordingly")

	//  Open the printer dialog
	window.print();
}

function Init_Labels() {
	// Provide the user some indications on how to print this report
	alert('This report has been formatted for AVERY 5160 labels. \nPlease set the following page margins on your browser:  \nLeft / Right : 0.25 \nTop / Bottom : 0.2')
}
