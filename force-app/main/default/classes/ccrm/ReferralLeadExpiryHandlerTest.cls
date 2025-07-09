/**
 * @author Ayushi Gupta
 * @since  03/2025
 * @group CCRM (Commercial CRM)
 * @description ReferralLeadExpiryHandlerTest is Test class to test ReferralLeadExpiryHandler.
 */

@isTest
public class ReferralLeadExpiryHandlerTest {
  static Lib_MockProvider referralRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    referralRepoMock = Lib_MockProvider.forType(
      CommercialReferralLeadRepository.class
    );
  }
  @isTest
  static void updateCancelledLeadsTest() {
    registerMocks();
    List<Lead> leads = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.getSobjectType()),
        LastName = 'Test Lead',
        RecordTypeId = RTLead.referralLead,
        Expiry_Date__c = System.today() - 1,
        Referral_Status__c = 'New'
      )
    };
    Test.startTest();
    ReferralLeadExpiryHandler.updateCancelledLeads(leads);
    Test.stopTest();

    List<Lead> updatedLeads = (List<Lead>) dmlRepoMock.getHistory('doUpdate')
      .getParam('records');

    Assert.areEqual(1, updatedLeads.size(), 'No leads updated.');
    Assert.areEqual(
      'Cancelled',
      updatedLeads[0].Referral_Status__c,
      'Referral status is not updated.'
    );
  }

  @isTest
  static void updateCancelledLeadsWithErrorTest() {
    registerMocks();
    List<Lead> leads = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.getSobjectType()),
        Referral_Status__c = 'New'
      )
    };
    Database.SaveResult sr = (Database.SaveResult) JSON.deserialize(
      '{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"DmlException"}]}',
      Database.SaveResult.class
    );
    dmlRepoMock.mock('doUpdate', new List<Database.SaveResult>{ sr });

    try {
      Test.startTest();
      ReferralLeadExpiryHandler.saveUpdatedLeads(leads);
      Test.stopTest();
    } catch (Exception ex) {
      Assert.isTrue(ex instanceof DmlException, 'Exception should be thrown');
    }
  }

  @isTest
  static void sendNotificationTest() {
    Boolean exceptionThrown = false;
    String errorMessage = '';
    List<Lead> leads = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        FinServ__ReferredByUser__c = Lib_FakeIdGenerator.getMockId(
          User.SObjectType
        )
      )
    };
    Test.startTest();
    try {
      ReferralLeadExpiryHandler.sendNotification(leads);
    } catch (Exception e) {
      exceptionThrown = true;
      errorMessage = e.getMessage();
    }
    Test.stopTest();
    Assert.areEqual(
      false,
      exceptionThrown,
      'Referral lead sender is not notified.'
    );
  }

  @isTest
  static void sendNotificationToManagerTest() {
    //Given list of referral Lead and map of Owner Id to manager Id
    Id ownerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<Lead> leadOwnerUserList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        OwnerId = ownerId,
        FinServ__ReferredByUser__c = Lib_FakeIdGenerator.getMockId(
          User.SObjectType
        ),
        Referral_Status__c = 'In Progress',
        RecordTypeId = RTLead.referralLead,
        Expiry_Date__c = Date.Today().addDays(2)
      )
    };
    List<User> managerList = new List<User>{
      new User(
        Id = ownerId,
        ManagerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    Exception ex;

    //WHEN calling a method
    Test.startTest();
    try {
      ReferralLeadExpiryHandler.sendNotificationToManager(
        leadOwnerUserList,
        managerList
      );
    } catch (Exception e) {
      ex = e;
    }
    Test.stopTest();

    //THEN assert should return null
    Assert.isNull(
      ex,
      'Exception should not be thrown when bell notification is send to lead owners'
    );
  }

  @isTest
  static void sendExpiryReminderNotificationToManagerTest() {
    registerMocks();
    //Given list of referral Lead and map of Owner Id to manager Id
    Id ownerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<Lead> referralLeadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        OwnerId = ownerId,
        FinServ__ReferredByUser__c = Lib_FakeIdGenerator.getMockId(
          User.SObjectType
        ),
        Referral_Status__c = 'In Progress',
        RecordTypeId = RTLead.referralLead,
        Expiry_Date__c = Date.Today().addDays(2)
      )
    };
    List<User> managerList = new List<User>{
      new User(
        Id = ownerId,
        ManagerId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };
    referralRepoMock.mock('getManagerInfo', managerList);
    Exception ex;

    //WHEN calling a method
    Test.startTest();
    try {
      ReferralLeadExpiryHandler.sendExpiryReminderNotificationToManager(
        referralLeadList
      );
    } catch (Exception e) {
      ex = e;
    }
    Test.stopTest();

    //THEN assert should return null
    Assert.isNull(
      ex,
      'Exception should not be thrown when sending bell notification before referral is expire'
    );
  }

  @isTest
  static void sendNotificationToQueueTest() {
    //Given list of referral Lead and map of Owner Id to manager Id
    Id ownerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<Lead> leadOwnerQueueList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        OwnerId = QueryQueue.get('Private_Banking_SA').Id,
        FinServ__ReferredByUser__c = Lib_FakeIdGenerator.getMockId(
          User.SObjectType
        ),
        Referral_Status__c = 'In Progress',
        RecordTypeId = RTLead.referralLead,
        Expiry_Date__c = Date.Today().addDays(2)
      )
    };
    List<GroupMember> queueMemberList = new List<GroupMember>{
      new GroupMember(
        UserOrGroupId = ownerId,
        GroupId = QueryQueue.get('Private_Banking_SA').Id
      )
    };
    Map<Id, List<GroupMember>> queueToUsersMap = new Map<Id, List<GroupMember>>{
      QueryQueue.get('Private_Banking_SA').Id => queueMemberList
    };
    Exception ex;

    //WHEN calling a method
    Test.startTest();
    try {
      ReferralLeadExpiryHandler.sendNotificationToQueue(
        leadOwnerQueueList,
        queueToUsersMap
      );
    } catch (Exception e) {
      ex = e;
    }
    Test.stopTest();

    //THEN assert should return null
    Assert.isNull(
      ex,
      'Exception should not be thrown when bell notification is send to queue members'
    );
  }

  @isTest
  static void sendExpiryReminderNotificationToQueueTest() {
    registerMocks();
    //Given list of referral Lead and map of Owner Id to manager Id
    Id ownerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<Lead> referralLeadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        OwnerId = QueryQueue.get('Private_Banking_SA').Id,
        FinServ__ReferredByUser__c = Lib_FakeIdGenerator.getMockId(
          User.SObjectType
        ),
        Referral_Status__c = 'In Progress',
        RecordTypeId = RTLead.referralLead,
        Expiry_Date__c = Date.Today().addDays(2)
      )
    };
    List<GroupMember> queueMemberList = new List<GroupMember>{
      new GroupMember(
        UserOrGroupId = ownerId,
        GroupId = QueryQueue.get('Private_Banking_SA').Id
      )
    };
    referralRepoMock.mock('getQueueMembers', queueMemberList);
    Exception ex;

    //WHEN calling a method
    Test.startTest();
    try {
      ReferralLeadExpiryHandler.sendExpiryReminderNotificationToQueue(
        referralLeadList
      );
    } catch (Exception e) {
      ex = e;
    }
    Test.stopTest();

    //THEN assert should return null
    Assert.isNull(
      ex,
      'Exception should not be thrown when sending bell notification before referral is expire'
    );
  }
}
