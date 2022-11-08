@IsTest
public class ExternalCaseStatusTriggerHandlerTest {
  @TestSetup
  static void setup() {
    createTestAccountsForDiputeCases();
  }

  @IsTest
  static void testRelatedCaseUpdate() {
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

    String caseRecordTypeName = 'Card_Dispute';
    Case newCase = TestDataFactory.insertDisputeCase(
      caseRecordTypeName,
      'OCV000000000'
    );

    Map<String, Object> dataMap = new Map<String, Object>{
      'External_System__c' => 'Pega_Smarts ',
      'External_Case_Id__c' => 'ABC1234',
      'Status' => 'Under Investigation'
    };
    newCase = TestDataFactory.updateCase(newCase, dataMap);

    //System.runAs(pegaIntegrationStatusUser) {
    newCase = [SELECT Id, Status FROM Case WHERE Id = :newCase.Id];
    verifyRelatedCaseUpdate(newCase);
    //}
  }

  private static void verifyRelatedCaseUpdate(Case theCase) {
    String caseStatusBefore = theCase.Status;
    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = theCase.Id,
      External_Status__c = 'Pending-xxxxx',
      Status_Event_ID__c = 'Status_Event_ID__c_0'
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
    String caseStatusAfter = theCase.Status;
    System.assertEquals(
      caseStatusBefore,
      caseStatusAfter,
      'Case status should not change'
    );

    externalCaseStatus = new External_Case_Status__c(
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

  private static void createTestAccountsForDiputeCases() {
    Account newAccount = new Account();
    newAccount.Name = 'TestAccount';
    newAccount.Display_Name__c = 'TestAccount';
    newAccount.OCV_ID__c = 'OCV000000000';
    newAccount.ANZx_Customer__c = true;
    newAccount.External_Id__c = 'EXTERNALID_000';
    insert newAccount;

    FinServ__FinancialAccount__c newFinServFinancialAccount = new FinServ__FinancialAccount__c();
    newFinServFinancialAccount.Name = 'TestAccount';
    newFinServFinancialAccount.FinServ__Balance__c = 400;
    newFinServFinancialAccount.FinServ__CurrentPostedBalance__c = 400;
    newFinServFinancialAccount.FinServ__Status__c = 'Active';
    newFinServFinancialAccount.FinServ__FinancialAccountType__c = 'Checking';
    newFinServFinancialAccount.Account_Key__c = 'OCV000000000';
    newFinServFinancialAccount.Primary_Owner_Start_Date__c = Date.valueOf(
      '2021-01-21'
    );
    newFinServFinancialAccount.FinServ__PrimaryOwner__c = newAccount.Id;
    insert newFinServFinancialAccount;
  }
}
