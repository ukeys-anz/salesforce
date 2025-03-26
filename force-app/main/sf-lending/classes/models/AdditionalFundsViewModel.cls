/**
 * @description View Model for For Category and Purpose Mapping and Additional funds records.
 * @author Jaya Srivastava
 * @since Nov 2024
 */
public with sharing class AdditionalFundsViewModel {
  /**
   * @description Additional Funds list
   */
  @AuraEnabled
  public List<AdditionalFunds> additionalFunds { get; set; }

  /**
   * @description Additional Funds record fields
   */
  public class AdditionalFunds {
    /**
     * @description Amount in addition Funds
     */
    @AuraEnabled
    public Decimal amount { get; set; }

    /**
     * @description Other Reason in addition Funds
     */
    @AuraEnabled
    public String otherReason { get; set; }

    /**
     * @description Purpose in addition Funds
     */
    @AuraEnabled
    public String purpose { get; set; }

    /**
     * @description blank constructor for parsing
     */
    public AdditionalFunds() {
    }
    /**
     * @description Assignment of Amount, OtherReason and Purpose
     * @param addFundRecord Additional_Fund__c
     */
    public AdditionalFunds(Additional_Fund__c addFundRecord) {
      this.amount = addFundRecord.Amount__c;
      this.otherReason = addFundRecord.Other_Reason__c;
      this.purpose = addFundRecord.Purpose__c;
    }
  }

  /**
   * @description blank constructor for parsing
   */
  public AdditionalFundsViewModel() {
  }

  /**
   * @description List of Additional Funds updated in Loan Preference Record
   * @param addFundsTransformedData List<Additional_Fund__c>
   */
  public AdditionalFundsViewModel(
    List<Additional_Fund__c> addFundsTransformedData
  ) {
    this.additionalFunds = new List<AdditionalFundsViewModel.AdditionalFunds>();
    for (Additional_Fund__c addFundRecord : addFundsTransformedData) {
      this.additionalFunds.add(new AdditionalFunds(addFundRecord));
    }
  }
}
