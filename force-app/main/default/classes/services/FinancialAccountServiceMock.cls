/**
 * @author Arpit Pittie
 * @since Mon Sep 30 2024
 * @description Mock service class for Financial Account
 */
public with sharing class FinancialAccountServiceMock extends FinancialAccountService {
  /**
   * @description constructor which sets default code as succesful
   */
  public FinancialAccountServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  private static final String LINKED_OFFSET_RESPONSE = getStaticResource(
    'mock_linkedOffsetAccount'
  );

  /**
   * @param ocvId ocv Id
   * @param loanAccNumber param to get the offset linked with financial account
   * @return `HttpcalloutResponse` the api response
   * @description fetches fake response for offset api
   */

  public override HttpCalloutResponse getOffsetAccounts(
    String ocvId,
    String loanAccNumber
  ) {
    if (!preset) {
      response.body = FinancialAccountServiceMock.LINKED_OFFSET_RESPONSE;
    }
    return response;
  }
}
