/**
 * @author Peter Charalambous
 * @since Tue Oct 08 2024
 * @description View model for savings finance section of getConsolidatedSOP API call
 */
public with sharing class SOPSavingsViewModel {
  @AuraEnabled
  public String ownerName;
  @AuraEnabled
  public Datetime updateTime;
  @AuraEnabled
  public String type;
  @AuraEnabled
  public Decimal balance;
  @AuraEnabled
  public String productName;
  @AuraEnabled
  public String financialInstitution;
  @AuraEnabled
  public String bsb;
  @AuraEnabled
  public String accountNumber;
  @AuraEnabled
  public String accountStatus;

  /**
   * @description Constructor for Savings view model
   * @param sourceData API data to map
   * @param partyIdToFirstNameMap party id to first name map
   */
  public SOPSavingsViewModel(
    SOPGetConsolidatedModel.Assets sourceData,
    Map<String, String> partyIdToFirstNameMap
  ) {
    this.updateTime = sourceData.updateTime;
    this.type = sourceData.type;
    this.productName = sourceData.account?.productDetails?.marketingName;
    this.financialInstitution = sourceData.account?.financialInstitution;
    this.bsb = sourceData.account?.bsb;
    this.accountNumber = sourceData.account?.accountNumber;
    this.balance = SOPHelper.convertAmountToDecimal(sourceData.estimatedValue);
    this.ownerName = sourceData.ownership.size() == 1
      ? partyIdToFirstNameMap.get(sourceData.ownership?.get(0).partyId)
      : 'Joint';
    this.accountStatus = sourceData.account?.status;
  }
}
