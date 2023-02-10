@IsTest
public class ExternalCaseStatusTriggerHandlerTest {
  @TestSetup
  static void setup() {
    Account newAccount = TestDataFactory.createTestAccountForDisputeCases();
    insert newAccount;
    FinServ__FinancialAccount__c newFinServFinancialAccount = TestDataFactory.createTestFinAccountForDisputeCases();
    newFinServFinancialAccount.FinServ__PrimaryOwner__c = newAccount.Id;
    insert newFinServFinancialAccount;
    List<Case> theCases = new List<Case>();
    Case theCase1 = TestDataFactory.createCase('Card_Dispute');
    theCase1.AccountId = newAccount.Id;
    theCase1.FinServ__FinancialAccount__c = newFinServFinancialAccount.Id;
    theCases.add(theCase1);
    insert theCases;
  }

  @IsTest
  static void testExternalCaseStatusTriggerActions() {
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = 'Integration User'
      LIMIT 1
    ];
    User pegaIntegrationStatusUser = [
      SELECT Id, Name
      FROM User
      WHERE Name = 'Pega Status Integration User' AND ProfileId = :profile.Id
    ];
    System.assertNotEquals(
      null,
      pegaIntegrationStatusUser,
      'Pega Status Integration User doesn\'t exist'
    );

    String recordTypeDeveloperName = 'Card_Dispute';
    String predicate =
      'RecordType.DeveloperName = \'' +
      recordTypeDeveloperName +
      '\'';
    Case theCase = CommonUtil.getCaseRecordWithAllFields(
      recordTypeDeveloperName,
      predicate
    );

    Map<String, Object> dataMap = new Map<String, Object>{
      'External_System__c' => 'Pega_Smarts ',
      'External_Case_Id__c' => 'ABC1234',
      'Status' => 'Under Investigation'
    };
    theCase = TestDataFactory.updateCase(theCase, dataMap);

    //System.runAs(pegaIntegrationStatusUser) {
    theCase = [SELECT Id, Status FROM Case WHERE Id = :theCase.Id];
    String caseStatusBefore = theCase.Status;
    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = theCase.Id,
      External_Status__c = 'Pending-xxxxx',
      Status_Event_ID__c = 'Status_Event_ID__c_0'
    );
    Test.startTest();
    insert externalCaseStatus;
    Test.stopTest();
    theCase = [SELECT Id, Status, CaseNumber FROM Case WHERE Id = :theCase.Id];
    System.assertEquals(
      caseStatusBefore,
      theCase.Status,
      'Case status should not change'
    );
    verifyCloudEventForExternalCase(externalCaseStatus, theCase);
    verifyRelatedCaseUpdate(theCase);
    //}
  }

  private static void verifyCloudEventForExternalCase(
    External_Case_Status__c externalCaseStatus,
    Case theCase
  ) {
    System.assertEquals(
      1,
      CloudEventController.cloudEvents.size(),
      'Cloud Event should be generated'
    );
    System.assert(
      String.isNotBlank(CloudEventController.cloudEvents[0].Data_1__c),
      'Cloud Event should be generated'
    );
    String payload = CloudEventController.cloudEvents[0].Data_1__c;
    ExternalCaseStatusCloudEventModel externalCaseStatusCEModel = (ExternalCaseStatusCloudEventModel) JSON.deserialize(
      payload,
      ExternalCaseStatusCloudEventModel.class
    );

    Map<String, Object> mappedResponse = (Map<String, Object>) JSON.deserializeUntyped(
      payload
    );
    Map<String, Object> mappedResponse2 = (Map<String, Object>) mappedResponse.get(
      'ce_data'
    );
    ExternalCaseStatusCloudEventModel.ExternalCaseStatusCloudEventDataModel externalCaseStatusCloudEventDataModel = (ExternalCaseStatusCloudEventModel.ExternalCaseStatusCloudEventDataModel) JSON.deserialize(
      JSON.serialize(mappedResponse2),
      ExternalCaseStatusCloudEventModel.ExternalCaseStatusCloudEventDataModel.class
    );
    System.assertEquals(
      externalCaseStatus.Id,
      externalCaseStatusCloudEventDataModel.recordId,
      'External Case Status Id should match'
    );
    System.assertEquals(
      theCase.CaseNumber,
      externalCaseStatusCloudEventDataModel.caseNumber,
      'Case Number should match'
    );
    System.assertEquals(
      'ExternalStatusID/' + externalCaseStatus.Id,
      externalCaseStatusCEModel.ce_subject,
      'ce_subject should match'
    );
  }

  private static void verifyRelatedCaseUpdate(Case theCase) {
    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = theCase.Id,
      External_Status__c = 'Resolved-xxxxx',
      Status_Event_ID__c = 'Status_Event_ID__c_1'
    );
    try {
      insert externalCaseStatus;
    } catch (DmlException e) {
      System.assert(
        false,
        'Failed to create External Case Status record: ' + e.getMessage()
      );
    }
    theCase = [SELECT Id, Status FROM Case WHERE Id = :theCase.Id];
    System.assertEquals(
      'Closed',
      theCase.Status,
      'Case status should change to Closed Status'
    );

    externalCaseStatus = new External_Case_Status__c(
      Case__c = theCase.Id,
      External_Status__c = 'Pending-xxxxx',
      Status_Event_ID__c = 'Status_Event_ID__c_2'
    );
    try {
      insert externalCaseStatus;
    } catch (DmlException e) {
      System.assert(
        false,
        'External Case Status record should be created even when the Case is Closed: ' +
        e.getMessage()
      );
    }
    theCase = [SELECT Id, Status FROM Case WHERE Id = :theCase.Id];
    System.assertEquals(
      'Closed',
      theCase.Status,
      'Case status should be Closed'
    );
  }
}
