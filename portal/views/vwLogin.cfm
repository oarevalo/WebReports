
<style type="text/css">
	.frmLogin {
		padding:30px;
		width:250px;
		margin:0 auto;
	}
	input {
		font-size:10px;
		border:1px solid black;
	}
	td input {
		width:100px;
	}

	/* Show only to IE PC \*/
	* html .SectionTitle h2 {height: 1%;} /* For IE 5 PC */
	
	.Section {
		margin: 0 auto; /* center for now */
		/*width: 17em; *//* ems so it will grow */
		background: url(/WebReports/portal/images/sbbody-r.gif) no-repeat bottom right;
		/*font-size: 100%;*/
		border:0px;
		font-size:11px;
		font-family:Arial, Helvetica, sans-serif;
	}
	.SectionTitle {
		background: url(/WebReports/portal/images/sbhead-r.gif) no-repeat top right;
		margin: 0;
		padding: 0;
		text-align: left;
	}
	.SectionTitle h2 {
		text-align: left;
		background: url(/WebReports/portal/images/sbhead-l.gif) no-repeat top left;
		margin: 0;
		padding: 22px 30px 5px;
		color: white; 
		font-weight: bold; 
		font-size: 1.2em; 
		line-height: 1em;
	}	
	.SectionBody {
		background: url(/WebReports/portal/images/sbbody-l.gif) no-repeat bottom left;
		margin: 0;
		padding: 5px 30px 31px;
		padding-top:20px;
		text-align:left;
	}	
</style>


<form name="frm" action="index.cfm" method="post" class="frmLogin">
	<input type="hidden" name="event" value="ehGeneral.doLogin">
	
	<div class="Section">
		<div class="SectionTitle"><h2>WebReports Login</h2></div>
		<div class="SectionBody">
			
			<table>
				<tr>
					<td><b>Username:</b></td>
					<td><input type="text" name="username" value=""></td>
				</tr>
				<tr><td colspan="2" style="height:10px;"></td></tr>
				<tr>
					<td><b>Password:</b></td>
					<td><input type="password" name="password" value=""></td>
				</tr>
			</table>
			
			<p align="center">
				<input type="submit" name="btn" value="Login">	
				<input type="button" name="btnCancel" value="Cancel" onclick="document.location='index.cfm'">	
			</p>		
		</div>
	</div>
</form>
