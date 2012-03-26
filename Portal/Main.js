/* ------------------------------------------------------------------------- ----
	
	File:		main.js
	Author:		Oscar Arevalo
	Section:	N/A
	Desc:		This file contains all javascript functions required by the 
	 			Report Portal
				
	Update History:
				10/21/2008 - Oscar Arevalo
				created

	Copyright: 2004-2008 CFEmpire Corp.
	
	THIS FILE CAN NOT BE DISTRIBUTED WITHOUT THE EXPRESS CONSENT OF CFEMPIRE CORP.

----- --------------------------------------------------------------------- */


function doFormEvent (e, targetID, frm) {
	var params = {};
	for(i=0;i<frm.length;i++) {
		if(!((frm[i].type=="radio" || frm[i].type=="checkbox") && !frm[i].checked))  {
			params[frm[i].name] = frm[i].value;
		}
	}
	doEvent(e, targetID, params);
}

function doEvent (e, targetID, params) {
	var pars = "";
	for(p in params) pars = pars + p + "=" + escape(params[p]) + "&";
	pars = pars + "event=" + e;
	var myAjax = new Ajax.Updater(targetID,
									"index.cfm",
									{method:'get', parameters:pars, evalScripts:true, onFailure:h_callError, onComplete:doEventComplete});
	$("loadingImage").className = "showlayer";
}

function h_callError(request) {
	alert('Sorry. An error ocurred while calling a server side component.');
}

function doEventComplete (obj) {
	$("loadingImage").className = "hidelayer";
}

function setStatusMessage(msg) {
	$("StatusBar").innerHTML = msg;
	setTimeout('clearStatusMessage()',2000);
}

function clearStatusMessage() {
	$("StatusBar").innerHTML = "&nbsp;";
}
