/**
 * @description test class for LoanApplicationPropertyActions
 * @author @fangl6
 * @since 17/06/2024
 */
@isTest
private class LoanApplicationPropertyActionsTest {
  static Faker faker = new Faker('AU');
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider lapRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    lapRepoMock = Lib_MockProvider.forType(
        LoanApplicationPropertyRepository.class
      )
      .mock('queryRelatedCase', relatedCases);
  }

  static List<Id> rlaIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(ResidentialLoanApplication.SObjectType),
    Lib_FakeIdGenerator.getMockId(ResidentialLoanApplication.SObjectType)
  };

  static List<Id> propertyIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(LoanApplicationProperty.SObjectType),
    Lib_FakeIdGenerator.getMockId(LoanApplicationProperty.SObjectType)
  };

  static List<Case> relatedCases {
    get {
      List<Case> cases = new List<Case>();
      for (Id rlaId : rlaIds) {
        Case newCase = new Case(
          Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
          Loan_Application__c = rlaId
        );
        cases.add(newCase);
      }
      return cases;
    }
  }

  static List<LoanApplicationProperty> lapRecords {
    get {
      List<LoanApplicationProperty> properties = new List<LoanApplicationProperty>();
      List<Id> rlaIdsCopy = new List<Id>(rlaIds);
      for (Id propertyId : propertyIds) {
        LoanApplicationProperty property = new LoanApplicationProperty(
          Id = propertyId,
          LoanApplicationId = rlaIdsCopy.remove(0),
          Collateral_Assessment_ID__c = faker.randomString(12)
        );
        properties.add(property);
      }
      return properties;
    }
  }

  static Map<Id, LoanApplicationProperty> lapOldMap {
    get {
      Map<Id, LoanApplicationProperty> propertyMap = new Map<Id, LoanApplicationProperty>();
      List<Id> rlaIdsCopy = new List<Id>(rlaIds);
      for (Id propertyId : propertyIds) {
        LoanApplicationProperty property = new LoanApplicationProperty(
          Id = propertyId,
          LoanApplicationId = rlaIdsCopy.remove(0)
        );
        propertyMap.put(property.Id, property);
      }
      return propertyMap;
    }
  }

  @isTest
  static void updateRelatedCasesTest() {
    registerMocks();

    Test.startTest();
    LoanApplicationPropertyActions.updateRelatedCases(lapRecords, lapOldMap);
    Test.stopTest();
    List<Case> cases = (List<Case>) dmlRepoMock.getHistory('updateRecords')
      .getParam('records');

    System.assertNotEquals(
      null,
      cases[0].Property_Valuation_Id__c,
      'The property valuation id should be the same as the value we are setting'
    );
    System.assertNotEquals(
      null,
      cases[1].Property_Valuation_Id__c,
      'The property valuation id should be the same as the value we are setting'
    );
  }

  @isTest
  static void updateRelatedCasesNegativeTest() {
    registerMocks();
    lapRepoMock = Lib_MockProvider.forType(
        LoanApplicationPropertyRepository.class
      )
      .mock('queryRelatedCase', new List<Case>());

    Test.startTest();
    LoanApplicationPropertyActions.updateRelatedCases(
      lapOldMap.values(),
      lapOldMap
    );
    Test.stopTest();
    Lib_MockProvider.MockHistory history = dmlRepoMock.getHistory(
      'updateRecords'
    );
    System.assertEquals(
      '()',
      String.valueOf(history.listOfArgs[0]),
      'no records should be passed'
    );
  }
}
