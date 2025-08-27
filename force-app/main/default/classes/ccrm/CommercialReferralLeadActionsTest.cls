/**
 * @author       : Naman Garg
 * @since        : Jan 2025
 * @description  : CommercialReferralLeadActionsTest is the test class for CommercialReferralLeadActions
 **/
@isTest
public with sharing class CommercialReferralLeadActionsTest {
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider commercialReferralLeadRepositoryMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    commercialReferralLeadRepositoryMock = Lib_MockProvider.forType(
      CommercialReferralLeadRepository.class
    );
  }

  @isTest
  public static void updateReferralStatusTest() {
    //GIVEN list of old records and new records
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = leadId,
        Referral_Status__c = CommercialReferralLeadActions.REFERRAL_STATUS_NEW,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        Id = leadId,
        Referral_Status__c = CommercialReferralLeadActions.REFERRAL_STATUS_NEW,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialReferralLeadActions.updateReferralStatus(records, oldMap);
    Test.stopTest();

    //THEN it should change the status to 'In Progress'
    Assert.areEqual(
      CommercialReferralLeadActions.REFERRAL_STATUS_IN_PROGRESS,
      records[0].Referral_Status__c,
      'Referral lead status should get updated.'
    );
  }

  @isTest
  public static void updateIknowReferralStatusTest() {
    //GIVEN list of old records and new records
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = leadId,
        Referral_Status__c = CommercialReferralLeadActions.REFERRAL_STATUS_NEW,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        External_Id__c = 'iknow_opp_Id-1'
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialReferralLeadActions.updateReferralStatus(records, null);
    Test.stopTest();

    //THEN it should change the status to 'In Progress'
    Assert.areEqual(
      CommercialReferralLeadActions.REFERRAL_STATUS_IN_PROGRESS,
      records[0].Referral_Status__c,
      'Referral lead status should get updated to In-Progress.'
    );
  }

  @isTest
  static void shareReferralRecordTest() {
    registerMocks();
    //GIVEN list of old records and new records
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = leadId,
        FinServ__ReferredByUser__c = userId,
        Referral_Status__c = CommercialReferralLeadActions.REFERRAL_STATUS_IN_PROGRESS,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        Id = leadId,
        FinServ__ReferredByUser__c = userId,
        Referral_Status__c = CommercialReferralLeadActions.REFERRAL_STATUS_IN_PROGRESS,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialReferralLeadActions.shareReferralRecord(records, oldMap);
    Test.stopTest();

    //THEN it should invoke do Insert method
    Assert.isNotNull(
      dmlRepoMock.getHistory('doInsert'),
      'doInsert should have been invoked'
    );

    List<LeadShare> insertedRecords = (List<LeadShare>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');

    //THEN it should create lead share record
    Assert.areEqual(
      new LeadShare(
        LeadId = leadId,
        UserOrGroupId = userId,
        leadAccessLevel = CommercialReferralLeadActions.REFERRAL_LEAD_ACCESS
      ),
      insertedRecords[0],
      'New Lead Share should be created with the correct values'
    );
  }

  @isTest
  static void shareReferralRecordWithExceptionTest() {
    registerMocks();
    //GIVEN list of old records and new records
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = leadId,
        FinServ__ReferredByUser__c = userId,
        Referral_Status__c = CommercialReferralLeadActions.REFERRAL_STATUS_IN_PROGRESS,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        Id = leadId,
        FinServ__ReferredByUser__c = userId,
        Referral_Status__c = CommercialReferralLeadActions.REFERRAL_STATUS_IN_PROGRESS,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    dmlRepoMock.mockException('doInsert', new DMLException('Insert failed!'));
    try {
      Test.startTest();
      CommercialReferralLeadActions.shareReferralRecord(records, oldMap);
      Test.stopTest();
    } catch (Exception ex) {
      Assert.isTrue(
        ex instanceof DMLException,
        'DMLException should have been thrown'
      );
    }
  }

  @isTest
  static void generateReferralLeadShareListTest() {
    //GIVEN list of old records and new records
    List<Lead> filteredReferralLeadsList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Referral_Status__c = CommercialReferralLeadActions.REFERRAL_STATUS_IN_PROGRESS,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };

    //WHEN calling a method
    Test.startTest();
    List<LeadShare> refLeadShareRecordList = CommercialReferralLeadActions.generateReferralLeadShareList(
      filteredReferralLeadsList
    );
    Test.stopTest();

    //THEN it should create a share record
    Assert.areEqual(
      1,
      refLeadShareRecordList.size(),
      'Referral lead share record should have been created.'
    );
  }

  @isTest
  static void sendBellNotificationTest() {
    //GIVEN list of old records and new records
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = leadId,
        FinServ__ReferredByUser__c = userId,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        Id = leadId,
        FinServ__ReferredByUser__c = userId,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    Boolean exceptionThrown = false;
    String errorMessage = '';

    //WHEN calling a method
    Test.startTest();
    try {
      CommercialReferralLeadActions.sendBellNotification(records, oldMap);
    } catch (Exception e) {
      exceptionThrown = true;
      errorMessage = e.getMessage();
    }
    Test.stopTest();

    //THEN it should successfully send the bell notification
    Assert.areEqual(
      false,
      exceptionThrown,
      'Referral lead owner should be notified by bell notification.'
    );
  }

  @isTest
  static void sendIknowReferralBellNotificationTest() {
    //GIVEN list of old records and new records
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = leadId,
        FinServ__ReferredByUser__c = userId,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    Boolean exceptionThrown = false;
    String errorMessage = '';

    //WHEN calling a method
    Test.startTest();
    try {
      CommercialReferralLeadActions.sendBellNotificationIknowReferral(records);
    } catch (Exception e) {
      exceptionThrown = true;
      errorMessage = e.getMessage();
    }
    Test.stopTest();

    //THEN it should successfully send the bell notification
    Assert.areEqual(
      false,
      exceptionThrown,
      'Referral lead owner should be notified by bell notification.'
    );
  }

  @isTest
  static void sendNotificationTest() {
    //GIVEN list of lead record
    List<Lead> filteredReferralLeadsList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        FinServ__ReferredByUser__c = Lib_FakeIdGenerator.getMockId(
          User.SObjectType
        )
      )
    };
    Boolean exceptionThrown = false;
    String errorMessage = '';

    //WHEN calling a method
    Test.startTest();
    try {
      CommercialReferralLeadActions.sendNotification(filteredReferralLeadsList);
    } catch (Exception e) {
      exceptionThrown = true;
      errorMessage = e.getMessage();
    }
    Test.stopTest();

    //THEN it should successfully send the bell notification
    Assert.areEqual(
      false,
      exceptionThrown,
      'Referral lead owner should be notified.'
    );
  }

  @isTest
  static void sendNotificationForCCRMUsersTest() {
    registerMocks();
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<Lead> filteredReferralLeadsList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        OwnerId = userId,
        FinServ__ReferredByUser__c = Lib_FakeIdGenerator.getMockId(
          User.SObjectType
        )
      )
    };
    commercialReferralLeadRepositoryMock.mock(
      'getCCRMUsers',
      new List<User>{ new user(Id = userId) }
    );
    Boolean exceptionThrown = false;
    String errorMessage = '';

    Test.startTest();
    try {
      CommercialReferralLeadActions.sendNotification(filteredReferralLeadsList);
    } catch (Exception e) {
      exceptionThrown = true;
      errorMessage = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      false,
      exceptionThrown,
      'Referral lead owner should be notified.'
    );
  }

  @isTest
  public static void publishCloudEventsTest() {
    registerMocks();

    // Mocking
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    ccrmUser.Lan_Id__c = 'TestLanId';
    commercialReferralLeadRepositoryMock.mock(
      'getUsers',
      new List<User>{ ccrmUser }
    );

    Account account = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Test Account'
    );
    commercialReferralLeadRepositoryMock.mock(
      'getCustomers',
      new List<Account>{ account }
    );

    //GIVEN list of new lead referal records
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

    List<Lead> records = new List<Lead>{
      new Lead(
        Id = leadId,
        FinServ__ReferredByUser__c = userId,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        channel__c = 'Branch',
        Entity_Type__c = 'Payer',
        Company = 'Test Business', //FinServ__RelatedAccount__r.Name
        Note__c = 'Test Note',
        FinServ__ExpressedInterest__c = 'Indemnity Guarantee',
        Referral_Category__c = 'Home Loan Check-In',
        Customer_ID__c = '12345678',
        FinServ__RelatedAccount__c = account.id,
        RecordTypeId = RTLead.referralLead,
        Referral_Status__c = 'In Progress',
        Primary_Contact_Method__c = 'Work Phone',
        Work_Phone__c = '+61234567890'
      ),
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__ReferredByUser__c = userId,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        channel__c = 'Commercial'
      ),
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__ReferredByUser__c = userId,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        channel__c = 'Private Bank'
      )
    };

    records[0] = (Lead) TestUtil.setFields(
      records[0],
      new Map<String, Object>{
        'LastModifiedById' => ccrmUser.Id,
        'LastModifiedDate' => '2024-06-28T08:00:27.000+0000',
        'Lead_Auto_Number__c' => '00006397'
      }
    );
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        Id = leadId,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };

    // WHEN calling publishCloudEvents method
    Test.startTest();
    CommercialReferralLeadActions.publishCloudEvents(records, oldMap);
    Test.stopTest();

    //THEN it should publish a cloud event
    List<Cloud_Event__e> publishedEvents = CloudEventController.cloudEvents;
    Assert.isNotNull(
      publishedEvents,
      'CeModels should be created successfully'
    );
    Assert.areEqual(
      1,
      publishedEvents.size(),
      'CeModels should be created successfully'
    );
    InteractionCloudEventModel publishedEventInstance1 = (InteractionCloudEventModel) JSON.deserialize(
      publishedEvents[0].Data_1__c,
      InteractionCloudEventModel.class
    );

    Assert.areEqual(
      'anzx.salesforce.ccrm.v1alpha1.referral.retail_referral',
      publishedEventInstance1.ce_type,
      'CeModels were not created successfully on create'
    );
  }
  @isTest
  public static void publishCloudEventsExceptionTest() {
    registerMocks();
    // Mocking
    User ccrmUser = CCRMTestDataFactory.getCCRMBaseUser();
    ccrmUser.Lan_Id__c = 'TestLanId';
    commercialReferralLeadRepositoryMock.mock(
      'getUsers',
      new List<User>{ ccrmUser }
    );

    Account account = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Name = 'Test Account'
    );
    commercialReferralLeadRepositoryMock.mock(
      'getCustomers',
      new List<Account>{ account }
    );

    //GIVEN list of new lead referal records
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

    List<Lead> records = new List<Lead>{
      new Lead(
        Id = leadId,
        FinServ__ReferredByUser__c = userId,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        channel__c = 'Branch',
        Entity_Type__c = 'Payer',
        Company = 'Test Business', //FinServ__RelatedAccount__r.Name
        Note__c = 'Test Note',
        FinServ__ExpressedInterest__c = 'Indemnity Guarantee',
        Referral_Category__c = 'Home Loan Check-In',
        Customer_ID__c = '12345678',
        FinServ__RelatedAccount__c = account.id,
        RecordTypeId = RTLead.referralLead,
        Referral_Status__c = 'In Progress'
      )
    };

    commercialReferralLeadRepositoryMock.mockException(
      'getUsers',
      new QueryException('invalid parameters')
    );

    Boolean exceptionThrown = false;
    String errorMessage = '';
    Map<Id, Lead> oldMap = new Map<Id, Lead>{ leadId => new Lead(Id = leadId) };
    // WHEN calling publishCloudEvents method and an exception occurs
    Test.startTest();
    try {
      CommercialReferralLeadActions.publishCloudEvents(records, oldMap);
    } catch (Exception e) {
      exceptionThrown = true;
      errorMessage = e.getMessage();
    }
    Test.stopTest();

    // THEN it should throw an exception
    Assert.areEqual(
      true,
      exceptionThrown,
      'An exception should have been thrown.'
    );
    Assert.areEqual(
      'invalid parameters',
      errorMessage,
      'The correct exception message should be logged.'
    );
  }

  @isTest
  static void updateParentLeadTest() {
    registerMocks();
    //GIVEN list of Referral lead
    Id parentLeadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Referrer_Lead__c = parentLeadId
      )
    };

    List<Lead> parentLeadsList = new List<Lead>{
      new Lead(Id = parentLeadId, Status = 'Assigned')
    };
    commercialReferralLeadRepositoryMock.mock(
      'fetchParentLeads',
      parentLeadsList
    );

    //WHEN calling a method
    Test.startTest();
    CommercialReferralLeadActions.updateParentLead(records);
    Test.stopTest();

    //THEN it should invoke do Update method
    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );

    List<Lead> updateRecords = (List<Lead>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.areEqual(
      'Referred',
      updateRecords[0].Lead_Outcome__c,
      'Lead Outcome should get updated to Referred on update'
    );
  }

  @isTest
  static void updateParentLeadTestWithException() {
    registerMocks();
    Id parentLeadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Referrer_Lead__c = parentLeadId
      )
    };
    commercialReferralLeadRepositoryMock.mockException(
      'fetchParentLeads',
      new QueryException('invalid parameters')
    );
    try {
      Test.startTest();
      CommercialReferralLeadActions.updateParentLead(records);
      Test.stopTest();
    } catch (Exception ex) {
      Assert.isTrue(
        ex instanceof QueryException,
        'QueryException should have been thrown'
      );
    }
  }

  @isTest
  static void mapReferralCustomerNeedTest() {
    //GIVEN list of lead
    List<Lead> leadsList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Referral_Customer_Needs__c = 'Purchase Commercial Property'
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialReferralLeadActions.mapReferralCustomerNeed(leadsList);
    Test.stopTest();

    //THEN it should return Lead with updated customer lead
    Assert.areEqual(
      'Purchasing Property',
      leadsList[0].FinServ__ExpressedInterest__c,
      'referral customer need should get mapped to correct value'
    );
  }

  @isTest
  static void mapReferralCustomerNeedTestNull() {
    //GIVEN list of lead
    List<Lead> leadsList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Referral_Customer_Needs__c = 'Selling/Closing your Business'
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialReferralLeadActions.mapReferralCustomerNeed(leadsList);
    Test.stopTest();

    //THEN it should return Lead with updated customer lead
    Assert.isNull(
      leadsList[0].FinServ__ExpressedInterest__c,
      'referral customer need should be null for other values'
    );
  }

  @isTest
  static void setDefaultInternalReferrerTest() {
    //GIVEN list of lead
    List<Lead> leadsList = new List<Lead>{
      new Lead(Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType))
    };

    //WHEN calling a method
    Test.startTest();
    CommercialReferralLeadActions.setDefaultInternalReferrer(leadsList);
    Test.stopTest();

    //THEN it should return Lead with updated lead outcome
    Assert.areEqual(
      UserInfo.getuserId(),
      leadsList[0].FinServ__ReferredByUser__c,
      'referral Internal referrer should get mapped to current user'
    );
  }

  @isTest
  static void populateNewToBankTest() {
    registerMocks();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id refId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(Id = refId, FinServ__RelatedAccount__c = accId)
    };

    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      refId => new Lead(
        Id = refId,
        FinServ__RelatedAccount__c = Lib_FakeIdGenerator.getMockId(
          Lead.SObjectType
        )
      )
    };

    List<Account> prospectAccountList = new List<Account>{
      new Account(Id = accId, Finserv__Status__c = 'Prospect')
    };

    commercialReferralLeadRepositoryMock.mock(
      'getAccountRecords',
      prospectAccountList
    );

    Test.startTest();
    CommercialReferralLeadActions.populateNewToBank(records, oldMap);
    Test.stopTest();

    Assert.areEqual(
      'Yes',
      records[0].New_to_Bank__c,
      'Should set New to Bank to Yes'
    );
  }

  @isTest
  static void populateNewToBankWithExceptionTest() {
    registerMocks();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id refId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(Id = refId, FinServ__RelatedAccount__c = accId)
    };

    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      refId => new Lead(
        Id = refId,
        FinServ__RelatedAccount__c = Lib_FakeIdGenerator.getMockId(
          Lead.SObjectType
        )
      )
    };
    commercialReferralLeadRepositoryMock.mockException(
      'getAccountRecords',
      new QueryException('invalid parameters')
    );
    try {
      Test.startTest();
      CommercialReferralLeadActions.populateNewToBank(records, oldMap);
      Test.stopTest();
    } catch (Exception ex) {
      Assert.isTrue(
        ex instanceof QueryException,
        'QueryException should have been thrown'
      );
    }
  }

  @isTest
  static void setNewToBankTest() {
    List<Lead> filteredRefList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = Lib_FakeIdGenerator.getMockId(
          Account.SObjectType
        )
      )
    };
    Set<Id> prospectAccountIdsSet = new Set<Id>{
      Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    };

    Test.startTest();
    CommercialReferralLeadActions.setNewToBank(
      filteredRefList,
      prospectAccountIdsSet
    );
    Test.stopTest();

    Assert.areEqual(
      'No',
      filteredRefList[0].New_to_Bank__c,
      'Should set New to Bank to No'
    );
  }

  @isTest
  static void updateContactInfoTest() {
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Referral_Status__c = 'New',
        External_Id__c = '2-2YDFHGF',
        MobilePhone = '01332424',
        Home_Phone__c = '+610131313',
        Work_Phone__c = '313218300',
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        FinServ__ReferredByUser__c = Lib_FakeIdGenerator.getMockId(
          User.SObjectType
        )
      )
    };

    Test.startTest();
    CommercialReferralLeadActions.updateContactInfo(records);
    Test.stopTest();

    Assert.areEqual(
      '01332424',
      records[0].MobilePhone,
      'should keep the same MobilePhone'
    );
    Assert.areEqual(
      '+61131313',
      records[0].Home_Phone__c,
      'should sanitize Home Phone'
    );
    Assert.areEqual(
      '313218300',
      records[0].Work_Phone__c,
      'should keep the same Work Phone '
    );
  }

  @isTest
  static void sanitizeContactValueTest() {
    Test.startTest();
    String sanitizeValue = CommercialReferralLeadActions.sanitizeContactValue(
      '+610424234'
    );
    Test.stopTest();

    Assert.areEqual('+61424234', sanitizeValue, 'should sanitize the value');
  }

  @isTest
  static void sanitizeContactValueTestWithNoValue() {
    Test.startTest();
    String sanitizeValue = CommercialReferralLeadActions.sanitizeContactValue(
      null
    );
    Test.stopTest();

    Assert.isNull(sanitizeValue, 'It will not sanitize the value');
  }

  @istest
  static void updateIknowReferralStatusPositiveTest() {
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Referral_Status__c = 'New',
        External_Id__c = '2-2YDFHGF',
        MobilePhone = '01332424',
        Home_Phone__c = '+610131313',
        Work_Phone__c = '313218300',
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        FinServ__ReferredByUser__c = Lib_FakeIdGenerator.getMockId(
          User.SObjectType
        )
      )
    };
    Test.startTest();
    CommercialReferralLeadActions.updateIknowReferralStatus(records);
    Test.stopTest();
    Assert.areEqual(
      'In Progress',
      records[0].Referral_Status__c,
      'Referral status is not changed to In Progress'
    );
  }
  @istest
  static void updateIknowReferralStatusNegativeTest() {
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Referral_Status__c = 'New',
        External_Id__c = null,
        MobilePhone = '01332424',
        Home_Phone__c = '+610131313',
        Work_Phone__c = '313218300',
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        FinServ__ReferredByUser__c = Lib_FakeIdGenerator.getMockId(
          User.SObjectType
        )
      )
    };
    Test.startTest();
    CommercialReferralLeadActions.updateIknowReferralStatus(records);
    Test.stopTest();
    Assert.areEqual(
      'New',
      records[0].Referral_Status__c,
      'Referral status is changed to In Progress'
    );
  }
}
