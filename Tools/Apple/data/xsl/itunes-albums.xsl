<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="html" indent="yes" encoding="UTF-8"/>

<xsl:key name="songsByAlbum" match="dict"
  use="string[preceding-sibling::key[1]='Album']"/>

<xsl:template match="/plist/dict/dict">
  <html>
    <body>
      <table>

        <xsl:for-each select="dict[generate-id(.)=generate-id(key('Album',string)[1])]">
          <xsl:sort select="string[preceding-sibling::key[1]='Album']"/>
          <tr>
            <td><xsl:call-template name="albumName"/></td>
            <td><xsl:call-template name="artistName"/></td>
          </tr>
        </xsl:for-each>

      </table>
    </body>
  </html>
</xsl:template>

<xsl:template name="albumName">
  <xsl:value-of select="string[preceding-sibling::key[1]='Album']"/>
</xsl:template>

<xsl:template name="artistName">
  <xsl:choose>
    <xsl:when test="true[preceding-sibling::key[1]='Compilation']">
      <i>Compilation</i>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="string[preceding-sibling::key[1]='Artist']"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>
</xsl:stylesheet>
