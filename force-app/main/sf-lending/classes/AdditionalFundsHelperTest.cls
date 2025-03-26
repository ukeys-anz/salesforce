/**
 * @description Test class for {@link AdditionalFundsHelper}
 * @author Arpit Pittie
 * @since Nov 2024
 */
@isTest
public class AdditionalFundsHelperTest {
  @isTest
  public static void testGetCategoryToListPurposeMap() {
    Test.startTest();
    List<AdditionalFundsCategoryPurposeViewModel> categoryPurposeModel = AdditionalFundsHelper.getCategoryToListPurposeMap(
      getPicklistValueToEntryMap
    );
    Test.stopTest();

    Assert.isTrue(
      categoryPurposeModel.size() == 5,
      'Funds Category and Purpose Mapping size should be 5'
    );
    Assert.areEqual(
      'Renovation',
      categoryPurposeModel[0].category,
      'Renovation Fund should be in the category'
    );
    Assert.isTrue(
      categoryPurposeModel[0].purpose.size() == 2,
      'It should return rennovation list size 2'
    );
  }

  static Map<String, Schema.PicklistEntry> getPicklistValueToEntryMap {
    get {
      Map<String, Schema.PicklistEntry> picklistEntryMap = new Map<String, Schema.PicklistEntry>();
      String mapJSON = '{"LENDING_PURPOSE_PERSONAL_OTHER_PROPERTY_MAINTENANCE":{"active":true,"defaultValue":false,"label":"Maintenance, repairs and pools","validFor":null,"value":"LENDING_PURPOSE_PERSONAL_OTHER_PROPERTY_MAINTENANCE"},"LENDING_PURPOSE_ALTERATIONS_DWELLING_EXISTING":{"active":true,"defaultValue":false,"label":"Non-structural alterations or additions","validFor":null,"value":"LENDING_PURPOSE_ALTERATIONS_DWELLING_EXISTING"}}';
      picklistEntryMap = (Map<String, Schema.PicklistEntry>) JSON.deserialize(
        mapJSON,
        Map<String, Schema.PicklistEntry>.class
      );
      return picklistEntryMap;
    }
  }
}
