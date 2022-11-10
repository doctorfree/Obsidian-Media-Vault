<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:output method="html" indent="yes" encoding="UTF-8"/>

<xsl:key name="songsByAlbum" match="dict"
  use="string[preceding-sibling::key[1]='Album']"/>
<xsl:key name="songsByGenre" match="dict"
  use="string[preceding-sibling::key[1]='Genre']"/>


<xsl:template match="/plist/dict/dict">
  <html>
    <body>
      <table>

        <xsl:for-each select="dict[generate-id(.)=
            generate-id(key('songsByGenre',string)[1])]">
          <xsl:sort select="string[preceding-sibling::key[1]='Genre']"/>
          <xsl:for-each select="key('songsByGenre',string)[1]">
            <xsl:call-template name="albumsInGenre">
              <xsl:with-param name="genre"
                  select="string[preceding-sibling::key[1]='Genre']"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:for-each>

      </table>
    </body>
  </html>
</xsl:template>


<xsl:template name="albumsInGenre">
  <xsl:param name="genre"/>

  <tr><td colspan='3'><b><xsl:value-of select="$genre"/></b></td></tr>

  <xsl:variable name="song" select="/plist/dict/dict/dict"/>
  <xsl:for-each select="$song[generate-id(.)=
      generate-id(key('songsByAlbum',string[preceding-sibling::key[1]='Album'])[1])]">
    <xsl:sort select="string[preceding-sibling::key[1]='Album']"/>
    <xsl:for-each select="key('songsByAlbum',string[preceding-sibling::key[1]='Album'])
        [string[preceding-sibling::key[1]='Genre']=$genre][1]">
      <tr>
        <td> </td>
        <td><xsl:call-template name="albumName"/></td>
        <td><xsl:call-template name="artistName"/></td>
      </tr>
    </xsl:for-each>
  </xsl:for-each>
</xsl:template>
</xsl:stylesheet>
