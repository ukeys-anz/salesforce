/**
 * @author       : Ayushi Gupta
 * @since        : June 2025
 * @description  : Test class for CommercialLeadActionsHelper
 **/
@isTest
public class CommercialLeadActionsHelperTest {
  static Lib_MockProvider leadActionRepoMock;
  static void registerMocks() {
    leadActionRepoMock = Lib_MockProvider.forType(LeadActionsRepository.class);
  }

  @isTest
  static void getProspectCustomersTest() {
    registerMocks();
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Finserv__Status__c = 'Prospect'
    );
    Lead leadRec = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = RTLead.commercialLead,
      FinServ__RelatedAccount__c = acc.Id
    );
    leadActionRepoMock.mock('getAccountRecords', new List<Account>{ acc });
    Test.startTest();
    Set<Id> prospectCustomers = CommercialLeadActionsHelper.getProspectCustomers(
      new List<Lead>{ leadRec }
    );
    Test.stopTest();
    Assert.areEqual(
      prospectCustomers.size(),
      1,
      'prospectCustomers is not returning correct records'
    );
    Assert.areEqual(
      prospectCustomers.contains(acc.Id),
      true,
      'Customer Record is not Prospect'
    );
  }

  @isTest
  static void updateNewToBankFlagTest() {
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    );
    Id accId2 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Lead lead1 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = RTLead.commercialLead,
      FinServ__RelatedAccount__c = acc.Id
    );
    Lead lead2 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = RTLead.mlcrmLead,
      FinServ__RelatedAccount__c = accId2
    );
    List<Lead> leadRecords = new List<Lead>{ lead1, lead2 };
    Set<ID> prospectCustomerIds = new Set<Id>{ acc.Id };
    Test.startTest();
    CommercialLeadActionsHelper.updateNewToBankFlag(
      leadRecords,
      prospectCustomerIds
    );
    Test.stopTest();
    Assert.areEqual(
      leadRecords[0].New_to_Bank__c,
      'Yes',
      'updateNewToBankFlag is not setting Yes to lead record'
    );
    Assert.areEqual(
      leadRecords[1].New_to_Bank__c,
      'No',
      'updateNewToBankFlag is not setting NO to lead record'
    );
  }

  @isTest
  static void testUpdateExpiryDateWhenFollowUpChanged() {
    List<Task> taskRecords = new List<Task>();
    taskRecords.add(
      new Task(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Task.getSObjectType()),
        Response_Status__c = 'Call Back',
        ActivityDate = System.Today().addDays(5)
      )
    );

    List<Lead> leadRecords = new List<Lead>();
    leadRecords.add(
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
        Expiry_Date__c = System.Today().addDays(1),
        RecordTypeId = RTLead.commercialLead
      )
    );

    Test.startTest();
    List<Lead> updatedLeadRecords = CommercialLeadActionsHelper.updateExpiryDateWhenFollowUpChanged(
      leadRecords,
      new Map<Id, Task>{ leadRecords[0].Id => taskRecords[0] }
    );
    Test.stopTest();

    Integer minDays = integer.valueOf(Label.CCRM_MinDaysExpiryDateExtends);
    Assert.areEqual(
      System.Today().addDays(5).addDays(minDays),
      updatedLeadRecords[0].Expiry_Date__c,
      'Expiry Date not updated properly for Call Back Response'
    );
  }
}
