<div class="helpBox" style="padding:15px;font-size:12px;line-height:18px;border:1px solid silver;margin-bottom:20px;margin-right:20px;">
	<div style="font-weight:bold;color:green;font-size:14px;margin-bottom:8px;">Congratulations!</div> 
	It appears that this is the first time using the WebReports Portal, 
	please complete the following form to create an administrator user and get started managing your
	reports library.
</div>

<form name="frm" method="post" action="index.cfm">
	<input type="hidden" name="event" value="ehSetup.doCreateAdmin">
	<br>
	<table>
		<tr>
			<td><strong>Username:</strong></td>
			<td><input type="text" name="username" value=""></td>
		</tr>
		<tr>
			<td>First Name:</td>
			<td><input type="text" name="firstName" value=""></td>
		</tr>
		<tr>
			<td>Last Name:</td>
			<td><input type="text" name="lastName" value=""></td>
		</tr>
		<tr>
			<td><strong>Password:</strong></td>
			<td><input type="password" name="password" value=""></td>
		</tr>
		<tr>
			<td><strong>Confirm Password:</strong></td>
			<td><input type="password" name="password2" value=""></td>
		</tr>
	</table>
	<br>
	<input type="submit" name="btnSubmit" value="Submit">
	<span style="font-size:11px;margin-left:20px;">* Fields in <b>BOLD</b> are required.</span>
</form>