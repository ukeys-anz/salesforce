/**
 * @author Kopal Goswami
 * @since  01/2024
 * @description This class helps in getting the user role of logged in user , Account details related to the interaction ,
 * Authorization request details and it's status
 */
public with sharing class AuthenticateCustomerController {
  @TestVisible
  private static final String K_ID = 'kid';
  private static final String ALG = 'alg';
  private static final String CIBAKEYID = 'local.ForgeToken.CibaKeyId';
  @TestVisible
  private static final String CANCELLED = 'Cancelled';
  @TestVisible
  private static final String VERIFIED = 'verified';
  @TestVisible
  private static final String AUTHORIZATION_PENDING = 'authorization_pending';
  @TestVisible
  private static final String SLOW_DOWN = 'slow_down';
  @TestVisible
  private static final String ACCESS_DENIED = 'access_denied';
  @TestVisible
  private static final String ERROR = 'error';
  @TestVisible
  private static final String CUSTOMER_APPROVED = 'Customer Approved';
  @TestVisible
  private static final String CUSTOMER_REJECTED = 'Customer Rejected';
  @TestVisible
  private static final String CUSTOMER_PENDING = 'Customer Pending';
  @TestVisible
  private static final String REQUEST_FAILED = 'Request Failed';
  @TestVisible
  private static final String REQUEST_EXPIRED = 'Request Expired';
  @TestVisible
  private static final String VERIFICATION_FAILED = 'Token Verification Failed';
  public static final string CIBA_JWT_SETTING_NAME = 'Client_Initiated_Backend_Authentication';
  private static final string PUBLICKEYSTART = '-----BEGIN PUBLIC KEY-----';
  private static final string PUBLICKEYEND = '-----END PUBLIC KEY-----';

  /**
   * @description This method queries interaction to get the customer details associated with the interaction
   * @param interactionId Variable for storing the interaction Id
   * @return Interaction Record
   */
  @AuraEnabled(cacheable=true)
  public static Interaction getAccountName(String interactionId) {
    Interaction interactionRecord = [
      SELECT
        Id,
        Account.FirstName,
        Account.LastName,
        AccountId,
        Account.OCV_ID__c,
        Account.FinServ__KYCStatus__c,
        Account.KYC_Verification_Level__c
      FROM Interaction
      WHERE Id = :interactionId
    ];

    if (interactionRecord.AccountId != null) {
      return interactionRecord;
    }

    return null;
  }

  /**
   * @description This method queries User role of the logged in User
   * @return Returns role of the logged in user
   */
  @AuraEnabled(cacheable=true)
  public static String getUserRole() {
    return [
      SELECT UserRole.DeveloperName
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ]
    .UserRole.DeveloperName;
  }

  /**
   * @description This method is for initiating the authentication request .
   * @param ocvId Id of the Customer associated with the interaction
   * @param acrValue authentication mechanism for which authentication request is initiated.
   * @param interactionId interaction record Id to on which the ciba authentication request was made
   * @return Authentication response with expire time, interval and authorisation id are returned
   */
  @AuraEnabled
  public static CIBAAuthenticationModel initiateAuthenticationRequest(
    String ocvId,
    String acrValue,
    String interactionId
  ) {
    try {
      String uuid = CommonUtil.generateUUID();
      JWTUtil util = new JWTUtil(CIBA_JWT_SETTING_NAME);
      String jwtRequest = util.getSignedJWT(ocvId, acrValue, uuid);

      JoinCIBARepository api = new JoinCIBARepository();
      CIBAAuthenticationModel res = (CIBAAuthenticationModel) api.initiateAuthenticationRequest(
        ocvId,
        jwtRequest
      );
      AuthenticationHistory__c authHistory = mapResponseToAuthenticateHistory(
        res,
        interactionId,
        acrValue,
        uuid
      );

      insert authHistory;

      res.authHistoryId = authHistory.Id;
      Logger.info(
        'CIBA Authentication request created : request_id: ' +
          authHistory.AuthorisationRequestID__c +
          ' , method: ' +
          authHistory.AuthenticationMethod__c +
          ' , status: ' +
          authHistory.Status__c,
        authHistory
      );
      Logger.saveLog();
      return res;
    } catch (Exception e) {
      Logger.error(
        'CIBA Initiate Authentication failed : ' + e.getMessage(),
        e
      );
      Logger.saveLog();
      return null;
    }
  }

  /**
   * @description This method is for checking the status of authentication request after certain interval within expirtiontime.
   * @param authrequestId Holds Id of the auth request for which we need status
   * @param authHistoryId Holds authorization History record Id
   * @param ocvId Holds OCV Id of the customer linked to the interaction record.
   * @return status of the authorisation request
   */
  @AuraEnabled
  public static String authenticationPollingResponse(
    String authrequestId,
    String authHistoryId,
    String ocvId
  ) {
    try {
      JoinCIBARepository api = new JoinCIBARepository();
      CIBAAccessTokenResponseModel res = api.authenticationPollingResponse(
        authrequestId,
        ocvId
      );
      String status = handleAccessTokenResponse(res, ocvId);
      updateAuthenticationHistory(authHistoryId, status);
      return status;
    } catch (Exception e) {
      Logger.error('CIBA Authentication Polling failed : ' + e.getMessage(), e);
      updateAuthenticationHistory(authHistoryId, ERROR);
      return ERROR;
    }
  }

  @TestVisible
  private static String handleAccessTokenResponse(
    CIBAAccessTokenResponseModel res,
    String ocvId
  ) {
    if (res == null) {
      return ERROR;
    }

    if (String.IsNotBlank(res.access_token)) {
      Boolean isTokenValidated = validateAccessToken(res.access_token, ocvId);
      return istokenValidated ? VERIFIED : VERIFICATION_FAILED;
    }

    String errorState = res.additionalInfo.errorDetails.error;
    List<String> expectedErrorStates = new List<String>{
      AUTHORIZATION_PENDING,
      SLOW_DOWN,
      ACCESS_DENIED
    };
    return expectedErrorStates.contains(errorState) ? errorState : ERROR;
  }

  /**
   * @description To validate the access token
   * @param accessToken
   * @param ocvId OCV Id for Customer providing authorisation
   * @return verifyAccessToken
   */
  private static Boolean validateAccessToken(String accessToken, String ocvId) {
    List<String> tokenParts = accessToken.split('\\.');

    String header = tokenParts[0];
    String payload = tokenParts[1];
    string headerAndPayload = header + '.' + payload;
    String signature = tokenParts[2];

    String kid = getAuthHeaderValue(header, K_ID);
    String alg = getAuthHeaderValue(header, ALG);
    String publicKey = getPublicKeyFromCache(kid);

    if (String.isBlank(publicKey)) {
      try {
        JoinCIBARepository api = new JoinCIBARepository();
        publicKey = api.getPublicKey(kid, ocvId);
        publicKey = publicKey.removeStart(PUBLICKEYSTART);
        publicKey = publicKey.removeEnd(PUBLICKEYEND);
      } catch (Exception e) {
        Logger.error(
          'CIBA Fetch public key for KID ' +
            kid +
            ' failed : ' +
            e.getMessage(),
          e
        );
        return false;
      }
    }
    storePublicKeyToCache(kid, publicKey);
    return verifyAccessToken(alg, headerAndPayload, signature, publicKey);
  }

  private static String getAuthHeaderValue(String header, String key) {
    String decodedHeader = EncodingUtil.base64Decode(
        CommonUtil.base64URLToBase64(header)
      )
      .toString();
    Map<String, Object> headerJson = (Map<String, Object>) Json.deserializeuntyped(
      decodedHeader
    );
    return String.valueOf(headerJson.get(key));
  }

  /**
   * @description To get the public key from cache
   * @param kid
   * @return public key
   */
  @TestVisible
  private static String getPublicKeyFromCache(String kid) {
    String alphaNumKid = TextUtils.removeNonAlphanumericChar(K_ID);
    if (!(Cache.Org.contains(CIBAKEYID + alphaNumKid))) {
      return '';
    }
    return (String.valueOf(cache.org.get(CIBAKEYID + alphaNumKid)));
  }

  /**
   * @description To store the public key in cache
   * @param kid
   * @param publicKey
   */
  @TestVisible
  private static void storePublicKeyToCache(String kid, String publicKey) {
    String alphaNumKid = TextUtils.removeNonAlphanumericChar(K_ID);
    cache.org.put(CIBAKEYID + alphaNumKid, publicKey);
  }

  /**
   * @description To verify the access token
   * @param algorithmName
   * @param data
   * @param signature
   * @param publicKeyinTextFormat
   * @return boolean
   */
  @TestVisible
  private static Boolean verifyAccessToken(
    String algorithmName,
    String data,
    String signature,
    String publicKeyinTextFormat
  ) {
    //##Verify Access Token (JWT) from Forge
    Blob publicKey = EncodingUtil.base64Decode(publicKeyinTextFormat);
    Blob bsignature = EncodingUtil.base64Decode(
      CommonUtil.base64URLToBase64(signature)
    );

    return Crypto.verify(
      CommonUtil.getAlgorithmNamefromHash(algorithmName),
      Blob.valueOf(data),
      bsignature,
      publicKey
    );
  }

  @TestVisible
  private static AuthenticationHistory__c mapResponseToAuthenticateHistory(
    CIBAAuthenticationModel authResponse,
    String interactionId,
    String acrValue,
    string uuid
  ) {
    if (
      authResponse == null ||
      String.isBlank(interactionId) ||
      String.isBlank(acrValue)
    ) {
      return null;
    }

    return new AuthenticationHistory__c(
      Status__c = CUSTOMER_PENDING,
      AuthenticationMethod__c = acrValue,
      AuthorisationRequestID__c = authResponse.auth_req_id,
      Interaction__c = interactionId,
      InternalAttendee__c = UserInfo.getUserId(),
      UUID__c = uuid
    );
  }

  /**
   * @description This method is for updating the status authorization history record with relavent fields.
   * @param authHistoryId Holds Id of the auth History Id
   * @param status status of Authentication History record. based on status it will relavent fields.
   */
  @AuraEnabled
  public static void updateAuthenticationHistory(
    String authHistoryId,
    String status
  ) {
    if (String.isBlank(authHistoryId)) {
      return;
    }
    List<AuthenticationHistory__c> authhistorylist = [
      SELECT
        Id,
        Status__c,
        AuthenticationMethod__c,
        AuthorisationRequestID__c,
        UUID__c,
        ValidAccessToken__c,
        VerificationDate__c,
        ErrorMessages__c,
        Interaction__c
      FROM AuthenticationHistory__c
      WHERE Id = :authHistoryId
    ];
    if (authHistoryList.isEmpty()) {
      return;
    }
    AuthenticationHistory__c authHistory = setAuthenticationHistoryStatus(
      authHistoryList[0],
      status
    );
    Interaction interactionToUpdate = setInteractionAuthenticationMethod(
      authHistory
    );
    try {
      update authHistory;
      if (interactionToUpdate != null) {
        update interactionToUpdate;
      }
      Logger.info(
        'CIBA Authentication request updated : request_id: ' +
          authHistory.AuthorisationRequestID__c +
          ' , method: ' +
          authHistory.AuthenticationMethod__c +
          ' , status: ' +
          authHistory.Status__c,
        authHistory
      );
    } catch (Exception e) {
      Logger.error(
        'CIBA Authentication request update failed : request_id: ' +
          authHistory.AuthorisationRequestID__c +
          ' , method: ' +
          authHistory.AuthenticationMethod__c +
          ' , status: ' +
          authHistory.Status__c +
          e.getMessage(),
        e
      );
    }
    Logger.saveLog();
  }

  @TestVisible
  private static AuthenticationHistory__c setAuthenticationHistoryStatus(
    AuthenticationHistory__c authHistory,
    String status
  ) {
    if (status == VERIFIED) {
      authHistory.Status__c = CUSTOMER_APPROVED;
      authHistory.ValidAccessToken__c = true;
      authHistory.VerificationDate__c = System.Now();
    } else if (status == ACCESS_DENIED) {
      authHistory.Status__c = CUSTOMER_REJECTED;
    } else if (status == ERROR) {
      authHistory.Status__c = REQUEST_FAILED;
    } else if (status == CANCELLED) {
      authHistory.Status__c = CANCELLED;
    } else if (status == REQUEST_EXPIRED) {
      authHistory.Status__c = REQUEST_EXPIRED;
    } else if (status == VERIFICATION_FAILED) {
      authHistory.Status__c = REQUEST_FAILED;
      authHistory.ErrorMessages__c = VERIFICATION_FAILED;
    }
    return authHistory;
  }
  @TestVisible
  private static Interaction setInteractionAuthenticationMethod(
    AuthenticationHistory__c authHistory
  ) {
    if (
      authHistory.Status__c != CUSTOMER_APPROVED &&
      authHistory.Status__c != CUSTOMER_REJECTED
    ) {
      return null;
    }
    String newAuthenticationMethod =
      getAuthenticationFieldLabelMap()
        .get(authHistory.AuthenticationMethod__c) +
      ' - ' +
      authHistory.Status__c;

    return new Interaction(
      Id = authHistory.Interaction__c,
      Authentication_Method__c = newAuthenticationMethod
    );
  }
  @TestVisible
  private static Map<String, String> getAuthenticationFieldLabelMap() {
    Map<String, String> fieldApiToLabelMap = new Map<String, String>();
    Schema.DescribeFieldResult fieldResult = AuthenticationHistory__c.AuthenticationMethod__c.getDescribe();
    for (Schema.PicklistEntry v : fieldResult.getPicklistValues()) {
      fieldApiToLabelMap.put(v.getValue(), v.getLabel());
    }
    return fieldApiToLabelMap;
  }
}
