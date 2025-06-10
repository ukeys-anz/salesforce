/**
 * @author Kopal Goswami
 * @since Oct 2024
 * @description  API service to request response from AEM
 * @group Services
 */
public with sharing virtual class AemService extends Service {
  private static final Lib_HttpCallout CALLOUT = (Lib_HttpCallout) Lib_InstanceProvider.forType(
    Lib_HttpCallout.class
  );

  /**
   * @param aemContentId Template Id
   * @return `HttpCalloutResponse` the api response
   * @description retrieves the AEM Content data details
   */
  public virtual HttpCalloutResponse getAemContentData(String aemContentId) {
    String aemEndPoint =
      Label.Push_Task_To_App_Endpoint +
      aemContentId +
      Label.Push_Task_To_App_Endpoint_Format;

    HttpCalloutResponse response = CALLOUT.makeRestCallout(
      aemEndPoint,
      HTTP_METHOD.HTTP_GET,
      null,
      null
    );

    return response;
  }
}
