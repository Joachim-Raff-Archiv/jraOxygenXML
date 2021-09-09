<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">
      <xsl:output method="xml" encoding="UTF-8"/>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*">
        <xsl:sort select="analytic/title[@type='main']" data-type="text" order="ascending"/>
        <xsl:sort select="analytic/title[@type='subordinate']" data-type="text" order="ascending"/>
        <xsl:sort select="analytic/title[@type='subsubordinate']" data-type="text" order="ascending"/>
        <xsl:sort select="analytic/title[@type='other']" data-type="text" order="ascending"/>
        <xsl:sort select="analytic/title[@type='none']" data-type="text" order="ascending"/>
        <xsl:sort select="analytic/author" data-type="text" order="ascending"/>
        <xsl:sort select="analytic/editor" data-type="text" order="ascending"/>
        <xsl:sort select="analytic/ref" data-type="text" order="ascending"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
