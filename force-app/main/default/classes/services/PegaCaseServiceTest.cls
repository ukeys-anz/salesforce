/**
 * @author       : Karen Valeriano
 * @since        : Dec 2025
 * @description  : Test Class for {@link PegaCaseService}
 **/
@isTest
private class PegaCaseServiceTest {
  static final Faker FAKER = new Faker('AU');
  static final String OPPORTUNITY_ID = Lib_FakeIdGenerator.getMockId(
    Opportunity.SObjectType
  );

  static Lib_MockProvider calloutMock = TestUtil.httpCalloutMock;

  @IsTest
  static void testCreateCase() {
    PegaCaseRequestModel payload = createTestPayload();
    AuthTokenCacheUtilTest.setupForgeAuthCache(
      PegaCaseService.PEGA_CASE_CREATE_API_SCOPE,
      ''
    );

    Test.startTest();
    new PegaCaseService().createCase(payload);
    Test.stopTest();

    Assert.isNotNull(
      calloutMock.getHistory('makeRestCallout'),
      'Callout should be made'
    );
    Assert.areEqual(
      JSON.serialize(payload, true),
      (String) calloutMock.getHistory('makeRestCallout')
        .getParam('requestBody'),
      'Request body should be serialized payload'
    );
  }

  @IsTest
  static void testCreateCaseMock() {
    PegaCaseRequestModel payload = createTestPayload();

    Test.startTest();
    HttpCalloutResponse response = new PegaCaseServiceMock()
      .createCase(payload);
    Test.stopTest();

    Assert.isTrue(response.successful, 'Response should be successful');
    Assert.areEqual(200, response.statusCode, 'Status code should be 200');
  }

  @IsTest
  static void testCreateCaseResponseDeserialization() {
    PegaCaseRequestModel payload = createTestPayload();

    Test.startTest();
    HttpCalloutResponse response = new PegaCaseServiceMock()
      .createCase(payload);
    Test.stopTest();

    PegaCaseResponseModel responseModel = PegaCaseResponseModel.parse(
      response.body
    );

    Assert.isNotNull(responseModel, 'Response model should not be null');
    Assert.areEqual(
      'COB-64020',
      responseModel.pyID,
      'Expected case id to match'
    );
    Assert.areEqual(
      'Confirm',
      responseModel.nextPageID,
      'Expected nextPageID to match'
    );
  }

  /**
   * @description Creates a test PegaCaseRequestModel payload
   * @return PegaCaseRequestModel test payload
   */
  private static PegaCaseRequestModel createTestPayload() {
    Opportunity opportunity = new Opportunity(
      Id = OPPORTUNITY_ID,
      AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    );

    List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>{
      new OpportunityLineItem(
        Id = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType),
        OpportunityId = OPPORTUNITY_ID
      )
    };
    List<FinServ__AccountAccountRelation__c> entities = new List<FinServ__AccountAccountRelation__c>{
      new FinServ__AccountAccountRelation__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__AccountAccountRelation__c.SObjectType
        ),
        FinServ__Account__c = opportunity.AccountId
      )
    };

    PegaCaseRequestModel payload = new PegaCaseRequestModel(
      opportunity,
      opportunityLineItems,
      entities
    );

    return payload;
  }
}
