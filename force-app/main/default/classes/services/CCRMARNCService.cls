/**
 * @author Ian Huang
 * @since July 2023
 * @description extended service class for ANZ Retail & Commercial banking API calls
 * @group Service
 * @runTests CCRMARNCServiceTest
 */
@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing class CCRMARNCService extends Service {
  static Organization SF_ORG = [SELECT Id, Name, IsSandbox FROM Organization];

  /**
   * @description Financial account API call request wrapper class
   */
  public class FinancialAccountQueryParameters {
    public List<String> accounts = new List<String>();
    public String nextPageId;
    public List<String> capCustomerIds = new List<String>();
    public String type;
    public String pageSize;
  }
  /**
   * @description Wrapper class to create diary comment API request
   */
  public class CreateDiaryCommentRequest {
    String expiryDate;
    String comment;
    Customer customer;
  }
  /**
   * @description Wrapper class to create diary comment API request
   */
  public class Customer {
    String id;
  }
  /**
   * @description Wrapper class to update security code API request
   */
  public class UpdateSecurityCodeRequest {
    String securityCode;
  }

  /**
   * @description query exernal CAP finanical accounst via API
   * @param productCategory Account product category e.g. DepositAccount
   * @param queryParams query parameters
   * @return HttpCalloutResponse
   */
  public HttpCalloutResponse queryCAPAccounts(
    String productCategory,
    FinancialAccountQueryParameters queryParams
  ) {
    HttpCalloutResponse response;

    Lib_HttpCallout calloutService = new Lib_HttpCallout();

    Map<String, String> headers = new Map<String, String>();
    setCommonHeaders(headers);
    headers.put('Content-Type', 'application/json');
    headers.put('Accept', '*/*');
    headers.put('Accept-Encoding', 'gzip, deflate, dr');
    headers.put('Content-Length', '2');
    String payload = JSON.serialize(queryParams);

    response = calloutService.makeRestCallout(
      Label.Financial_Account_Endpoint + 'summaries',
      HTTP_METHOD.HTTP_POST,
      headers,
      payload
    );

    return response;
  }

  /**
   * @param productCategory Account product category e.g. CommericalBill
   * @param queryParams query parameters
   * @param assetFinanceType AssetFinance type AMBIT, ELS
   * @return HttpCalloutResponse
   * @description query exernal EBD financial account via API
   */
  public HttpCalloutResponse queryEBDAccounts(
    String productCategory,
    FinancialAccountQueryParameters queryParams,
    String assetFinanceType
  ) {
    HttpCalloutResponse response;

    Lib_HttpCallout calloutService = new Lib_HttpCallout();

    Map<String, String> headers = new Map<String, String>();
    setCommonHeaders(headers);
    String productHeader;
    if (
      productCategory == 'asset-finance' && String.isNotBlank(assetFinanceType)
    ) {
      productHeader =
        assetFinanceType.toLowerCase().trim() + '-success-with-one-account';
    } else {
      productHeader = productCategory.trim() + '-success-with-one-account';
    }
    headers.put('ms2-example', productHeader);
    headers.put('Content-Type', 'application/json');
    headers.put('Accept', '*/*');
    headers.put('Accept-Encoding', 'gzip, deflate, dr');
    headers.put('Content-Length', '2');

    String payload = JSON.serialize(queryParams);

    response = calloutService.makeRestCallout(
      Label.Financial_Account_Endpoint + productCategory + '-accounts',
      HTTP_METHOD.HTTP_POST,
      headers,
      payload
    );

    return response;
  }

  /**
   * @param productCategory Account product category e.g. deposit-account
   * @param payload Request body
   * @return HttpCalloutResponse
   * @description query exernal CAP finanical accounst via API
   */
  public HttpCalloutResponse queryAccountDetail(
    String productCategory,
    String payload
  ) {
    HttpCalloutResponse response;
    Lib_HttpCallout calloutService = new Lib_HttpCallout();

    Map<String, String> headers = new Map<String, String>();
    setCommonHeaders(headers);
    String category;
    if (productCategory == 'transactions') {
      category = productCategory;
    } else {
      category = productCategory + '-accounts';
    }
    response = calloutService.makeRestCallout(
      Label.Financial_Account_Endpoint + category,
      HTTP_METHOD.HTTP_POST,
      headers,
      payload
    );

    return response;
  }

  /**
   * @return String
   * @description get Lan Id of user
   */
  private static String getLanIdOfUser() {
    String lanId;
    if (Schema.sObjectType.User.isQueryable()) {
      User user = [
        SELECT Id, Lan_Id__c
        FROM User
        WHERE Id = :UserInfo.getUserId()
        LIMIT 1
      ];
      if (user != null) {
        lanId = user.Lan_Id__c;
      }
    }
    return lanId;
  }

  /**
   * @param parent parent
   * @param params parameters
   * @param nextPageId nextPageId
   * @return HttpCalloutResponse
   * @description query exernal Diary Comment for customer/financial accounts via API
   */
  public HttpCalloutResponse queryDiaryComment(
    String parent,
    Map<String, String> params,
    String nextPageId
  ) {
    HttpCalloutResponse response;

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCommonHeaders(headers);
    String endPoint = 'callout:SF_MS_Party' + Label.Diary_Comments_Endpoint;
    String parentId;
    String parentValue;
    if (params.containsKey(parent)) {
      parentValue = params.get(parent);
      if (parentValue.contains('_')) {
        parentId = parentValue.substringAfter('_');
      } else if (parentValue.contains('-')) {
        parentId = parentValue.substringAfter('-');
      } else {
        parentId = parentValue;
      }
    }
    parentId = String.isNotBlank(parentId) ? parentId : null;
    nextPageId = nextPageId != null
      ? EncodingUtil.urlEncode(nextPageId, 'UTF-8')
      : '';
    if (parent == 'Customer') {
      endPoint +=
        '?customer-id=' +
        parentId +
        '&conversation-control=' +
        nextPageId;
    } else if (String.isNotBlank(parentValue)) {
      String product = parentValue.contains('|')
        ? parentValue.substringAfter('|')
        : null;
      String productCode = product.contains('-')
        ? product.substringBefore('-')
        : null;
      parentId = product.contains('-') ? product.substringAfter('-') : null;
      endPoint +=
        '?account-number=' +
        parentId +
        '&product-code=' +
        productCode +
        '&conversation-control=' +
        nextPageId;
    }
    try {
      response = calloutService.makeRestCallout(
        endPoint,
        HTTP_METHOD.HTTP_GET,
        headers,
        null
      );
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      throw new AuraHandledException('Error : ' + e.getMessage());
    }
    return response;
  }

  /**
   * @param headers key value pairs of headers to set
   * @return `Map<String, String>` header map
   * @description sets all headers required for a mulesoft callout, loads client id and secret from named credential
   */
  private Map<String, String> setCommonHeaders(Map<String, String> headers) {
    headers.put('Channel', 'DCRM');
    headers.put('Content-Type', 'application/json');
    headers.put('X-Workstation', System.Label.Customer_Auth_Workstation);
    headers.put(
      'X-Operator-Branch',
      System.Label.Customer_Auth_Operator_Branch
    );
    headers.put(
      'X-Originating-App',
      System.Label.Customer_Auth_Originating_App
    );
    String operatorId = getLanIdOfUser();
    if (String.isNotEmpty(operatorId)) {
      headers.put('X-Operator-Id', operatorId);
    }
    headers = setMuleSoftCommonHeaders(headers);
    return headers;
  }
  /**
   * @param customerId CustomerId (required)
   * @return String
   * @description get source system Id
   */
  private static String getSourceSystemId(Id customerId) {
    List<Account> accounts = new List<Account>(
      [SELECT Id, Source_System_ID__c FROM Account WHERE Id = :customerId]
    );
    if (accounts.size() > 0) {
      return accounts[0].Source_System_ID__c;
    }
    return null;
  }
  /**
   * @param headers key value pairs of headers to set
   * @return `Map<String, String>` header map
   * @description sets all headers required for a mulesoft callout, loads client id and secret from named credential
   */
  private Map<String, String> setMuleSoftCommonHeaders(
    Map<String, String> headers
  ) {
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('x-correlation-id', UniqueIdUtil.getTraceId());
    headers.put('Authorization', 'Bearer ' + generateJWTToken());
    return headers;
  }

  /**
   * @param customerId CustomerId (required)
   * @return String
   * @description get security code API
   */
  public String getSecurityCode(Id customerId) {
    HttpCalloutResponse response;

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCommonHeaders(headers);
    String param = Label.Security_Code_Endpoint.replace(
      '{capcisid}',
      getSourceSystemId(customerId)
    );
    String endPoint = 'callout:SF_MS_Party' + param;
    Map<String, Object> result = new Map<String, Object>();
    if (
      Schema.sObjectType.Account.isUpdateable() &&
      Schema.sObjectType.Account.fields.Security_Code_Requested__c.isUpdateable()
    ) {
      try {
        response = calloutService.makeRestCallout(
          endPoint,
          HTTP_METHOD.HTTP_GET,
          headers,
          null
        );
        if (response.statusCode == 200 && String.isNotBlank(response.body)) {
          result = (Map<String, Object>) JSON.deserializeUntyped(response.body);
          Account updatedAccount = new Account(Id = customerId);
          updatedAccount.Security_Code_Requested__c = System.now();
          DMLUtil.updateRecords(
            new List<Account>{ updatedAccount },
            false,
            true
          );
        } else {
          Logger.error('Error : ' + response.error);
          Logger.saveLog();
        }
        return result.containsKey('securityCode')
          ? (String) result.get('securityCode')
          : null;
      } catch (Exception e) {
        Logger.error(e.getMessage());
        Logger.saveLog();
        throw new AuraHandledException(e.getMessage());
      }
    }
    Logger.error(
      'You do not have the required permissions to retrieve Security Code.'
    );
    Logger.saveLog();
    throw new AuraHandledException(
      'You do not have the required permissions to retrieve Security Code.'
    );
  }

  /**
   * @param customerId CustomerId (required)
   * @param comment comment (required)
   * @param event name of event (required)
   * @return Boolean
   * @description Write Diary Comment API
   */
  public Boolean createDiaryComment(
    Id customerId,
    String comment,
    String event
  ) {
    HttpCalloutResponse response;
    String payload;

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCommonHeaders(headers);
    headers.put('Content-Type', 'application/json');
    String capcisId = getSourceSystemId(customerId);
    Date expiryDate;
    CreateDiaryCommentRequest req = new CreateDiaryCommentRequest();
    switch on event {
      when 'FailedAuth' {
        expiryDate = System.today().addYears(30);
      }
      when 'ExistingBranch' {
        expiryDate = System.today().addYears(3);
      }
      when 'IdTheft' {
        expiryDate = System.today().addYears(3);
      }
    }
    req.expiryDate = String.valueOf(expiryDate);
    req.comment = comment;
    Customer customer = new Customer();
    customer.id = capcisId;
    req.customer = customer;
    payload = JSON.serialize(req);
    String endPoint =
      'callout:SF_MS_Party' +
      Label.Diary_Comments_Endpoint +
      '?customer-id=' +
      capcisId;
    Map<String, Object> result = new Map<String, Object>();
    try {
      response = calloutService.makeRestCallout(
        endPoint,
        HTTP_METHOD.HTTP_POST,
        headers,
        payload
      );
      if (response.statusCode == 200 && String.isNotBlank(response.body)) {
        result = (Map<String, Object>) JSON.deserializeUntyped(response.body);
      } else {
        Logger.error('Error : ' + response.error);
        Logger.saveLog();
      }
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
    return result.containsKey('status')
      ? (String) result.get('status') == 'Added'
      : false;
  }
  /**
   * @param customerId CustomerId (required)
   * @param securityCode security code (required)
   * @return Boolean
   * @description Update Security Code API
   */
  public Boolean updateSecurityCode(Id customerId, String securityCode) {
    HttpCalloutResponse response;

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCommonHeaders(headers);
    headers.put('Content-Type', 'application/json');
    String payload;
    UpdateSecurityCodeRequest req = new UpdateSecurityCodeRequest();
    req.securityCode = securityCode;
    payload = JSON.serialize(req);
    String param = Label.Security_Code_Endpoint.replace(
      '{capcisid}',
      getSourceSystemId(customerId)
    );
    String endPoint = 'callout:SF_MS_Party' + param;
    Map<String, Object> result = new Map<String, Object>();
    if (
      Schema.sObjectType.Account.isUpdateable() &&
      Schema.sObjectType.Account.fields.Security_Code_Updated__c.isUpdateable()
    ) {
      try {
        response = calloutService.makeRestCallout(
          endPoint,
          HTTP_METHOD.HTTP_PUT,
          headers,
          payload
        );
        if (response.statusCode == 200 && String.isNotBlank(response.body)) {
          result = (Map<String, Object>) JSON.deserializeUntyped(response.body);
          Account updatedAccount = new Account(Id = customerId);
          updatedAccount.Security_Code_Updated__c = System.now();
          DMLUtil.updateRecords(
            new List<Account>{ updatedAccount },
            false,
            true
          );
        } else {
          Logger.error('Error : ' + response.error);
          Logger.saveLog();
        }
        return result.containsKey('status')
          ? (String) result.get('status') ==
            'security code updated successfully'
          : false;
      } catch (Exception e) {
        Logger.error(e.getMessage());
        Logger.saveLog();
        throw new AuraHandledException(e.getMessage());
      }
    }
    Logger.error(
      'You do not have the required permissions to update Security Code.'
    );
    Logger.saveLog();
    throw new TypeException(
      'You do not have the required permissions to update Security Code.'
    );
  }

  /**
   * @return String jwt token
   * @description generate jwt token
   */
  public static String generateJWTToken() {
    Auth.JWT jwt = new Auth.JWT();
    jwt.setAud('mulesoft');
    jwt.setIss('salesforce');
    jwt.setSub(UserInfo.getUserEmail());
    jwt.setValidityLength(15);

    //determine JWT signing certificate based on if the org is Production or Sandbox
    String jwtSigningCert = SF_ORG.IsSandbox
      ? System.Label.CCRM_JWT_Siging_Certificate_NP
      : System.Label.CCRM_JWT_Siging_Certificate;
    Auth.JWS jws = new Auth.JWS(jwt, jwtSigningCert);

    String token = jws.getCompactSerialization();
    return token;
  }
}
