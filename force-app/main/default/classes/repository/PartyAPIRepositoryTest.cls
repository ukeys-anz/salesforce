/**
 * @author ML Developer
 * @since Feb 2025
 * @description test class for PartyAPIRepository
 */
@isTest
private class PartyAPIRepositoryTest {
  static StaticResource sr = [
    SELECT Body
    FROM StaticResource
    WHERE Name = 'mock_dcrmMaintainPartyModel'
  ];
  static Lib_MockProvider maintainPartyMock;
  static Lib_MockProvider retrievePartyMock;

  static void registerMocks() {
    maintainPartyMock = Lib_MockProvider.forType(MaintainPartyService.class);
    retrievePartyMock = Lib_MockProvider.forType(RetrievePartyService.class);
  }
  @isTest
  static void testSuccessResponseMaintainParty() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = true;
    res.statusCode = 200;
    res.body = sr.Body.toString();
    registerMocks();
    maintainPartyMock.mock('maintainPartyForIndividual', res);
    OCVRequestPayloadWrapper requestModel = getRequestRecord(
      UserInfo.getUserId()
    );
    Test.startTest();
    MaintainPartyModel resModel = new PartyAPIRepository()
      .maintainParty(requestModel);
    Test.stopTest();
    Assert.areEqual(
      '8019989879',
      resModel.ocvId,
      'Maintain party is failing, OCV id is blank'
    );
  }

  @isTest
  static void testError500ResponseMaintainParty() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    res.body = 'Error';
    res.error = new CalloutException(
      'Endpoint or Method cannot be empty for a HTTP callout'
    );
    registerMocks();
    maintainPartyMock.mock('maintainPartyForIndividual', res);
    OCVRequestPayloadWrapper requestModel = getRequestRecord(
      UserInfo.getUserId()
    );
    try {
      Test.startTest();
      new PartyAPIRepository().maintainParty(requestModel);
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        PartyAPIRepository.ServerErrorException.class,
        'Exception should be an instanceof ServerErrorException.'
      );
    }
  }

  @isTest
  static void testSuccessResponseRetrieveParty() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = true;
    res.statusCode = 200;
    res.body = 'Success';
    registerMocks();
    retrievePartyMock.mock('retrieveParty', res);
    OCVRetrievePartyPayloadWrapper requestModel = new OCVRetrievePartyPayloadWrapper();
    Test.startTest();
    String resModel = new PartyAPIRepository().retrieveParty(requestModel);
    Test.stopTest();
    Assert.areEqual('Success', resModel, 'Retrieve party is failing');
  }

  @isTest
  static void testError500ResponseRetrieveParty() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 500;
    res.body = 'Error';
    res.error = new CalloutException(
      'Endpoint or Method cannot be empty for a HTTP callout'
    );
    registerMocks();
    retrievePartyMock.mock('retrieveParty', res);
    OCVRetrievePartyPayloadWrapper requestModel = new OCVRetrievePartyPayloadWrapper();
    try {
      Test.startTest();
      new PartyAPIRepository().retrieveParty(requestModel);
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        PartyAPIRepository.ServerErrorException.class,
        'Exception should be an instanceof ServerErrorException.'
      );
    }
  }

  @isTest
  static void testError400ResponseRetrieveParty() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 400;
    res.body = 'Error';
    res.error = new CalloutException(
      'Endpoint or Method cannot be empty for a HTTP callout'
    );
    registerMocks();
    retrievePartyMock.mock('retrieveParty', res);
    OCVRetrievePartyPayloadWrapper requestModel = new OCVRetrievePartyPayloadWrapper();
    try {
      Test.startTest();
      new PartyAPIRepository().retrieveParty(requestModel);
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        PartyAPIRepository.UserErrorException.class,
        'Exception should be an instanceof UserErrorException.'
      );
    }
  }

  @isTest
  static void testUnhandledException() {
    HttpCalloutResponse res = new HttpCalloutResponse();
    res.successful = false;
    res.statusCode = 300;
    res.body = 'Error';
    res.error = new CalloutException(
      'Endpoint or Method cannot be empty for a HTTP callout'
    );
    registerMocks();
    retrievePartyMock.mock('retrieveParty', res);
    OCVRetrievePartyPayloadWrapper requestModel = new OCVRetrievePartyPayloadWrapper();
    try {
      Test.startTest();
      new PartyAPIRepository().retrieveParty(requestModel);
      Test.stopTest();
      Assert.fail('An Exception should be thrown');
    } catch (Exception e) {
      Assert.isInstanceOfType(
        e,
        PartyAPIRepository.UnhandledException.class,
        'Exception should be an instanceof UnhandledException.'
      );
    }
  }

  /**
   * @description payload request to OCV
   * @name getRequestRecord
   * @param mlUserId User Id
   * @return ocvRequest as OCVRequestPayloadWrapper
   */
  static OCVRequestPayloadWrapper getRequestRecord(ID mlUserId) {
    OCVRequestPayloadWrapper ocvRequest = new OCVRequestPayloadWrapper();
    ocvRequest.strOwnerId = mlUserId;
    ocvRequest.isValidStreet = true;
    ocvRequest.strStreet = 'Street';
    ocvRequest.strCity = 'City';
    ocvRequest.strState = 'State';
    ocvRequest.strCountry = 'Country';
    ocvRequest.strPostalCode = '110050';
    ocvRequest.strMobilePhone = '+61512345678';
    ocvRequest.strHomePhone = '+61412345678';
    ocvRequest.strWorkPhone = '+61412345678';
    ocvRequest.strEmail = 'abc@ml.anz.com';
    ocvRequest.strSalutation = 'Mr';
    ocvRequest.strFirstName = 'FirstName';
    ocvRequest.strMiddleName = 'MiddleName';
    ocvRequest.strLastName = 'LastName';
    ocvRequest.strGender = 'F';
    ocvRequest.strRecordId = '';
    ocvRequest.strAdvertisingIndicator = 'Y';
    return ocvRequest;
  }
}
