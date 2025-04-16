/**
 * @author Prahlad Bhadani
 * @since  November 2024
 * @group Platform
 * @description Service class for Salesforce to Create application in LEX
 */
public with sharing class LoanappService extends Service {
  /**
   * @description to get the callout response from Create Application endpoint
   * @param model LoanappModel
   * @return String
   */
  public String getCreateApplicationCalloutResponse(LoanappModel model) {
    if (model == null) {
      return null;
    }
    String createApplicationEndpoint = Label.CreateApplicationEndpoint;
    String payLoad = JSON.serialize(model, true);
    ARNCService service = new ARNCService();
    HttpCalloutResponse response = service.makeLoanappCallout(
      createApplicationEndpoint,
      payLoad
    );
    if (!response.successful) {
      throw response.error;
    }
    Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
      response.body
    );
    List<Object> extRefs = responseMap.containsKey('externalReferences')
      ? (List<Object>) responseMap.get('externalReferences')
      : new List<Object>();
    Object firstEntry = !extRefs.isEmpty() ? extRefs[0] : null;
    String applicationKey = (firstEntry != null)
      ? String.valueOf(firstEntry).substringAfter('simpology/')
      : null;
    return applicationKey;
  }
}
