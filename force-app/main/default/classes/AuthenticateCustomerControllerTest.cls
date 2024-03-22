/**
 * @author Kopal Goswami
 * @since 01/2024
 * @description AuthenticateCustomerControllerTest is the test class to cover tests for {@link AuthenticateCustomerController.cls}
 */
@isTest
public class AuthenticateCustomerControllerTest {
  private static final string ACR_AAL3 = 'IAL4.AAL3.FAL1';
  private static final string ACR_AAL4 = 'IAL4.AAL4.FAL1';
  /**
   * @description Create Account and Interaction records
   */
  @TestSetup
  public static void setup() {
    Account testAccount = TestDataFactory.createPersonAccount('123456', true);

    Interaction testInteraction = new Interaction(
      RecordTypeId = GetHelpConstants.INTERACTION_GENERAL_RT_ID,
      Direction__c = 'Inbound',
      InteractionType = 'Chat',
      Authentication_Method__c = 'Not Required',
      AccountId = testAccount.Id,
      Name = 'Inbound Chat',
      OwnerId = UserInfo.getUserId()
    );
    insert testInteraction;
  }

  static Interaction getInteractionRecord() {
    return [
      SELECT Id, AccountId, Account.OCV_ID__c
      FROM Interaction
      WHERE name = :'Inbound Chat'
      LIMIT 1
    ];
  }

  static AuthenticationHistory__c getPrendingAuthenticationHistory() {
    return new AuthenticationHistory__c(
      Status__c = AuthenticateCustomerController.CUSTOMER_PENDING,
      AuthenticationMethod__c = ACR_AAL3
    );
  }

  static User getFraudXAgentTestUser() {
    User fraudxagent = TestDataFactory.createANZxUser(
      'FraudX_Agent',
      'FraudX_Agent'
    );
    PermissionSet ps = CommonUtil.getPermissionSetByName(
      'CIBA_Authorisation_Access'
    );
    PermissionSetAssignment psa1 = TestUtil.createPSAssignment(
      fraudxagent.Id,
      ps.Id
    );
    insert psa1;
    return fraudxagent;
  }

  @isTest
  static void testGetAccountName() {
    Interaction interactionId = getInteractionRecord();
    Test.startTest();
    Interaction result = AuthenticateCustomerController.getAccountName(
      interactionId.Id
    );
    Test.stopTest();
    assert.areEqual(
      interactionId.Id,
      result.Id,
      'The expected Interaction Id is not returned'
    );
  }

  @isTest
  static void testGetUserRole() {
    User fraudxagent = getFraudXAgentTestUser();
    Test.startTest();
    System.runAs(fraudxagent) {
      String result = AuthenticateCustomerController.getUserRole();
      Test.stopTest();
      assert.areEqual(
        'FraudX_Agent',
        result,
        'The expected user role is not returned'
      );
    }
  }

  @isTest
  static void testInitiateAuthenticationRequest() {
    Interaction interactionRecord = getInteractionRecord();
    Test.startTest();
    CIBAAuthenticationModel result = AuthenticateCustomerController.initiateAuthenticationRequest(
      interactionRecord.Account.OCV_ID__c,
      ACR_AAL3,
      interactionRecord.Id
    );
    Test.stopTest();
    Assert.isNotNull(
      result.auth_req_id,
      'The expected authentication response is not returned, auth_req_id is missing'
    );
    Assert.areEqual(
      300,
      result.expires_in,
      'The expected authentication response is not returned, expires_in is missing'
    );
  }

  @isTest
  static void testAuthenticationPollingResponse() {
    Interaction interactionRecord = getInteractionRecord();
    AuthenticationHistory__c testAuthHistory = getPrendingAuthenticationHistory();
    testAuthHistory.Interaction__c = interactionRecord.Id;
    insert testAuthHistory;

    Test.startTest();
    String resultstatus = AuthenticateCustomerController.authenticationPollingResponse(
      '123',
      testAuthHistory.Id,
      interactionRecord.Account.OCV_ID__c
    );
    Test.stopTest();
    assert.areEqual(
      AuthenticateCustomerController.VERIFICATION_FAILED,
      resultstatus,
      'Access token verification should be failed'
    );
  }

