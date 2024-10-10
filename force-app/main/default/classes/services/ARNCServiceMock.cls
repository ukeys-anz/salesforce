/**
 * @author Ayushi Gupta
 * @since July 2023
 * @description Mock class for ARNCServiceMock
 *              extended service class for ANZ Retail & Commercial banking API calls
 * @group Service
 */
public with sharing class ARNCServiceMock extends Service {
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
   * @description query DIary comments
   * @return HttpCalloutResponse
   */
  public HttpCalloutResponse queryDiaryComments() {
    HttpCalloutResponse calloutResponse = new HttpCalloutResponse();
    calloutResponse.body = '{"conversationControl":"","totalComments":93,"commentsCount":43,"moreComments":"N","commentDetails":[{"branch":3026,"customerReviewFlag":"N","cycleCode":"","workQueue":"","datePrompt":"","datePlaced":"2017-12-12","timePlaced":"173448","dateChanged":"","operatorId":"TALLYMAN","dateExpires":"2023-12-12","commentId":"01677721509957","comment":"PERICHAS ADDED A COMMENT5", "compositeId" : "2001437661-01677721509957", "sequenceNumber" : "0001"}]}';
    return calloutResponse;
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
   * @description create Diary Comment
   * @return HttpCalloutResponse
   */
  public HttpCalloutResponse createDiaryComment() {
    HttpCalloutResponse calloutResponse = new HttpCalloutResponse();
    calloutResponse.body = '{"status":"Added"}';
    return calloutResponse;
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
