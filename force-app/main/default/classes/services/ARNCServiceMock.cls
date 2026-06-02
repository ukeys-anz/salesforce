/**
 * @author Ayushi Gupta
 * @since July 2023
 * @description Mock class for ARNCServiceMock
 *              extended service class for ANZ Retail & Commercial banking API calls
 * @group Service
 */
public with sharing class ARNCServiceMock extends ARNCService {
  /**
   * @description constructor which sets default status code and successful
   */
  public ARNCServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  /**
   * @description query non-EBD Accounts
   * @return HttpCalloutResponse
   */
  public HttpCalloutResponse queryCAPAccounts() {
    HttpCalloutResponse calloutResponse = new HttpCalloutResponse();
    calloutResponse.body = '{"accounts":[{"compositeAccountNumber":"4011643101-431214465","accountName":"TO_BE_CLARIFIED","accountNumber":"431214465","productCode":"51","accountBalance":"0","status":"L"}]}';
    return calloutResponse;
  }

  /**
   * @description query EBD Accounts
   * @return HttpCalloutResponse
   */
  public HttpCalloutResponse queryEBDAccounts() {
    HttpCalloutResponse calloutResponse = new HttpCalloutResponse();
    calloutResponse.body = '{"accounts":[{"compositeAccountNumber":"4011643101-431214465","accountName":"TO_BE_CLARIFIED","accountNumber":"431214465","productCode":"51","accountBalance":"0","status":"L"}]}';
    return calloutResponse;
  }

  /**
   * @description query EBD Accounts
   * @return HttpCalloutResponse
   */
  public HttpCalloutResponse queryAccountDetails() {
    HttpCalloutResponse calloutResponse = new HttpCalloutResponse();
    calloutResponse.body = '{"accounts":[{"accountName":"VAALEPU CORP. NOMINEES TRUST","accountNumber":"901221265","productCode":"DDA","subProductCode":"EB","accountRestrictions":false,"restrainsHardHold":false,"pledgeAmount":0,"pledgesNumber":"0","restrainsStopPay":false,"restrainsStopPayNumber":"0","openDate":"2009-04-21","accountBalance":905.57,"availableBalance":905.57,"anzsicCode":"9900","controllingPostId":"F0068","odLimit":0,"seasonalLimits":[{"limit":0},{"limit":0},{"limit":0}],"anzPlusIdentifier":false,"debitInterestCode":"RI","debitInterestIndexRate":8.72,"debitInterestMargin":8.5,"debitInterestRate":8.72,"tempODAccountLimit":0,"tempODMargin":0,"tempODInterestRate":0,"tpmiNumber":0,"tpmiSAO":0,"tempODInterestRepaymentFrequency":"EM"}]}';
    return calloutResponse;
  }

  /**
   * @param parent parent (customer or financial account)
   * @param params parameters
   * @return HttpCalloutResponse
   * @description query external Diary Comment for customer/financial accounts via API
   * Returns mock data from static resources based on parent type
   */
  public override HttpCalloutResponse queryDiaryComment(
    String parent,
    Map<String, String> params
  ) {
    if (!preset) {
      // Check if this is for a financial account or customer based on parent format
      // Financial accounts typically have format like "ILS-391337814"
      // Customer IDs are typically numeric like "4025937927"
      // Default to customer mock data for backward compatibility with tests
      if (parent == 'Financial Account') {
        response.body = Service.getStaticResource(
          'mock_DiaryCommentsFinancialAccount'
        );
      } else if (parent == 'Customer' || parent == 'Account') {
        response.body = Service.getStaticResource('mock_DiaryCommentsCustomer');
      } else {
        response.body = Service.getStaticResource('mock_diaryCommentResponse');
      }
    }
    return response;
  }

  /**
   * @description query Security Code
   * @return HttpCalloutResponse
   */
  public HttpCalloutResponse getSecurityCode() {
    HttpCalloutResponse calloutResponse = new HttpCalloutResponse();
    calloutResponse.body = '{"securityCode": "BRANCH TO LOAD"}';
    return calloutResponse;
  }

  /**
   * @return HttpCalloutResponse
   * @description Write Diary Comment API - parameterless version for backward compatibility
   */
  public HttpCalloutResponse createDiaryComment() {
    HttpCalloutResponse calloutResponse = new HttpCalloutResponse();
    calloutResponse.body = '{"status":"Added"}';
    return calloutResponse;
  }

  /**
   * @param customerId customer id
   * @param comment comment (required)
   * @param event name of event (required)
   * @return Boolean
   * @description Write Diary Comment API - returns mock success response
   */
  public override Boolean createDiaryComment(
    Id customerId,
    String comment,
    String event
  ) {
    // Return true to indicate successful creation in mock mode
    return true;
  }

  /**
   * @description update Security Code
   * @return HttpCalloutResponse
   */
  public HttpCalloutResponse updateSecurityCode() {
    HttpCalloutResponse calloutResponse = new HttpCalloutResponse();
    calloutResponse.body = '{"status":"security code updated successfully"}';
    return calloutResponse;
  }

  /**
   * @description set pagination info
   * @return HttpCalloutResponse
   */
  public HttpCalloutResponse setPaginationInfo() {
    HttpCalloutResponse calloutResponse = new HttpCalloutResponse();
    calloutResponse.body = '{"id":"a2r9h000000qVZFAA2","success":true,"errors":[],"created":false}';
    return calloutResponse;
  }
}
