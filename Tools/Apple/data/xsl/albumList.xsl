<?xml version="1.0" encoding="UTF-8"?>

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

          <!-- totals -->
          <tr>
            <td colspan='4' style='color: gray'><b>Total</b></td>
            <td style='color: gray' align='right'><xsl:call-template name="iPodTimeTotal"/></td>
            <td style='color: gray' align='right'><xsl:call-template name="iTunesTimeTotal"/></td>
          </tr>
          <tr>
            <td colspan='4'> </td>
            <td style='color: gray' align='right'><xsl:call-template name="iPodSizeTotal"/></td>
            <td style='color: gray' align='right'><xsl:call-template name="iTunesSizeTotal"/></td>
          </tr>

        </table>
      </body>
    </html>
  </xsl:template>


  <xsl:template name="albumsInGenre">
    <xsl:param name="genre"/>

    <tr>  <!-- genre header -->
      <td colspan='4'><b><xsl:value-of select="$genre"/></b></td>
      <td align='right' style='color: gray'><i>iPod</i></td>
      <td align='right' style='color: gray'><i>iTunes</i></td>
    </tr>

    <xsl:variable name="song" select="/plist/dict/dict/dict"/>
    <xsl:for-each select="$song[generate-id(.)=
        generate-id(key('songsByAlbum',string[preceding-sibling::key[1]='Album'])[1])]">
      <xsl:sort select="string[preceding-sibling::key[1]='Album']"/>
      <xsl:for-each select="key('songsByAlbum',string[preceding-sibling::key[1]='Album'])
          [string[preceding-sibling::key[1]='Genre']=$genre]
          [1]">
          <!--  for albums on iPod only, add
                [not(true[preceding-sibling::key[1]='Disabled'])] -->
        <tr>
          <td> </td>
          <td><xsl:call-template name="album"/></td>
          <td><xsl:call-template name="artist"/></td>
          <td align='right'><xsl:call-template name="iPodTimeAlbum"/></td>
          <td align='right'><xsl:call-template name="iTunesTimeAlbum"/></td>
        </tr>
      </xsl:for-each>
    </xsl:for-each>
    <tr><td colspan='6'>&#160;</td></tr>  <!-- space between genres -->
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


  <xsl:template name="iPodTimeAlbum">
    <xsl:variable name="tracksInAlbum"
        select="key('songsByAlbum',string[preceding-sibling::key[1]='Album'])"/>
    <xsl:variable name="t"
        select="sum($tracksInAlbum/integer[preceding-sibling::key[1]='Total Time']
            [not(../true[preceding-sibling::key[1]='Disabled'])])"/>
    <xsl:call-template name="formatTime">
      <xsl:with-param name="t" select="$t"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="iTunesTimeAlbum">
    <xsl:variable name="tracksInAlbum"
        select="key('songsByAlbum',string[preceding-sibling::key[1]='Album'])"/>
    <xsl:variable name="t"
        select="sum($tracksInAlbum/integer[preceding-sibling::key[1]='Total Time'])"/>
    <xsl:call-template name="formatTime">
      <xsl:with-param name="t" select="$t"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="iPodTimeTotal">
    <xsl:variable name="t" select="sum(dict/integer[preceding-sibling::key[1]='Total Time']
        [not(../true[preceding-sibling::key[1]='Disabled'])])"/>
    <xsl:call-template name="formatTime">
      <xsl:with-param name="t" select="$t"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="iTunesTimeTotal">
    <xsl:variable name="t" select="sum(dict/integer[preceding-sibling::key[1]='Total Time'])"/>
    <xsl:call-template name="formatTime">
      <xsl:with-param name="t" select="$t"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="iPodSizeTotal">
    <xsl:variable name="s" select="sum(dict/integer[preceding-sibling::key[1]='Size']
        [not(../true[preceding-sibling::key[1]='Disabled'])])"/>
    <xsl:value-of select="floor($s div (1000000)) div 1000"/>GB
  </xsl:template>


  <xsl:template name="iTunesSizeTotal">
    <xsl:variable name="s" select="sum(dict/integer[preceding-sibling::key[1]='Size'])"/>
    <xsl:value-of select="floor($s div (1000000)) div 1000"/>GB
  </xsl:template>


  <xsl:template name="formatTime">
    <xsl:param name="t"/>
    <xsl:if test="$t != 0">
      <xsl:variable name="h" select="floor(($t div (1000*60*60)))"/>
      <xsl:variable name="m" select="floor(($t div (1000*60)) mod 60)"/>
      <xsl:variable name="s" select="floor(($t div 1000) mod 60)"/>
      <xsl:if test="$h != 0"><xsl:value-of select="$h"/>:</xsl:if>
      <xsl:value-of select="format-number($m,'00')"/>:<xsl:value-of select="format-number($s,'00')"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
