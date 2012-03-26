<!-- ------------------------------------------------------------------------- ----
	
	File:		setup.cfm
	Author:		Oscar Arevalo
	Desc:		This file creates sample data to use with the example applications
	
					
	Update History:
				11/18/2008 - Oscar Arevalo - created
				

	Copyright: 2004-2008 CFEmpire Corp.
	
	THIS FILE CAN NOT BE DISTRIBUTED WITHOUT THE EXPRESS CONSENT OF CFEMPIRE CORP.

----- --------------------------------------------------------------------- -->

<!------ DB SETTINGS ------------>
<cfset dsn = "webreportsdemo">
<cfset dbtype = "mysql">
<!------------------------------->

<cfset numCustomers = 100>
<cfset numOrders = 100>

<cfset oConfigBean = createObject("component","WebReports.common.components.lib.daoFactory.dbDataProviderConfigBean").init()>
<cfset oConfigBean.setDSN( dsn )>
<cfset oConfigBean.setDBType( dbtype )>
<cfset oDataProvider = createObject("component", "WebReports.common.components.lib.daoFactory.dbDataProvider").init( oConfigBean )>

<!--- create data objects --->
<cfset oCustomersDAO = createObject("component","WebReports.docs.samples.components.customersDAO").init( oDataProvider )>
<cfset oOrdersDAO = createObject("component","WebReports.docs.samples.components.ordersDAO").init( oDataProvider )>

<!--- define a pool for random data --->
<cfset aFirstNames = listToArray("John,Isabel,Roger,Nancy,Charles,Oscar,Mike,Maria,Luis,Eric")>
<cfset aLastNames = listToArray("Peterson,Michaels,Perez,Clayton,Viso,Cuenca,Gates,Smith,Donaldson,Wilkerson")>
<cfset aStates = listToArray("Alabama,Florida,Hawaii,Nevada,Washington,California,Georgia,North Carolina,South Carolina,New York,Colorado,Oregon")>
<cfset aCities = listToArray("Birmingham,Miami,Honolulu,Las Vegas,Seattle,Los Angeles,Atlanta,Durham,Charleston,New York,Boulder,Portland")>
<cfset aDomains = listToArray("gotmail.com,hmail.com,mahoo.com,bol.com,msm.net,metscape.org")>
<cfset aPaymentMethods = listToArray("paypal,creditcard,giftcard")>
<cfset aShipmentMethods = listToArray("FedEx,UPS,USPS Priority,USPS Ground")>
<cfset aCustomerNames = arrayNew(1)>		
		
<!--- create customers ---->
Creating customers....
<cfloop from="1" to="#numCustomers#" index="i">
	<cfset args = structNew()>
	<cfset args.firstName = aFirstNames[randRange(1,arrayLen(aFirstNames))]>
	<cfset args.lastName = aLastNames[randRange(1,arrayLen(aLastNames))]>
	<cfset args.email = lcase(left(args.firstName,1)) & lcase(args.lastName) & "@" & aDomains[randRange(1,arrayLen(aDomains))]>
	<cfset index = randRange(1,arrayLen(aStates))>
	<cfset args.city = aCities[index]>
	<cfset args.state = aStates[index]>
	<cfset args.phone = "(" & randRange(100,999) & ") " & randRange(100,999) & "-" & randRange(1111,9999)>
	<cfset oCustomersDAO.save( argumentCollection = args )>
	<cfset aCustomerNames[i] = args.firstName & " " & args.lastName>
</cfloop>
OK<br>

<!--- create orders ---->
Creating orders....
<cfloop from="1" to="#numOrders#" index="i">
	<cfset args = structNew()>
	<cfset args.orderDate = randRange(1,12) & "/" & randRange(1,28) & "/" & randRange(2006,2009)>
	<cfset args.customerID = randRange(1,numCustomers)>
	<cfset args.customerName = aCustomerNames[i]>
	<cfset args.subTotal = decimalFormat(rand() * randRange(1,10)*10)>
	<cfset args.shipping = randRange(0,50)>
	<cfset args.tax = randRange(0,1) * 0.7 * args.subtotal>
	<cfset args.total = args.subTotal + args.shipping + args.tax>
	<cfset args.paymentMethod = aPaymentMethods[randRange(1,arrayLen(aPaymentMethods))]>
	<cfset args.shipmentMethod = aShipmentMethods[randRange(1,arrayLen(aShipmentMethods))]>
	<cfset args.trackingNo = randRange(111111,99999) & "-" & randRange(111111,99999)>
	<cfset index = randRange(1,arrayLen(aStates))>
	<cfset args.shipToCity = aCities[index]>
	<cfset args.shipToState = aStates[index]>
	<cfset index = randRange(1,arrayLen(aStates))>
	<cfset args.billToCity = aCities[index]>
	<cfset args.billToState = aStates[index]>
	<cfset oOrdersDAO.save( argumentCollection = args )>
</cfloop>
OK<br>


