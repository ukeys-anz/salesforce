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

  @TestVisible
  private static final string CREDIT_ASSESSMENT_LIST_RESPONSE = getStaticResource(
    'mock_CRListAssessment'
  );

  private static final string SOP_LIST_ASSETS_RESPONSE = getStaticResource(
    'mock_getConsolidateSOP'
  );
  private static final string UMI_LIST_ASSEEEMENTS_RESPONSE = getStaticResource(
    'mock_UMIListAssessments'
  );

  /**
   * @param ocvId ocv id of the customer account
   * @param sopId sop id to retrieve customer savings and asset
   * @return `HttpcalloutResponse` the api response
   * @description fetches fake response for sop api
   */

  public override HttpCalloutResponse getListAssets(
    String ocvId,
    String sopId
  ) {
    if (!preset) {
      response.body = BOHServiceMock.SOP_LIST_ASSETS_RESPONSE;
    }
    return response;
  }

  /**
   * @param creditId to receive credit assessment list
   * @param ocvId customer ocv id
   * @return `HttpcalloutResponse` the api response
   * @description fetches fake response for gearbox
   */
  public override HttpCalloutResponse getCreditAssessments(
    String creditId,
    String ocvId
  ) {
    if (!preset) {
      response.body = BOHServiceMock.CREDIT_ASSESSMENT_LIST_RESPONSE;
    }
    return response;
  }

  /**
   * @param payload payload containing credit id and uuid from credit assessment
   * @param ocvId customer ocv id
   * @return `HttpCalloutResponse` the api response
   * @description submits credit assessment for reassessment
   */
  public override HttpCalloutResponse creditReassessment(
    String payload,
    String ocvId
  ) {
    if (!preset) {
      response.body = BOHServiceMock.CREDIT_ASSESSMENT_LIST_RESPONSE;
    }
    return response;
  }

  /**
   * @param creditId credit id from credit assessment
   * @param assessmentId id of assessment submitted for finalisation
   * @param ocvId customer ocv id
   * @return `HttpCalloutResponse` the api response
   * @description submits credit assessment for reassessment
   */
  public override HttpCalloutResponse finaliseAssessment(
    String creditId,
    String assessmentId,
    String ocvId
  ) {
    if (!preset) {
      response.body = BOHServiceMock.CREDIT_ASSESSMENT_LIST_RESPONSE;
    }
    return response;
  }

  /**
   * @param payload payload containing credit id, referralOutcome and uuid from credit assessment
   * @param ocvId customer ocv id
   * @return HttpCalloutResponse api response
   * @description submits referral outcome update
   */
  public override HttpCalloutResponse createCreditEnquiryAssessment(
    String payload,
    String ocvId
  ) {
    if (!preset) {
      response.body = BOHServiceMock.CREDIT_ASSESSMENT_LIST_RESPONSE;
    }
    return response;
  }

  /**
   * @param sopIds sop id
   * @param creditId credit id
   * @param loanId loan id
   * @param ocvId ocv id of the primary loan application
   * @return `HttpCalloutResponse` the api response
   * @description fetches UMI assessments from sop and gearbox api through mule
   */
  public override HttpCalloutResponse getUMIAssessments(
    List<String> sopIds,
    String creditId,
    String loanId,
    String ocvId
  ) {
    if (!preset) {
      response.body = BOHServiceMock.UMI_LIST_ASSEEEMENTS_RESPONSE;
    }
    return response;
  }
}
