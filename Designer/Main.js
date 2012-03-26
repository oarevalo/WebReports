/* ------------------------------------------------------------------------- ----
	
	File:		main.js
	Author:		Oscar Arevalo
	Section:	N/A
	Desc:		This file contains all javascript functions required by the 
	 			Report Designer
				
	Update History:
				11/20/2006 - Oscar Arevalo
				created

	Copyright: 2004-2006 CFEmpire Corp.
	
	THIS FILE CAN NOT BE DISTRIBUTED WITHOUT THE EXPRESS CONSENT OF CFEMPIRE CORP.

----- --------------------------------------------------------------------- */

var aPodNames = new Array("podSource","podColumns","podGroups","podSort","podFilters");
var isReportReady = false;

function setupUI(showDBDialog) {
	resizePanes(false);

	// add open/close feature to pods
	var aPods = document.getElementsByClassName("pod");
	for(i=0;i<aPods.length;i++) {
		aPodTitle = aPods[i].getElementsByClassName("podTitle");
		aPodTitle[0].onclick=function(){togglePod($(this.parentNode.id+"Body"))};
	}

	// load pod contents
	loadPods();
	
	// set initial state for pods (open/closed)
	for(i=0;i<aPodNames.length;i++) {
		if(readCookie(aPodNames[i] + "State")=="1") 
			if($(aPodNames[i])) {
				$(aPodNames[i]+"Body").style.display='block';
			}
	}
	
	if(showDBDialog=='YES') {
		setTimeout("openDatabasePanel()",500);
	} else {
		// refresh the report
		loadReport();
	}
}

function resizePanes(load) {
	resizeToClient("reportPreview",-1,150);
	resizeToClient("reportControls",-1,80);
	if($("EditColumnPanel"))
		resizeToClient("reportPreviewIfr",245,450);
	else
		resizeToClient("reportPreviewIfr",245,155);
	
	if(load || load==null) loadReport();
}

function togglePod(podBody) {
	var duration = 1;
	var isVisible = podBody.visible();
	if(isVisible) {
		new Effect.SlideUp(podBody,{duration: duration});
		eraseCookie(podBody.parentNode.id + "State");
	} else {
		new Effect.SlideDown(podBody,{duration: duration});
		createCookie(podBody.parentNode.id + "State","1",30);
	}
}

function loadPods() {
	doEvent("ehDatasource.dspMain","podSourceContent");
	//doEvent("ehParameters.dspMain","podParametersContent");
	doEvent("ehColumns.dspMain","podColumnsContent");
	doEvent("ehGroups.dspMain","podGroupsContent");
	doEvent("ehSort.dspMain","podSortContent");
	doEvent("ehFilters.dspMain","podFiltersContent");
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


	reportWidth = screenWidth - 400;
	reportHeight = screenHeight - 180;
	rptSrc = "index.cfm?event=ehReportRenderer.dspMain&w=" + reportWidth + "&h=" + reportHeight;

	// load "loading" page
	loadInIFrame("includes/loading.htm");

	// load report after a short delay to give time
	// for the loading page to display
	setTimeout("loadInIFrame(rptSrc)",1000);
}

function resetReport() {
	if(confirm("Create New Report?\n\nWARNING: This action will erase any unsaved changes\n\n")) {
		document.location = "index.cfm?event=ehGeneral.dspMain&resetReport=1";
	}
}

function toggleCheckboxes( frm, className, ctrlChk ) {
	var aChks =	document.getElementsByClassName(className)
	for(var i=0;i<aChks.length;i++) {
		aChks[i].checked = ctrlChk.checked
	}			
}

function AdjustDataType(obj) {
	//This function will adjust the data type
	//according to the value selected		

	var SelectedValue = obj.value;
			
	if(Number(SelectedValue))
		obj.form.FilterByType.selectedIndex = 1;
	else
		obj.form.FilterByType.selectedIndex = 2;
}

function openDialogPanel(w, h){
	if (w == null || w == 0) w = 580;
	if (h == null || h == 0) h = 360;
	_openDialogPanel(w, h);
}

function openDatabasePanel() {
	openDialogPanel(280,210);
	doEvent("ehGeneral.dspDatabase","DialogPanelContainer");
}

function openEditColumnPanel(fieldName) {
	openDialogPanel();
	doEvent("ehColumns.dspEdit","DialogPanelContainer",{fieldName:fieldName});
}
function closeEditColumnPanel() { closeDialogPanel(); }

function openSettingsPanel() {
	openDialogPanel(400,230);
	doEvent("ehGeneral.dspSettings","DialogPanelContainer");
}






//FILE BROWSER JS
function openBrowser( vEvent, vCallbackInput ){
	openDialogPanel();
	doEvent(vEvent,'DialogPanelContainer',{callBackItem:vCallbackInput});
}
function closeBrowser( ){ closeDialogPanel(); }

function selectItem( vdir , vFullUrl, vType){
	var selectedDir = vdir;
	$("span_selectedfolder").innerHTML = selectedDir;
	if(vType=='file') {
		$("selectdir_btn").disabled = false;
		$("selectedFilename").value = selectedDir;
	} else {
		$("selectdir_btn").disabled = true;
		$("selecteddir").value = vFullUrl;
	}
	//Color Pattern
	if ( selectDirectoryHistoryID != ""){
		try{$(selectDirectoryHistoryID).style.backgroundColor = '#ffffff';}
		catch(err){null;}
		$(vdir).style.backgroundColor = '#b3cbff';
		selectDirectoryHistoryID = vdir;
	}
	else{
		$(vdir).style.backgroundColor = '#b3cbff';
		selectDirectoryHistoryID = vdir;
	}
}
var selectDirectoryHistoryID = "";

function newFolder( vEvent, vcurrentRoot ){
	var vNewFolder = prompt("Please enter the name of the folder to create:");
	if (vNewFolder == "" || vNewFolder==null){ 
		alert("Please enter a valid name");
	}
	else{
		doEvent(vEvent,'FileBrowser',{dir:vcurrentRoot,newfolder:vNewFolder});
	}
}
function chooseFile( vcallbackItem ){
	var selectedDir = $("selecteddir").value;
	var selectedFile = $("selectedFilename").value;
	selectedResource = selectedDir+"/"+selectedFile;
	
	if(selectedResource=="" || selectedResource==null) {
		alert("Nothing has been selected");
	} else {
		str = vcallbackItem + "('" + selectedResource + "')"
		eval(str);
		closeBrowser();
	}
	
	//$(vcallbackItem).value = $("selecteddir").value;
}

function openReport(path) {
	if(path!="" && path!=null)
		document.location="index.cfm?event=ehGeneral.doOpenReport&path=" + path;
	else
		alert("Invalid document. Can't open");
}
function saveReport(path) {
	if(path!="" && path!=null)
		document.location="index.cfm?event=ehGeneral.doSaveReport&path=" + path;
	else
		alert("Invalid file name.");	
}
function enableColumn(oChk,field) {
	$("fldVisible_"+field).disabled=!(oChk.checked);	
	if(oChk.checked) $("fldVisible_"+field).checked=true;
}
