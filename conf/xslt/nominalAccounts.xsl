<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:template match="nominalAccounts">
        <fo:root>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="simpleA4"
                                       page-height="29.7cm" page-width="21.0cm" margin="1.5cm" margin-top="1cm">
                    <fo:region-body   margin-top="2cm" region-name="xsl-region-body" extent="1cm"/>
                    <fo:region-before  region-name="xsl-region-before" display-align="after" />

                </fo:simple-page-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="simpleA4">
                <fo:static-content flow-name="xsl-region-before"  font-family="Helvetica" >
                     <xsl:apply-templates select="company"/>
                     <fo:block margin-top="10pt" text-align="center" font-size="14pt" font-weight="bold" >
                         <xsl:value-of select="@pageName"/>
                         <xsl:text>   </xsl:text>
                         <xsl:value-of select="@accountingYear"/>
                     </fo:block>


                </fo:static-content>
                <fo:flow flow-name="xsl-region-body">
                    <fo:block font-family="Helvetica" font-size="12pt">

                        <xsl:apply-templates select="nominalAccount"/>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>

    <xsl:template match="company">
        <fo:table width="100%" column-gap="5pt" border-bottom="1px solid black">
            <fo:table-column column-width="80%" />
            <fo:table-column column-width="20%" />
            <fo:table-body border="1px solid black">
                <fo:table-row >
                    <fo:table-cell>
                        <fo:block text-align="left" font-size="12pt">
                            <xsl:value-of select="@name"/>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell>
                        <fo:block text-align="right" font-size="12pt">
                            <xsl:text> in €  </xsl:text>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
    </xsl:template>

    <xsl:template match="nominalAccount">
        <fo:block margin-top="20pt" text-align="left" font-weight="bold" font-size="13pt" >
            <xsl:text> Konto:  </xsl:text>
            <xsl:value-of select="@accountId"/>
            <xsl:text>  </xsl:text>
            <xsl:value-of select="@accountName"/>
        </fo:block>
        <fo:table width="100%" column-gap="5pt" border="1px solid black">
            <fo:table-column column-width="14%" />
            <fo:table-column column-width="10%" />
            <fo:table-column column-width="15%"/>
            <fo:table-column column-width="12%"/>
            <fo:table-column column-width="15%"/>
            <fo:table-column column-width="12%"/>
            <fo:table-column column-width="11%"/>
            <fo:table-column column-width="11%"/>

            <fo:table-header font-weight="bold" >
                <fo:table-row >
                    <fo:table-cell border-bottom="1px solid black" border-right="1px solid black">
                        <fo:block text-align="center" >
                                           <xsl:text>
                                               Datum
                                           </xsl:text>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border-bottom="1px solid black" border-right="1px solid black">
                        <fo:block text-align="center" >
                                             <xsl:text>
                                               Beleg- nr.
                                             </xsl:text>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell number-columns-spanned="3" border-bottom="1px solid black" border-right="1px solid black">
                        <fo:block text-align="left" margin-left="5pt">
                                            <xsl:text>
                                               Buchungstext
                                            </xsl:text>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border-bottom="1px solid black" border-right="1px solid black">
                        <fo:block text-align="center" >
                                            <xsl:text>
                                               Gegen- konto
                                            </xsl:text>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border-bottom="1px solid black" border-right="1px solid black">
                        <fo:block text-align="center" >
                                             <xsl:text>
                                               SOLL
                                             </xsl:text>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border-bottom="1px solid black">
                        <fo:block text-align="center" >
                                             <xsl:text>
                                               HABEN
                                             </xsl:text>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-header>
            <fo:table-body>
                <xsl:apply-templates select="nominalAccountEntry"/>
                <fo:table-row>
                    <fo:table-cell number-columns-spanned="6" border-bottom="2px solid black" border-top="1pt solid black" border-right="1pt solid black" >
                        <fo:block text-align="left" font-weight="bold" margin-right="5pt" margin-left="5pt">
                            Summe
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border-bottom="2px solid black" border-top="1pt solid black" border-right="1pt solid black">
                        <fo:block text-align="right" margin-right="5pt">
                            <xsl:value-of  select="@debitBalance"/>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border-bottom="2px solid black" border-top="1pt solid black"  >
                        <fo:block text-align="right" margin-right="5pt">
                            <xsl:value-of  select="@creditBalance"/>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>

                <fo:table-row>
                    <fo:table-cell number-columns-spanned="2"  border-right="1pt solid black">
                        <fo:block margin-right="5pt" margin-left="5pt">
                            gebucht bis
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell>
                        <fo:block text-align="left" margin-left="5pt">
                            EB-Wert:
                            </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border-right="1pt solid black">
                        <fo:block text-align="right" margin-right="5pt">
                           <xsl:value-of  select="@openingBalance"/>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell >
                        <fo:block text-align="left" margin-left="5pt">
                            Saldo-Neu:
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border-right="1pt solid black">
                        <fo:block text-align="right" margin-right="5pt">
                            <xsl:value-of  select="@balance"/>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell border-right="1pt solid black">
                        <fo:block text-align="right" margin-right="5pt">
                            <xsl:value-of  select="@revenue"/>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell>
                        <fo:block text-align="right" margin-right="5pt">
                            <xsl:value-of  select="@creditBalance"/>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
    </xsl:template>



    <xsl:template match="nominalAccountEntry">
        <fo:table-row>
            <fo:table-cell border-bottom="1px solid black" border-right="1px solid black">
                <fo:block text-align="right" margin-right="5pt">
                    <xsl:value-of select="@date"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border-bottom="1px solid black" border-right="1px solid black">
                <fo:block text-align="right" margin-right="5pt" >
                    <xsl:value-of select="@receiptNumber"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell number-columns-spanned="3" border-bottom="1px solid black" border-right="1px solid black">
                <fo:block text-align="left" margin-left="5pt">
                    <xsl:value-of select="@description"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border-bottom="1px solid black" border-right="1px solid black">
                <fo:block text-align="center" >
                    <xsl:value-of select="@offsetAccount"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border-bottom="1px solid black" border-right="1px solid black">
                <fo:block text-align="right" margin-right="5pt">
                    <xsl:value-of select="@debitAmount"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border-bottom="1px solid black">
                <fo:block text-align="right" margin-right="5pt">
                    <xsl:value-of select="@creditAmount"/>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>

</xsl:stylesheet>