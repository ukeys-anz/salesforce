/**
 * @author Raman Gupta
 * @date November 2024
 * @description Test class for {@link SOPAPIRepository}
 * @group repository
 */

@isTest
public with sharing class SOPAPIRepositoryTest {
  static Lib_MockProvider sopServiceMock;

  static void registerMocks() {
    sopServiceMock = Lib_MockProvider.forType(SOPService.class);
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

  private static HttpCalloutResponse getInvalidResponse() {
    HttpCalloutResponse response = new HttpCalloutResponse();
    response.error = new CalloutException('callout failed');
    response.statusCode = 500;
    response.successful = false;
    return response;
  }

  /**
   * @description Static method to return URLParameters List
   */
  static List<String> getURLParameters {
    get {
      List<String> urlParameters = new List<String>{
        'a36782045-b850-46a6-8b13-ffb8839633c9',
        'true',
        'true'
      };
      return urlParameters;
    }
  }

  @isTest
  public static void testGetSOP() {
    registerMocks();

    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = Service.getStaticResource('mock_sop');
    successResponse.successful = true;
    successResponse.statusCode = 200;
    sopServiceMock.mock('getSOP', successResponse);

    String ocvId = '11111231';
    String sopId = 'a36782045-b850-46a6-8b13-ffb8839633c9';
    Test.startTest();
    SOPAPIRepository sopAPIRepository = new SOPAPIRepository();
    SOPViewModel response = sopAPIRepository.getSOP(ocvId, sopId);
    Test.stopTest();

    // Assert that the response is successful
    Assert.areEqual(
      0,
      response.dependantsCount,
      'dependantsCount should be as expected'
    );
    Assert.isFalse(
      response?.parties[0]?.spouseEarnsIncome,
      'dependantsCount should be as expected'
    );
  }

  @isTest
  public static void testGetSOPException() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.error = new CalloutException('callout failed');
    errorResponse.statusCode = 500;
    errorResponse.successful = false;
    sopServiceMock.mock('getSOP', errorResponse);

    String ocvId = '11111231';
    String sopId = 'a36782045-b850-46a6-8b13-ffb8839633c9';

    Exception resultException;
    Test.startTest();
    try {
      SOPAPIRepository sopRepository = new SOPAPIRepository();
      sopRepository.getSOP(ocvId, sopId);
    } catch (Exception exc) {
      resultException = exc;
    }
    Test.stopTest();

    Assert.isTrue(
      resultException instanceof SOPAPIRepository.ServerErrorGetSOPException,
      'Exception should be thrown.'
    );
    Assert.areEqual(
      'callout failed',
      resultException.getMessage(),
      'Should throw invalid data exception'
    );
  }

  @isTest
  public static void testUpdateSOPAndParty() {
    registerMocks();

    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = Service.getStaticResource('mock_updateSOPAndParty');
    successResponse.successful = true;
    successResponse.statusCode = 200;
    sopServiceMock.mock('updateSOPAndParty', successResponse);

    String ocvId = '11111231';
    Test.startTest();
    SOPAPIRepository sopAPIRepository = new SOPAPIRepository();
    SOPViewModel response = sopAPIRepository.updateSOPAndParty(
      ocvId,
      getSOPUpdateSOPAndPartyRequestModel,
      getURLParameters
    );
    Test.stopTest();
    // Assert that the response is successful
    Assert.isFalse(response.isUpdatePartyFailed, 'updateParty Callout success');
    Assert.isFalse(response.isUpdateSOPFailed, 'updateSOP Callout success');
    Assert.areEqual(response?.dependantsCount, 2, 'parties data are populated');
  }

  @isTest
  public static void testupdateSOPAndPartyException() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.error = new CalloutException('callout failed');
    errorResponse.statusCode = 500;
    errorResponse.successful = false;
    sopServiceMock.mock('updateSOPAndParty', errorResponse);

    String ocvId = '11111231';
    Exception resultException;
    Test.startTest();
    try {
      SOPAPIRepository sopRepository = new SOPAPIRepository();
      sopRepository.updateSOPAndParty(
        ocvId,
        getSOPUpdateSOPAndPartyRequestModel,
        getURLParameters
      );
    } catch (Exception exc) {
      resultException = exc;
    }
    Test.stopTest();
    // Assert that the method fails
    Assert.isTrue(
      resultException instanceof SOPAPIRepository.ServerErrorUpdateSOPAndPartyException,
      'Exception should be thrown.'
    );
    Assert.areEqual(
      'callout failed',
      resultException.getMessage(),
      'Should throw invalid data exception'
    );
  }
}
