/**
 * @author Peter Charalambous
 * @since Wed Jun 05 2024
 * @description service class for Loan Property API callouts
 */

public with sharing virtual class LoanApplicationPropertyService extends Service {
  /**
   * @param payload payload to send to API
   * @param ocvId ocv id of account
   * @param collateralAssessmentId collateral assessment id
   * @return `HttpCalloutResponse` the api response
   * @description reasses collateral assesment
   */
  public virtual HttpCalloutResponse reassessCollateralAssessment(
    String payload,
    String ocvId,
    String collateralAssessmentId
  ) {
    Map<String, String> headers = new Map<String, String>();

    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('Content-Type', 'application/json');

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Reassess_Collateral + collateralAssessmentId,
      HTTP_METHOD.HTTP_POST,
      headers,
      payload
    );

    return response;
  }
}
