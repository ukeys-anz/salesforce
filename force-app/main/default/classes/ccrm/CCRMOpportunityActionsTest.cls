/**
 * @author Emmanuel Yap
 * @since 05/2022
 * @description CCRM Opportunity Action Test is the test class for CCRM Opportunity Actions Class.
 */
@isTest
private class CCRMOpportunityActionsTest {
  @testSetup
  static void makeData() {
    User ccrmBaseUser = CCRMTestDataFactory.createCCRMBaseUser();
    TestUtil.assignPermissionSets(
      new List<String>{ 'CCRM_Opportunity_Access', 'ActionPlans' },
      new List<User>{ ccrmBaseUser }
    );
    System.runAs(ccrmBaseUser) {
      CCRMTestDataFactory.createActionPlans();
    }
  }

  @isTest
  static void testCreateOpportunity() {
    //Given when banker creates a new Opportunity
    //When Account Name is valid and Amount is valid
    //Then Opportunity Name is Account_Name_Amount
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      Test.startTest();
      Account accnt = CCRMTestDataFactory.createPersonAccount();

      Opportunity opp = new Opportunity();
      opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get('Commercial_Opportunity')
        .getRecordTypeId();
      opp.Name = 'sample Opp';
      opp.AccountId = accnt.id;
      opp.StageName = 'Opportunity Identified';
      opp.Customer_Needs__c = 'Purchasing a new Business';
      opp.Amount = 2000;
      opp.CloseDate = System.today() + 10;
      insert opp;
      Test.stopTest();
      opp = [
        SELECT Id, Name, Opp_Id__c, Customer_Needs__c, Amount
        FROM Opportunity
        WHERE id = :opp.id
      ];
      System.assertEquals(
        opp.Opp_Id__c + ' ' + opp.Customer_Needs__c + ' sample Opp',
        opp.Name,
        'Opportunity Name is the same for Manual Opportunity.'
      );
    }
  }

  @isTest
  static void getFilteredCCRMOppsTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    ccrmBaseUser.Commercial_Segment__c = 'BB';
    update ccrmBaseUser;

    System.runAs(ccrmBaseUser) {
      Map<Id, Opportunity> oldOppMap;
      List<Opportunity> oppList;
      CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper;

      Test.startTest();

      oldOppMap = new Map<Id, Opportunity>{
        '0069h000004rqUQAAY' => CCRMTestDataFactory.createStaticOpportunityData(
          '0069h000004rqUQAAY',
          'Test Opp',
          CCRMConstants.CCRM_OPP_RT_ID,
          'Opportunity Identified'
        ),
        '0069h00000ATaQYAA1' => CCRMTestDataFactory.createStaticOpportunityData(
          '0069h00000ATaQYAA1',
          'Test Opp2',
          CCRMConstants.CCRM_OPP_RT_ID,
          CCRMConstants.CUST_ACCEPT
        )
      };

      oppList = new List<Opportunity>{
        CCRMTestDataFactory.createStaticOpportunityData(
          '0069h000004rqUQAAY',
          'Test Opp',
          CCRMConstants.CCRM_OPP_RT_ID,
          CCRMConstants.NEED_ANALYSIS
        ),
        CCRMTestDataFactory.createStaticOpportunityData(
          '0069h00000ATaQYAA1',
          'Test Opp2',
          CCRMConstants.CCRM_OPP_RT_ID,
          CCRMConstants.OPP_WON
        )
      };

      oppWrapper = CCRMOpportunityActions.getFilteredCCRMOpps(
        oppList,
        oldOppMap,
        true
      );
      Test.stopTest();
      System.assertEquals(2, oppWrapper.filteredOpps.size(), 'Size is not 2');
    }
  }

  @isTest
  static void getStageSegmentOrTemplateMapTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    ccrmBaseUser.Commercial_Segment__c = 'BB';
    update ccrmBaseUser;
    System.runAs(ccrmBaseUser) {
      Map<Id, Opportunity> oldOppMap;
      List<Opportunity> oppList;
      Map<String, CCRM_Commercial_Stage_Action_Plan__mdt> stageActionPlanMapping;
      CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper;

      Test.startTest();
      oldOppMap = new Map<Id, Opportunity>{
        '0069h000004rqUQAAY' => CCRMTestDataFactory.createStaticOpportunityData(
          '0069h000004rqUQAAY',
          'Test Opp',
          CCRMConstants.CCRM_OPP_RT_ID,
          'Opportunity Identified'
        ),
        '0069h00000ATaQYAA1' => CCRMTestDataFactory.createStaticOpportunityData(
          '0069h00000ATaQYAA1',
          'Test Opp2',
          CCRMConstants.CCRM_OPP_RT_ID,
          CCRMConstants.NEED_ANALYSIS
        )
      };

      oppList = new List<Opportunity>{
        CCRMTestDataFactory.createStaticOpportunityData(
          '0069h000004rqUQAAY',
          'Test Opp',
          CCRMConstants.CCRM_OPP_RT_ID,
          CCRMConstants.NEED_ANALYSIS
        ),
        CCRMTestDataFactory.createStaticOpportunityData(
          '0069h00000ATaQYAA1',
          'Test Opp2',
          CCRMConstants.CCRM_OPP_RT_ID,
          CCRMConstants.SOL_DEV
        )
      };
      stageActionPlanMapping = new Map<String, CCRM_Commercial_Stage_Action_Plan__mdt>{
        'Needs Analysis-BB' => new CCRM_Commercial_Stage_Action_Plan__mdt(
          Current_Stage__c = CCRMConstants.NEED_ANALYSIS,
          Previous_Stage__c = 'Opportunity Identified',
          Template_Name__c = CCRMConstants.NEEDS_ANALYSIS_ACTION_PLAN_TEMP,
          Next_Stage__c = CCRMConstants.SOL_DEV
        )
      };

      oppWrapper = new CCRMOpportunityActions.CCRMOpportunityWrapper();
      oppWrapper.stageUpdatedOpps = new Map<Id, Opportunity>(oppList);
      oppWrapper.oppOwnerIdToSegmentMap = new Map<Id, User>{
        '0059t000003l3OvAAI' => ccrmBaseUser
      };
      oppWrapper.oppIdToOwnerIdMap = new Map<Id, String>{
        '0069h000004rqUQAAY' => '0059t000003l3OvAAI',
        '0069h00000ATaQYAA1' => '0059t000003l3OvAAI'
      };

      CCRMOpportunityActions.getStageSegmentOrTemplateMap(
        oppWrapper,
        oldOppMap,
        stageActionPlanMapping
      );
      Test.stopTest();
      System.assertEquals(
        1,
        oppWrapper.oppIdToTemplateNameMap.keySet().size(),
        'Size is not 1'
      );
      System.assertEquals(
        1,
        oppWrapper.oppWithMandatoryTaskMap.keySet().size(),
        'Size is not 1'
      );
    }
  }

  @isTest
  static void getStageActionPlanMetadataTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      Map<String, CCRM_Commercial_Stage_Action_Plan__mdt> metadataRecord;

      Test.startTest();
      metadataRecord = CCRMOpportunityActions.getStageActionPlanMetadata(
        new List<Opportunity>{
          CCRMTestDataFactory.createStaticOpportunityData(
            '0069h000004rqUQAAY',
            'Test Opp',
            CCRMConstants.CCRM_OPP_RT_ID,
            CCRMConstants.NEED_ANALYSIS
          )
        }
      );
      Test.stopTest();
      System.assertEquals(21, metadataRecord.keySet().size(), 'Size is not 21');
    }
  }

  @isTest
  static void generateOpportunityNameTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      String oppName;

      Test.startTest();
      oppName = CCRMOpportunityActions.generateOpportunityName(
        '0-0000097',
        'Multiple Customer Needs',
        'TestOpp'
      );
      Test.stopTest();
      System.assert(oppName.contains('Multiple'), 'Name is not updated');
    }
  }

  @isTest
  static void updateOpportunityListOnInsertTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      List<Opportunity> oppsToUpdate;
      List<Database.saveResult> results;
      Map<Id, String> updatedOppsNameMap = new Map<Id, String>();

      Test.startTest();
      Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.getSObjectType());
      updatedOppsNameMap.put(
        oppId,
        '0-0000097 Multiple Customer Needs TestOpp'
      );
      results = CCRMOpportunityActions.updateOpportunityListOnInsert(
        new List<Opportunity>{
          CCRMTestDataFactory.createStaticOpportunityData(
            oppId,
            '0-0000097 Multiple Customer Needs TestOpp',
            CCRMConstants.CCRM_OPP_RT_ID,
            CCRMConstants.NEED_ANALYSIS
          )
        },
        updatedOppsNameMap
      );
      Test.stopTest();
      System.assertEquals(1, results.size(), 'no opps to update');
    }
  }

  @isTest
  static void getOpportunityOldNameTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      String result;
      Opportunity newOpp;
      List<Opportunity> oppList;

      //Inserted opportunity so as to test for Opp_Id__c(autonumber)
      oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        true
      );
      oppList[0].Customer_Needs__c = 'Purchasing Vacant Land';

      newOpp = [
        SELECT Id, Name, Opp_Id__c, Lead_Converted__c
        FROM Opportunity
        WHERE Id = :oppList[0].Id
      ];
      newOpp.Customer_Needs__c = 'Purchasing Property';

      Test.startTest();
      result = CCRMOpportunityActions.getOpportunityOldName(
        newOpp,
        new Map<Id, Opportunity>{ oppList[0].Id => oppList[0] }
      );

      Test.stopTest();
      System.assertEquals('Test Opp 1', result, 'Name mismatch');
    }
  }

  @isTest
  static void getMapWithUpdatedOpportunitiesNameTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      Map<Id, String> result = new Map<Id, String>();
      Opportunity newOpp;
      List<Opportunity> oppList;

      //Inserted opportunity so as to test for Opp_Id__c(autonumber)
      oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        true
      );
      oppList[0].Customer_Needs__c = 'Purchasing Vacant Land';

      newOpp = [
        SELECT Id, Name, Opp_Id__c, Secondary_Customer_Needs__c
        FROM Opportunity
        WHERE Id = :oppList[0].Id
      ];
      newOpp.Customer_Needs__c = 'Purchasing Property';
      newOpp.Lead_Converted__c = true;

      Test.startTest();
      result = CCRMOpportunityActions.getMapWithUpdatedOpportunitiesName(
        new List<Opportunity>{ newOpp },
        new Map<Id, Opportunity>{ oppList[0].Id => oppList[0] }
      );
      Test.stopTest();
      System.assertEquals(1, result.size(), 'Result is null');
    }
  }

  @isTest
  static void getFilteredOpportunitiesTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      List<Opportunity> result = new List<Opportunity>();
      List<Opportunity> oppList;
      Opportunity oldOpp;
      Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.getSObjectType());
      oppList = new List<Opportunity>{
        CCRMTestDataFactory.createStaticOpportunityData(
          oppId,
          '0-0000097 Multiple Customer Needs TestOpp',
          CCRMConstants.CCRM_OPP_RT_ID,
          CCRMConstants.NEED_ANALYSIS
        )
      };
      oppList[0].Customer_Needs__c = 'Purchasing Vacant Land';
      oppList[0].Secondary_Customer_Needs__c = 'Purchasing Property';
      oldOpp = new Opportunity(
        Id = oppId,
        Customer_Needs__c = 'Purchasing Property'
      );
      Test.startTest();
      result = CCRMOpportunityActions.getFilteredOpportunities(
        oppList,
        new Map<Id, Opportunity>{ oppId => oldOpp }
      );
      Test.stopTest();
      System.assert(result.size() > 0, 'No opps found');
    }
  }

  @isTest
  static void updateOpportunityNameOnUpdateTest() {
    User ccrmBaseUser = [SELECT Id FROM User WHERE LastName = 'CCRM' LIMIT 1];
    System.runAs(ccrmBaseUser) {
      List<Opportunity> result = new List<Opportunity>();
      Opportunity newOpp;
      List<Opportunity> oppList;

      oppList = CCRMTestDataFactory.createOpportunityRecords(
        1,
        ccrmBaseUser,
        false
      );
      oppList[0].Customer_Needs__c = 'Purchasing Vacant Land';
      oppList[0].Secondary_Customer_Needs__c = 'Purchasing Property';
      insert oppList[0];

      newOpp = [
        SELECT Id, Name, Opp_Id__c, Secondary_Customer_Needs__c
        FROM Opportunity
        WHERE Id = :oppList[0].Id
      ];
      newOpp.Customer_Needs__c = 'Construction and Renovation';

      Test.startTest();
      update newOpp;
      Test.stopTest();
      result = [SELECT Id, Name FROM Opportunity WHERE Id = :oppList[0].Id];
      System.assert(result[0].Name.contains('Multiple'), 'No opps to update');
    }
  }

  @isTest
  static void testCheckIfSecondaryCustomerNeedsContainsCustomerNeeds() {
    System.runAs(CCRMTestDataFactory.getCCRMBaseUser()) {
      Opportunity opp;
      Map<Id, Opportunity> oldMap;
      List<Database.Error> errors;
      Database.Error error;

      opp = new Opportunity(
        Id = Lib_FakeIdGenerator.getMockId(Schema.Opportunity.getSObjectType()),
        Customer_Needs__c = 'Purchasing Property',
        Secondary_Customer_Needs__c = 'Purchasing Property',
        RecordTypeId = CCRMConstants.CCRM_OPP_RT_ID
      );

      oldMap = new Map<Id, Opportunity>{
        opp.Id => new Opportunity(
          Id = opp.Id,
          Customer_Needs__c = 'Purchasing Vacant Land',
          RecordTypeId = CCRMConstants.CCRM_OPP_RT_ID
        )
      };

      Test.startTest();
      CCRMOpportunityActions.checkIfSecondaryCustomerNeedsContainsCustomerNeeds(
        new List<Opportunity>{ opp },
        oldMap,
        false
      );
      Test.stopTest();

      errors = opp.getErrors();
      error = errors.get(0);

      System.assertEquals(1, errors.size());
      System.assertEquals(
        CCRMConstants.CUSTOMER_NEEDS_ERROR,
        error.getMessage(),
        'Opportunity updated successfully'
      );
    }
  }
}
