/* ------------------------------------------------------------------------- ----
	
	File:		ajax-core.js
	Author:		Oscar Arevalo
	Section:	N/A
	Desc:		This file contains all javascript functions required to provide
				ajax-style interaction
				
	Update History:
				11/13/2008 - Oscar Arevalo
				created this file

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
									{method:'post', parameters:pars, evalScripts:true, onFailure:h_callError, onComplete:doEventComplete});
	$("loadingImage").className = "showlayer";
}

function h_callError(request) {
	alert('Sorry. An error ocurred while calling a server side component.');
}

function doEventComplete (obj) {
//	$("loadingImage").className = "hidelayer";
	$("loadingImage").style.display = "none";
}

function h_setLoadingImg(secID) {
	var d = document.getElementById("h_loading");
	var url_loadingImage =  "../Common/Images/loading_text.gif";

	if(!d) {
		var tmpHTML = "<div id='h_loading'><img src='" + url_loadingImage + "'></div>";
		new Insertion.After("ViewerMenuBar",tmpHTML);

		if(window.innerWidth)  clientWidth = window.innerWidth;
		else if (document.body) clientWidth = document.body.clientWidth;

		if(window.innerHeight)  clientHeight = window.innerHeight;
		else if (document.body) clientHeight = document.body.clientHeight;
		
		var d = document.getElementById("h_loading");
		d.style.left = ((clientWidth/2)-70) + "px";
		d.style.top = ((clientHeight/2)-100) + "px";
	}
}
function h_clearLoadingImg() {
	var d = document.getElementById("h_loading");
	if(d) {
		new Element.remove("h_loading");
	}
	
}



