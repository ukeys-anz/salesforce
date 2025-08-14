/**
 * @author Ashwin Mohan
 * @since  May 2025
 * @group Platform
 * @description Mock class for LoanappService
 */
public class LoanappServiceMock extends LoanappService {
  /**
   * @param model ANZ Plus Loanapp request model
   * @description sends mock response for callout
   * @return HttpCalloutResponse
   */
  public override HttpCalloutResponse getANZPlusLoanappCalloutResponse(
    ANZPlusLoanAppModel model
  ) {
    super.response.body = '{"applicationId": "213354327"}';
    super.response.statusCode = 200;
    super.response.successful = true;
    return super.response;
  }
}
