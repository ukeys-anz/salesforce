/**
 * @author Arpit
 * @since July 2023
 * @description Service class for PayTo
 * @group Services
 */
public with sharing class PayToFraudxService extends Service {
  /**
   * @param mandateId mandate Id
   * @param ocvId ocv Id
   * @param status status
   * @param headerProperties headerProperties
   * @return `HttpCalloutResponse` the api response
   * @description changes the mandate status for fraudx through mule
   */
  public override HttpCalloutResponse changeMandateStatus(
    String mandateId,
    String ocvId,
    String status,
    Map<String, String> headerProperties
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('Content-type', 'application/json');
    headers.put('userId', headerProperties.get('userId'));
    headers.put('userIdType', headerProperties.get('userIdType'));
    headers.put(
      'mandateAccountIdentificationType',
      headerProperties.get('mandateAccountIdentificationType')
    );
    headers.put(
      'mandateAccountIdentification',
      headerProperties.get('mandateAccountIdentification')
    );
    ChangeMandateStatusRequest requestBody = new ChangeMandateStatusRequest(
      status,
      System.Label.PayTo_Fraud_Description,
      System.Label.PayTo_Fraud_Reason_Code
    );

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Fraudx_Change_Status.replace(
        'mandates/{mandateId}',
        mandateId
      ),
      HTTP_METHOD.HTTP_PATCH,
      headers,
      Json.serialize(requestBody, true)
    );

    return response;
  }

  /**
   * @description Represents Mandate Status Change Wrapper
   */

  public class MandateStatusChangeWrapper {
    public String change;
    public String reasonDescription;
    public String reasonCode;

    /**
     * @description Constructor to set the fabric request
     * @param change status to which the mandate needs to be updated to
     * @param reasonDescription reason description for the status change
     * @param reasonCode reason code for the status change
     */

    public MandateStatusChangeWrapper(
      String change,
      String reasonDescription,
      String reasonCode
    ) {
      this.change = change;
      this.reasonDescription = reasonDescription;
      this.reasonCode = reasonCode;
    }
  }

  /**
   * @description Represents Request body for Change Manadate Status for Fraudx
   */

  public class ChangeMandateStatusRequest {
    public MandateStatusChangeWrapper mandateStatusChange;

    /**
     * @description Constructor to set the fabric request
     * @param change status to which the mandate needs to be updated to
     * @param reasonDescription reason description for the status change
     * @param reasonCode reason code for the status change
     */

    public ChangeMandateStatusRequest(
      String change,
      String reasonDescription,
      String reasonCode
    ) {
      this.mandateStatusChange = new PayToFraudxService.MandateStatusChangeWrapper(
        change,
        reasonDescription,
        reasonCode
      );
    }
  }
}
