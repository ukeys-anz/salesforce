/**
 * @author Anuja Vats
 * @since April 2024
 * @description extended service class for CMOS SNOW Integration callout
 * @group Service
 */
public with sharing virtual class SNOWIntegrationService extends Service {
  private static final ServiceNowSettingRepository SNOW_SETTING_REPOSITORY = (ServiceNowSettingRepository) Lib_InstanceProvider.forType(
    ServiceNowSettingRepository.class
  );
  /**
   * @param riskEventId risk event Id to be searched
   * @return HttpCalloutResponse
   * @description gathers all the parameters required for callout
   */
  public virtual HttpCalloutResponse getSNOWRiskEventInformation(
    String riskEventId
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    return calloutService.makeRestCallout(
      'callout:ServiceNow_Integration/' +
        Label.SNOW_Risk_Event_End_Point +
        riskEventId,
      HTTP_METHOD.HTTP_GET,
      null,
      ''
    );
  }
}
