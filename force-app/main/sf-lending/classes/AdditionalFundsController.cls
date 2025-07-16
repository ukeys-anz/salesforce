/**
 * @description Controller for the Additional Funds feature.
 * @author Arpit Pittie
 * @since Nov 2024
 */
public with sharing class AdditionalFundsController {
  private static final AdditionalFundsRepository ADDITIONAL_FUNDS_SOQL_REPOSITORY = (AdditionalFundsRepository) Lib_InstanceProvider.forType(
    AdditionalFundsRepository.class
  );

  /**
   * @description To get the list of Additional Fund records associated with the RLA(LoanApplicationFinancial)
   * @param recordId Id
   * @return AdditionalFundsViewModel
   */
  @AuraEnabled
  public static AdditionalFundsViewModel getAdditionFundsForLoanPreference(
    Id recordId
  ) {
    List<Additional_Fund__c> additionalFundsForLoanPref = ADDITIONAL_FUNDS_SOQL_REPOSITORY.queryAddFundByRLAWithoutRefinance(
      recordId
    );
    AdditionalFundsViewModel addFundsRecords = new AdditionalFundsViewModel(
      additionalFundsForLoanPref
    );
    return addFundsRecords;
  }

  /**
   * @description Retrieves all the records of metadata based on the Category in List<AdditionalFundsCategoryPurposeViewModel> format
   * @return List<AdditionalFundsCategoryPurposeViewModel>
   */
  @AuraEnabled
  public static List<AdditionalFundsCategoryPurposeViewModel> getCategoryToPurposeMapping() {
    List<Additional_Fund_Purpose_Mapping__mdt> catPurposeRecords = QueryAdditionalFundsPurposeMapping.getAll();

    List<AdditionalFundsCategoryPurposeViewModel.PurposeViewModel> purposeModelList = new List<AdditionalFundsCategoryPurposeViewModel.PurposeViewModel>();
    for (Additional_Fund_Purpose_Mapping__mdt record : catPurposeRecords) {
      AdditionalFundsCategoryPurposeViewModel.PurposeViewModel purposeRecord = new AdditionalFundsCategoryPurposeViewModel.PurposeViewModel(
        record
      );
      purposeModelList.add(purposeRecord);
    }

    Map<String, List<AdditionalFundsCategoryPurposeViewModel.PurposeViewModel>> categoryPurposeMap = (Map<String, List<AdditionalFundsCategoryPurposeViewModel.PurposeViewModel>>) ListUtil.groupBy(
      purposeModelList,
      'category',
      String.class
    );
    List<AdditionalFundsCategoryPurposeViewModel> viewModel = AdditionalFundsCategoryPurposeViewModel.convertToViewModel(
      categoryPurposeMap
    );
    return viewModel;
  }
}
