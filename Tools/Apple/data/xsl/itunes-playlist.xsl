<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" />
  <xsl:variable name="newline">
<xsl:text>
</xsl:text>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:for-each select="plist/dict/key[text()='Playlists']/ following-sibling::array/dict">
      <xsl:value-of select="key[text()='Name']/ following-sibling::string" /><xsl:value-of select="$newline" />
    </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
