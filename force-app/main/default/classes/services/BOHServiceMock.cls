/**
 * @author @fangl6(Lei Fang)
 * @since April 2023
 * @description Mock implementation of mule api service for SOP service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class BOHServiceMock extends Service {
  /**
   * @description constructor which sets default code as successful
   */

  public BOHServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }
  private static final string SOP_LIST_ASSETS_RESPONSE = getStaticResource(
    'mock_getConsolidateSOP'
  );
  private static final string UMI_LIST_ASSEEEMENTS_RESPONSE = getStaticResource(
    'mock_UMIListAssessments'
  );

  /**
   * @param sopId sop id to retrieve customer savings and asset
   * @return `HttpcalloutResponse` the api response
   * @description fetches fake response for sop api
   */

  public override HttpCalloutResponse getListAssets(String sopId) {
    if (!preset) {
      response.body = BOHServiceMock.SOP_LIST_ASSETS_RESPONSE;
    }
    return response;
  }

  /**
   * @param sopIds sop id
   * @param creditId credit id
   * @param loanId loan id
   * @return `HttpCalloutResponse` the api response
   * @description fetches UMI assessments from sop and gearbox api through mule
   */
  public override HttpCalloutResponse getUMIAssessments(
    List<String> sopIds,
    String creditId,
    String loanId
  ) {
    if (!preset) {
      response.body = BOHServiceMock.UMI_LIST_ASSEEEMENTS_RESPONSE;
    }
    return response;
  }
}
