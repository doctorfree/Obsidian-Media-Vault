<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" /> 
<xsl:template match="/"> 
<xsl:for-each select="plist/dict/array/dict">
    <xsl:choose>
        <xsl:when test="child::integer[preceding-sibling::key[1]='Playlist ID']=4053"> 
        <xsl:for-each select="array/dict"> <!--**This should be relative**-->
            <xsl:value-of select="child::integer[preceding-sibling::key[1]='Track ID']"/>
            </xsl:for-each>
        </xsl:when>
    </xsl:choose>
</xsl:for-each>
</xsl:template>
</xsl:stylesheet>
