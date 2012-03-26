<!--- This template displays a system message --->
<cfparam name="messageBoxClass" default="standardMessageBox">

<!--- This indicates how to find the images within the HTML --->
<cfset IMAGES_ROOT = "images">

<!--- message contents are stored in cookies to persist across requests --->
<cfparam name="cookie.message_type" default="">
<cfparam name="cookie.message_text" default="">
<cfset msgStruct.type = cookie.message_type>
<cfset msgStruct.text = cookie.message_text>

<!--- expire cookies instead of just deleting them because of bluedragon compatibility,
seems that deleting from the cookie struct in BD does not actually erase the cookie --->
<cfcookie name="message_type" expires="now" value="">
<cfcookie name="message_text" expires="now" value="">
		
<!--- Render Message --->		
<cfif msgStruct.text neq "">
	<!--- Get image to display --->
	<cfif CompareNocase(msgStruct.type, "error") eq 0>
		<cfset img = "emsg.gif">
	<cfelseif CompareNocase(msgStruct.type, "warning") eq 0>
		<cfset img = "wmsg.gif">
	<cfelse>
		<cfset img = "cmsg.gif">
	</cfif>
	
	<cfoutput>
		<style type="text/css">
			##app_messagebox {
				border:1px dotted ##999999;
				background-image:none;
				background-color:##FFFFE0;
				font-family: Arial, Helvetica, sans-serif;
				font-size: 11px;
				font-weight: bold;
				padding:5px;
				z-index:9999;
			}		
		</style>
		
		<div id="app_messagebox" <cfif messageBoxClass eq "fancyMessageBox">style="display:none;"</cfif> class="#messageBoxClass#">
			<div style="background-color:##FFFFE0;font-family: Arial, Helvetica, sans-serif;font-size: 11px;font-weight: bold;">
				<img src="#IMAGES_ROOT#/#img#" align="absmiddle" alt="[#msgStruct.type#]"> #msgStruct.text#
			</div>
		</div>
	</cfoutput>
</cfif>
