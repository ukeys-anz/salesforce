/**
 * @author Arpit
 * @since July 2023
 * @description PayTo API repository for to invoke Mule to get response from Fabric
 * @design https://confluence.service.anz/pages/viewpage.action?pageId=1927443960
 * @group Repository
 */
public with sharing class PayToAPIRepository extends RepositoryBase {
  /**
   * @param ocvId ocv Id
   * @param status status
   * @param pageNumber pageNumber
   * @return `PayToModel`
   * @description fetches Mandate List from Fabric through mule
   */
  public PayToModel getMandateList(
    String ocvId,
    Integer status,
    Integer pageNumber
  ) {
    Service s = ServiceProvider.getService(PayToService.class);
    HttpCalloutResponse response = s.getMandateList(ocvId, status, pageNumber);
    if (response.successful == false) {
      throw response.error;
    }
    try {
      return PayToModel.parse(response.body);
    } catch (Exception e) {
      handleErrors(response, e, PayToModel.class);
    }
    return null;
  }

  /**
   * @param mandateId mandate Id
   * @param ocvId ocv Id
   * @param status status
   * @return `PayToFabricChangeStatusModel`
   * @description cancels Mandate from Fabric through mule
   */
  public PayToFabricChangeStatusModel changeMandateStatus(
    String mandateId,
    String ocvId,
    String status
  ) {
    PayToFabricChangeStatusModel responseWrapper = new PayToFabricChangeStatusModel();
    Service s = ServiceProvider.getService(PayToService.class);
    HttpCalloutResponse response = s.changeMandateStatus(
      mandateId,
      ocvId,
      status
    );
    try {
      if (response.statusCode >= 200 && response.statusCode <= 299) {
        responseWrapper.status = 'success';
        responseWrapper.message = 'success';
      } else {
        responseWrapper = PayToFabricChangeStatusModel.parse(
          response.error.getMessage()
        );
        responseWrapper.status = 'failed';
      }
      return responseWrapper;
    } catch (Exception e) {
      handleErrors(response, e, PayToAPIRepository.class);
      return null;
    }
  }
}
