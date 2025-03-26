/**
 * @description Helper for the Additional Funds feature.
 * @author Arpit Pittie
 * @since Nov 2024
 */
public with sharing class AdditionalFundsHelper {
  /**
   * @description To get mapping for Funds Category to the purpose picklist values
   * @param purposeValueToPicklistEntryMap PicklistEntry map for api name to picklistEntry
   * @return List<AdditionalFundsCategoryPurposeViewModel>
   */
  public static List<AdditionalFundsCategoryPurposeViewModel> getCategoryToListPurposeMap(
    Map<String, Schema.PicklistEntry> purposeValueToPicklistEntryMap
  ) {
    List<AdditionalFundsCategoryPurposeViewModel> purposeViewModel = new List<AdditionalFundsCategoryPurposeViewModel>();
    for (
      String category : QueryAdditionalFundsPurposeMapping.getAllMasterLabelKeys()
    ) {
      List<String> purposeList = QueryAdditionalFundsPurposeMapping.getByMasterLabel(
          category
        )
        ?.Purpose__c
        ?.split(';') ?? new List<String>();
      List<AdditionalFundsCategoryPurposeViewModel.PicklistEntryViewModel> pewList = new List<AdditionalFundsCategoryPurposeViewModel.PicklistEntryViewModel>();

      for (String subPurpose : purposeList) {
        if (!purposeValueToPicklistEntryMap.containsKey(subPurpose)) {
          continue;
        }
        Schema.PicklistEntry pe = purposeValueToPicklistEntryMap.get(
          subPurpose
        );
        AdditionalFundsCategoryPurposeViewModel.PicklistEntryViewModel pew = new AdditionalFundsCategoryPurposeViewModel.PicklistEntryViewModel(
          pe
        );
        pewList.add(pew);
      }
      AdditionalFundsCategoryPurposeViewModel categoryPurposeViewModel = new AdditionalFundsCategoryPurposeViewModel(
        category,
        pewList
      );
      purposeViewModel.add(categoryPurposeViewModel);
    }
    return purposeViewModel;
  }
}
