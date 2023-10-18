/**
 * @author Arpit
 * @since August 2023
 * @description PayTo API repository for to invoke Mule to get response from Fabric
 * @design https://confluence.service.anz/pages/viewpage.action?pageId=1927443960
 * @group Repository
 */
public with sharing class PayToFraudxAPIRepository extends RepositoryBase {
  /**
   * @param mandateId mandate Id
   * @param ocvId ocv Id
   * @param status status
   * @param headerProperties headerProperties
   * @return `PayToModel`
   * @description changes the mandate status for fraudx through mule
   */
  public PayToFabricChangeStatusModel changeMandateStatus(
    String mandateId,
    String ocvId,
    String status,
    Map<String, String> headerProperties
  ) {
    PayToFabricChangeStatusModel responseWrapper = new PayToFabricChangeStatusModel();
    Service s = ServiceProvider.getService(PayToFraudxService.class);
    HttpCalloutResponse response = s.changeMandateStatus(
      mandateId,
      ocvId,
      status,
      headerProperties
    );
    try {
      PayToChangeStatusModel result = PayToChangeStatusModel.parse(
        response.body
      );
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        responseWrapper.status = 'success';
        responseWrapper.message = result.mandateId;
      } else {
        responseWrapper.status = 'failed';
        responseWrapper.message = result.errors[0]?.description;
      }
      return responseWrapper;
    } catch (Exception e) {
      handleErrors(response, e, PayToFraudxAPIRepository.class);
      return null;
    }
  }
}