  @isTest
  static void testPublicKeyCache() {
    String kid = 'kId123keyalpha@';
    String mockPublicKey = '56544';
    String publicKey = AuthenticateCustomerController.getPublicKeyFromCache(
      kid
    );
    assert.isTrue(String.isBlank(publicKey), ' public key not found');
    Test.startTest();
    AuthenticateCustomerController.storePublicKeyToCache(kid, mockPublicKey);
    publicKey = AuthenticateCustomerController.getPublicKeyFromCache(kid);
    Test.stopTest();
    assert.areEqual(mockPublicKey, publicKey, 'Failed to fetch public key');
  }

  @isTest
  static void testHandleAccessTokenResponsePending() {
    CIBAAccessTokenResponseModel sampleRes = new CIBAAccessTokenResponseModel();
    CIBAAccessTokenResponseModel.AdditionalInfo additionalInfo = new CIBAAccessTokenResponseModel.AdditionalInfo();
    CIBAAccessTokenResponseModel.ErrorDetails errDetail = new CIBAAccessTokenResponseModel.ErrorDetails();
    errDetail.error = AuthenticateCustomerController.AUTHORIZATION_PENDING;
    additionalInfo.errorDetails = errDetail;
    sampleRes.additionalInfo = additionalInfo;
    Test.startTest();
    String status = AuthenticateCustomerController.handleAccessTokenResponse(
      sampleRes,
      '123'
    );
    Test.stopTest();
    assert.areEqual(
      AuthenticateCustomerController.AUTHORIZATION_PENDING,
      status,
      'The expected status is not returned'
    );
  }

  @isTest
  static void testHandleAccessTokenResponseNegative() {
    Test.startTest();
    String status = AuthenticateCustomerController.handleAccessTokenResponse(
      null,
      '123'
    );
    Test.stopTest();
    assert.areEqual(
      AuthenticateCustomerController.ERROR,
      status,
      'The expected status is not returned'
    );
  }

  @isTest
  static void testUpdateAuthenticationHistory() {
    User fraudxagent = getFraudXAgentTestUser();
    Test.startTest();
    System.runAs(fraudxagent) {
      AuthenticationHistory__c testAuthHistory = getPrendingAuthenticationHistory();
      insert testAuthHistory;
      AuthenticateCustomerController.updateAuthenticationHistory(
        testAuthHistory.Id,
        AuthenticateCustomerController.CANCELLED
      );
      Test.stopTest();
      AuthenticationHistory__c updatedRecord = [
        SELECT Id, Status__c
        FROM AuthenticationHistory__c
        WHERE Id = :testAuthHistory.Id
        LIMIT 1
      ];
      assert.areEqual(
        AuthenticateCustomerController.CANCELLED,
        updatedRecord.Status__c,
        'The expected status is not returned'
      );
    }
  }

  @isTest
  static void testUpdateAuthenticationHistoryNegative() {
    Test.startTest();
    //covering early exit, since no return from this method there is no assert required
    AuthenticateCustomerController.updateAuthenticationHistory('', '');
    AuthenticateCustomerController.updateAuthenticationHistory('123', '123');
    Test.stopTest();
  }

  @isTest
  static void testSetAuthenticationHistoryStatusToVerified() {
    AuthenticationHistory__c testAuthHistory = getPrendingAuthenticationHistory();
    Test.startTest();
    AuthenticateCustomerController.setAuthenticationHistoryStatus(
      testAuthHistory,
      AuthenticateCustomerController.VERIFIED
    );
    Test.stopTest();
    assert.areEqual(
      'Customer Approved',
      testAuthHistory.Status__c,
      'The expected status is not returned'
    );
  }

  @isTest
  static void testSetAuthenticationHistoryStatusToVerificationFailed() {
    AuthenticationHistory__c testAuthHistory = getPrendingAuthenticationHistory();
    Test.startTest();
    AuthenticateCustomerController.setAuthenticationHistoryStatus(
      testAuthHistory,
      AuthenticateCustomerController.VERIFICATION_FAILED
    );
    assert.areEqual(
      AuthenticateCustomerController.REQUEST_FAILED,
      testAuthHistory.Status__c,
      'The expected status is not returned'
    );
    assert.areEqual(
      AuthenticateCustomerController.VERIFICATION_FAILED,
      testAuthHistory.ErrorMessages__c,
      'The expected error message is not returned'
    );
  }

