
<!--- Parameters ---->
<cfparam name="attributes.Root">
<cfparam name="attributes.RowName">

<cfparam name="attributes.ColumnNames">
<cfparam name="attributes.ColumnMasks" default="">
<cfparam name="attributes.ColumnDataTypes" default="">
<cfparam name="attributes.ColumnWidths" default="">
<cfparam name="attributes.ColumnHREFs" default="">

<cfparam name="attributes.TotalNames" default="">
<cfparam name="attributes.TotalFunctions" default="">
<cfparam name="attributes.TotalMasks" default="">
<cfparam name="attributes.TotalLabels" default="">
<cfparam name="attributes.TotalMainLabel" default="">

<cfparam name="attributes.SortNames" default="">
<cfparam name="attributes.SortOrder" default="">
<cfparam name="attributes.SortDataTypes" default="">

<cfparam name="attributes.GroupNames">
<cfparam name="attributes.GroupTitles" default="">
<cfparam name="attributes.GroupDataTypes" default="">
<cfparam name="attributes.GroupMasks" default="">
<cfparam name="attributes.GroupDisplayTotals" default="">
<cfparam name="attributes.GroupDisplayContents" default="true">

<cfparam name="attributes.Index" type="numeric" default="#ListLen(attributes.GroupNames)#">
<cfparam name="attributes.KeyValue" default="''">


<cfscript>
	Index = attributes.index;
	Root = attributes.root;
	RowName = attributes.RowName;
	KeyValue = attributes.KeyValue;

	ColumnNames = attributes.ColumnNames;
	ColumnDataTypes = attributes.ColumnDataTypes;
	ColumnMasks = attributes.ColumnMasks;
	ColumnWidths = attributes.ColumnWidths;
	ColumnHREFs = attributes.ColumnHREFs;

	SortNames = attributes.SortNames;
	SortOrder = attributes.SortOrder;
	SortDataTypes = attributes.SortDataTypes;

	GroupNames = attributes.GroupNames;
	GroupTitles = attributes.GroupTitles;
	GroupDataTypes = attributes.GroupDataTypes;
	GroupMasks = attributes.GroupMasks;
	GroupDisplayTotals = attributes.GroupDisplayTotals;
	GroupDisplayContents = attributes.GroupDisplayContents;

	TotalNames = attributes.TotalNames;
	TotalFunctions  = attributes.TotalFunctions;
	TotalMainLabel = attributes.TotalMainLabel;
	TotalMasks = attributes.TotalMasks;
	TotalLabels = attributes.TotalLabels;
	
	aGroupNames = ListToArray(GroupNames);
	aGroupDataTypes = ListToArray(GroupDataTypes);
	aGroupMasks = ListToArray(GroupMasks,"|");

	NumColumns = ListLen(ColumnNames);
	NumGroups = ListLen(GroupNames);
	NumTotals = ListLen(TotalNames);
</cfscript>

<cfoutput>

