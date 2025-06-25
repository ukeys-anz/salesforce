/**
 * @author Ashish Kumar
 * @since 5/2025
 * @description LeadExpiryActionsTestTest class for unit testing of LeadExpiryActions
 */
@isTest
public with sharing class LeadExpiryActionsTest {
  static Lib_MockProvider campMembActionRepoMock;
  static Lib_MockProvider taskMockProvider;
  static void registerMocks() {
    campMembActionRepoMock = Lib_MockProvider.forType(
      CampaignMemberActionRepository.class
    );
    taskMockProvider = Lib_MockProvider.forType(TaskActionRepository.class);
  }

  @isTest
  static void filterListOfExpiredLeadTest() {
    Date today = System.today();
    List<Lead> leadRecords = new List<Lead>{
      new Lead(Expiry_Date__c = today.addDays(5)),
      new Lead(Expiry_Date__c = today.addDays(-5))
    };
    Test.startTest();
    List<Lead> expiredLeads = LeadExpiryActions.getUnexpiredLeads(leadRecords);
    Test.stopTest();
    Assert.areEqual(
      1,
      expiredLeads.size(),
      'Non-Expired Leads size is not correct'
    );
    Assert.areEqual(
      today.addDays(5),
      expiredLeads[0].Expiry_Date__c,
      'filterListOfExpiredLead is returning wrong leads'
    );
  }

  @isTest
  static void populateExpiryDaysBasedOnWeekDaysTest() {
    Date friday = Date.newInstance(2022, 6, 17);
    Date saturday = Date.newInstance(2022, 6, 18);
    Date sunday = Date.newInstance(2022, 6, 19);

    List<Lead> leadRecords = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Expiry_Date__c = friday
      ),
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Expiry_Date__c = saturday
      ),
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Expiry_Date__c = sunday
      )
    };
    Map<Id, Boolean> leadWithIncludeFridayMap = new Map<Id, Boolean>{
      leadRecords[0].Id => true,
      leadRecords[1].Id => false,
      leadRecords[2].Id => false
    };
    Test.startTest();
    LeadExpiryActions.populateExpiryDaysBasedOnWeekDays(
      leadRecords,
      leadWithIncludeFridayMap
    );
    Test.stopTest();
    Assert.areEqual(
      Date.newInstance(2022, 6, 20),
      leadRecords[0].Expiry_Date__c,
      'Next expiry date from Friday should be Monday'
    );
    Assert.areEqual(
      Date.newInstance(2022, 6, 20),
      leadRecords[1].Expiry_Date__c,
      'Next expiry date from Saturday should be Monday'
    );
    Assert.areEqual(
      Date.newInstance(2022, 6, 20),
      leadRecords[2].Expiry_Date__c,
      'Next expiry date from Sunday should be Monday'
    );
  }

  @isTest
  static void validateExpiryDateWithCampaignDateTest() {
    Date todayPlusFive = System.today().addDays(5);
    Date todayPlusOne = System.today().addDays(1);
    Date todayPlusYear = System.today().addDays(365);
    Campaign cRecord = new Campaign(
      Enddate = todayPlusFive,
      Id = Lib_FakeIdGenerator.getMockId(Schema.Campaign.getSObjectType())
    );

    CampaignMember cmRecord = (CampaignMember) TestUtil.setFields(
      new CampaignMember(
        Id = Lib_FakeIdGenerator.getMockId(
          Schema.CampaignMember.getSObjectType()
        )
      ),
      new Map<String, Object>{ 'Campaign' => cRecord }
    );

    List<Lead> leadRecords = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Expiry_Date__c = todayPlusYear
      ),
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Expiry_Date__c = todayPlusOne
      )
    };
    Map<Id, CampaignMember> leadIdToCmMap = new Map<Id, CampaignMember>{
      leadRecords[0].Id => cmRecord,
      leadRecords[1].Id => cmRecord
    };

    Test.startTest();
    LeadExpiryActions.validateExpiryDateWithCampaignDate(
      leadRecords,
      leadIdToCmMap
    );
    Test.stopTest();
    Assert.areEqual(
      todayPlusFive,
      leadRecords[0].Expiry_Date__c,
      'Expiry Date not reduced to campaign end date'
    );
    Assert.areEqual(
      todayPlusOne,
      leadRecords[1].Expiry_Date__c,
      'Expiry Date updated for wrong lead wrong'
    );
  }

  @isTest
  static void getMapOfCampaignTest() {
    registerMocks();
    Lead leadRec = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType)
    );
    CampaignMember cmRecord = new CampaignMember(
      Id = Lib_FakeIdGenerator.getMockId(
        Schema.CampaignMember.getSObjectType()
      ),
      leadId = leadRec.Id
    );
    campMembActionRepoMock.mock(
      'getCampaignMember',
      new List<CampaignMember>{ cmRecord }
    );
    Test.startTest();
    Map<Id, CampaignMember> campaignMap = LeadExpiryActions.getMapOfCampaign(
      new List<Lead>{ leadRec }
    );
    Test.stopTest();
    Assert.isTrue(
      campaignMap.containsKey(leadRec.Id),
      'getMapOfCampaign is not creating correct map'
    );
    Assert.areEqual(
      cmRecord.Id,
      campaignMap.get(leadRec.id).Id,
      'getMapOfCampaign is not tagging correct campaign for map'
    );
  }

  @isTest
  static void updateExpiryDateForNextDayTest() {
    Date monday = Date.newInstance(2022, 6, 13);
    Date friday = Date.newInstance(2022, 6, 17);
    List<Lead> leadRecords = new List<Lead>{
      new Lead(Expiry_Date__c = monday),
      new Lead(Expiry_Date__c = friday)
    };
    Test.startTest();
    LeadExpiryActions.updateExpiryDateForNextDay(leadRecords);
    Test.stopTest();
    Assert.areEqual(
      monday.addDays(1),
      leadRecords[0].Expiry_Date__c,
      'updateExpiryDateForNextDay did not updated expiry date for Monday'
    );
    Assert.areEqual(
      friday,
      leadRecords[1].Expiry_Date__c,
      'updateExpiryDateForNextDay updated expiry date for friday'
    );
  }

  @isTest
  static void getLeadsWithIncludeFridayMapTest() {
    Date friday = Date.newInstance(2022, 6, 17);
    Date saturday = Date.newInstance(2022, 6, 18);
    Date monday = Date.newInstance(2022, 6, 13);

    List<Lead> leadRecords = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Expiry_Date__c = friday
      ),
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Expiry_Date__c = saturday
      ),
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Expiry_Date__c = monday
      )
    };
    Test.startTest();
    Map<Id, Boolean> leadWithIncludeFridayMap = LeadExpiryActions.getLeadsWithIncludeFridayMap(
      leadRecords
    );
    Test.stopTest();
    Assert.isTrue(
      leadWithIncludeFridayMap.get(leadRecords[0].Id),
      'getLeadsWithIncludeFridayMap is not returing map value true for friday '
    );
    Assert.isFalse(
      leadWithIncludeFridayMap.get(leadRecords[1].Id),
      'getLeadsWithIncludeFridayMap is not returing map value false for saturday '
    );
    Assert.isFalse(
      leadWithIncludeFridayMap.containsKey(leadRecords[2].Id),
      'getLeadsWithIncludeFridayMap is returning map having monday'
    );
  }

  @isTest
  static void testGetLeadsWithIncludeFridayMapForFutureExpiry() {
    List<Lead> leadList = new List<Lead>{
      new Lead(
        RecordTypeId = RTLead.mlcrmLead,
        Expiry_Date__c = Date.today().addDays(5)
      )
    };
    Test.startTest();
    Map<Id, Boolean> leadMapOutput = LeadExpiryActions.getLeadsWithIncludeFridayMapForFutureExpiry(
      leadList,
      new Map<Id, Boolean>{ leadList[0].Id => false }
    );
    Test.stopTest();
    Assert.areEqual(
      true,
      leadMapOutput.values()[0],
      'Include friday for lead expiry not working properly.'
    );
  }

  @isTest
  static void testGetMapOfTask() {
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    registerMocks();
    taskMockProvider.mock(
      'getTaskResponse',
      new List<Task>{ new Task(whoId = leadId) }
    );

    List<sObject> lstOfSobject = new List<Lead>{
      new Lead(
        Id = leadId,
        RecordTypeId = RTLead.mlcrmLead,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Followup_Date__c = Date.today().addDays(5),
        Expiry_Date__c = Date.today().addDays(25)
      )
    };
    Lead oldSObject = new Lead(
      Id = leadId,
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Territory__c = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Followup_Date__c = Date.today().addDays(6)
    );
    Map<Id, Lead> oldMapSobject = new Map<Id, Lead>{
      (Id) oldSObject.get('Id') => oldSObject
    };
    Test.startTest();
    Map<Id, Task> taskMapOutput = LeadExpiryActions.getMapOfTask(
      lstOfSobject,
      oldMapSobject
    );
    Test.stopTest();
    Assert.isTrue(
      taskMapOutput.containsKey(leadId),
      'unable to fetch task related to ML Lead properly'
    );
  }
}
