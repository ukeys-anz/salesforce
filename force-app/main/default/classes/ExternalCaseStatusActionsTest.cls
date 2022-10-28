/**
 * @author Qing Wang
 * @since 07/2022
 * @description ExternalCaseStatusActionsTest class is to test each action in ExternalCaseStatusActions class
 */

@isTest
public with sharing class ExternalCaseStatusActionsTest {
  private static final String RESOLVED_ACQUIRER_LIABLE = 'Resolved-AcquirerLiable';
  private static final String RESOLVED_DUPLICATE = 'Resolved-Duplicate';

  @testSetup
  static void steup() {
    Faker faker = new Faker('AU');

    Account[] accnts = new List<Account>();

    // Create a PersonAccount
    Account personAcc = new Account(
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('PersonAccount')
        .getRecordTypeId(),
      FirstName = Faker.randomString(5),
      LastName = Faker.randomString(5),
      OCV_ID__c = 'PERSONOCV879879',
      ANZx_Customer__c = true
    );
    accnts.add(personAcc);

    Account a = new Account(
      Name = 'Complaint Entitlement Account',
      OCV_ID__c = faker.randomString(10),
      AR_C_Customer__c = true
    );
    accnts.add(a);
    insert accnts;

    Case disputeCase = new Case(
      RecordTypeId = GetHelpConstants.CARD_DISPUTE_RT_ID,
      AccountId = personAcc.Id,
      Auto_Created__c = false,
      Origin = '1',
      Description = 'Charged more than once for same purchase',
      Priority = 'High',
      Transaction_Id__c = '9be08660-23bb-4f12-b124-7cfe561ba086',
      External_System__c = 'Pega_Smarts', // mock test data has this field populated for meet Validation Rule
      External_Case_Id__c = 'ABC123'
    );
    insert disputeCase;

    // Update to 'Under Investigation'
    disputeCase.Status = GetHelpConstants.UNDER_INVESTIGATION_STATUS;
    update disputeCase;
  }

  /**
   * @description test updateCaseStatusFromLatestExternalStatus to update Case Status
   * Given Pega Status Integration User inserts two External Case Status records
   * AND they have resolved status
   * THEN the master case status is updated to Closed
   */
  @isTest
  public static void testUpdateCaseStatusFromLatestExternalStatus() {
    Test.startTest();

    Case parentCase = [
      SELECT Id
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.CARD_DISPUTE_RT_ID
    ];

    List<External_Case_Status__c> newEscs = new List<External_Case_Status__c>();

    External_Case_Status__c ecs1 = new External_Case_Status__c(
      Case__c = parentCase.Id,
      External_Status__c = RESOLVED_ACQUIRER_LIABLE,
      Status_Event_ID__c = '123456789'
    );
    newEscs.add(ecs1);

    External_Case_Status__c ecs2 = new External_Case_Status__c(
      Case__c = parentCase.Id,
      External_Status__c = RESOLVED_DUPLICATE,
      Status_Event_ID__c = '1234567890'
    );
    newEscs.add(ecs2);

    insert newEscs;

    Test.stopTest();

    Case updatedCase = [
      SELECT Id, Status
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.CARD_DISPUTE_RT_ID
      LIMIT 1
    ];

    System.assertEquals(
      GetHelpConstants.CLOSED_STATUS,
      updatedCase.Status,
      'Case Status should be Closed.'
    );
  }
}
