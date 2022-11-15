<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" />
  <xsl:param name="playlist" />
  <xsl:variable name="newline">
<xsl:text>
</xsl:text>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:for-each select="plist/dict/key[text()='Playlists']/ following-sibling::array/dict/key[text()='Name']/ following-sibling::string[text()=$playlist]/ following-sibling::key[text()='Playlist Items']/ following-sibling::array/dict">
      <xsl:call-template name="track">
        <xsl:with-param name="trackid" select="key[text()='Track ID']/following-sibling::integer" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="track">
    <xsl:param name="trackid" />
      <xsl:variable name="url" select="//plist/dict/key[text()='Tracks']/ following-sibling::dict/dict/key[text()='Track ID']/ following-sibling::integer[text()=$trackid]/../ key[text()='Location']/following-sibling::string" />
<xsl:value-of select="$url" /><xsl:value-of select="$newline" />
    </xsl:template>
</xsl:stylesheet>
