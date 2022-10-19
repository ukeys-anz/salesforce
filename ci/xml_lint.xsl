<!--
    Author: Mouhamed "Mo" Assafiri
    Date: Sept 22
    Description: Use this template to structure XML to order and style consistantly across the repo
    
    Note: If you wish to use this with SaxonJS, you must convert the file into a .sef.json which can be done with this command:
    npx xslt3 -xsl:ci/xml_lint.xsl -export:ci/xml_lint.sef.json
-->
<xsl:stylesheet version="1.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
xmlns:sf="http://soap.sforce.com/2006/04/metadata"
xmlns:saxon="http://saxon.sf.net/">
    <xsl:output indent="yes" saxon:indent-spaces="4"/>
    <xsl:strip-space elements="*"/>

    <!-- Keep all of SFDX's encoding within the document -->
    <xsl:character-map name="doc-entities">
        <xsl:output-character character="&quot;" string="&amp;quot;"/>
        <xsl:output-character character="&apos;" string="&amp;apos;"/>
        <xsl:output-character character="&lt;" string="&amp;lt;"/>
        <xsl:output-character character="&gt;" string="&amp;gt;"/>
    </xsl:character-map>
    <xsl:output use-character-maps="doc-entities" />
    
    <!-- Order Specific Meta's by putting the Full Name up the very top and the rest below -->
    <xsl:template match="
          sf:CustomField|sf:ValidationRule|
          sf:ListView|
          sf:SharingRules//sf:sharingCriteriaRules|
          sf:SharingRules//sf:sharingOwnerRules|
          sf:MatchingRules//sf:matchingRules|
          sf:CustomLabels//sf:labels|
          sf:Flow//sf:decisions|
          sf:Flow//sf:actionCalls//sf:processMetadataValues
          ">
        <xsl:copy>
            <xsl:apply-templates select="sf:fullName|sf:name"></xsl:apply-templates>
            <xsl:apply-templates select="node()[not(self::sf:fullName||self::sf:name)]">            
                <xsl:sort select="local-name()" data-type="text"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>

    <!--  Order Wave/EA XML -->
     <xsl:template match="
          sf:WaveDataflow|
          sf:WaveDashboard
          ">
        
        <xsl:copy>
            <xsl:copy-of select="sf:content"/>
            <xsl:apply-templates select="node()[not(self::sf:content)]">            
                <xsl:sort select="local-name()" data-type="text"/>
            </xsl:apply-templates>
        </xsl:copy>
    </xsl:template>


    <!-- Order Permission Sets Alphabetically and then order the nodes Alphabetically -->
    <xsl:template match="sf:PermissionSetGroup">
            <xsl:variable name="permissionSetGroup">
                <xsl:apply-templates select="node()">
                    <xsl:sort select="local-name()"/>
                    <xsl:sort select="." data-type="text"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:copy>
                <xsl:apply-templates select="$permissionSetGroup">
                    <xsl:sort select="local-name()"/>
                </xsl:apply-templates>
            </xsl:copy>

    </xsl:template>

    <!-- / End Permission Set -->


    <!-- For Everything else, order by Node Alphabetically -->
     <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()[not(self::comment())]">
                <xsl:sort select="local-name()"/>
            </xsl:apply-templates>

            <xsl:apply-templates select="comment()" />      
        </xsl:copy>
    </xsl:template>



</xsl:stylesheet>