<cfif attributes.Index gt 0>
	<cfscript>
		ThisGroupLevel = NumGroups - Index;
		NextGroupLevel = thisGroupLevel + 1;
		NextGroupName = aGroupNames[NextGroupLevel];
		NextGroupDataType = aGroupDataTypes[NextGroupLevel];
		NextGroupMask = aGroupMasks[NextGroupLevel];
		NewKeyValue = "concat(#keyValue#,#NextGroupName#)";	
		tmpCondition = "generate-id(.) = generate-id(key('Group_#NextGroupName#', #NewKeyValue#))";	
			
		if (Index eq NumGroups) {
			tmpSelect = "/#Root#/#RowName#[#tmpCondition#]";
		} else {
			ThisGroupName = aGroupNames[thisGroupLevel];
			tmpSelect = "key('Group_#ThisGroupName#',#KeyValue#)[#tmpCondition#]";
		}
	</cfscript>

	<xsl:for-each select="#tmpSelect#">
		<!---- Apply sorts ---->
		<cfloop from="1" to="#ListLen(SortNames)#" index="i">
			<xsl:sort  select="#ListGetAt(SortNames,i)#"
								order="#ListGetAt(SortOrder,i)#"
								data-type="#ListGetAt(SortDataTypes,i)#" />
		</cfloop>

		<!--- Display Group Heading --->
		<cfif ListGetAt(GroupTitles, NextGroupLevel) eq "Yes">
			<tr>
				<td>
					<xsl:attribute name="colspan">
						<xsl:value-of select="$NumberOfColumns" />
					</xsl:attribute>	
					
					<table cellpadding="0" cellspacing="0" class="GroupTable">
						<xsl:variable name="rownumber_#NextGroupLevel#">
							<xsl:number /> 
						</xsl:variable>
						<xsl:attribute name="id">
							<xsl:value-of select="concat('grpTbl_',concat($rownumber_#NextGroupLevel#, concat('_', #NextGroupLevel#)))"/>	
						</xsl:attribute>
						<thead class="PageHeader">
							<xsl:call-template name="DisplayGroupHeader">
								<xsl:with-param name="value" select="#NextGroupName#"/>
								<xsl:with-param name="datatype" select="'#LCase(NextGroupDataType)#'"/>
								<xsl:with-param name="mask" select="'#NextGroupMask#'"/>
								<xsl:with-param name="GroupLevel" select="#NextGroupLevel#"/>
								<xsl:with-param name="index" select="$rownumber_#NextGroupLevel#"/>
							</xsl:call-template>
						</thead>
						<tbody class="grpBody">
		</cfif>
		
		<!--- Display Group ---->
		<cf_XSL_Group 
						Root="#Root#"
						RowName="#RowName#" 
						Index="#Evaluate(Index-1)#" 
						KeyValue="#NewKeyValue#"
						ColumnNames="#ColumnNames#"
						ColumnDataTypes="#ColumnDataTypes#"
						ColumnMasks="#ColumnMasks#"
						ColumnWidths="#ColumnWidths#"
						ColumnHREFs="#ColumnHREFs#"	
						SortNames="#SortNames#"
						SortOrder="#SortOrder#"
						SortDataTypes="#SortDataTypes#"
						GroupTitles="#GroupTitles#"
						GroupNames="#GroupNames#" 
						GroupDataTypes="#GroupDataTypes#"
						GroupMasks="#GroupMasks#"
						GroupDisplayTotals="#GroupDisplayTotals#"
						GroupDisplayContents="#GroupDisplayContents#"
						TotalNames="#TotalNames#"
						TotalFunctions="#TotalFunctions#"
						TotalMainLabel="#TotalMainLabel#"
						TotalMasks="#TotalMasks#"
						TotalLabels="#TotalLabels#">

		<cfif ListGetAt(GroupTitles, NextGroupLevel) eq "Yes">
						</tbody>
						<!---- Display total for the previous group --->
						<cfif NumTotals gt 0  and ListGetAt(GroupDisplayTotals, NextGroupLevel) eq "Yes">
						<xsl:if test="string-length(#NextGroupName#) > 0">
							<tfoot>
								<cfif NumTotals eq 1 and not ListFindNoCase(columnNames,ListGetAt(TotalNames,1))>
									<cfset thisColumn = ListGetAt(TotalNames,1)>
									<cfset thisFunction = ListGetAt(TotalFunctions, 1)>
									<cfset thisMask = ListGetAt(TotalMasks, 1, "|")>
									<cfset thisTotal = "#LCase(thisFunction)#(key('Group_#NextGroupName#',#NewKeyValue#)/#thisColumn#)">
									<cfset thisLabel = ListGetAt(TotalLabels, 1)>
									<cfset thisLabel = Replace(thisLabel, "NOLABEL", "")>
										<xsl:variable name="thisTotal">
											<xsl:call-template name="DisplayData">
												<xsl:with-param name="value" select="#thisTotal#"/>
												<xsl:with-param name="datatype" select="'numeric'"/>
												<xsl:with-param name="mask" select="'#thisMask#'"/>
											</xsl:call-template>
										</xsl:variable>

										<xsl:call-template name="DisplayTotalRow">
											<xsl:with-param name="value" select="concat('#thisLabel#',$TotalMainLabel, $thisTotal)"/>
											<xsl:with-param name="class" select="'GroupHeader_#NextGroupLevel#'"/>
											<xsl:with-param name="GroupName" select="#NextGroupName#"/>
										</xsl:call-template>
								<cfelse>
									<!---- If there is more than one total column, but there is no total for the first column and
										there is a main total label, then display the main total label on the first column ---->
									<cfset UseFirstColumnForLabel = (NumTotals gt 0 
																	and TotalMainLabel neq ""
																	and ListFindNoCase(TotalNames,ListGetAt(ColumnNames,1)) eq 0)>
									<!--- Show the totals label in a row by itself:
									<xsl:call-template name="DisplayTotalRow">
										<xsl:with-param name="value" select="$TotalMainLabel"/>
										<xsl:with-param name="class" select="'GroupHeader_#NextGroupLevel#'"/>
										<xsl:with-param name="GroupName" select="#NextGroupName#"/>
									</xsl:call-template>
									---->
									<tr>
										<cfloop from="1" to="#NumColumns#" index="i">
											<cfset thisColumn = ListGetAt(ColumnNames,i)>
											<cfset tmpPos = ListFindNoCase(TotalNames,thisColumn)>
						
											<cfif UseFirstColumnForLabel and i eq 1>
												<td class="ReportGroupTotalCell_1">
													<xsl:variable name="thisGroupTotalLabel">
														<xsl:call-template name="DisplayGroupTotalLabel">
															<xsl:with-param name="value" select="$TotalMainLabel"/>
															<xsl:with-param name="GroupName" select="#NextGroupName#"/>
														</xsl:call-template>
													</xsl:variable>
													<xsl:value-of select="$thisGroupTotalLabel" />
												</td>
											<cfelse>
												<td class="ReportGroupTotalCell_#i#" <cfif i eq NumColumns>style="padding-right:20px;"</cfif>>
													<cfif tmpPos gt 0>
														<cfset thisFunction = ListGetAt(TotalFunctions, tmpPos)>
														<cfset thisMask = ListGetAt(TotalMasks, tmpPos, "|")>
														<cfset thisTotal = "#LCase(thisFunction)#(key('Group_#NextGroupName#',#NewKeyValue#)/#thisColumn#)">
														<cfset thisLabel = ListGetAt(TotalLabels, tmpPos, "|")>
														<cfset thisLabel = Replace(thisLabel, "NOLABEL", "")>
															#thisLabel#
															<xsl:call-template name="DisplayData">
																<xsl:with-param name="value" select="#thisTotal#"/>
																<xsl:with-param name="datatype" select="'numeric'"/>
																<xsl:with-param name="mask" select="'#thisMask#'"/>
															</xsl:call-template>
													</cfif>
												</td>
											</cfif>
										</cfloop>
									</tr> 
								</cfif>
								<xsl:call-template name="DisplayEmptyRow" />
							</tfoot>
						</xsl:if>
						<!--- <cfelse>
							<xsl:call-template name="DisplayEmptyRow" /> --->
						</cfif>
					</table>
				</td>
			</tr>
		</cfif>
	</xsl:for-each>

