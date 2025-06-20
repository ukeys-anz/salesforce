/**
 * @author Ashish Kumar
 * @since 05/2023
 * @description MLCRM Lead Action is the test class for MLCRM Lead Actions Class functionality.
 */
@isTest
private class MobileLendingLeadActionsTest {
  static Lib_MockProvider leadActionsRepoMock;
  static Lib_MockProvider territoryActionsRepoMock;
  static Lib_MockProvider userInfoRepoMock;
  static void registerMocks() {
    leadActionsRepoMock = Lib_MockProvider.forType(LeadActionsRepository.class);
    territoryActionsRepoMock = Lib_MockProvider.forType(
      TerritoryActionsRepository.class
    );
    userInfoRepoMock = Lib_MockProvider.forType(UserInfoRepository.class);
  }

  @isTest
  static void updateExpiryDateWhenFollowUpChangedTest() {
    List<Task> taskRecords = new List<Task>();
    taskRecords.add(
      new Task(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Task.getSObjectType()),
        Response_Status__c = 'Call Back'
      )
    );
    taskRecords.add(
      new Task(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Task.getSObjectType()),
        Response_Status__c = 'Accepted'
      )
    );

    List<Lead> leadRecords = new List<Lead>();
    leadRecords.add(
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
        Followup_Date__c = System.Today().addDays(1)
      )
    );
    leadRecords.add(
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
        Followup_Date__c = null,
        Expiry_Date__c = system.today()
      )
    );

    Test.startTest();
    List<Lead> updatedLeadRecords = MobileLendingLeadActions.updateExpiryDateWhenFollowUpChanged(
      leadRecords,
      new Map<Id, Task>{
        leadRecords[0].Id => taskRecords[0],
        leadRecords[1].Id => taskRecords[1]
      }
    );
    Test.stopTest();

    Integer minDays = integer.valueOf(System.Label.DefaultLeadExpiryDate);
    Assert.areEqual(
      system.today().addDays(minDays + 1),
      updatedLeadRecords[0].Expiry_Date__c,
      'Expiry Date not updated properly for Call Back Response'
    );
    Assert.areEqual(
      system.today().addDays(minDays),
      updatedLeadRecords[1].Expiry_Date__c,
      'Expiry Date not updated properly for Accepted'
    );
  }

  @isTest
  static void updateFollowupdateTest() {
    Integer followUpExtension = Integer.valueOf(
      System.Label.FollowUpDateExtends
    );
    Integer followUpReduction = Integer.valueOf(
      System.Label.FollowUpDateLessThanToday
    );
    Campaign cRecord = new Campaign(
      Enddate = System.today(),
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

    List<Lead> leadRecords = new List<Lead>();
    leadRecords.add(
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
        Followup_Date__c = System.Today().addDays(1),
        Expiry_Date__c = System.today().addDays(followUpExtension + 2)
      )
    );
    leadRecords.add(
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
        Followup_Date__c = System.Today().addDays(1),
        Expiry_Date__c = System.today().addDays(followUpExtension - 2)
      )
    );

    Test.startTest();
    MobileLendingLeadActions.updateFollowupdate(
      leadRecords,
      new Map<Id, CampaignMember>{
        leadRecords[0].Id => cmRecord,
        leadRecords[1].Id => cmRecord
      }
    );

    Test.stopTest();
    Assert.areEqual(
      leadRecords[0].Expiry_Date__c - followUpExtension,
      leadRecords[0].Followup_Date__c,
      'updateFollowupdate did not updated Followup date correctly'
    );
    Assert.areEqual(
      leadRecords[1].Expiry_Date__c - followUpReduction,
      leadRecords[1].Followup_Date__c,
      'Followupdate is not updated correctly'
    );
  }

  @isTest
  static void testNoLongerNewLeads() {
    Lead leadrecord = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      Skip_Validations__c = 'test',
      isNewLead__c = true
    );
    List<Lead> newleadList = new List<Lead>{ leadrecord };
    Map<Id, Lead> oldMap = new Map<Id, Lead>(newleadList);
    Test.startTest();
    MobileLendingLeadActions.noLongerNewLeads(oldMap, newleadList);
    Test.stopTest();
    Assert.areEqual(false, leadrecord.isNewLead__c, 'Lead is still New Lead');
  }

  @isTest
  static void testSetDefaultValueWithoutExpiryDate() {
    Lead leadrecord = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      Expiry_Date__c = null,
      Lead_Originator__c = 'MLCRM',
      RecordTypeId = RTLead.mlcrmLead
    );
    Test.startTest();
    MobileLendingLeadActions.setDefaultValue(new List<Lead>{ leadrecord });
    String dayName = DateTimeUtils.getDay(
      System.today()
        .addDays(Integer.valueOf(System.Label.DefaultLeadExpiryDate))
    );
    switch on dayName {
      when 'Sat' {
        Assert.areEqual(
          System.today()
            .addDays(Integer.valueOf(System.Label.DefaultLeadExpiryDate) + 2),
          leadrecord.Expiry_Date__c,
          'Expiry_Date__c is not getting populated correctly when day is Saturday'
        );
      }
      when 'Sun' {
        Assert.areEqual(
          System.today()
            .addDays(Integer.valueOf(System.Label.DefaultLeadExpiryDate) + 1),
          leadrecord.Expiry_Date__c,
          'Expiry_Date__c is not getting populated correctly when day is Sunday'
        );
      }
      when else {
        Assert.areEqual(
          System.today()
            .addDays(Integer.valueOf(System.Label.DefaultLeadExpiryDate)),
          leadrecord.Expiry_Date__c,
          'For Monday to Friday Expiry Date is not getting populated correctly'
        );
      }
    }
    Test.stopTest();
  }

  @isTest
  static void testSetDefaultValueWithExpiryDate() {
    Lead leadrecord = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      Expiry_Date__c = System.today() + 7,
      Lead_Originator__c = 'MLCRM'
    );
    Test.startTest();
    MobileLendingLeadActions.setDefaultValue(new List<Lead>{ leadrecord });
    Assert.areEqual(
      System.today() + 7,
      leadrecord.Expiry_Date__c,
      'Expiry_Date__c is not getting populated correctly when day is Saturday'
    );
    Test.stopTest();
  }

  @isTest
  static void testPopulatePrimaryFranchise() {
    registerMocks();
    Id newTerritoryID = Lib_FakeIdGenerator.getMockId(
      Schema.Territory__c.getSObjectType()
    );
    Id leadID = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType());
    List<Territory__c> territoryList = new List<Territory__c>{
      new Territory__c(
        Id = newTerritoryID,
        Primary_Franchise_Owner__c = userInfo.getUserId()
      )
    };
    territoryActionsRepoMock.mock('getTerrritories', territoryList);
    Lead oldLeadRecord = new Lead(
      Id = leadID,
      Territory__c = Lib_FakeIdGenerator.getMockId(
        Schema.Territory__c.getSObjectType()
      ),
      Primary_Franchise_Owner__c = null
    );
    Map<Id, Lead> oldMap = new Map<Id, Lead>(new List<Lead>{ oldLeadRecord });
    Lead newLeadRecord = new Lead(
      Id = leadID,
      RecordTypeId = RTLead.mlcrmLead,
      Territory__c = newTerritoryID
    );
    List<Lead> newLeadList = new List<Lead>{ newLeadRecord };
    Test.startTest();
    MobileLendingLeadActions.populatePrimaryFranchise(newLeadList, oldMap);
    Test.stopTest();
    Assert.areNotEqual(
      null,
      newLeadRecord.Primary_Franchise_Owner__c,
      'Primary Franchise Owner is not Populated on Lead'
    );
  }

  @isTest
  static void testPopulatePrimaryFranchiseOnInsert() {
    registerMocks();
    Id newTerritoryID = Lib_FakeIdGenerator.getMockId(
      Schema.Territory__c.getSObjectType()
    );
    Id leadID = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType());
    List<Territory__c> territoryList = new List<Territory__c>{
      new Territory__c(
        Id = newTerritoryID,
        Primary_Franchise_Owner__c = userInfo.getUserId()
      )
    };
    territoryActionsRepoMock.mock('getTerrritories', territoryList);
    Lead newLeadRecord = new Lead(
      Id = leadID,
      RecordTypeId = RTLead.mlcrmLead,
      Territory__c = newTerritoryID
    );
    List<Lead> newLeadList = new List<Lead>{ newLeadRecord };
    Test.startTest();
    MobileLendingLeadActions.populatePrimaryFranchise(newLeadList, null);
    Test.stopTest();
    Assert.areNotEqual(
      null,
      newLeadRecord.Primary_Franchise_Owner__c,
      'Primary Franchise Owner is not Populated on Lead'
    );
  }

  @isTest
  static void testSetLeadPrimaryFranchiseOwner() {
    Id territoryID = Lib_FakeIdGenerator.getMockId(
      Schema.Territory__c.getSObjectType()
    );
    List<Territory__c> territoryList = new List<Territory__c>{
      new Territory__c(
        Id = territoryID,
        Primary_Franchise_Owner__c = userInfo.getUserId()
      )
    };
    Lead leadRecord = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      RecordTypeId = RTLead.mlcrmLead,
      Territory__c = territoryID
    );
    List<Lead> leadList = new List<Lead>{ leadRecord };
    Test.startTest();
    MobileLendingLeadActions.setLeadPrimaryFranchiseOwner(
      leadList,
      territoryList
    );
    Test.stopTest();
    Assert.areNotEqual(
      null,
      leadRecord.Primary_Franchise_Owner__c,
      'Primay Franchise Owner is not Poulated on Lead'
    );
  }

  // Test Method to validate if there is leads creation allowed as Field Team User
  @IsTest
  static void testvalidateLeadCreationForFieldTeam() {
    registerMocks();
    Lead leadRecord = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = RTLead.mlcrmLead
    );
    userInfoRepoMock.mock(
      new Map<String, Object>{
        'checkProfile' => false,
        'checkCustomPermission' => false
      }
    );
    Test.startTest();
    MobileLendingLeadActions.validateLeadCreation(new List<Lead>{ leadRecord });
    Test.stopTest();

    List<Database.Error> errors = leadRecord.getErrors();
    Database.Error error = errors.get(0);
    Assert.areEqual(1, errors.size(), 'There is no error during lead updation');
    Assert.areEqual(
      Label.Lead_Record_Creation_Error,
      error.getMessage(),
      'Lead updated successfully'
    );
  }

  // Test Method to validate if there is leads creation allowed with ML_Allow_Lead_Creation Permission
  @IsTest
  static void testvalidateLeadCreation() {
    registerMocks();
    Lead leadRecord = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = RTLead.mlcrmLead
    );
    userInfoRepoMock.mock(
      new Map<String, Object>{
        'checkProfile' => true,
        'checkCustomPermission' => true
      }
    );
    Test.startTest();
    MobileLendingLeadActions.validateLeadCreation(new List<Lead>{ leadRecord });
    Test.stopTest();

    Assert.areEqual(
      0,
      leadRecord.getErrors().size(),
      'There is error during lead updation'
    );
  }
}
