/**
 * @author Naman Garg
 * @since May 2025
 * @group CCRM (Commercial CRM)
 * @description CommercialLeadPlatformEventActionsTest is a test class for CommercialLeadPlatformEventActions
 */
@isTest
public with sharing class CommercialLeadPlatformEventActionsTest {
  static Lib_MockProvider userActionsRepo;
  static Lib_MockProvider leadActionsRepo;
  static Lib_MockProvider dmlRepo;
  static void registerMocks() {
    userActionsRepo = Lib_MockProvider.forType(UserActionsRepository.class);
    leadActionsRepo = Lib_MockProvider.forType(LeadActionsRepository.class);
    dmlRepo = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void publishManualLeadsTest() {
    registerMocks();

    //GIVEN leadList, userList & accList
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        RecordTypeId = RTLead.commercialLead,
        OwnerId = userId,
        Status = 'New'
      )
    };

    Map<Id, User> mapOfOwnerLanIds = new Map<Id, User>{
      userId => new User(Id = userId, Lan_Id__c = 'lanId1')
    };

    Map<Id, Account> mapOfAccount = new Map<Id, Account>{
      accId => new Account(
        Id = accId,
        Source_System_Name__c = 'CAP-CIS',
        Source_System_ID__c = '1245'
      )
    };

    userActionsRepo.mock('getUserMapFromUserIds', mapOfOwnerLanIds);
    leadActionsRepo.mock('getAccountRecords', mapOfAccount);

    //WHEN calling a method
    Test.startTest();
    new CommercialLeadPlatformEventActions().publishManualLeads(leadList);
    Test.stopTest();

    //THEN it should publish the platform Event
    Assert.isNotNull(
      dmlRepo.getHistory('doPublish'),
      'doPublish should have been invoked from publishManualLeads'
    );
  }

  @isTest
  static void formUnicaLeadEventListTest() {
    registerMocks();
    //GIVEN leadList, userList & accList
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        RecordTypeId = RTLead.commercialLead,
        OwnerId = userId,
        Status = 'New',
        Campaign_Code__c = 'IKCMP-1234'
      )
    };

    Map<Id, User> mapOfOwnerLanIds = new Map<Id, User>{
      userId => new User(Id = userId, Lan_Id__c = 'lanId1')
    };

    Map<Id, Account> mapOfAccount = new Map<Id, Account>{
      accId => new Account(
        Id = accId,
        Source_System_Name__c = 'CAP-CIS',
        Source_System_ID__c = '1245'
      )
    };

    userActionsRepo.mock('getUserMapFromUserIds', mapOfOwnerLanIds);
    leadActionsRepo.mock('getAccountRecords', mapOfAccount);

    //WHEN calling a method
    Test.startTest();
    List<Lead_Event__e> leadEventList = CommercialLeadPlatformEventActions.formUnicaLeadEventList(
      leadList,
      mapOfOwnerLanIds,
      mapOfAccount
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      'IKCMP-1234',
      leadEventList[0].Campaign_Code__c,
      'Campaign code should be set correctly in lead event'
    );
  }

  @isTest
  static void getUnicaPlatformEventMappingTest() {
    registerMocks();
    //GIVEN leadList, leadEvent
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = leadId,
        Campaign_Code__c = 'IKCMP-1909',
        RecordTypeId = RTLead.commercialLead,
        Status = 'Outcome',
        Lead_Outcome__c = 'Opportunity Identified',
        Lead_Quality__c = 'Good'
      )
    };

    Lead_Event__e leadEvent = new Lead_Event__e();

    //WHEN calling a method
    Test.startTest();
    CommercialLeadPlatformEventActions.getLeadToPlatformEventMapping(
      leadList[0],
      leadEvent
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      'Good',
      leadEvent.Lead_Quality__c,
      'Lead Quality should be set to Good'
    );
  }

  @isTest
  static void publishLeadUpdateToUnicaOrAdobeTest() {
    registerMocks();
    //GIVEN leadList, userList & accList
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        RecordTypeId = RTLead.commercialLead,
        OwnerId = userId,
        Status = 'New'
      )
    };

    Map<Id, User> mapOfOwnerLanIds = new Map<Id, User>{
      userId => new User(Id = userId, Lan_Id__c = 'lanId1')
    };

    Map<Id, Account> mapOfAccount = new Map<Id, Account>{
      accId => new Account(
        Id = accId,
        Source_System_Name__c = 'CAP-CIS',
        Source_System_ID__c = '1245'
      )
    };

    userActionsRepo.mock('getUserMapFromUserIds', mapOfOwnerLanIds);
    leadActionsRepo.mock('getAccountRecords', mapOfAccount);

    //WHEN calling a method
    Test.startTest();
    new CommercialLeadPlatformEventActions()
      .publishLeadUpdateToUnicaOrAdobe(leadList, new List<Task>(), false);
    Test.stopTest();

    //THEN it should publish the platform Event
    Assert.isNotNull(
      dmlRepo.getHistory('doPublish'),
      'doPublish should have been invoked from publishLeadUpdateToUnicaOrAdobe'
    );
  }

  @isTest
  static void publishLeadUpdateToUnicaOrAdobeForOwnerChangeTest() {
    registerMocks();
    //GIVEN leadList, userList & accList
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        RecordTypeId = RTLead.commercialLead,
        OwnerId = userId,
        Status = 'New'
      )
    };

    Map<Id, User> mapOfOwnerLanIds = new Map<Id, User>{
      userId => new User(Id = userId, Lan_Id__c = 'lanId1')
    };

    Map<Id, Account> mapOfAccount = new Map<Id, Account>{
      accId => new Account(
        Id = accId,
        Source_System_Name__c = 'CAP-CIS',
        Source_System_ID__c = '1245'
      )
    };

    userActionsRepo.mock('getUserMapFromUserIds', mapOfOwnerLanIds);
    leadActionsRepo.mock('getAccountRecords', mapOfAccount);

    //WHEN calling a method
    Test.startTest();
    new CommercialLeadPlatformEventActions()
      .publishLeadUpdateToUnicaOrAdobe(leadList, new List<Task>(), true);
    Test.stopTest();

    //THEN it should publish the platform Event
    Assert.isNotNull(
      dmlRepo.getHistory('doPublish'),
      'doPublish should have been invoked from publishLeadUpdateToUnicaOrAdobe'
    );
  }

  @isTest
  static void formLeadEventListTest() {
    registerMocks();
    //GIVEN leadList, userList & accList
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        RecordTypeId = RTLead.commercialLead,
        OwnerId = userId,
        Status = 'New'
      )
    };

    Map<Id, User> mapOfOwnerLanIds = new Map<Id, User>{
      userId => new User(Id = userId, Lan_Id__c = 'lanId1')
    };

    Map<Id, Account> mapOfAccount = new Map<Id, Account>{
      accId => new Account(
        Id = accId,
        Source_System_Name__c = 'CAP-CIS',
        Source_System_ID__c = '1245'
      )
    };

    userActionsRepo.mock('getUserMapFromUserIds', mapOfOwnerLanIds);
    leadActionsRepo.mock('getAccountRecords', mapOfAccount);

    //WHEN calling a method
    Test.startTest();
    List<Lead_Event__e> leadEventList = CommercialLeadPlatformEventActions.formLeadEventList(
      leadList,
      mapOfOwnerLanIds,
      mapOfAccount,
      false
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.isNotNull(leadEventList, 'Lead Event List should not be empty');
    Assert.areEqual(
      'Update',
      leadEventList[0].Action__c,
      'Action should be update'
    );
  }

  @isTest
  static void mapSubstatusTest() {
    registerMocks();
    //GIVEN leadList, mapOfOpportunityId, leadEvent
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = leadId,
        RecordTypeId = RTLead.commercialLead,
        Status = 'New'
      )
    };

    CommercialLeadPlatformEventActions.mapOfOpportunityId = new Map<Id, Id>{
      leadId => oppId
    };

    Lead_Event__e leadEvent = new Lead_Event__e();

    //WHEN calling a method
    Test.startTest();
    CommercialLeadPlatformEventActions.mapSubstatus(
      leadList[0],
      leadEvent,
      false
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.isNull(leadEvent.SubStatus__c, 'Sub status should be null');
  }

  @isTest
  static void getLeadToPlatformEventMappingTest() {
    registerMocks();
    //GIVEN leadList, leadEvent
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = leadId,
        Campaign_Code__c = 'IKCMP-1909',
        RecordTypeId = RTLead.commercialLead,
        Status = 'Outcome',
        Lead_Outcome__c = 'Opportunity Identified'
      )
    };

    Lead_Event__e leadEvent = new Lead_Event__e();

    //WHEN calling a method
    Test.startTest();
    CommercialLeadPlatformEventActions.getLeadToPlatformEventMapping(
      leadList[0],
      leadEvent
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      'Completed',
      leadEvent.Status__c,
      'Status should be set to Completed'
    );
    Assert.areEqual(
      'IKCMP-1909',
      leadEvent.Campaign_Code__c,
      'should set campaign code correctly'
    );
  }

  @isTest
  static void getLeadToPlatformEventMappingForStatusTest() {
    registerMocks();
    //GIVEN leadList, leadEvent
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = leadId,
        RecordTypeId = RTLead.commercialLead,
        Status = 'Outcome',
        Lead_Outcome__c = 'Opportunity Identified'
      )
    };

    Lead_Event__e leadEvent = new Lead_Event__e();

    //WHEN calling a method
    Test.startTest();
    CommercialLeadPlatformEventActions.getLeadToPlatformEventMappingForStatus(
      leadList[0],
      leadEvent,
      'Status__c'
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      'Completed',
      leadEvent.Status__c,
      'Status should be set to Completed'
    );
  }

  @isTest
  static void mapSourceSystemIdsTest() {
    registerMocks();
    //GIVEN leadList, mapOfAccount, leadEvent
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = leadId,
        RecordTypeId = RTLead.commercialLead,
        Status = 'Outcome',
        Lead_Outcome__c = 'Opportunity Identified',
        Note__c = '</p>Test</p>',
        FinServ__RelatedAccount__c = accId
      )
    };

    Map<Id, Account> mapOfAccount = new Map<Id, Account>{
      accId => new Account(
        Id = accId,
        Source_System_Name__c = 'CAP-CIS',
        Source_System_ID__c = '1245',
        RecordTypeId = RTAccount.businessAccount
      )
    };

    Lead_Event__e leadEvent = new Lead_Event__e();

    //WHEN calling a method
    Test.startTest();
    CommercialLeadPlatformEventActions.mapSourceSystemIds(
      mapOfAccount,
      leadList[0],
      leadEvent
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      'Company',
      leadEvent.Customer_Type__c,
      'Customer Type should be set to Company'
    );
    Assert.areEqual(
      '1245',
      leadEvent.Business_ID__c,
      'Business ID should be set correctly'
    );
  }

  @isTest
  static void mapSourceSystemIdsNullTest() {
    registerMocks();
    //GIVEN leadList, mapOfAccount, leadEvent
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = leadId,
        RecordTypeId = RTLead.commercialLead,
        Lead_Originator__c = 'CCRM',
        Status = 'Outcome',
        Lead_Outcome__c = 'Opportunity Identified',
        Note__c = '</p>Test</p>'
      )
    };

    Map<Id, Account> mapOfAccount = new Map<Id, Account>{
      accId => new Account(
        Id = accId,
        Source_System_Name__c = 'CAP-CIS',
        Source_System_ID__c = '1245'
      )
    };

    Lead_Event__e leadEvent = new Lead_Event__e();

    //WHEN calling a method
    Test.startTest();
    CommercialLeadPlatformEventActions.mapSourceSystemIds(
      mapOfAccount,
      leadList[0],
      leadEvent
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      'Prospect',
      leadEvent.Customer_Type__c,
      'Customer Type should be set to Prospect'
    );
    Assert.areEqual(
      'New',
      leadEvent.Prospect_ID__c,
      'Prospect Id should be set to New'
    );
  }
}
