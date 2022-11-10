<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
   <head>...</head>
   <body><xsl:apply-templates/></body>
  </html>
</xsl:template>

<xsl:template match="testsuites">
  <table>
    <thead>
      <tr><th>name</th><th>.....</th>
    </thead>
    <tbody>
      <xsl:apply-templates/>
    </tbody>
  </table>
</xsl:template>

<xsl:template match="testcase">
  <tr>
   <td><xsl:value-of select="@name"/>
   <td><xsl:value-of select="@status"/>
   <td><xsl:value-of select="@time"/>
   <td><xsl:value-of select="@classname"/>
  </tr>
</xsl:template>

</xsl:stylesheet>
