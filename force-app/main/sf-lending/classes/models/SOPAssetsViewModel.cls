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

  /**
   * @description Constructor for Assets view model
   * @param sourceData API data to map
   * @param partyIdToFirstNameMap party id to first name map
   * @param properties list of properties for property assets
   */
  public SOPAssetsViewModel(
    SOPGetConsolidatedModel.Assets sourceData,
    Map<String, String> partyIdToFirstNameMap,
    List<LoanApplicationProperty> properties
  ) {
    this.ownerName = sourceData.ownership.size() == 1
      ? partyIdToFirstNameMap.get(sourceData.ownership[0].partyId)
      : 'Joint';
    this.updateTime = sourceData.updateTime;
    this.type = sourceData.type;
    this.subType = sourceData.subType;
    this.assetName = sourceData.assetName;
    this.estimatedValue = SOPHelper.convertAmountToDecimal(
      sourceData.estimatedValue
    );
    //Populate property details
    if (sourceData.type == 'ASSET_TYPE_PROPERTY' && !properties.isEmpty()) {
      for (LoanApplicationProperty lap : properties) {
        if (lap.Property_ID__c == sourceData.propertyId) {
          this.propertyAddress = lap.Name;
          this.propertyValue = lap.PropertyValue;
        }
      }
    }
  }
}
