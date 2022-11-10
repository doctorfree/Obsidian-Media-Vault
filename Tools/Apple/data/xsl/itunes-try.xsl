    <xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes"/>
     
    <xsl:template match="/plist">
      <FMPXMLRESULT xmlns="http://www.filemaker.com/fmpxmlresult">
        <!-- FIELDS -->
        <METADATA>
          <FIELD NAME="Track ID"/>
          <FIELD NAME="Name"/>
          <FIELD NAME="Artist"/>
          <!-- add more fields here -->
        </METADATA>
        <!-- DATA -->
        <RESULTSET>
          <xsl:for-each select="dict/dict/dict">
            <ROW>
              <COL>
                <DATA>
                  <xsl:value-of select="key[.='Track ID']/following-sibling::integer"/>
                </DATA>
              </COL>
              <COL>
                <DATA>
                  <xsl:value-of select="key[.='Name']/following-sibling::string"/>
                </DATA>
              </COL>
              <COL>
                <DATA>
                  <xsl:value-of select="key[.='Artist']/following-sibling::string"/>
                </DATA>
              </COL>
              <!-- add more COLs here -->
            </ROW>
          </xsl:for-each>
        </RESULTSET>
      </FMPXMLRESULT>
    </xsl:template>
     
    </xsl:stylesheet>