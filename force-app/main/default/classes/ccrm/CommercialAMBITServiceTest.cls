/**
 * @author Naman Garg
 * @since  Jan 2025
 * @description Test class for CommercialAMBITService
 */
@isTest
public class CommercialAMBITServiceTest {
  static Lib_MockProvider launchAppRepoMock;
  static Lib_MockProvider calloutMock;

  static void registerMocks() {
    launchAppRepoMock = Lib_MockProvider.forType(
      LaunchAppOnOppControllerRepository.class
    );
    calloutMock = Lib_MockProvider.forType(Lib_HttpCallout.class);
  }

  @TestSetup
  static void makeData() {
    Non_Prod_Settings__c settings = Non_Prod_Settings__c.getOrgDefaults();
    settings.SSO_Not_Configured__c = true;
    upsert settings;
  }

  static Contact getBrokerRecord() {
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
    return brokerRec;
  }

  static Opportunity getOpportunityRecord() {
    Opportunity oppRec = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
      Name = 'Sample Opportunity',
      StageName = 'Opportunity Identified',
      AccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Broker_Name__c = getBrokerRecord().Id,
      Broker_Name__r = getBrokerRecord(),
      Description = 'Sample Opp'
    );
    return oppRec;
  }

  @isTest
  static void testCreateAMBITQuote() {
    registerMocks();

    //GIVEN Opp record
    Opportunity oppRec = getOpportunityRecord();
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    CommercialAMBITRequestModel ambitModel = new CommercialAMBITRequestModel(
      oppRec,
      oliId
    );

    //WHEN calling a method
    Test.startTest();
    new CommercialAMBITService().createAMBITQuote(ambitModel);
    Test.stopTest();

    //THEN it should make a callout
    Assert.isNotNull(
      calloutMock.getHistory('makeRestCallout'),
      'Callout should be made'
    );

    //THEN it should serialized request body
    Assert.areEqual(
      JSON.serialize(ambitModel),
      (String) calloutMock.getHistory('makeRestCallout')
        .getParam('requestBody'),
      'Request body should be serialized request'
    );
  }

  @IsTest
  static void testCreateAMBITQuoteMock() {
    //WHEN Calling a method
    Test.startTest();
    HttpCalloutResponse response = new CommercialAMBITServiceMock()
      .createAMBITQuote(null);
    Test.stopTest();

    //THEN it should return a successful response
    Assert.isTrue(response.successful, 'Response should be successful');
  }
}
