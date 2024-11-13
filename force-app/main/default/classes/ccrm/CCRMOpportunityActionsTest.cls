/**
 * @author Emmanuel Yap
 * @since 05/2022
 * @description CCRMOpportunityActionsTest is the test class for CCRMOpportunityActions class.
 */
@isTest
private class CCRMOpportunityActionsTest {
  @isTest
  static void testCreateOpportunity() {
    //Given when banker creates a new Opportunity
    //When Account Name is valid and Amount is valid
    //Then Opportunity Name is Account_Name_Amount

    Account accnt = CCRMTestDataFactory.createPersonAccount();

    Opportunity opp = new Opportunity();
    opp.RecordTypeId = RTOpportunity.commercialOpportunity;
    opp.Name = 'sample Opp';
    opp.AccountId = accnt.id;
    opp.StageName = CCRMConstants.NEW_STAGE;
    opp.Customer_Needs__c = 'Purchasing a new Business';
    opp.Amount = 2000;
    opp.CloseDate = DateTimeUtils.getNextWeekdayDate(3);
    Test.startTest();
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
    String oppName;

    Test.startTest();
    oppName = CCRMOpportunityActions.generateOpportunityName(
      '0-0000097',
      'Multiple Customer Needs',
      'TestOpp'
    );
    Test.stopTest();
    Assert.isTrue(oppName.contains('Multiple'), 'Name is not updated');
  }

  @isTest
  static void updateOpportunityListOnInsertTest() {
    Map<Id, String> updatedOppsNameMap = new Map<Id, String>();
    List<Database.saveResult> results;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    updatedOppsNameMap.put(oppId, '0-0000097 Multiple Customer Needs TestOpp');

    Test.startTest();
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
    Assert.areEqual(1, results.size(), 'no opps to update');
  }

  @isTest
  static void getOpportunityOldNameTest() {
    String result;
    Opportunity newOpp;
    List<Opportunity> oppList;

    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    oppList = CCRMTestDataFactory.createOpportunityRecords(1, null, false);
    oppList[0].Id = oppId;
    oppList[0].Customer_Needs__c = 'Purchasing Vacant Land';

    newOpp = (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = oppList[0].Id,
        Customer_Needs__c = 'Purchasing Property'
      ),
      new Map<String, Object>{ 'Opp_Id__c' => '12345678' }
    );

    Test.startTest();
    result = CCRMOpportunityActions.getOpportunityOldName(
      newOpp,
      new Map<Id, Opportunity>{ oppList[0].Id => oppList[0] }
    );

    Test.stopTest();
    Assert.areEqual('Test Opp 1', result, 'Name mismatch');
  }

  @isTest
  static void getMapWithUpdatedOpportunitiesNameTest() {
    Map<Id, String> result = new Map<Id, String>();
    Opportunity newOpp;
    List<Opportunity> oppList;

    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    oppList = CCRMTestDataFactory.createOpportunityRecords(1, null, false);
    oppList[0].Id = oppId;
    oppList[0].Customer_Needs__c = 'Purchasing Vacant Land';

    newOpp = (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = oppList[0].Id,
        Customer_Needs__c = 'Purchasing Property',
        Lead_Converted__c = true
      ),
      new Map<String, Object>{ 'Opp_Id__c' => '12345678' }
    );

    Test.startTest();
    result = CCRMOpportunityActions.getMapWithUpdatedOpportunitiesName(
      new List<Opportunity>{ newOpp },
      new Map<Id, Opportunity>{ oppList[0].Id => oppList[0] }
    );
    Test.stopTest();
    Assert.areEqual(1, result.size(), 'Result is null');
  }

  @isTest
  static void getFilteredOpportunitiesTest() {
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
    Assert.isTrue(result.size() > 0, 'No opps found');
  }

  @isTest
  static void updateOpportunityNameOnUpdateTest() {
    List<Opportunity> oppList = CCRMTestDataFactory.createOpportunityRecords(
      1,
      null,
      false
    );
    oppList[0].Customer_Needs__c = 'Purchasing Vacant Land';
    oppList[0].Secondary_Customer_Needs__c = 'Purchasing Property';

    Opportunity newOpp = (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = oppList[0].Id,
        Customer_Needs__c = 'Construction and Renovation',
        Name = 'test',
        Secondary_Customer_Needs__c = 'Purchasing Property'
      ),
      new Map<String, Object>{ 'Opp_Id__c' => '12345678' }
    );
    Test.startTest();
    List<Opportunity> opps = CCRMOpportunityActions.updateOpportunityNameOnUpdate(
      new List<Opportunity>{ newOpp },
      new Map<Id, Opportunity>{ oppList[0].Id => oppList[0] }
    );
    Test.stopTest();
    Assert.isTrue(opps[0].Name.contains('Multiple'), 'No opps to update');
  }

  @isTest
  static void testCheckIfSecondaryCustomerNeedsContainsCustomerNeeds() {
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