<cfelse>

	<!---- Show detail of group ---->
	<cfif isBoolean(GroupDisplayContents) and GroupDisplayContents>
		<cfif NumGroups gt 0>
			<cfset tmpSelect ="key('Group_#aGroupNames[NumGroups]#', #KeyValue#)">
		<cfelse>
			<cfset tmpSelect ="#Root#/#RowName#">
		</cfif>

		<xsl:for-each select="#tmpSelect#">
			<!---- Apply sorts ---->
			<cfloop from="1" to="#ListLen(SortNames)#" index="i">
				<xsl:sort  select="#ListGetAt(SortNames,i)#"
									order="#ListGetAt(SortOrder,i)#"
									data-type="#ListGetAt(SortDataTypes,i)#" />
			</cfloop>
	
			<tr valign="top" class="dataRow">
				<!---- Make rows alternate its background ---->
				<xsl:choose>
					<xsl:when test="(position() mod 2 = 1)">
						<xsl:attribute name="class">AlternatingRow_0</xsl:attribute>
					</xsl:when>			
					<xsl:otherwise>
						<xsl:attribute name="class">AlternatingRow_1</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
				
				<!---- Display cell contents  for this row ----->
				<cfloop from="1" to="#ListLen(ColumnNames)#" index="i">
					<cfset tmpHREF = xmlFormat(ListGetAt(ColumnHREFs,i))>
					<cfset tmpHREFExpr = "'#tmpHREF#'">
					
					<cfif tmpHREF neq "">
						<cfscript>
							index = 1;
							finished = false;
							aHREFTokens = arrayNew(1);
							while(Not finished) {
								stResult = reFindNoCase("\$[A-Za-z0-9 ]*\$", tmpHREF, index, true);
								
								if(stResult.len[1] gt 0) {
									// match found
									tokenOuter = mid(tmpHREF,stResult.pos[1],stResult.len[1]);
									tokenInner = mid(tmpHREF,stResult.pos[1]+1,stResult.len[1]-2);
									arrayAppend(aHREFTokens,tokenInner);	
									tmpHREF = replace(tmpHREF, tokenOuter, "%" & arrayLen(aHREFTokens), "ALL");
									index = stResult.pos[1] + stResult.len[1];
								} else {
									finished = true;
								}
							}
						</cfscript>

						<cfif arrayLen(aHREFTokens) gt 0>
							<xsl:variable name="rawFieldHREF#i#0">
								<xsl:value-of select="'#tmpHREF#'" />
							</xsl:variable>
							<cfloop from="1" to="#arrayLen(aHREFTokens)#" index="tokenIndex">
								<xsl:variable name="rawFieldHREF#i##tokenIndex#">
									<xsl:call-template name="str:subst">
										<xsl:with-param name="text" select="$rawFieldHREF#i##tokenIndex-1#"/>
										<xsl:with-param name="replace" select="'%#tokenIndex#'"/>
										<xsl:with-param name="with" select="#aHREFTokens[tokenIndex]#"/>
									</xsl:call-template>
								</xsl:variable>
							</cfloop>
							<cfset tmpHREFExpr = "$rawFieldHREF#i##arrayLen(aHREFTokens)#">
						</cfif>
					</cfif>
					
					<td class="ReportTableCell_#i#" <cfif i eq listLen(columnNames)>style="padding-right:20px;"</cfif>>
						<div class="ReportCell_#i#">
							<xsl:call-template name="DisplayData">
								<xsl:with-param name="value" select="#ListGetAt(ColumnNames,i)#"/>
								<xsl:with-param name="datatype" select="'#LCase(ListGetAt(ColumnDataTypes,i))#'"/>
								<xsl:with-param name="mask" select="'#ListGetAt(ColumnMasks,i,"|")#'"/>
								<xsl:with-param name="href" select="#tmpHREFExpr#"/>
							</xsl:call-template>
						</div>
					</td>
				</cfloop>
			</tr>								
		</xsl:for-each>
	</cfif>
</cfif>

</cfoutput>
	
	<cffunction name="throw" access="private" hint="Facade for cfthrow">
		<cfargument name="message" 		type="String" required="yes">
		<cfargument name="type" 		type="String" required="no" default="custom">
		<cfthrow type="#arguments.type#" message="#arguments.message#">
	</cffunction>
	
	<cffunction name="dump" access="private" hint="Facade for cfmx dump">
		<cfargument name="var" required="yes">
		<cfdump var="#var#">
	</cffunction>
	
	<cffunction name="abort" access="private" hint="Facade for cfabort">
		<cfabort>
	</cffunction>