  @isTest
  static void testSetAuthenticationHistoryStatusToDenied() {
    AuthenticationHistory__c testAuthHistory = getPrendingAuthenticationHistory();
    Test.startTest();
    AuthenticateCustomerController.setAuthenticationHistoryStatus(
      testAuthHistory,
      AuthenticateCustomerController.ACCESS_DENIED
    );
    Test.stopTest();
    assert.areEqual(
      AuthenticateCustomerController.CUSTOMER_REJECTED,
      testAuthHistory.Status__c,
      'The expected status is not returned'
    );
  }

  @isTest
  static void testSetAuthenticationHistoryStatusToFailed() {
    AuthenticationHistory__c testAuthHistory = getPrendingAuthenticationHistory();
    Test.startTest();
    AuthenticateCustomerController.setAuthenticationHistoryStatus(
      testAuthHistory,
      AuthenticateCustomerController.ERROR
    );
    Test.stopTest();
    assert.areEqual(
      AuthenticateCustomerController.REQUEST_FAILED,
      testAuthHistory.Status__c,
      'The expected status is not returned'
    );
  }

  @isTest
  static void testSetAuthenticationHistoryStatusToExpired() {
    AuthenticationHistory__c testAuthHistory = getPrendingAuthenticationHistory();
    Test.startTest();
    AuthenticateCustomerController.setAuthenticationHistoryStatus(
      testAuthHistory,
      AuthenticateCustomerController.REQUEST_EXPIRED
    );
    Test.stopTest();
    assert.areEqual(
      AuthenticateCustomerController.REQUEST_EXPIRED,
      testAuthHistory.Status__c,
      'The expected status is not returned'
    );
  }

  @isTest
  static void testSetInteractionAuthenticationMethod() {
    AuthenticationHistory__c testAuthHistory = getPrendingAuthenticationHistory();
    AuthenticateCustomerController.setAuthenticationHistoryStatus(
      testAuthHistory,
      AuthenticateCustomerController.VERIFIED
    );
    Test.startTest();
    Interaction relatedInteraction = AuthenticateCustomerController.setInteractionAuthenticationMethod(
      testAuthHistory
    );
    Test.stopTest();
    assert.areEqual(
      'AAL3 - Pin or Local Biometric - Customer Approved',
      relatedInteraction.Authentication_Method__c,
      'The expected authentication method is not returned'
    );
  }

  @isTest
  static void testMapToAuthHistory() {
    String uuid = CommonUtil.generateUUID();
    CIBAAuthenticationModel authres = new CIBAAuthenticationModel();
    authres.auth_req_id = uuid;
    authres.expires_in = 300;
    authres.interval = 5;

    Test.startTest();
    AuthenticationHistory__c testAuthHistory = AuthenticateCustomerController.mapResponseToAuthenticateHistory(
      authres,
      getInteractionRecord().Id,
      ACR_AAL3,
      uuid
    );
    Test.stopTest();
    assert.areEqual(
      AuthenticateCustomerController.CUSTOMER_PENDING,
      testAuthHistory.Status__c,
      'The expected status is not returned'
    );
    assert.areEqual(
      uuid,
      testAuthHistory.AuthorisationRequestID__c,
      'The expected Auth request id is not set'
    );
  }

  @isTest
  static void testMapToAuthHistoryNegative() {
    Test.startTest();
    AuthenticationHistory__c mappedAuthHistory = AuthenticateCustomerController.mapResponseToAuthenticateHistory(
      null,
      getInteractionRecord().Id,
      ACR_AAL3,
      '123'
    );
    Test.stopTest();
    assert.isNull(mappedAuthHistory, 'mapped Auth History should be null');
  }

  @isTest
  static void testAuthFieldDescribe() {
    Test.startTest();
    Map<String, String> returnMap = AuthenticateCustomerController.getAuthenticationFieldLabelMap();
    Test.stopTest();
    assert.areEqual(
      'AAL3 - Pin or Local Biometric',
      returnMap.get(ACR_AAL3),
      'AAL3 authentication method label and apiname not matching'
    );
    assert.areEqual(
      'AAL4 - Selfie ID',
      returnMap.get(ACR_AAL4),
      'AAL4 authentication method label and apiname not matching'
    );
  }
}
