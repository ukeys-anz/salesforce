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
  static void validateSkipStageTest() {
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);
    ApplicationFormProduct afp = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormId,
      CCRMConstants.OPP_WON
    )[0];
    afp.Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType);
    ApplicationFormProduct oldAfp = CCRMTestDataFactory.createAppFormProduct(
      1,
      appFormId,
      CCRMConstants.OPP_IDENTIFIED
    )[0];
    oldAfp.Id = afp.Id;

    Map<Id, String> afpStageSegmentMap = new Map<Id, String>{
      afp.Id => 'Opportunity Identified-CBO'
    };

    Test.startTest();
    CommercialAppFormProductActionsHelper.addErrorForSkippedStage(
      new List<ApplicationFormProduct>{ afp },
      new Map<Id, ApplicationFormProduct>{ oldAfp.Id => oldAfp },
      afpStageSegmentMap
    );
    Test.stopTest();

    List<Database.Error> errors = afp.getErrors();
    Database.Error error = errors.get(0);

    Assert.isFalse(errors.isEmpty(), 'Error found');
    Assert.areEqual(
      CCRMConstants.SKIP_STAGE,
      error.getMessage(),
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
    Assert.isFalse(errors.size() == 0, 'no errors found');
  }
}
