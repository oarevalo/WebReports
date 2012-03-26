/* ------------------------------------------------------------------------- ----
	
	File:		main.js
	Author:		Oscar Arevalo
	Section:	N/A
	Desc:		This file contains all javascript functions required by the 
	 			Report Viewer
				
	Update History:
				10/28/2006 - Oscar Arevalo
				added this notice

	Copyright: 2004-2006 CFEmpire Corp.
	
	THIS FILE CAN NOT BE DISTRIBUTED WITHOUT THE EXPRESS CONSENT OF CFEMPIRE CORP.

----- --------------------------------------------------------------------- */

function setupUI(showDBDialog) {
	resizePanes(false);

	if(showDBDialog=='YES') {
		setTimeout("openDatabasePanel()",500);
	} else {
		// refresh the report
		loadReport();
	}
}

function resizePanes(load) {
	resizeToClient("reportPreview",60,110);
	resizeToClient("reportPreviewIfr",60,130);
	if (load || load == null) {
		loadReport();
	} 
}

function loadReport() {
	resizePanes(false);
	
	// close the dialog panel
	closeDialogPanel();
	
	// this code is needed because IE5 and IE6  differences
	if (document.documentElement && document.documentElement.clientWidth)
		screenWidth = document.documentElement.clientWidth;
	else if (document.body)
		screenWidth = document.body.clientWidth

	if (document.documentElement && document.documentElement.clientHeight)
		screenHeight = document.documentElement.clientHeight;
	else if (document.body)
		screenHeight = document.body.clientHeight	


	reportWidth = screenWidth - 40;
	reportHeight = screenHeight - 140;
	rptSrc = "index.cfm?event=ehReportRenderer.dspMain&w=" + reportWidth + "&h=" + reportHeight;

	// load "loading" page
	loadInIFrame("includes/loading.htm");

	// load report after a short delay to give time
	// for the loading page to display
	setTimeout("loadInIFrame(rptSrc)",1000);

	// refresh report criteria
	refreshReportCriteria();
}

function openReport(mode, target) {
	closeDialogPanel();
	var rptSrc = "index.cfm?event=ehReportRenderer.dspMain&exportTo=" + target + "&reportMode=" + mode;
	window.open(rptSrc,"w","");
}

function AdjustDataType(obj) {
	//This function will adjust the data type
	//according to the value selected		

	var thisForm = this.document.forms[0];		
	var SelectedValue = thisForm.FilterByValue.value;
			
	if(Number(SelectedValue))
		thisForm.FilterByType.selectedIndex = 1;
	else
		thisForm.FilterByType.selectedIndex = 2;
}

function column_selectAll() {
	var frm = document.frmSelColumns;
	for(i=0;i < frm.length;i=i+1) {
		if(frm.elements[i].type=="checkbox")
			frm.elements[i].checked = true;
	}
}

function column_clearAll() {
	var frm = document.frmSelColumns;
	for(i=0;i < frm.length;i=i+1) {
		if(frm.elements[i].type=="checkbox")
			frm.elements[i].checked = false;
	}
}

function refreshReportCriteria() {
	doEvent("ehReport.dspReportCriteria","ReportCriteriaPanel");
}

function setupReport(doc) {
	try {
		aHeaders = getElementsByClassName(doc, "th", "ReportHeaderCell");
		for(i=0;i < aHeaders.length;i++) {
			fieldHeader = aHeaders[i].innerHTML;
			aHeaders[i].innerHTML = "<a href=\"javascript:parent.reportEditColumn('" + fieldHeader + "')\" style='color:#fff;'>" + fieldHeader + "</a>";
		}
	/*	
		aElems = getElementsByClassName(doc,"a","grpTitle");
		for(i=0;i < aElems.length;i++) {
			aElems[i].parentNode.style.cursor = "pointer";
			aElems[i].parentNode.onclick = toggleGroup;
		}
*/
	} catch(e) {
		alert(e);		
	}
}

function toggleGroup(event) {
	e = fixEvent(event);
	var modID = this.id;

	if(navigator.appName.indexOf("Microsoft") > -1){
		var canSee = 'block'
	} else {
		var canSee = 'table-row-group';
	}
	
	elem = this.parentNode.parentNode.nextSibling;
	if(elem.style.display=="none") {
		elem.style.display = canSee;
	}
	else  {
		elem.style.display = "none";
	}

	function fixEvent(event) {
		if (typeof event == 'undefined') event = window.event;
		return event;
	}	
}

function reportEditColumn(columnHeader) {
	openDialogPanel();
	doEvent("ehColumns.dspColumn","DialogPanelContainer",{fieldTitle:columnHeader});
} 

function openDatabasePanel() {
	openDialogPanel(280,210);
	doEvent("ehGeneral.dspDatabase","DialogPanelContainer");
}

function openDialogPanel(w, h){
	if (w == null || w == 0) 
		w = 480;
	if (h == null || h == 0) 
		h = 290;
	_openDialogPanel(w, h);
}
