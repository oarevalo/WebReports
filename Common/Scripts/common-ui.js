/* ------------------------------------------------------------------------- ----
	
	File:		util.js
	Author:		Oscar Arevalo
	Section:	N/A
	Desc:		This file contains common ui-related javascript functions
				
	Update History:
				11/13/2008 - Oscar Arevalo
				created this file

	Copyright: 2004-2008 CFEmpire Corp.
	
	THIS FILE CAN NOT BE DISTRIBUTED WITHOUT THE EXPRESS CONSENT OF CFEMPIRE CORP.

----- --------------------------------------------------------------------- */

function dialogEvent(event) {
	openDialogPanel();
	doEvent(event,"DialogPanelContainer");
}
function setStatusMessage(msg) {
	$("StatusBar").innerHTML = msg;
	setTimeout('clearStatusMessage()',2000);
}
function clearStatusMessage() {
	$("StatusBar").innerHTML = "&nbsp;";
}

function _openDialogPanel(w,h) {
	if(w==null||w==0) w=480;
	if(h==null||h==0) h=290;

	// if the report iframe is visible then hide it
	if (isIE()) {
		var ifr = $("reportPreviewIfr");
		if (ifr) 
			ifr.style.display = "none";
	}
	
	// this code is needed because IE5 and IE6  differences
	if (document.documentElement && document.documentElement.clientWidth)
		clientWidth = document.documentElement.clientWidth;
	else if (document.body)
		clientWidth = document.body.clientWidth

	if (document.documentElement && document.documentElement.clientHeight)
		clientHeight = document.documentElement.clientHeight;
	else if (document.body)
		clientHeight = document.body.clientHeight	

	

	var Container = $("DialogPanelContainer");
	Container.style.width = w + "px";
	Container.style.height = h + "px";
	Container.style.left = ((clientWidth/2)-(w/2)) + "px";
	Container.style.top = ((clientHeight/2)-(h/2)) + "px";
	
	//Show it
	new Effect.Grow("DialogPanelContainer",{duration: .2});
}

function closeDialogPanel( ){
	cleardiv("DialogPanelContainer");
	divoff("DialogPanelContainer");

	// if the report iframe is there then show it
	var ifr = $("reportPreviewIfr");
	if(ifr)	 ifr.style.display = "block";		
}

function loadInIFrame(href,scrollbars) {
	var d = document.getElementById('reportPreviewIfr');
	if(scrollbars==undefined||scrollbars==null) scrollbars="no";
	if(d) {
		d.scrolling = scrollbars;
		d.src = href;
	}
}

function showMessageBox() {
	var w = 500;
	var Container = $("app_messagebox");
	if(Container) {
		if(window.innerWidth)  clientWidth = window.innerWidth;
		else if (document.body) clientWidth = document.body.clientWidth;
		Container.style.left = ((clientWidth/2)-(w/2)) + "px";
		Container.style.top = "0px";

		new Effect.Appear(Container,{duration: 1});
		setTimeout("closeMessageBox()",5000);
	}
}
function closeMessageBox() {
	var Container = $("app_messagebox");
	if (Container) {
		Effect.Fade(Container,{duration: 1});
	}	
}
