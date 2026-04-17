/**
 * @author Ayushi Gupta
 * @since  09/2024
 * @description Test class of LaunchAppOnOppController
 */
@isTest
private class LaunchAppOnOppControllerTest {
  static Lib_MockProvider launchAppRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    launchAppRepoMock = Lib_MockProvider.forType(
      LaunchAppOnOppControllerRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void getOpportunityLineItemsTest() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    //Mock data creation
    OpportunityLineItem oli = new OpportunityLineItem(
      Id = oliId,
      Product2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
      UnitPrice = 20,
      Funding_purpose__c = 'Property Purchase or Construction',
      Product2 = new Product2(Name = 'Test')
    );
    ApplicationFormProduct afp = new ApplicationFormProduct(
      Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
      Source_System_Id__c = oppId + '' + oliId,
      ApplicationForm = new ApplicationForm(
        OpportunityId = oppId,
        RecordType = new RecordType(DeveloperName = 'AMBIT')
      )
    );
    launchAppRepoMock.mock(
      'getOpportunityLineItems',
      new List<OpportunityLineItem>{ oli }
    );
    launchAppRepoMock.mock(
      'getAppFormProductsRelatedToOpp',
      new List<ApplicationFormProduct>{ afp }
    );
    Test.startTest();
    List<LaunchAppOnOppController.OppLineItemWrapper> oliList = LaunchAppOnOppController.getOpportunityLineItems(
      oppId,
      'AMBIT'
    );
    Test.stopTest();
    Assert.isNotNull(oliList, 'No records are created');
  }

