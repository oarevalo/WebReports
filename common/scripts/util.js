/* ------------------------------------------------------------------------- ----
	
	File:		util.js
	Author:		Oscar Arevalo
	Section:	N/A
	Desc:		This file contains common utility javascript functions
				
	Update History:
				11/13/2008 - Oscar Arevalo
				created this file

	Copyright: 2004-2008 CFEmpire Corp.
	
	THIS FILE CAN NOT BE DISTRIBUTED WITHOUT THE EXPRESS CONSENT OF CFEMPIRE CORP.

----- --------------------------------------------------------------------- */

function resizeToClient(sec,offsetX,offsetY) {
	var newHeight = 0;
	var newWidth = 0;
	var clientHeight = 0;
	var clientWidth = 0;

//	if(window.innerHeight)  clientHeight = window.innerHeight;
//	else if (document.body) clientHeight = document.body.clientHeight;

	if (document.documentElement && document.documentElement.clientHeight)
		clientHeight = document.documentElement.clientHeight;
	else if (document.body)
		clientHeight = document.body.clientHeight	


	if (document.documentElement && document.documentElement.clientWidth)
		clientWidth = document.documentElement.clientWidth;
	else if (document.body)
		clientWidth = document.body.clientWidth	
	
	newHeight = clientHeight - offsetY;	
	newWidth = clientWidth - offsetX;	
	//alert("sec:" + sec +"    clientHeight:" + clientHeight + "   offsetY:"+offsetY);
	
	var s = document.getElementById(sec);
	if(s) {
		if(offsetY > -1) s.style.height = newHeight + "px";
		if(offsetX > -1) s.style.width = newWidth + "px";
	}
}	

function isIE() {
	var browser=navigator.appName;
	var b_version=navigator.appVersion;
	var version=parseFloat(b_version);
	return (browser=="Microsoft Internet Explorer");
}

function isMoz() {
	if(document.body)
		return true;
	else
		return false;
}

function cleardiv(id) {
	$(id).innerHTML = "";
}

function divon(divid){
	new Effect.Appear(divid,{duration: .2});
}

function divoff(divid){
	new Effect.Fade(divid,{duration: .2});
}

function createCookie(name,value,days) {
	if (days) {
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}

function readCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function eraseCookie(name) {
	createCookie(name,"",-1);
}


/*
    Written by Jonathan Snook, http://www.snook.ca/jonathan
    Add-ons by Robert Nyman, http://www.robertnyman.com
*/

function getElementsByClassName(oElm, strTagName, strClassName){
    var arrElements = (strTagName == "*" && oElm.all)? oElm.all : oElm.getElementsByTagName(strTagName);
    var arrReturnElements = new Array();
    strClassName = strClassName.replace(/\-/g, "\\-");
    var oRegExp = new RegExp("(^|\\s)" + strClassName + "(\\s|$)");
    var oElement;
    for(var i=0; i<arrElements.length; i++){
        oElement = arrElements[i];      
        if(oRegExp.test(oElement.className)){
            arrReturnElements.push(oElement);
        }   
    }
    return (arrReturnElements)
}
