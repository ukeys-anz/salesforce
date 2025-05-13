/**
 * @author Jaya Srivastava
 * @since Jan 2025
 * @description service class for Lending Case Approve/Reject API callouts
 * @group Services
 */
public with sharing virtual class LendingCaseService extends Service {
  private static final Lib_HttpCallout HTTP_CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );
  /**
   * @description Send the Loan Preference record updates to the external system
   * @param caseRecord Case
   * @param requestBody LendingCaseRequestModel
   * @return `HttpCalloutResponse` the api response
   */
  public virtual HttpCalloutResponse updateCaseStatusApproveReject(
    Case caseRecord,
    LendingCaseRequestModel requestBody
  ) {
    Map<String, String> headers = new Map<String, String>();
    String ocvId = caseRecord.Account?.OCV_ID__c;
    String accountNumber = caseRecord.FinServ__FinancialAccount__r
      ?.FinServ__FinancialAccountNumber__c;
    String changeId = caseRecord.Loan_Account_Change_Number__c
      ?.substring(
        caseRecord.Loan_Account_Change_Number__c.lastIndexOf('_') + 1
      );
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    List<Object> urlParams = new List<Object>{ accountNumber, changeId };
    String requestUrl = String.format(
      Label.MS_SubmitLoanAccountChangeApprovalOrReject,
      urlParams
    );
    headers.put('Content-Type', 'application/json');
    HttpCalloutResponse response = HTTP_CALLOUT.makeRestCallout(
      requestUrl,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(requestBody)
    );
    return response;
  }
}
