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
  public class AdditionalFunds implements Comparable {
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
     * @description Purpose Label in addition Funds
     */
    @AuraEnabled
    public String purposeLabel { get; set; }

    /**
     * @description category in addition Funds
     */
    @AuraEnabled
    public String category { get; set; }

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
      Additional_Fund_Purpose_Mapping__mdt purposeMetadata = QueryAdditionalFundsPurposeMapping.getByPurpose(
        addFundRecord.Purpose__c
      );

      this.amount = addFundRecord.Amount__c;
      this.otherReason = addFundRecord.Other_Reason__c;
      this.purpose = addFundRecord.Purpose__c;
      this.purposeLabel = purposeMetadata?.Purpose_Label__c;
      this.category = purposeMetadata?.Category__c;
    }
    /**
     * @description Sorting based on Category and Purpose
     * @param compareTo
     * @return Integer
     */
    public Integer compareTo(Object compareTo) {
      AdditionalFunds compareToFunds = (AdditionalFunds) compareTo;
      Additional_Fund_Purpose_Mapping__mdt purposeMetadata = QueryAdditionalFundsPurposeMapping.getByPurpose(
        purpose
      );
      Additional_Fund_Purpose_Mapping__mdt compareToPurposeMetadata = QueryAdditionalFundsPurposeMapping.getByPurpose(
        compareToFunds.purpose
      );

      // Sorting based on Category

      Integer categorySort = Integer.valueOf(
        purposeMetadata?.Sorting_Category__c ?? 0
      );
      Integer categoryToCompareSort = Integer.valueOf(
        compareToPurposeMetadata?.Sorting_Category__c ?? 0
      );

      if (categorySort != categoryToCompareSort) {
        return categorySort - categoryToCompareSort;
      }
      // Sorting Based on Purpose if Category Sorting is equal

      Integer purposeSort = Integer.valueOf(
        purposeMetadata?.Sorting_Purpose__c ?? 0
      );
      Integer purpseToCompareSort = Integer.valueOf(
        compareToPurposeMetadata?.Sorting_Purpose__c ?? 0
      );

      return purposeSort - purpseToCompareSort;
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
    this.additionalFunds.sort();
  }
}