  @isTest
  static void createApplicationTest() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Id recordTypeId = QueryRT.of(ApplicationForm.SObjectType).getId('AMBIT');
    OpportunityLineItem oli = new OpportunityLineItem(
      Id = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType),
      Product2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
      UnitPrice = 20,
      Funding_purpose__c = 'Property Purchase or Construction',
      Product2 = new Product2(Name = 'Test')
    );
    launchAppRepoMock.mock(
      'getSelectedOppLineItems',
      new List<OpportunityLineItem>{ oli }
    );
    launchAppRepoMock.mock(
      'getAppFormProductsUsingExtId',
      new List<ApplicationFormProduct>()
    ); // Return empty list to simulate no existing app form products
    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true,"id":"0013000000abcde"}')
      }
    );
    Test.startTest();
    List<Id> appFormProductIds = LaunchAppOnOppController.createApplication(
      oppId,
      new List<Id>{ productId },
      recordTypeId
    );
    Test.stopTest();
    Assert.isNotNull(appFormProductIds, 'No records are created');
  }

  @isTest
  static void populateRecordTypeWrapperTest() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id recordTypeId = QueryRT.of(ApplicationForm.SObjectType).getId('ACM');
    launchAppRepoMock.mock(
      'getOppIdAndSourceSystemId',
      new Opportunity(Id = oppId)
    );
    Test.startTest();
    List<LaunchAppOnOppController.RecordTypeWrapper> recordTypeWrapperList = LaunchAppOnOppController.populateRecordTypeWrapper(
      oppId
    );
    Test.stopTest();
    Assert.isNotNull(recordTypeWrapperList, 'No record types found');
  }

  @isTest
  static void populateRecordTypeWrapperBBDTest() {
    registerMocks();
    Exception ex;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id recordTypeId = QueryRT.of(ApplicationForm.SObjectType).getId('BBD');
    launchAppRepoMock.mock(
      'getOppIdAndSourceSystemId',
      new Opportunity(
        Id = oppId,
        Account = new Account(Source_System_ID__c = '12345')
      )
    );
    Test.startTest();
    try {
      List<LaunchAppOnOppController.RecordTypeWrapper> recordTypeWrapperList = LaunchAppOnOppController.populateRecordTypeWrapper(
        oppId
      );
    } catch (Exception e) {
      ex = e;
    }
    Test.stopTest();
    Assert.isNotNull(ex, 'Exception should be thrown');
  }

  @isTest
  static void populateRecordTypeWrapperCatchTest() {
    registerMocks();
    Exception ex;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    launchAppRepoMock.mock('getOppIdAndSourceSystemId', null);

    Test.startTest();
    try {
      List<LaunchAppOnOppController.RecordTypeWrapper> recordTypeWrapperList = LaunchAppOnOppController.populateRecordTypeWrapper(
        oppId
      );
    } catch (Exception e) {
      ex = e;
    }
    Test.stopTest();
    Assert.isNotNull(ex, 'Exception should be thrown');
  }

  @isTest
  static void testValidateOpportunityPositive() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Contact brokerRec = (Contact) TestUtil.setFields(
      new Contact(
        FirstName = 'Sample',
        LastName = 'Contact',
        Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
        Broker_Accreditation_Type__c = 'Asset Finance',
        Asset_Finance_Accreditation_Status__c = 'Active',
        AssetFinanceTPMISAO__c = 'CA-123456'
      ),
      new Map<String, Object>()
    );
    Opportunity oppRec = (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = oppId,
        Name = 'Sample Opportunity',
        StageName = 'Opportunity Identified',
        AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Broker_Name__c = brokerRec.Id,
        Broker_Name__r = brokerRec,
        Description = 'Sample Opp'
      ),
      new Map<String, List<OpportunityTeamMember>>{
        'OpportunityTeamMembers' => new List<OpportunityTeamMember>{
          new OpportunityTeamMember(
            Id = Lib_FakeIdGenerator.getMockId(
              OpportunityTeamMember.SObjectType
            ),
            TeamMemberRole = 'Asset Finance'
          )
        }
      }
    );
    launchAppRepoMock.mock('getOpportunityData', oppRec);
    Test.startTest();
    String errorMessage = LaunchAppOnOppController.validateOpportunity(oppId);
    Test.stopTest();

    Assert.isNull(
      errorMessage,
      'Opportunity should be associated with AF Accrediated Broker'
    );
  }

  @isTest
  static void testValidateOpportunityNegative() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Contact brokerRec = (Contact) TestUtil.setFields(
      new Contact(
        FirstName = 'Sample',
        LastName = 'Contact',
        Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
        Broker_Accreditation_Type__c = 'Asset Finance',
        Asset_Finance_Accreditation_Status__c = 'In Progress',
        AssetFinanceTPMISAO__c = 'CA-123456'
      ),
      new Map<String, Object>()
    );
    Opportunity oppRec = new Opportunity(
      Id = oppId,
      Name = 'Sample Opportunity',
      StageName = 'Opportunity Identified',
      AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Broker_Name__c = brokerRec.Id,
      Broker_Name__r = brokerRec,
      Description = 'Sample Opp'
    );

    launchAppRepoMock.mock('getOpportunityData', oppRec);
    Test.startTest();
    String errorMessage = LaunchAppOnOppController.validateOpportunity(oppId);
    Test.stopTest();

    Assert.areEqual(
      LaunchAppOnOppController.AF_ACCREDITED_BROKER_ERROR,
      errorMessage,
      'Opportunity should not be associated with AF Accrediated Broker'
    );
  }

  @isTest
  static void testCLGCustomerNoAMBITApp() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Account accRecord = (Account) TestUtil.setFields(
      new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.getSobjectType()),
        RecordType = new RecordType(Name = 'CLG'),
        Name = 'Sample Account'
      ),
      new Map<String, Object>()
    );

    Opportunity oppRec = new Opportunity(
      Id = oppId,
      Name = 'Sample Opportunity',
      StageName = 'Opportunity Identified',
      Account = accRecord,
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Description = 'Sample Opp'
    );

    launchAppRepoMock.mock('getOpportunityData', oppRec);
    Test.startTest();
    String errorMessage = LaunchAppOnOppController.validateOpportunity(oppId);
    Test.stopTest();

    Assert.areEqual(
      LaunchAppOnOppController.NON_CLG_INDIVIDUAL_CUSTOMER_ERROR,
      errorMessage,
      'Opportunity with CLG CUstomer should not launch AMBIT application'
    );
  }

  @isTest
  static void getAMBITResponseTest() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    Account accRec = (Account) TestUtil.setFields(
      new Account(
        Name = 'Sample Account',
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Source_System_ID__c = '12345'
      ),
      new Map<String, Object>()
    );
    User ownerRec = (User) TestUtil.setFields(
      new User(
        FirstName = 'Sample',
        LastName = 'User',
        Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Lan_Id__c = 'userlanId1'
      ),
      new Map<String, Object>()
    );
    Contact brokerRec = (Contact) TestUtil.setFields(
      new Contact(
        FirstName = 'Sample',
        LastName = 'Contact',
        Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
        Broker_Accreditation_Type__c = 'Asset Finance',
        Asset_Finance_Accreditation_Status__c = 'Active',
        AssetFinanceTPMISAO__c = 'CA-123456'
      ),
      new Map<String, Object>()
    );
    User userRec = (User) TestUtil.setFields(
      new User(
        Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Lan_Id__c = 'userlanId2'
      ),
      new Map<String, Object>()
    );
    Opportunity oppRec = (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = oppId,
        Name = 'Sample Opportunity',
        StageName = 'Opportunity Identified',
        Account = accRec,
        Owner = ownerRec,
        Broker_Name__r = brokerRec,
        Description = 'Sample Opp'
      ),
      new Map<String, List<OpportunityTeamMember>>{
        'OpportunityTeamMembers' => new List<OpportunityTeamMember>{
          new OpportunityTeamMember(
            Id = Lib_FakeIdGenerator.getMockId(
              OpportunityTeamMember.SObjectType
            ),
            TeamMemberRole = 'Asset Finance',
            User = userRec
          )
        }
      }
    );
    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>{
      new OpportunityLineItem(
        Id = oliId,
        OpportunityId = oppId,
        Product2Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
        UnitPrice = 20,
        Funding_purpose__c = 'Property Purchase or Construction',
        Product2 = new Product2(Name = 'Test')
      )
    };
    List<Id> oliIdsList = new List<Id>{ oliId };
    launchAppRepoMock.mock('getOpportunityData', oppRec);
    launchAppRepoMock.mock('getSelectedOppLineItems', oliList);

    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true,"id":"0013000000abcde"}')
      }
    );
    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new AmbitTestMock());

    //WHEN calling a createApplication method
    Boolean response = LaunchAppOnOppController.getAMBITResponse(
      oppId,
      oliIdsList[0]
    );
    Test.stopTest();

    //THEN it should return successful response
    Assert.isTrue(response, 'AMBIT Response should be true');
  }

  @isTest
  static void testValidateOpportunityTeamMember() {
    registerMocks();

    //GIVEN Opportunity with Opp Team Member record
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Opportunity oppRec = (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = oppId,
        Name = 'Sample Opportunity',
        StageName = 'Opportunity Identified',
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Description = 'Sample Opp'
      ),
      new Map<String, List<OpportunityTeamMember>>{
        'OpportunityTeamMembers' => new List<OpportunityTeamMember>{
          new OpportunityTeamMember(
            Id = Lib_FakeIdGenerator.getMockId(
              OpportunityTeamMember.SObjectType
            ),
            TeamMemberRole = 'Private Banking',
            UserId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
          )
        }
      }
    );

    launchAppRepoMock.mock('getOpportunityData', oppRec);

    //WHEN calling a method
    Test.startTest();
    String errorMessage = LaunchAppOnOppController.validateOpportunity(oppId);
    Test.stopTest();

    //THEN it should assert successfully
    Assert.areNotEqual(
      LaunchAppOnOppController.OPP_TEAM_MEMBR_ERROR,
      errorMessage,
      'Asset Finance Manager under Opportunity team should be there'
    );
  }

  @isTest
  static void testValidateOpportunityTeamMemberPositive() {
    registerMocks();

    //GIVEN Opportunity with Opp Team Member record
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Opportunity oppRec = (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = oppId,
        Name = 'Sample Opportunity',
        StageName = 'Opportunity Identified',
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Description = 'Sample Opp'
      ),
      new Map<String, List<OpportunityTeamMember>>{
        'OpportunityTeamMembers' => new List<OpportunityTeamMember>{
          new OpportunityTeamMember(
            Id = Lib_FakeIdGenerator.getMockId(
              OpportunityTeamMember.SObjectType
            ),
            TeamMemberRole = 'Asset Finance',
            UserId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
          )
        }
      }
    );

    launchAppRepoMock.mock('getOpportunityData', oppRec);

    //WHEN calling a method
    Test.startTest();
    String errorMessage = LaunchAppOnOppController.validateOpportunity(oppId);
    Test.stopTest();

    //THEN it should assert successfully
    Assert.isNull(
      errorMessage,
      'should have Asset Finance Manager under Opportunity team'
    );
  }

  @isTest
  static void validateSelectedOppLineItemsTest() {
    registerMocks();

    //GIVEN Opportunity Id, appFormProducts
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    List<Id> selectedLineItemIds = new List<Id>{ oliId };

    List<ApplicationFormProduct> appFormProducts = new List<ApplicationFormProduct>{
      new ApplicationFormProduct(
        Id = Lib_FakeIdGenerator.getMockId(ApplicationFormProduct.SObjectType),
        Opportunity_Product__c = oliId,
        Opportunity_Product__r = new OpportunityLineItem(
          Id = oliId,
          Opp_Product_name__c = 'ANZ Product'
        )
      )
    };

    launchAppRepoMock.mock(
      'getAppFormProductsNotRelatedToAMBIT',
      appFormProducts
    );

    //WHEN calling a method
    Test.startTest();
    List<String> alreadyLaunchedProductList = LaunchAppOnOppController.validateSelectedOppLineItems(
      oppId,
      selectedLineItemIds
    );
    Test.stopTest();

    //THEN it should successfully get the AFP records
    Assert.areEqual(
      1,
      alreadyLaunchedProductList.size(),
      'should have 1 Application Form Product'
    );
  }

  @isTest
  static void getOpportunityLineItemsCatchTest() {
    registerMocks();

    //GIVEN opportunityId
    Exception ex;
    Id opportunityId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    launchAppRepoMock.mock('getOpportunityLineItems', null);

    //WHEN calling a method
    Test.startTest();
    try {
      List<LaunchAppOnOppController.OppLineItemWrapper> itemWrapper = LaunchAppOnOppController.getOpportunityLineItems(
        opportunityId,
        'BBD'
      );
    } catch (Exception e) {
      ex = e;
    }
    Test.stopTest();

    //THEN it should throw an exception
    Assert.isNotNull(ex, 'Exception should be thrown');
  }

  @isTest
  static void createApplicationCatchTest() {
    registerMocks();

    //GIVEN opportunityId, productId, recordTypeId, oli
    Exception ex;
    Id opportunityId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Id recordTypeId = QueryRT.of(ApplicationForm.SObjectType).getId('AMBIT');
    launchAppRepoMock.mock('getSelectedOppLineItems', null);

    //WHEN calling a method
    Test.startTest();
    try {
      List<Id> appFormProductIds = LaunchAppOnOppController.createApplication(
        opportunityId,
        new List<Id>{ productId },
        recordTypeId
      );
    } catch (Exception e) {
      ex = e;
    }
    Test.stopTest();

    //THEN it should throw an exception
    Assert.isNotNull(ex, 'Exception should be thrown');
  }

  @isTest
  static void validateSelectedOppLineItemsCatchTest() {
    registerMocks();

    //GIVEN oppId, oliId, selectedLineItemIds
    Exception ex;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    List<Id> selectedLineItemIds = new List<Id>{ oliId };

    launchAppRepoMock.mock('getAppFormProductsNotRelatedToAMBIT', null);

    //WHEN calling a method
    Test.startTest();
    try {
      List<String> alreadyLaunchedProductList = LaunchAppOnOppController.validateSelectedOppLineItems(
        oppId,
        selectedLineItemIds
      );
    } catch (Exception e) {
      ex = e;
    }
    Test.stopTest();

    //THEN it should throw an exception
    Assert.isNotNull(ex, 'Exception should be thrown');
  }

  @isTest
  static void createApplicationWithExistingProductsTest() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id productId = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    Id recordTypeId = QueryRT.of(ApplicationForm.SObjectType).getId('AMBIT');
    Id appFormProductId = Lib_FakeIdGenerator.getMockId(
      ApplicationFormProduct.SObjectType
    );
    Id appFormId = Lib_FakeIdGenerator.getMockId(ApplicationForm.SObjectType);

    // Create mock ApplicationFormProduct
    ApplicationFormProduct existingAppFormProduct = new ApplicationFormProduct(
      Id = appFormProductId,
      ApplicationFormId = appFormId,
      Source_System_Id__c = 'testSourceSystemId'
    );

    // Mock the repository to return existing products
    launchAppRepoMock.mock(
      'getAppFormProductsUsingExtId',
      new List<ApplicationFormProduct>{ existingAppFormProduct }
    );

    // Mock the update operation
    dmlRepoMock.mock(
      'doUpdate',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true,"id":"0013000000abcde"}')
      }
    );

    Test.startTest();
    List<Id> appFormProductIds = LaunchAppOnOppController.createApplication(
      oppId,
      new List<Id>{ productId },
      recordTypeId
    );
    Test.stopTest();

    Assert.isNotNull(appFormProductIds, 'No records are created');
  }

  @isTest
  static void createApplicationEmptyLineItemsTest() {
    registerMocks();
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id recordTypeId = QueryRT.of(ApplicationForm.SObjectType).getId('AMBIT');

    // Mock empty line items
    launchAppRepoMock.mock(
      'getSelectedOppLineItems',
      new List<OpportunityLineItem>()
    );

    launchAppRepoMock.mock(
      'getAppFormProductsUsingExtId',
      new List<ApplicationFormProduct>()
    );

    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true,"id":"0013000000abcde"}')
      }
    );

    Test.startTest();
    List<Id> appFormProductIds = LaunchAppOnOppController.createApplication(
      oppId,
      new List<Id>(),
      recordTypeId
    );
    Test.stopTest();

    Assert.isNotNull(
      appFormProductIds,
      'Should handle empty line items gracefully'
    );
  }

  @isTest
  static void getAMBITResponseCatchTest() {
    registerMocks();

    //GIVEN oppId, oliId
    Exception ex;
    Id oppId = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType);
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);

    launchAppRepoMock.mock('getOpportunityData', null);

    //WHEN calling a method
    Test.startTest();
    try {
      Boolean response = LaunchAppOnOppController.getAMBITResponse(
        oppId,
        oliId
      );
    } catch (Exception e) {
      ex = e;
    }
    Test.stopTest();

    //THEN it should throw an exception
    Assert.isNotNull(ex, 'Exception should be thrown');
  }

  @isTest
  static void validateBrokerAFStatusNullTest() {
    //GIVEN oppRec
    Opportunity oppRec = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
      Name = 'Sample Opportunity',
      StageName = 'Opportunity Identified',
      AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Description = 'Sample Opp'
    );

    //WHEN Calling a method
    Test.startTest();
    String brokerValue = LaunchAppOnOppController.validateBrokerAFStatus(
      oppRec
    );
    Test.stopTest();

    //THEN it should assert correctly
    Assert.isNull(brokerValue, 'Broker should be null');
  }

  @isTest
  static void validateOppTeamMemberNullTest() {
    //GIVEN oppRec
    Opportunity oppRec = (Opportunity) TestUtil.setFields(
      new Opportunity(
        Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
        Name = 'Sample Opportunity',
        StageName = 'New',
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Description = 'Sample Opp'
      ),
      new Map<String, List<OpportunityTeamMember>>{
        'OpportunityTeamMembers' => new List<OpportunityTeamMember>{
          new OpportunityTeamMember(
            Id = Lib_FakeIdGenerator.getMockId(
              OpportunityTeamMember.SObjectType
            ),
            TeamMemberRole = 'Asset Finance',
            UserId = Lib_FakeIdGenerator.getMockId(User.SObjectType)
          )
        }
      }
    );

    //WHEN Calling a method
    Test.startTest();
    String teamMemberValue = LaunchAppOnOppController.validateOppTeamMember(
      oppRec
    );
    Test.stopTest();

    //THEN it should assert correctly
    Assert.isNull(teamMemberValue, 'Team Member should be null');
  }

  /**
   * @description create HTTP mock response for testing
   */
  public class AmbitTestMock implements HttpCalloutMock {
    /**
     * @description HTTP mock response
     * @param req HTTP request
     * @return HTTPResponse
     */
    public HTTPResponse respond(HTTPRequest req) {
      String jsonBody = Service.getStaticResource(
        'mock_commercialAmbitResponse'
      );
      HTTPResponse res = new HTTPResponse();
      res.setBody(jsonBody);
      res.setStatusCode(200);
      return res;
    }
  }
}
