<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:template match="journal">
        <fo:root>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="simpleA4"
                                       page-height="29.7cm" page-width="21.0cm" margin="1.5cm" margin-top="1cm" margin-bottom="1cm">
                    <fo:region-body   margin-top="2.5cm" margin-bottom="0.5cm" region-name="xsl-region-body" extent="1cm"/>
                    <fo:region-before  region-name="xsl-region-before" display-align="after" />
                    <fo:region-after   region-name="xsl-region-after" display-align="before" extent="0.5cm"/>

                </fo:simple-page-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="simpleA4">
                <fo:static-content flow-name="xsl-region-before"  font-family="Helvetica" >
                     <xsl:apply-templates select="company"/>
                     <fo:block margin-top="15pt" margin-bottom="15pt" text-align="center" font-size="16pt" font-weight="bold" >
                         <xsl:value-of select="@pageName"/>
                         <xsl:value-of select="@from_l"/>
                         <xsl:value-of select="@firstBookingDate"/>
                         <xsl:value-of select="@to_l"/>
                         <xsl:value-of select="@lastBookingDate"/>
                     </fo:block>
                </fo:static-content>


                <fo:static-content flow-name="xsl-region-after"  font-family="Helvetica">
                    <fo:block  text-align="right" font-size="12pt" >
                        <fo:page-number />
                    </fo:block>
                </fo:static-content>

                <fo:flow flow-name="xsl-region-body">
                    <fo:block font-family="Helvetica" font-size="12pt">
                        <fo:table width="100%" column-gap="5pt" border-left ="1px solid black">
                            <fo:table-column column-width="14%" />
                            <fo:table-column column-width="5%" />
                            <fo:table-column column-width="10%" />
                            <fo:table-column column-width="40%"/>
                            <fo:table-column column-width="12%"/>
                            <fo:table-column column-width="10%"/>
                            <fo:table-column column-width="10%"/>

                            <fo:table-header font-weight="bold" >
                                <fo:table-row>
                                    <fo:table-cell border-top="1pt solid black" border-bottom="1pt solid black" border-right="1pt solid black">
                                        <fo:block text-align="center"  >
                                            <xsl:value-of select="@date_l"/>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell  border-top="1pt solid black"  border-bottom="1pt solid black" border-right="1pt solid black" display-align="after">
                                        <fo:block text-align="center"  >
                                            <xsl:value-of select="@number_l"/>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell  border-top="1pt solid black" border-bottom="1pt solid black" border-right="1pt solid black">
                                        <fo:block text-align="center" >
                                             <xsl:value-of select="@receiptNumber_l"/>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell  border-top="1pt solid black"  border-bottom="1pt solid black" border-right="1pt solid black" display-align="after">
                                        <fo:block text-align="left" margin-left="5pt">
                                            <xsl:value-of select="@description_l"/>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell  border-top="1pt solid black"  border-bottom="1pt solid black" border-right="1pt solid black" display-align="after">
                                        <fo:block text-align="center" >
                                            <xsl:value-of select="@amount_l"/>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell  border-top="1pt solid black"  border-bottom="1pt solid black" border-right="1pt solid black" display-align="after">
                                        <fo:block text-align="center" >
                                            <xsl:value-of select="@debit_l"/>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell  border-top="1pt solid black" border-bottom="1pt solid black" border-right="1pt solid black" display-align="after">
                                        <fo:block text-align="center" >
                                            <xsl:value-of select="@credit_l"/>
                                        </fo:block>
                                    </fo:table-cell>
                                </fo:table-row>
                            </fo:table-header>
                            <fo:table-body>
                                <xsl:apply-templates select="accountingEntry"/>
                                <fo:table-row>
                                    <fo:table-cell number-columns-spanned="4" border-top="1pt solid black" border-bottom="2pt solid black">
                                        <fo:block text-align="left" margin-left="5pt" font-weight="bold">
                                            <xsl:value-of select="@sum_l"/>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell border-top="1pt solid black" border-right="1pt solid black" border-bottom="2pt solid black">
                                        <fo:block text-align="right" margin-right="5pt" font-weight="bold">
                                            <xsl:value-of select="@sum"/>
                                        </fo:block>
                                    </fo:table-cell>
                                    <fo:table-cell number-columns-spanned="2" border-top="1pt solid black" border-right="1pt solid black" border-bottom="2pt solid black">
                                        <fo:block />
                                    </fo:table-cell>

                                </fo:table-row>
                            </fo:table-body>
                        </fo:table>
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

    <xsl:template match="accountingEntry">
        <fo:table-row>
            <fo:table-cell border-bottom="1pt solid black" border-right="1pt solid black">
                <fo:block text-align="right" margin-right="5pt">
                    <xsl:value-of select="@date"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border-bottom="1pt solid black" border-right="1pt solid black">
                <fo:block text-align="right" margin-right="5pt">
                    <xsl:value-of select="@number"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border-bottom="1pt solid black" border-right="1pt solid black" >
                <fo:block text-align="right" margin-right="5pt" >
                    <xsl:value-of select="@receiptNumber"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border-bottom="1pt solid black" border-right="1pt solid black">
                <fo:block text-align="left" margin-left="5pt">
                    <xsl:value-of select="@description"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border-bottom="1pt solid black" border-right="1pt solid black">
                <fo:block text-align="right" margin-right="5pt">
                    <xsl:value-of select="@amount"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border-bottom="1pt solid black" border-right="1pt solid black">
                <fo:block text-align="right" margin-right="5pt">
                    <xsl:value-of select="@debit"/>
                </fo:block>
            </fo:table-cell>
            <fo:table-cell border-bottom="1pt solid black" border-right="1pt solid black" >
                <fo:block text-align="right" margin-right="5pt">
                    <xsl:value-of select="@credit"/>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>

</xsl:stylesheet>