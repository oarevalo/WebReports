<cfparam name="request.requestState.oReport" default="">
<cfparam name="request.requestState.sampleSize" default="">

<cfset oReport = request.requestState.oReport>
<cfset lstPods = "Source,Columns,Groups,Sort,Filters">
<cfset reportTitle = trim(oReport.getTitle())>
<cfset reportSubtitle = trim(oReport.getSubTitle())>
<cfset sampleSize = request.requestState.sampleSize>

<div id="reportControls">
	<cfoutput>
	<cfloop list="#lstPods#" index="podName">
		<div class="pod" id="pod#podName#">
			<div class="podTitle"><div style="margin:2px;">&nbsp;#podName#</div></div>
			<div class="podBody" style="display:none;" id="pod#podName#Body">
				<div style="margin:2px;" id="pod#podName#Content"></div>
			</div>
		</div>
	</cfloop>
	</cfoutput>
</div>

<cfoutput>
<div id="reportHeader">
	<table cellpadding="0" cellspacing="0" width="90%">
		<tr>
			<td nowrap="nowrap">
				Title: <input type="text" name="txtReportTitle" value="#reportTitle#" style="width:200px;padding:2px;" onchange="doEvent('ehGeneral.doSetReportTitle','StatusBar',{title:this.value})">&nbsp;&nbsp;&nbsp;
				Subtitle: <input type="text" name="txtReportSubtitle" value="#reportSubtitle#" style="width:200px;padding:2px;" onchange="doEvent('ehGeneral.doSetReportSubtitle','StatusBar',{subtitle:this.value})">
			</td>
			<td align="right" nowrap="nowrap" style="font-size:10px;">
				Sample Size: #sampleSize# rows
			</td>
		</tr>
	</table>
</div>
</cfoutput>

<div id="reportPreview">
	<iframe width="400" 
			height="400" 
			src="includes/blankPreview.htm"
			scrolling="no" 
			id="reportPreviewIfr" 
			frameborder="0"></iframe>
</div>


