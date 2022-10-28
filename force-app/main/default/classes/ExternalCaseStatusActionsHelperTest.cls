/**
 * @author Qing Wang
 * @since 07/2022
 * @description ExternalCaseStatusActionsHelperTest class is to test each method in ExternalCaseStatusActionsHelper class
 */

@isTest
public with sharing class ExternalCaseStatusActionsHelperTest {
  private static final String RESOLVED_ACQUIRER_LIABLE = 'Resolved-AcquirerLiable';
  private static final String RESOLVED_CARDHOLDER_LIABLE = 'Resolved-CardholderLiable';

  @testSetup
  static void steup() {
    Faker faker = new Faker('AU');

    Account[] accnts = new List<Account>();

    // Create a PersonAccount
    Account personAcc = new Account(
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('PersonAccount')
        .getRecordTypeId(),
      FirstName = faker.randomString(5),
      LastName = faker.randomString(5),
      OCV_ID__c = faker.randomString(15),
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
   * @description test getValidExternalStatuses to return valid External Case Status
   * Given Pega Status Integration User inserts two External Case Status records
   * AND one has External ID, the other does not
   * THEN getValidExternalStatuses returns a list contains only 1 valid ECS
   */
  @isTest
  static void testGetValidExternalStatuses() {
    ExternalCaseStatusActionsHelper.externalStatusToCaseStatusMap = new Map<String, String>{
      RESOLVED_ACQUIRER_LIABLE => 'Closed'
    };
    Test.startTest();

    Case parentCase = [
      SELECT Id
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.CARD_DISPUTE_RT_ID
      LIMIT 1
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
      Status_Event_ID__c = '1234567890'
    );
    newEscs.add(ecs2);

    insert newEscs;

    Test.stopTest();

    List<External_Case_Status__c> escs = [
      SELECT Id
      FROM External_Case_Status__c
    ];
    List<External_Case_Status__c> validECSs = ExternalCaseStatusActionsHelper.getValidExternalStatuses(
      escs
    );

    System.assertEquals(
      1,
      validECSs.size(),
      'Should have only 1 valid External Case Status.'
    );
  }

  /**
   * @description test getRelatedCases to return the master Case of given External Case Status
   * Given Pega Status Integration User inserts two External Case Status records
   * AND they have same master Case
   * THEN getRelatedCases returns a map contains only 1 Case
   */
  @isTest
  static void testGetRelatedCases() {
    ExternalCaseStatusActionsHelper.externalStatusToCaseStatusMap = new Map<String, String>{
      RESOLVED_ACQUIRER_LIABLE => 'Closed',
      RESOLVED_CARDHOLDER_LIABLE => 'Closed'
    };
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
      External_Status__c = RESOLVED_CARDHOLDER_LIABLE,
      Status_Event_ID__c = '1234567890'
    );
    newEscs.add(ecs2);

    insert newEscs;

    Test.stopTest();

    List<External_Case_Status__c> escs = [
      SELECT Id
      FROM External_Case_Status__c
    ];
    Map<String, Case> relateCases = ExternalCaseStatusActionsHelper.getRelatedCases(
      escs
    );

    System.assertEquals(
      1,
      relateCases.size(),
      'Should have only 1 related case in return result.'
    );
  }

  /**
   * @description test getLatestExternalStatusByCaseIdMap to return the latest External Cast Status for each given Case
   * Given Pega Status Integration User inserts two External Case Status records with different timestamp
   * AND they have same master Case
   * THEN getLatestExternalStatusByCaseIdMap returns a map with 1 entry, case id is the key and latest ECS is the value
   */
  @isTest
  static void testGetLatestExternalStatusByCaseIdMap() {
    ExternalCaseStatusActionsHelper.externalStatusToCaseStatusMap = new Map<String, String>{
      RESOLVED_ACQUIRER_LIABLE => 'Closed',
      RESOLVED_CARDHOLDER_LIABLE => 'Closed'
    };
    Test.startTest();

    Case parentCase = [
      SELECT Id
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.CARD_DISPUTE_RT_ID
      LIMIT 1
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
      External_Status__c = RESOLVED_CARDHOLDER_LIABLE,
      Status_Event_ID__c = '1234567890'
    );
    newEscs.add(ecs2);

    insert newEscs;

    Test.stopTest();

    List<External_Case_Status__c> escs = [
      SELECT Id, Case__c, CreatedDate
      FROM External_Case_Status__c
    ];
    External_Case_Status__c latestECS = [
      SELECT Id, Case__c, CreatedDate
      FROM External_Case_Status__c
      WHERE External_Status__c = :RESOLVED_ACQUIRER_LIABLE
    ];
    Map<String, External_Case_Status__c> caseWithLatestECS = ExternalCaseStatusActionsHelper.getLatestExternalStatusByCaseIdMap(
      escs
    );

    System.assertEquals(
      1,
      caseWithLatestECS.size(),
      'Should have only 1 entry in return result.'
    );
    System.assertEquals(
      latestECS.Id,
      caseWithLatestECS.values()[0].Id,
      'Should return the latest External Case Status.'
    );
  }

  @IsTest
  static void testExtenalStatusToCaseStatusMap() {
    ExternalCaseStatusActionsHelper.externalStatusToCaseStatusMap = null;
    Map<String, String> testExternalStatusToCaseStatusMap = ExternalCaseStatusActionsHelper.externalStatusToCaseStatusMap;
    System.debug(
      'testExternalStatusToCaseStatusMap: ' + testExternalStatusToCaseStatusMap
    );
    System.assertNotEquals(
      null,
      testExternalStatusToCaseStatusMap,
      'Map from Custom Metadata is not inititated'
    );
  }
}
