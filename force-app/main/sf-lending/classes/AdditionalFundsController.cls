/**
 * @description Controller for the Additional Funds feature.
 * @author Arpit Pittie
 * @since Nov 2024
 */
public with sharing class AdditionalFundsController {
  private static final AdditionalFundsRepository ADDITIONAL_FUNDS_SOQL_REPOSITORY = (AdditionalFundsRepository) Lib_InstanceProvider.forType(
    AdditionalFundsRepository.class
  );
  public static final String OBJECT_NAME = 'Additional_Fund__c';
  public static final String PURPOSE_FIELD_API_NAME = 'Purpose__c';

  /**
   * @description To get the category and purpose mapping
   * @return List<AdditionalFundsCategoryPurposeViewModel> List of Category to Purpose for Additional Funds
   */
  @AuraEnabled
  public static List<AdditionalFundsCategoryPurposeViewModel> getCategoryToPurposeMapping() {
    try {
      // Get Purpose Picklist entry values
      List<Schema.PicklistEntry> purposePicklistValueList = PicklistUtil.getPicklistEntries(
        OBJECT_NAME,
        PURPOSE_FIELD_API_NAME
      );
      // Get picklist API value to entry map
      Map<String, Schema.PicklistEntry> purposeValueToPicklistEntryMap = PicklistUtil.getPicklistValueToEntryMap(
        purposePicklistValueList
      );

      // Get Funds Category to Purpose Picklist Model
      List<AdditionalFundsCategoryPurposeViewModel> categoryPurposeViewModelList = AdditionalFundsHelper.getCategoryToListPurposeMap(
        purposeValueToPicklistEntryMap
      );

      return categoryPurposeViewModelList;
    } catch (Exception exp) {
      Logger.info(
        'Exception in getting the funds Purpose and Category Mapping',
        exp
      );
      Logger.saveLog();
      return null;
    }
  }
  /**
   * @description To get the list of Additional Fund records associated with the RLA(LoanApplicationFinancial)
   * @param recordId Id
   * @return AdditionalFundsViewModel
   */
  @AuraEnabled
  public static AdditionalFundsViewModel getAdditionFundsForLoanPreference(
    Id recordId
  ) {
    try {
      List<Additional_Fund__c> additionalFundsForLoanPref = ADDITIONAL_FUNDS_SOQL_REPOSITORY.queryAddFundByRLAWithoutRefinance(
        recordId
      );
      if (additionalFundsForLoanPref.isEmpty()) {
        throw new IllegalArgumentException(
          'No Additional Funds records found for the Loan Preference'
        );
      }
      AdditionalFundsViewModel addFundsRecords = new AdditionalFundsViewModel(
        additionalFundsForLoanPref
      );
      return addFundsRecords;
    } catch (Exception e) {
      Logger.info('Failure on fetching Additional Funds records', e);
      Logger.saveLog();
      return null;
    }
  }
}
