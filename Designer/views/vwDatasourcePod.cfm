<cfparam name="request.requestState.aTables" default="#arrayNew(1)#">
<cfparam name="request.requestState.oReport" default="0">

<cfset aTables = request.requestState.aTables>
<cfset oReport = request.requestState.oReport>
<cfset reportTable = oReport.getTableName()>
<cfset bTableFound = false>

<cfset arraySort(aTables,"textnocase")>

<cfoutput>
	<div style="margin:3px;margin-bottom:10px;">
		Select the database object that will provide the data for the report.<br>
		<select name="tableName" 
				style="width:150px;font-size:10px;margin-top:5px;"
				onchange="document.location='index.cfm?event=ehDatasource.doSetDatasource&name='+this.value">
			<option value=""></option>
			<cfloop from="1" to="#arrayLen(aTables)#" index="i">
				<cfset table = aTables[i]>
				<cfif table eq reportTable>
					<cfset tmpSelected = "selected">
					<cfset bTableFound = true>
				<cfelse>
					<cfset tmpSelected = "">
				</cfif>
				<option value="#table#" <cfif table eq reportTable>selected</cfif>>#table#</option>
			</cfloop>
		</select>
		
		<cfif Not bTableFound and reportTable neq "">
			<div style="margin-top:5px;color:##CC3300;">
				** The report table was not found on the current database. Please
				check that you connected to the right database.
			</div>
		</cfif>
	</div>
</cfoutput>
