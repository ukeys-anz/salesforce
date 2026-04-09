/**
 * @author Akanksha Kulkarni
 * @description Test class for ApplicationFormEventActions
 */
@isTest
public with sharing class ApplicationFormEventActionsTest {
  static Lib_MockProvider appFormRepoMock = Lib_MockProvider.forType(
    ApplicationFormEventRepository.class
  );

  /**************************************
   * TEST 1: Assisted_Broker__c lookup CHANGED
   **************************************/
  /**
   * @description Validates that an event is published when Assisted_Broker__c changes.
   */

  @isTest
  static void testApplicationFormAddAssistedBrokerChanged() {
    Account acc = createAccount();
    Contact broker1 = createContact();
    Contact broker2 = createContact();

    // OLD record
    ApplicationForm oldApp = createApplicationForm(acc.Id);
    oldApp.Assisted_Broker__c = broker1.Id;
    oldApp.Sync_Status__c = ApplicationFormEventActions.SYNC_STATUS_BROKER_ORG;

    // NEW record (same Id, changed Assisted_Broker__c)
    ApplicationForm newApp = createApplicationForm(acc.Id);
    newApp.Id = oldApp.Id;
    newApp.Assisted_Broker__c = broker2.Id;
    newApp.Sync_Status__c = ApplicationFormEventActions.SYNC_STATUS_BROKER_ORG;

    Map<Id, ApplicationForm> oldMap = new Map<Id, ApplicationForm>{
      oldApp.Id => oldApp
    };

    appFormRepoMock.mock(
      'getRelatedAccounts',
      new Map<Id, String>{ acc.Id => acc.External_Id__c }
    );

    Test.startTest();
    List<Cloud_Event__e> events = ApplicationFormEventActions.publishSimpleApplicationFormEvent(
      new List<ApplicationForm>{ newApp },
      oldMap,
      'applicationformadd'
    );
    Test.stopTest();

    System.assertEquals(
      1,
      events.size(),
      'Event must publish when Assisted_Broker__c lookup changes.'
    );
  }

  /**************************************
   * TEST 2: update context → always publishes
   **************************************/
  /**
   * @description Ensures an event is published when context is 'update'.
   */
  @isTest
  static void testPublishOnUpdateContext() {
    Account acc = createAccount();
    Contact broker = createContact();

    ApplicationForm app = createApplicationForm(acc.Id);
    app.Assisted_Broker__c = broker.Id;
    app.Sync_Status__c = ApplicationFormEventActions.SYNC_STATUS_BROKER_ORG;

    Map<Id, ApplicationForm> oldMap = null;

    appFormRepoMock.mock(
      'getRelatedAccounts',
      new Map<Id, String>{ acc.Id => acc.External_Id__c }
    );

    Test.startTest();
    List<Cloud_Event__e> events = ApplicationFormEventActions.publishSimpleApplicationFormEvent(
      new List<ApplicationForm>{ app },
      oldMap,
      'update'
    );
    Test.stopTest();

    System.assertEquals(
      1,
      events.size(),
      'Event should publish in update context.'
    );
  }

  /**************************************
   * TEST 3: Sync_Status__c = Blocked → No event
   **************************************/
  /**
   * @description Ensures no event is published when Sync_Status__c = 'Blocked'.
   */
  @isTest
  static void testSyncStatusBlockedNoEvent() {
    Account acc = createAccount();
    Contact broker = createContact();

    ApplicationForm app = createApplicationForm(acc.Id);
    app.Assisted_Broker__c = broker.Id;
    app.Sync_Status__c = ApplicationFormEventActions.SYNC_STATUS_BLOCKED;

    Map<Id, ApplicationForm> oldMap = null;

    appFormRepoMock.mock(
      'getRelatedAccounts',
      new Map<Id, String>{ acc.Id => acc.External_Id__c }
    );

    Test.startTest();
    List<Cloud_Event__e> events = ApplicationFormEventActions.publishSimpleApplicationFormEvent(
      new List<ApplicationForm>{ app },
      oldMap,
      'update'
    );
    Test.stopTest();

    System.assertEquals(
      0,
      events.size(),
      'Blocked record must NOT publish events.'
    );
  }

  /**************************************
   * TEST 4: Validate event field values
   **************************************/
  /**
   * @description Validates Cloud Event fields when publishing succeeds.
   */
  @isTest
  static void testCloudEventFieldValues() {
    Account acc = createAccount();
    Contact broker = createContact();

    ApplicationForm app = createApplicationForm(acc.Id);
    app.Assisted_Broker__c = broker.Id;
    app.Sync_Status__c = ApplicationFormEventActions.SYNC_STATUS_BROKER_ORG;
    app.Application_Number__c = 'AF00077';

    appFormRepoMock.mock(
      'getRelatedAccounts',
      new Map<Id, String>{ acc.Id => acc.External_Id__c }
    );

    Test.startTest();
    List<Cloud_Event__e> events = ApplicationFormEventActions.publishSimpleApplicationFormEvent(
      new List<ApplicationForm>{ app },
      null,
      'update'
    );
    Test.stopTest();

    System.assertEquals(1, events.size(), 'Event must be published.');
  }

  /**************************************
   * TEST 5: Force Exception → Catch block must execute
   **************************************/
  /**
   * @description Ensures the catch block is executed when repository throws exception.
   */
  @isTest
  static void testCatchBlockExecution() {
    Account acc = createAccount();
    Contact broker = createContact();

    ApplicationForm app = createApplicationForm(acc.Id);
    app.Assisted_Broker__c = broker.Id;
    app.Sync_Status__c = ApplicationFormEventActions.SYNC_STATUS_BROKER_ORG;

    List<ApplicationForm> records = new List<ApplicationForm>{ app };

    appFormRepoMock.mockException(
      'getRelatedAccounts',
      new AuraHandledException('Forced exception for test')
    );

    Test.startTest();
    List<Cloud_Event__e> result = ApplicationFormEventActions.publishSimpleApplicationFormEvent(
      records,
      null,
      'update'
    );
    Test.stopTest();

    System.assertEquals(
      0,
      result.size(),
      'Method should catch the exception and return an empty list.'
    );
  }

  /* ==========================================================================
       Helper Methods
       ========================================================================== */

  /**
   * @description Helper method that creates a mock Account record.
   * @return Account Mock Account object with Id and External ID.
   */
  static Account createAccount() {
    Account acc = new Account();
    acc.Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    acc.Name = 'TestAccount';
    acc.External_Id__c = 'EXT-' + String.valueOf(Math.random()).substring(2, 8);
    return acc;
  }
  /**
   * @description Helper method that creates a mock Contact record.
   * @return Contact Mock Contact object with fake Id.
   */
  static Contact createContact() {
    Contact con = new Contact();
    con.Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    con.FirstName = 'FN';
    con.LastName = 'LN';
    con.Email = 'test@test.com';
    return con;
  }
  /**
   * @description Helper method that creates a mock ApplicationForm record.
   * @param accId Id of the Account to attach to the ApplicationForm.
   * @return ApplicationForm Mock ApplicationForm object with fake Id.
   */
  static ApplicationForm createApplicationForm(Id accId) {
    ApplicationForm app = new ApplicationForm();
    app.Id = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    app.AccountId = accId;
    app.Application_Number__c =
      'APP' + String.valueOf(Math.random()).substring(2, 6);
    app.Sync_Status__c = ApplicationFormEventActions.SYNC_STATUS_BROKER_ORG;
    app.Source_System_Id__c = String.valueOf(Math.random()).substring(2, 6);
    return app;
  }
}
