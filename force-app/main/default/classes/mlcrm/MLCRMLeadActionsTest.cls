/**
 * @author Ashish Kumar
 * @since 05/2023
 * @description MLCRM Lead Action is the test class for MLCRM Lead Actions Class functionality.
 */
@isTest
public class MLCRMLeadActionsTest {
  static Lib_MockProvider leadActionsRepoMock;
  static Lib_MockProvider territoryActionsRepoMock;
  static void registerMocks() {
    leadActionsRepoMock = Lib_MockProvider.forType(LeadActionsRepository.class);
    territoryActionsRepoMock = Lib_MockProvider.forType(
      TerritoryActionsRepository.class
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
    MLCRMLeadActions.noLongerNewLeads(oldMap, newleadList);
    Test.stopTest();
    System.assertEquals(
      false,
      leadrecord.isNewLead__c,
      'Lead is still New Lead'
    );
  }

  @isTest
  static void testSetDefaultValueWithoutExpiryDate() {
    Lead leadrecord = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      Expiry_Date__c = null,
      Lead_Originator__c = MLCRMConstants.ORIGINATOR_MLCRM,
      RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID
    );
    Test.startTest();
    MLCRMLeadActions.setDefaultValue(new List<Lead>{ leadrecord });
    String dayName = DateTimeUtils.getDay(
      System.today()
        .addDays(Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate))
    );
    switch on dayName {
      when 'Sat' {
        System.assertEquals(
          System.today()
            .addDays(
              Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate) + 2
            ),
          leadrecord.Expiry_Date__c,
          'Expiry_Date__c is not getting populated correctly when day is Saturday'
        );
      }
      when 'Sun' {
        System.assertEquals(
          System.today()
            .addDays(
              Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate) + 1
            ),
          leadrecord.Expiry_Date__c,
          'Expiry_Date__c is not getting populated correctly when day is Sunday'
        );
      }
      when else {
        System.assertEquals(
          System.today()
            .addDays(Integer.valueOf(System.Label.ML_DefaultLeadExpiryDate)),
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
      Lead_Originator__c = MLCRMConstants.ORIGINATOR_MLCRM,
      RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID
    );
    Test.startTest();
    MLCRMLeadActions.setDefaultValue(new List<Lead>{ leadrecord });
    System.assertEquals(
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
      RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID,
      Territory__c = newTerritoryID
    );
    List<Lead> newLeadList = new List<Lead>{ newLeadRecord };
    Test.startTest();
    MLCRMLeadActions.populatePrimaryFranchise(newLeadList, oldMap);
    Test.stopTest();
    System.assertNotEquals(
      null,
      newLeadRecord.Primary_Franchise_Owner__c,
      'Primay Franchise Owner is not Poulated on Lead'
    );
  }

  @isTest
  static void testGetTerritoryUpdatedLeads() {
    Id leadID = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType());
    Lead oldLeadRecord = new Lead(
      Id = leadID,
      Territory__c = Lib_FakeIdGenerator.getMockId(
        Schema.Territory__c.getSObjectType()
      ),
      Primary_Franchise_Owner__c = null
    );
    Map<Id, Lead> oldMap = new Map<Id, Lead>(new List<Lead>{ oldLeadRecord });
    List<Lead> newLeadList = new List<Lead>{
      new Lead(
        Id = leadID,
        RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID,
        Territory__c = Lib_FakeIdGenerator.getMockId(
          Schema.Territory__c.getSObjectType()
        )
      )
    };
    Test.startTest();
    List<Lead> leadList = MLCRMLeadActions.getTerritoryUpdatedLeads(
      newLeadList,
      oldMap
    );
    Test.stopTest();
    System.assertEquals(
      false,
      leadList.isEmpty(),
      'Territory value is not updated on Lead'
    );
  }

  @isTest
  static void testGetRelatedTerritoryIds() {
    Lead leadRecord = new Lead(
      Territory__c = Lib_FakeIdGenerator.getMockId(
        Schema.Territory__c.getSObjectType()
      )
    );
    Test.startTest();
    Set<ID> territoryIdsSet = MLCRMLeadActions.getRelatedTerritoryIds(
      new List<Lead>{ leadRecord }
    );
    Test.stopTest();
    System.assertEquals(
      false,
      territoryIdsSet.isEmpty(),
      'Territory value is blank on Lead'
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
      RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID,
      Territory__c = territoryID
    );
    List<Lead> leadList = new List<Lead>{ leadRecord };
    Test.startTest();
    MLCRMLeadActions.setLeadPrimaryFranchiseOwner(leadList, territoryList);
    Test.stopTest();
    System.assertNotEquals(
      null,
      leadRecord.Primary_Franchise_Owner__c,
      'Primay Franchise Owner is not Poulated on Lead'
    );
  }

  // Test Method to validate if there is leads creation allowed as Field Team User
  @IsTest
  static void testValidateMLCRMLeadCreationForFieldTeam() {
    registerMocks();
    Lead leadRecord = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID
    );
    leadActionsRepoMock.mock('isCurrentUserAdmin', false);
    leadActionsRepoMock.mock('isAllowLeadCreationCustomPermission', false);
    Test.startTest();
    MLCRMLeadActions.validateMLCRMLeadCreation(new List<Lead>{ leadRecord });
    Test.stopTest();

    List<Database.Error> errors = leadRecord.getErrors();
    Database.Error error = errors.get(0);
    System.assertEquals(
      1,
      errors.size(),
      'There is no error during lead updation'
    );
    System.assertEquals(
      Label.MLCRM_Record_Creation_Error,
      error.getMessage(),
      'Lead updated successfully'
    );
  }

  // Test Method to validate if there is leads creation allowed with ML_Allow_Lead_Creation Permission
  @IsTest
  static void testValidateMLCRMLeadCreation() {
    registerMocks();
    Lead leadRecord = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID
    );
    leadActionsRepoMock.mock('isCurrentUserAdmin', true);
    leadActionsRepoMock.mock('isAllowLeadCreationCustomPermission', true);
    Test.startTest();
    MLCRMLeadActions.validateMLCRMLeadCreation(new List<Lead>{ leadRecord });
    Test.stopTest();

    System.assertEquals(
      0,
      leadRecord.getErrors().size(),
      'There is error during lead updation'
    );
  }

  // Test Method to validate if there are MLCRM Leads records
  @IsTest
  static void testGetFilteredMLCRMLeads() {
    Lead leadRecord = new Lead(RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID);
    Test.startTest();
    List<Lead> leadList = MLCRMLeadActions.getFilteredMLCRMLeads(
      new List<Lead>{ leadRecord }
    );
    Test.stopTest();
    System.assertEquals(1, leadList.size(), 'There is no MLCRM lead records');
  }

  @IsTest
  static void testRaiseLeadError() {
    Lead leadRecord = new Lead(RecordTypeId = MLCRMConstants.MLCRM_LEAD_RT_ID);
    Test.startTest();
    MLCRMLeadActions.raiseLeadError(
      new List<Lead>{ leadRecord },
      Label.MLCRM_Record_Creation_Error
    );
    Test.stopTest();
    List<Database.Error> errors = leadRecord.getErrors();
    Database.Error error = errors.get(0);
    System.assertEquals(
      1,
      errors.size(),
      'There is no error during lead updation'
    );
    System.assertEquals(
      Label.MLCRM_Record_Creation_Error,
      error.getMessage(),
      'Lead updated successfully'
    );
  }
}
