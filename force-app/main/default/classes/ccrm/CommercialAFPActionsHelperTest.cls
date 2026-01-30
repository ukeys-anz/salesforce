/**
 * @author Ayushi Gupta
 * @since 09/2024
 * @description  CommercialAFPActionsHelperTest is the test class for CommercialAFPActionsHelper.
 */
@isTest
private class CommercialAFPActionsHelperTest {
  static Lib_MockProvider appFormProductRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider commercialOppRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    appFormProductRepoMock = Lib_MockProvider.forType(
      CommercialAppFormProductActionsRepo.class
    );
    commercialOppRepoMock = Lib_MockProvider.forType(
      CommercialOpportunityRepository.class
    );
  }
  @isTest
  static void validateAFPOnInsertTest() {
    String expMsg = 'Stage can only be set to Opportunity Identified.';
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    List<ApplicationFormProduct> afpList = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormId,
      CCRMConstants.NEED_ANALYSIS
    );
    CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = new CommercialAppFormProductActionsHelper.AppFormProductWrapper();
    appFormProductWrapper.filteredAppFormProducts = afpList;

    Test.startTest();
    CommercialAppFormProductActionsHelper.validateCommercialAppFormProducts(
      appFormProductWrapper,
      true
    );
    Test.stopTest();
    List<Database.Error> errors = afpList[0].getErrors();
    Database.Error error = errors.get(0);
    Assert.areEqual(expMsg, error.getMessage(), 'No error occured');
  }

  @isTest
  static void populateAppFormProductWrapperTest() {
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    List<ApplicationFormProduct> afpList = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormId,
      CCRMConstants.NEED_ANALYSIS
    );
    afpList[0].Id = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      afpList[0].Id => new ApplicationFormProduct(
        Id = afpList[0].Id,
        Stage = CCRMConstants.OPP_IDENTIFIED
      )
    };
    CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = new CommercialAppFormProductActionsHelper.AppFormProductWrapper();
    appFormProductWrapper.filteredAppFormProducts = afpList;
    Test.startTest();
    appFormProductWrapper = CommercialAppFormProductActionsHelper.populateAppFormProductWrapper(
      appFormProductWrapper,
      oldMap
    );
    Test.stopTest();
    Assert.isFalse(
      appFormProductWrapper.stageUpdatedAppFormProducts.values().isEmpty(),
      'No error occured'
    );
  }

  @isTest
  static void validateCommercialAppFormProductsTest() {
    String expMsgForLostOpp =
      'Please provide valid Lost Reason/Lost Reason Detail.\n' +
      'Won From/Lost To is mandatory to Proceed to Opportunity Won/Lost.';
    String expMsgForWonOpp = 'Won From/Lost To is mandatory to Proceed to Opportunity Won/Lost.';

    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    ApplicationFormProduct closedLostOpp = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormId,
      CCRMConstants.OPP_LOST
    )[0];
    closedLostOpp.Id = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    ApplicationFormProduct closedWonOpp = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormId,
      CCRMConstants.OPP_WON
    )[0];
    closedWonOpp.Id = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = new CommercialAppFormProductActionsHelper.AppFormProductWrapper();
    appFormProductWrapper.filteredAppFormProducts = new List<ApplicationFormProduct>{
      closedLostOpp,
      closedWonOpp
    };
    appFormProductWrapper.stageUpdatedAppFormProducts = new Map<Id, ApplicationFormProduct>{
      closedLostOpp.Id => closedLostOpp,
      closedWonOpp.Id => closedWonOpp
    };

    Test.startTest();
    CommercialAppFormProductActionsHelper.validateCommercialAppFormProducts(
      appFormProductWrapper,
      false
    );
    Test.stopTest();
    List<Database.Error> lostOppErrors = closedLostOpp.getErrors();
    Database.Error lostOppError = lostOppErrors.get(0);

    List<Database.Error> wonOppErrors = closedWonOpp.getErrors();
    Database.Error wonOppError = wonOppErrors.get(0);

    Assert.areEqual(
      expMsgForLostOpp,
      lostOppError.getMessage(),
      'AFP updated successfully'
    );
    Assert.areEqual(
      expMsgForWonOpp,
      wonOppError.getMessage(),
      'AFP updated successfully'
    );
  }

  @isTest
  static void getStageSegmentMapTest() {
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    User runningUser = new User(Id = userId, Commercial_Segment__c = 'CBO');
    Id appFormProductId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    ApplicationFormProduct newRec = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormId,
      'Needs Analysis'
    )[0];
    newRec.Id = appFormProductId;
    ApplicationFormProduct oldRec = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormId,
      CCRMConstants.OPP_IDENTIFIED
    )[0];
    oldRec.Id = appFormProductId;

    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      appFormProductId => oldRec
    };

    CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = new CommercialAppFormProductActionsHelper.AppFormProductWrapper();
    appFormProductWrapper.stageUpdatedAppFormProducts = new Map<Id, ApplicationFormProduct>{
      newRec.Id => newRec
    };

    appFormProductWrapper.afpOwnerIdToSegmentMap = new Map<Id, User>{
      userId => runningUser
    };
    appFormProductWrapper.afpIdToOwnerIdMap = new Map<Id, String>{
      appFormProductId => userId
    };

    Test.startTest();
    appFormProductWrapper = CommercialAppFormProductActionsHelper.getStageSegmentMap(
      appFormProductWrapper,
      oldMap
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      appFormProductWrapper.afpStageSegmentMap.keySet().size(),
      'Size is not 1'
    );
    Assert.areEqual(
      new List<String>{ 'Opportunity Identified-CBO' },
      appFormProductWrapper.afpStageSegmentMap.values(),
      'no value found'
    );
  }

  @isTest
  static void getAppFormProductsRelatedToCommOppTest() {
    registerMocks();
    //Create mock data
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    List<ApplicationFormProduct> afpList = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormId,
      CCRMConstants.OPP_IDENTIFIED
    );
    List<ApplicationForm> appForms = CCRMTestDataFactory.createAppForm(
      1,
      oppId
    );
    appForms[0].Id = appFormId;
    // Mock the Repo Methods
    appFormProductRepoMock.mock('getApplicationForms', appForms);
    Test.startTest();
    CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = CommercialAppFormProductActionsHelper.getAppFormProductsRelatedToCommercialOpportunity(
      new Set<Id>{ appFormId },
      afpList
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      appFormProductWrapper.filteredAppFormProducts.size(),
      'No records found'
    );
  }

  @isTest
  static void mandatoryFieldAndSkipStageCheckTest() {
    registerMocks();
    List<Database.Error> errors;
    CommercialAppFormProductActionsHelper.AppFormProductWrapper appFormProductWrapper = new CommercialAppFormProductActionsHelper.AppFormProductWrapper();
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    User userRec = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Commercial_Segment__c = 'CBO'
    );
    List<ApplicationFormProduct> afpList = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormId,
      CCRMConstants.CUST_ACCEPT
    );
    afpList[0].Id = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    afpList[0].OwnerId = userRec.Id;
    appFormProductWrapper.filteredAppFormProducts = afpList;
    Map<Id, ApplicationFormProduct> oldMap = new Map<Id, ApplicationFormProduct>{
      afpList[0].Id => new ApplicationFormProduct(
        Id = afpList[0].Id,
        Stage = CCRMConstants.OPP_IDENTIFIED,
        OwnerId = userRec.Id
      )
    };

    // Mock the Repo Methods
    commercialOppRepoMock.mock('getUsers', new List<User>{ userRec });

    Test.startTest();
    CommercialAppFormProductActionsHelper.mandatoryFieldAndSkipStageCheck(
      appFormProductWrapper,
      oldMap,
      false
    );
    Test.stopTest();
    errors = afpList[0].getErrors();
    Assert.isTrue(
      errors.isEmpty(),
      'Expected no errors, but found: ' + errors.size()
    );
  }

  @isTest
  static void updateStageTest() {
    // Create a mock ApplicationFormProduct record
    ApplicationFormProduct afp = new ApplicationFormProduct(
      Stage = 'Opportunity Identified',
      Source_System_Status__c = 'Locked for Assessment'
    );
    Test.startTest();
    CommercialAppFormProductActionsHelper.updateStage(
      new List<ApplicationFormProduct>{ afp }
    );
    Test.stopTest();
    Assert.areEqual('Solution Development', afp.Stage, 'No record updated');
  }

  @isTest
  static void formOppToAmountMapTest() {
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    Id afId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id afId2 = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    Id afpId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );

    List<ApplicationFormProduct> afpList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = afpId,
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId,
        Revenue__c = 50,
        ApplicationForm = new ApplicationForm(
          Id = afId,
          RecordTypeId = RTApplicationForm.acmApplication,
          OpportunityId = oppId
        )
      ),
      new ApplicationFormProduct(
        Id = afpId,
        Opportunity_Product__c = oliId,
        ApplicationFormId = afId2,
        Revenue__c = 500,
        ApplicationForm = new ApplicationForm(
          Id = afId2,
          RecordTypeId = RTApplicationForm.ambitApplication,
          OpportunityId = oppId
        )
      )
    };

    Map<Id, Id> itemIdToOppIdMap = new Map<Id, Id>{ oliId => oppId };
    Map<Id, List<ApplicationFormProduct>> oliToAfpMap = new Map<Id, List<ApplicationFormProduct>>{
      oliId => afpList
    };
    Test.startTest();
    Map<Id, Decimal> oppToEstimatedRevenueMap = CommercialAppFormProductActionsHelper.formOppToAmountMap(
      itemIdToOppIdMap,
      oliToAfpMap,
      ApplicationFormProduct.Revenue__c
    );
    Test.stopTest();
    Assert.areEqual(
      500,
      oppToEstimatedRevenueMap.get(oppId),
      'Estimated Revenue on opp is not 500'
    );
  }

  @isTest
  static void formOppToAmountMapNegativeTest() {
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);

    Map<Id, Id> itemIdToOppIdMap = new Map<Id, Id>{ oliId => oppId };
    Map<Id, List<ApplicationFormProduct>> oliToAfpMap = new Map<Id, List<ApplicationFormProduct>>{
      oliId => new List<ApplicationFormProduct>()
    };
    Test.startTest();
    Map<Id, Decimal> oppToEstimatedRevenueMap = CommercialAppFormProductActionsHelper.formOppToAmountMap(
      itemIdToOppIdMap,
      oliToAfpMap,
      ApplicationFormProduct.Revenue__c
    );
    Test.stopTest();
    Assert.areEqual(
      0,
      oppToEstimatedRevenueMap.get(oppId),
      'Estimated Revenue on opp is not 0'
    );
  }

  @isTest
  static void updateAmountOnOpportunityTest() {
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Map<Id, Decimal> oppToAppAmountMap = new Map<Id, Decimal>{ oppId => 500 };

    Test.startTest();
    List<Opportunity> opps = CommercialAppFormProductActionsHelper.updateAmountOnOpportunity(
      oppToAppAmountMap,
      Opportunity.Estimated_Revenue__c
    );
    Test.stopTest();
    Assert.areEqual(
      500,
      opps[0].Estimated_Revenue__c,
      'Estimated Revenue on opp is not 500'
    );
  }
  @isTest
  static void formRefNoToExistingAfpListMapTest() {
    //GIVEN existingAfpList
    List<ApplicationFormProduct> existingAfpList = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
        Reference_Number__c = '1234'
      )
    };

    //WHEN calling a method
    Test.startTest();
    Map<String, List<ApplicationFormProduct>> refNoToExistingAfpListMap = CommercialAppFormProductActionsHelper.formRefNoToExistingAfpListMap(
      existingAfpList
    );
    Test.stopTest();

    //THEN it should assert successfully
    Assert.areEqual(
      1,
      refNoToExistingAfpListMap.size(),
      'should form a map successfully'
    );
  }

  @isTest
  static void setPDFlagTest() {
    //GIVEN refNoToExistingAfpListMap
    Map<String, List<ApplicationFormProduct>> refNoToExistingAfpListMap = new Map<String, List<ApplicationFormProduct>>{
      '1234' => new List<ApplicationFormProduct>{
        new ApplicationFormProduct(
          Id = Lib_FakeIdGenerator.getMockId(
            ApplicationFormProduct.SObjectType
          ),
          Reference_Number__c = '1234'
        )
      },
      '12345' => new List<ApplicationFormProduct>{
        new ApplicationFormProduct(
          Id = Lib_FakeIdGenerator.getMockId(
            ApplicationFormProduct.SObjectType
          ),
          Reference_Number__c = '12345'
        ),
        new ApplicationFormProduct(
          Id = Lib_FakeIdGenerator.getMockId(
            ApplicationFormProduct.SObjectType
          ),
          Reference_Number__c = '12345'
        )
      }
    };

    //WHEN calling a method
    Test.startTest();
    List<ApplicationFormProduct> afpListToUpdate = CommercialAppFormProductActionsHelper.setPDFlag(
      refNoToExistingAfpListMap
    );
    Test.stopTest();

    //THEN it should assert successfully
    Assert.areEqual(
      3,
      afpListToUpdate.size(),
      'should return 3 records of AFP to be updated'
    );
  }
}
