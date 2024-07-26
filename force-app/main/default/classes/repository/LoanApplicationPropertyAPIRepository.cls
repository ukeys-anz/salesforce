/**
 * @author Peter Charalambous
 * @since Wed Jun 05 2024
 * @description API repository for Loan Property callouts
 */

public with sharing class LoanApplicationPropertyAPIRepository {
  /**
   * @param ocvId ocv id of account
   * @param recordId property record id
   * @param collateralAssessmentId collateral assessment id
   * @description reasses collateral assesment
   * @return `Boolean` confirms whether reassessment was successful
   */
  public Boolean reassessCollateralAssessment(
    String ocvId,
    String recordId,
    String collateralAssessmentId
  ) {
    LoanApplicationPropertyService s = (LoanApplicationPropertyService) ServiceProvider.getService(
      LoanApplicationPropertyService.class
    );
    UUIDLog uuidLog = new UUIDLog(collateralAssessmentId);
    Map<String, String> payload = new Map<String, String>{
      'collateralAssessmentId' => collateralAssessmentId
    };
    String requestPayload = json.serialize(payload, true);
    HttpCalloutResponse resp = s.reassessCollateralAssessment(
      uuidLog.attachUUID(requestPayload),
      ocvId,
      collateralAssessmentId
    );

    if (resp.statusCode == 200) {
      return true;
    }

    ReassessCollateralErrorModel errorResp = ReassessCollateralErrorModel.parse(
      resp.body
    );
    for (ReassessCollateralErrorModel.details details : errorResp.details) {
      if (
        !String.isBlank(details.errorCode) && details.errorCode == '400_205'
      ) {
        uuidLog.insertUUID(recordId, 'BOH - Property - Reassess Collateral');
        break;
      }
    }

    Logger.error(
      'Reassess Collateral callout failed with status code of: ' +
      resp.statusCode,
      resp.error
    );
    Logger.saveLog();
    throw resp.error;
  }
}
