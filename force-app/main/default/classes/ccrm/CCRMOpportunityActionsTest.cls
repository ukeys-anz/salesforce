/**
 * @author Emmanuel Yap
 * @since 05/2022
 * @description CCRMOpportunityActionsTest is the test class for CCRMOpportunityActions class.
 */
@isTest
private class CCRMOpportunityActionsTest {
  @testSetup
  static void makeData() {
    User ccrmBaseUser = CCRMTestDataFactory.createCCRMBaseUser();
    TestUtil.assignPermissionSets(
      new List<String>{ 'CCRM_Opportunity_Access' },
      new List<User>{ ccrmBaseUser }
    );
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
      opp.StageName = CCRMConstants.NEW_STAGE;
      opp.Customer_Needs__c = 'Purchasing a new Business';
      opp.Amount = 2000;
      opp.CloseDate = DateTimeUtils.getNextWeekdayDate(3);
      insert opp;
      Test.stopTest();
      opp = [
        SELECT Id, Name, Opp_Id__c, Customer_Needs__c, Amount
        FROM Opportunity
        WHERE id = :opp.id
      ];
      Assert.areEqual(
        opp.Opp_Id__c + ' ' + opp.Customer_Needs__c + ' sample Opp',
        opp.Name,
        'Opportunity Name is the same for Manual Opportunity.'
      );
    }
  }

  @isTest
  static void getFilteredCCRMOppsTest() {
    List<Opportunity> oppList;
    CCRMOpportunityActions.CCRMOpportunityWrapper oppWrapper;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);

    oppList = new List<Opportunity>{
      CCRMTestDataFactory.createStaticOpportunityData(
        oppId,
        'Test Opp',
        RTOpportunity.commercialOpportunity,
        CCRMConstants.IN_PROGRESS_STAGE
      )
    };

    Test.startTest();
    oppWrapper = CCRMOpportunityActions.setOpportunityWrapper(
      oppList,
      new Map<Id, Opportunity>(),
      false
    );
    Test.stopTest();
    Assert.areEqual(1, oppWrapper.filteredOpps.size(), 'Size is not 1');
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
      List<Database.saveResult> results;
      Map<Id, String> updatedOppsNameMap = new Map<Id, String>();

      Test.startTest();
      Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
      updatedOppsNameMap.put(
        oppId,
        '0-0000097 Multiple Customer Needs TestOpp'
      );
      results = CCRMOpportunityActions.updateOpportunityListOnInsert(
        new List<Opportunity>{
          CCRMTestDataFactory.createStaticOpportunityData(
            oppId,
            '0-0000097 Multiple Customer Needs TestOpp',
            RTOpportunity.commercialOpportunity,
            CCRMConstants.NEW_STAGE
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
      Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
      oppList = new List<Opportunity>{
        CCRMTestDataFactory.createStaticOpportunityData(
          oppId,
          '0-0000097 Multiple Customer Needs TestOpp',
          RTOpportunity.commercialOpportunity,
          CCRMConstants.NEW_STAGE
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
        RecordTypeId = RTOpportunity.commercialOpportunity
      );

      oldMap = new Map<Id, Opportunity>{
        opp.Id => new Opportunity(
          Id = opp.Id,
          Customer_Needs__c = 'Purchasing Vacant Land',
          RecordTypeId = RTOpportunity.commercialOpportunity
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
      Assert.areEqual(1, errors.size(), 'Error on update');
      Assert.areEqual(
        CCRMConstants.CUSTOMER_NEEDS_ERROR,
        error.getMessage(),
        'Opportunity updated successfully'
      );
    }
  }
}
