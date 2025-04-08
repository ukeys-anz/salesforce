/**
 * @author Peter Charalambous
 * @since Tue Sep 24 2024
 * @description View model for assets finance section of getConsolidatedSOP API call
 */
public with sharing class SOPAssetsViewModel {
  @AuraEnabled
  public String ownerName;
  @AuraEnabled
  public Datetime updateTime;
  @AuraEnabled
  public String propertyAddress;
  @AuraEnabled
  public Decimal propertyValue;
  @AuraEnabled
  public String type;
  @AuraEnabled
  public String subType;
  @AuraEnabled
  public String assetName;
  @AuraEnabled
  public Decimal estimatedValue;
  @AuraEnabled
  public String propertyId;
  @AuraEnabled
  public String collateralAssessmentId;
  @AuraEnabled
  public Decimal calculatedValue;
  @AuraEnabled
  public String propertyCategory;
  @AuraEnabled
  public String source;
  @AuraEnabled
  public String belongsTo;
  @AuraEnabled
  public String ownershipSplit;

  /**
   * @description Constructor for Assets view model
   * @param sourceData API data to map
   * @param partyIdToFirstNameMap party id to first name map
   */
  public SOPAssetsViewModel(
    SOPGetConsolidatedModel.Assets sourceData,
    Map<String, String> partyIdToFirstNameMap
  ) {
    Map<String, String> ownershipMap = SOPHelper.buildOwnershipStrings(
      sourceData.ownership,
      partyIdToFirstNameMap
    );

    this.belongsTo = ownershipMap.get('belongs-to');
    this.ownershipSplit = ownershipMap.get('ownership-split');

    this.updateTime = sourceData.updateTime;
    this.type = sourceData.type;
    this.subType = sourceData.subType;
    this.assetName = sourceData.assetName;
    this.estimatedValue = SOPHelper.convertAmountToDecimal(
      sourceData.estimatedValue
    );
    this.propertyAddress = sourceData.address?.singleLineAddress;

    this.collateralAssessmentId = sourceData.collateralAssessmentId;
    this.calculatedValue = SOPHelper.convertAmountToDecimal(
      sourceData.calculatedValue
    );
    this.propertyCategory = sourceData.propertyCategory;
    this.source = sourceData.source?.get(0);
  }
}
