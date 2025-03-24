/**
 * @author Shivraj
 * @since Feb 2025
 * @description Test class for TrustMeCaseActions
 */
@IsTest
private class TrustMeCaseActionsTest {
  static Faker faker = new Faker('AU');
  static List<Id> caseIds = new List<Id>{
    Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    Lib_FakeIdGenerator.getMockId(Case.SObjectType)
  };

  static List<Case> caseTrustMeQARecord {
    get {
      List<Case> cases = new List<Case>();
      for (Id caseId : caseIds) {
        Case newCase = new Case(
          Id = caseId,
          Priority = 'Medium',
          Description = faker.randomString(10),
          Subject = 'FAILED_DOC',
          Origin = 'Origination',
          Status = 'Open',
          Fraud_Customer_Details__c = 'Yes',
          Fraud_MiddleNameCheck__c = 'Yes',
          Fraud_Selfie_Comparison_Match__c = 'Yes',
          Fraud_Address_Valid__c = 'Yes',
          Fraud_ID_Legible__c = 'Yes',
          Fraud_ID_Not_Picture__c = 'Yes',
          Fraud_Customer_Photo_Modified__c = 'Yes',
          RecordTypeId = RTCase.trustMeQA
        );
        cases.add(newCase);
      }
      return cases;
    }
  }

  @isTest
  static void testUpdateTestedDate() {
    Case theCase = caseTrustMeQARecord[0];
    TrustMeCaseActions.updateTestedDate(new List<Case>{ theCase });
    Assert.isNull(theCase.TestedDate__c, 'The Tested Date should be null');

    theCase.Fraud_Security_Features__c = 'Yes';
    TrustMeCaseActions.updateTestedDate(new List<Case>{ theCase });
    Assert.isNotNull(
      theCase.TestedDate__c,
      'The Tested Date should not be null'
    );
  }
}