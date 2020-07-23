<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format">

    <xsl:template match="report">
        <fo:root>
            <fo:layout-master-set>
                <fo:simple-page-master master-name="simpleA4"
                                       page-height="29.7cm" page-width="21.0cm" margin="2cm">
                    <fo:region-body/>
                </fo:simple-page-master>
            </fo:layout-master-set>
            <fo:page-sequence master-reference="simpleA4">
                <fo:flow flow-name="xsl-region-body">
                    <fo:block font-family="Helvetica" font-size="16pt">
                        <fo:table width="100%">
                            <fo:table-column column-width="33%"/>
                            <fo:table-column column-width="33%"/>
                            <fo:table-column column-width="33%"/>
                            <fo:table-body>
                                <xsl:apply-templates select="accountingEntry"/>
                            </fo:table-body>
                        </fo:table>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
        </fo:root>
    </xsl:template>

    <xsl:template match="accountingEntry">
        <fo:table-row>
            <fo:table-cell>
                <fo:block>
                    <xsl:value-of select="@number"/>
                </fo:block>
            </fo:table-cell>
        </fo:table-row>
    </xsl:template>

</xsl:stylesheet>