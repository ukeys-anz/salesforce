@isTest
private class LoanApplicationPropertyHelperTest {
  static Lib_MockProvider lapRepoMock;

  static List<Id> rlaIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(ResidentialLoanApplication.SObjectType),
    Lib_FakeIdGenerator.getMockId(ResidentialLoanApplication.SObjectType)
  };

  static List<Id> propertyIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(LoanApplicationProperty.SObjectType),
    Lib_FakeIdGenerator.getMockId(LoanApplicationProperty.SObjectType)
  };
  static Map<Id, LoanApplicationProperty> lapRecordsMap {
    get {
      List<Id> rlaIdsCopy = new List<Id>(rlaIds);
      Map<Id, LoanApplicationProperty> properties = new Map<Id, LoanApplicationProperty>();
      Integer i = 1;
      for (Id propertyId : propertyIds) {
        LoanApplicationProperty property = new LoanApplicationProperty(
          Id = propertyId,
          LoanApplicationId = rlaIdsCopy.remove(0),
          Collateral_Assessment_ID__c = 'fdsdfsdfsd' + String.valueOf(i)
        );
        i++;
        properties.put(property.LoanApplicationId, property);
      }
      return properties;
    }
  }

  static Map<Id, LoanApplicationProperty> lapOldMap {
    get {
      Map<Id, LoanApplicationProperty> propertyMap = new Map<Id, LoanApplicationProperty>();
      for (Id propertyId : propertyIds) {
        LoanApplicationProperty property = new LoanApplicationProperty(
          Id = propertyId
        );
        propertyMap.put(property.Id, property);
      }
      return propertyMap;
    }
  }

  @isTest
  static void updatedAssessmentIdPropertiesTest() {
    Map<Id, LoanApplicationProperty> properties = LoanApplicationPropertyHelper.updatedAssessmentIdProperties(
      lapRecordsMap.values(),
      lapOldMap
    );
    System.assertEquals(2, properties.size(), 'two properties expected');
  }

  @isTest
  static void updateCaseValuesTest() {
    List<Case> cases = new List<Case>();
    for (Id rlaId : rlaIds) {
      Case newCase = new Case(
        Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
        Loan_Application__c = rlaId
      );
      cases.add(newCase);
    }
    Test.startTest();
    List<Case> casewithNewValues = LoanApplicationPropertyHelper.updateCaseValues(
      cases,
      lapRecordsMap
    );
    Test.stopTest();
    System.assertEquals(
      lapRecordsMap.get(casewithNewValues[0].Loan_Application__c)
        .Collateral_Assessment_ID__c,
      casewithNewValues[0].Property_Valuation_Id__c,
      'property valuation id should be updated'
    );
  }
}
