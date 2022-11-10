<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <!-- (c) Chris Veness 2005-2006 -->
  <xsl:output method="html" encoding="UTF-8" indent="yes"/>

  <!-- match the wrapper and apply templates to the <incl> xml file -->
  <xsl:template match="/wrapper">
    <xsl:apply-templates select="document(incl/@file)/plist/dict/dict"/>
  </xsl:template>

  <xsl:key name="songsByGenre" match="dict" use="string[preceding-sibling::key[1]='Genre']"/>
  <xsl:key name="songsByAlbum" match="dict" use="string[preceding-sibling::key[1]='Album']"/>

  <xsl:template match="dict">
    <html>
      <head>
        <title>iTunes Album Listing</title>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
        <style type='text/css'> td { vertical-align: top; padding-right: 1em; } </style>
      </head>
      <body>
        <table>

          <xsl:for-each select="dict[generate-id(.)=generate-id(key('songsByGenre',string)[1])]">
            <xsl:sort select="string[preceding-sibling::key[1]='Genre']"/>
            <xsl:for-each select="key('songsByGenre',string)[1]">
              <xsl:call-template name="albumsInGenre">
                <xsl:with-param name="genre" select="string[preceding-sibling::key[1]='Genre']"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:for-each>

        </table>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="albumsInGenre">
    <xsl:param name="genre"/>

    <tr>  <!-- genre header -->
      <td colspan='3'><b><xsl:value-of select="$genre"/></b></td>
    </tr>

    <xsl:variable name="song" select="/plist/dict/dict/dict"/>
    <xsl:for-each select="$song[generate-id(.)=
        generate-id(key('songsByAlbum',string[preceding-sibling::key[1]='Album'])[1])]">
      <xsl:sort select="string[preceding-sibling::key[1]='Album']"/>
      <xsl:for-each select="key('songsByAlbum',string[preceding-sibling::key[1]='Album'])
          [string[preceding-sibling::key[1]='Genre']=$genre]
          [1]">
        <tr>
          <td> </td>
          <td><xsl:call-template name="album"/></td>
          <td><xsl:call-template name="artist"/></td>
        </tr>
      </xsl:for-each>
    </xsl:for-each>
    <tr><td colspan='3'>&#160;</td></tr>  <!-- space between genres -->
  </xsl:template>

  <xsl:template name="album">
    <xsl:value-of select="string[preceding-sibling::key[1]='Album']"/>
  </xsl:template>

  <xsl:template name="artist">
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
