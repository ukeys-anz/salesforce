/**
 * @author Anuja Vats
 * @since April 2024
 * @description extended service class for CMOS SNOW Integration callout
 * @group Service
 * @last modified on  : 20-02-2025
 * @last modified by  : Prabhupad Sahu
 */
public with sharing virtual class SNOWIntegrationService extends Service {
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

  /**
   * @return url as string
   * @description method to fetch service-now instance url for redirection
   */
  @AuraEnabled(cacheable=true)
  public static String getEnvSettings() {
    List<ServiceNow_environment_settings__c> envSettings = SNOW_SETTING_REPOSITORY.getSnowEnvSettings();
    String domainUrl = System.URL.getOrgDomainUrl().getHost().split('\\.')[0];
    String envUrl = '';
    for (ServiceNow_environment_settings__c setting : envSettings) {
      if (
        !(',' +
          setting.Environment_name__c.toLowerCase() +
          ',')
          .contains(',' + domainUrl + ',')
      ) {
        continue;
      }
      envUrl = setting.Url__c;
    }
    return envUrl;
  }
}
