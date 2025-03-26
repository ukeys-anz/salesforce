/**
 * @description Test class for {@link AdditionalFundsController}
 * @author Arpit Pittie
 * @since Nov 2024
 */
@isTest
public class AdditionalFundsControllerTest {
  static Lib_MockProvider picklistUtilMock;
  static Lib_MockProvider additionalFundRepoMock;

  static void registerMocks() {
    picklistUtilMock = Lib_MockProvider.forType(
      LoanApplicationFinancialRepository.class
    );
    picklistUtilMock.mock('getPicklistEntries', getpicklistEntries);
    picklistUtilMock.mock(
      'getPicklistValueToEntryMap',
      getPicklistValueToEntryMap
    );

    additionalFundRepoMock = Lib_MockProvider.forType(
        AdditionalFundsRepository.class
      )
      .mock('queryAddFundByRLAWithoutRefinance', getAddFund);
  }
  @isTest
  public static void testGetCategoryToPurposeMapping() {
    registerMocks();

    Test.startTest();
    List<AdditionalFundsCategoryPurposeViewModel> categoryPurposeModel = AdditionalFundsController.getCategoryToPurposeMapping();
    Test.stopTest();

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

  @isTest
  public static void testGetCategoryToPurposeMappingException() {
    registerMocks();
    QueryAdditionalFundsPurposeMapping.recordsByMasterLabel = null;

    Test.startTest();
    List<AdditionalFundsCategoryPurposeViewModel> categoryPurposeModel = AdditionalFundsController.getCategoryToPurposeMapping();
    Test.stopTest();

    Assert.isNull(
      categoryPurposeModel,
      'Exception occurred. Should return null'
    );
  }

  @isTest
  static void testGetAdditionalFundsSuccess() {
    Id recordId = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    registerMocks();
    Test.startTest();
    AdditionalFundsViewModel addFundRecords = AdditionalFundsController.getAdditionFundsForLoanPreference(
      recordId
    );
    Test.stopTest();
    Assert.areEqual(
      addFundRecords.additionalFunds[0].amount,
      1234.00,
      'Addition Funds Data fetched'
    );
  }

  @isTest
  static void testGetAdditionalFundsFailure() {
    Test.startTest();
    AdditionalFundsViewModel addFundRecords = AdditionalFundsController.getAdditionFundsForLoanPreference(
      null
    );
    Test.stopTest();
    Assert.isNull(addFundRecords, 'No records');
  }

  static List<Schema.PicklistEntry> getpicklistEntries {
    get {
      List<Schema.PicklistEntry> picklistEntryList = new List<Schema.PicklistEntry>();
      String listJSON = '[{"active":true,"defaultValue":false,"label":"Non-structural alterations or additions","validFor":null,"value":"LENDING_PURPOSE_ALTERATIONS_DWELLING_EXISTING"},{"active":true,"defaultValue":false,"label":"Maintenance, repairs and pools","validFor":null,"value":"LENDING_PURPOSE_PERSONAL_OTHER_PROPERTY_MAINTENANCE"}]';
      picklistEntryList = (List<Schema.PicklistEntry>) JSON.deserialize(
        listJSON,
        List<Schema.PicklistEntry>.class
      );
      return picklistEntryList;
    }
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

  static List<AdditionalFundsCategoryPurposeViewModel> getCategoryToListPurposeMap {
    get {
      List<AdditionalFundsCategoryPurposeViewModel> purposeCategoryMap = new List<AdditionalFundsCategoryPurposeViewModel>();
      String mapJSON = '[{"purpose":[{"value":"LENDING_PURPOSE_ALTERATIONS_DWELLING_EXISTING","label":"Non-structural alterations or additions"},{"value":"LENDING_PURPOSE_PERSONAL_OTHER_PROPERTY_MAINTENANCE","label":"Maintenance, repairs and pools"}],"category":"Renovation"}]';
      purposeCategoryMap = (List<AdditionalFundsCategoryPurposeViewModel>) JSON.deserialize(
        mapJSON,
        List<AdditionalFundsCategoryPurposeViewModel>.class
      );
      return purposeCategoryMap;
    }
  }

  /**
   * @description Static method to return Additional Fund Record
   */
  static List<Additional_Fund__c> getAddFund {
    get {
      List<Additional_Fund__c> addFundList = new List<Additional_Fund__c>();
      Additional_Fund__c addFund = new Additional_Fund__c();
      addFund.Id = Lib_FakeIdGenerator.getMockId(
        Additional_Fund__c.SObjectType
      );
      addFund.Amount__c = 1234.00;
      addFund.Other_Reason__c = 'Testing';
      addFund.Purpose__c = 'LENDING_PURPOSE_PERSONAL_MOTOR_VEHICLE_NEW';
      addFundList.add(addFund);
      return addFundList;
    }
  }
}
