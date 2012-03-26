<cfcomponent extends="WebReports.common.components.lib.daoFactory.DAO">

	<cffunction name="initTableParams" access="package" returntype="void" hint="setup table specific settings">
		<cfset setTableName("orders")>
		<cfset setPrimaryKey("orderID","cf_sql_numeric")>
		
		<cfset addColumn("orderDate", "cf_sql_date")>
		<cfset addColumn("customerName", "cf_sql_varchar")>
		<cfset addColumn("customerID", "cf_sql_numeric")>
		<cfset addColumn("subtotal", "cf_sql_float")>
		<cfset addColumn("shipping", "cf_sql_float")>
		<cfset addColumn("tax", "cf_sql_float")>
		<cfset addColumn("total", "cf_sql_float")>
		<cfset addColumn("paymentMethod", "cf_sql_varchar")>
		<cfset addColumn("shipmentMethod", "cf_sql_varchar")>
		<cfset addColumn("trackingNo", "cf_sql_varchar")>
		<cfset addColumn("shipToCity", "cf_sql_varchar")>
		<cfset addColumn("shipToState", "cf_sql_varchar")>
		<cfset addColumn("billToCity", "cf_sql_varchar")>
		<cfset addColumn("billToState", "cf_sql_varchar")>
	</cffunction>
	
</cfcomponent>