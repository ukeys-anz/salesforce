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
      oliIdsList
    );
    Test.stopTest();

    //THEN it should return successful response
    Assert.isTrue(response, 'AMBIT Response should be true');
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
