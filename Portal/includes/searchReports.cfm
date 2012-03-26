<style type="text/css">
	#searchBox {
		border:1px solid silver;
		background-color:#ebebeb;
		padding:10px;
		font-size:11px;
	}
	
	#searchBox form {
		margin:0px;
		padding:0px;
	}
	#searchBox input {
		font-size:11px;
	}
</style>

<cfparam name="searchTerm" default="">
<cfoutput>
	<div id="searchBox">
		<form name="frmSearch" method="post" action="index.cfm">
			<b>Search:</b>
			<input type="text" name="searchTerm" value="#searchTerm#">
			<input type="submit" name="btnSearch" value="Go!">
			<input type="hidden" name="event" value="ehGeneral.dspStart">
		</form>
	</div>
</cfoutput>
