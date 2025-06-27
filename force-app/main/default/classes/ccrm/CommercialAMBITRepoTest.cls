/**
 * @author Naman Garg
 * @since  Jan 2025
 * @description Test class for CommercialAMBITRepo
 */
@isTest
public class CommercialAMBITRepoTest {
  static Lib_MockProvider ambitService;

  static void registerMocks() {
    ambitService = Lib_MockProvider.forType(CommercialAMBITService.class);
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

  @IsTest
  static void testGetAMBITQuoteResponseSuccess() {
    registerMocks();
    //GIVEN successful response, Opp rec
    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = '{"data": {"responseMessage" : "AMBIT Quote created Successfully", "isSuccessful":true} }';
    successResponse.successful = true;
    successResponse.statusCode = 200;

    Opportunity oppRec = getOpportunityRecord();
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    ambitService.mock('createAMBITQuote', successResponse);
    Exception ex;

    //WHEN calling a method
    try {
      new CommercialAMBITRepo()
        .getAMBITQuoteResponse(new CommercialAMBITRequestModel(oppRec, oliId));
    } catch (Exception e) {
      ex = e;
    }

    //THEN assert should return null
    Assert.isNull(ex, 'Exception should not be thrown');
  }

  @IsTest
  static void testGetAMBITQuoteResponseError() {
    registerMocks();
    //GIVEN  unsuccessful response, Opp rec
    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.body = '{"data": {"responseMessage" : "", "isSuccessful":false} }';
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    errorResponse.error = new CalloutException('Error');

    Opportunity oppRec = getOpportunityRecord();
    Id oliId = Lib_FakeIdGenerator.getMockId(OpportunityLineItem.SObjectType);
    ambitService.mock('createAMBITQuote', errorResponse);
    Exception ex;

    //WHEN calling a method
    try {
      new CommercialAMBITRepo()
        .getAMBITQuoteResponse(new CommercialAMBITRequestModel(oppRec, oliId));
    } catch (Exception e) {
      ex = e;
    }

    //THEN assert should return true
    Assert.isTrue(
      ex instanceof CommercialAMBITRepo.ServerErrorException,
      'Server Exception should be thrown.'
    );
  }
}
