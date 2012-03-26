function FixedTable(vwName, hdrName) {
	this.viewPortName = vwName
	this.headerName = hdrName
	this.prevTopValue = 0
	if (is_ie5up) { this.assignHeaders() }
	if (is_gecko) { this.convertFormat() }
}

function assignFxHeaders() {
	var vwPorts = document.getElementsByTagName("DIV")
	for (var i=0; i<vwPorts.length; i++) {
		if (vwPorts[i].className == this.viewPortName) {
			var elem = vwPorts[i];
			elem.onscroll = fixHeaderTop;
			var rows = elem.getElementsByTagName("tr")
			for (var i=0; i<rows.length; i++) {
				if (rows[i].className == this.headerName) {
					elem.headElem = rows[i];
					return;
				}
			}
		}
	}
}
FixedTable.prototype.assignHeaders = assignFxHeaders

function convertCSSFormat() {
	var vwPorts = document.getElementsByTagName("DIV")
	for (var i=0; i<vwPorts.length; i++) {
		if (vwPorts[i].className == this.viewPortName){
			var vwPort = vwPorts[i]
			var sPort = getComputedStyle(vwPort,'')
			//var vwPortH = sPort.getPropertyCSSValue("height").getFloatValue(CSSPrimitiveValue.CSS_PX)
			var vwPortH = window.innerHeight;
			
			vwPort.style.overflow = "hidden"
			var rows = vwPort.getElementsByTagName("TR")
			for (var i=0; i<rows.length; i++) {
				if (rows[i].className == this.headerName) {
					var sHead = getComputedStyle(rows[i], '')
					var headHeight = sHead.getPropertyCSSValue("height").getFloatValue(CSSPrimitiveValue.CSS_PX)
				}
			}
			var fxTBodies = vwPort.getElementsByTagName("TBODY")
			fxTBodies[0].style.overflow = "auto"
			for (var i=0; i<fxTBodies.length; i++) {
				var fxTBody = fxTBodies[i]
				if(fxTBody.id=="ReportBody") {
					fxTBody.style.height = vwPortH - headHeight + "px"
				}
			}
		}
	}
}
FixedTable.prototype.convertFormat = convertCSSFormat

function fixHeaderTop() {
	var parElem = event.srcElement
	var offSet = parElem.scrollTop
	parElem.headElem.style.top = offSet - 1 + "px";
}
