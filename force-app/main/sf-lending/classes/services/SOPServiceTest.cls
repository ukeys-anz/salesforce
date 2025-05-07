/**
 * @author Raman gupta
 * @date march 2025
 * @description Test class for {@link SOPService}
 */

@isTest
public with sharing class SOPServiceTest {
  static Lib_MockProvider calloutMock;

  static void registerMocks() {
    calloutMock = Lib_MockProvider.forType(Lib_HttpCallout.class);
  }

  /**
   * @description Static method to return URLParameters List
   */
  static List<String> getURLParameters {
    get {
      List<String> urlParameters = new List<String>{
        'e6782045-b850-46a6-8b13-ffb8839633c9',
        'true',
        'true'
      };
      return urlParameters;
    }
  }
  /**
   * @description Static method to return SOPUpdateSOPAndPartyRequestModel Record
   */
  static SOPUpdateSOPAndPartyRequestModel getSOPUpdateSOPAndPartyRequestModel {
    get {
      SOPUpdateSOPAndPartyRequestModel updatePartyBody = new SOPUpdateSOPAndPartyRequestModel();
      updatePartyBody.partyData = new SOPUpdateSOPAndPartyRequestModel.PartyData();
      updatePartyBody.partyData.party = new SOPUpdateSOPAndPartyRequestModel.Party();
      updatePartyBody.partyData.party.spouseEarnsIncome = true;
      updatePartyBody.partyData.party.relationshipState = 'RELATIONSHIP_STATE_IN_RELATIONSHIP';
      updatePartyBody.partyData.party.id = '123456';
      updatePartyBody.sopData = new SOPUpdateSOPAndPartyRequestModel.SopData();
      updatePartyBody.sopData.dependantsCount = 2;
      updatePartyBody.sopData.etag = '13243356664';
      return updatePartyBody;
    }
  }

  @isTest
  static void testUpdateSOPAndPartySuccess() {
    registerMocks();

    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = Service.getStaticResource('mock_updateSOPAndParty');
    successResponse.successful = true;
    successResponse.statusCode = 200;
    calloutMock.mock('makeRestCallout', successResponse);

    String ocvId = '11111231';
    // Need to set Token for mock callout
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    SOPService service = new SOPService();
    HttpCalloutResponse response = service.updateSOPAndParty(
      ocvId,
      getSOPUpdateSOPAndPartyRequestModel,
      getURLParameters
    );
    Test.stopTest();

    Assert.isNotNull(
      calloutMock.getHistory('makeRestCallout'),
      'Callout should be made'
    );
    Assert.isTrue(response.successful, 'Response should be successful');
    Assert.areEqual(
      JSON.serialize(getSOPUpdateSOPAndPartyRequestModel),
      (String) calloutMock.getHistory('makeRestCallout')
        .getParam('requestBody'),
      'Request body should be serialized request'
    );
  }

  @isTest
  static void testUpdateSOPAndPartyFailure() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    errorResponse.error = new CalloutException('Error');
    calloutMock.mock('makeRestCallout', errorResponse);

    String ocvId = '11111231';
    // Need to set Token for mock callout
    Cache.Session.put(
      AuthTokenCacheUtil.STAFFPART + 'forgeJWTToken' + ocvId,
      AuthServiceTest.IDTESTVALUE
    );

    Test.startTest();
    SOPService service = new SOPService();
    HttpCalloutResponse response = service.updateSOPAndParty(
      ocvId,
      getSOPUpdateSOPAndPartyRequestModel,
      getURLParameters
    );
    Test.stopTest();

    Assert.isNotNull(
      calloutMock.getHistory('makeRestCallout'),
      'Callout should be made'
    );
    Assert.isFalse(response.successful, 'Response should be error');
    Assert.areEqual(
      500,
      response.statusCode,
      'Status code of the response should be 500'
    );
  }
}
