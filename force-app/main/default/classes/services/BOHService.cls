/**
 * @author @fangl6(Lei Fang)
 * @since April 2023
 * @description Service class for residential loan application
 * @group Services
 */
public with sharing class BOHService extends Service {
  public static final String ANZPLUSLOAN = 'ANZ PLUS LOAN APPLIED FOR';
  public static final String FLEXCARDDATETIMEDISPLAYFORMAT = 'd MMMM y | K:mm a';
  /**
   * @param ocvId ocv id of the customer account
   * @param sopId sop id to retrieve customer information
   * @return `HttpCalloutResponse` the api response
   * @description fetches customer information of sop from lex api through mule
   * ===========
   * curl command in dev: grpcurl -H "Authorization: Bearer ${TOKEN}" -d '{"sop_id":"0626ba39-aeb9-4ebb-a275-01bf15aeb8d1"}' sop-service.lex-dev.apps-dev.x.gcpnp.anz:443 lex.service.sop.v1beta1.SopService/ListAssets
   * ===========
   */
  //
  public override HttpCalloutResponse getListAssets(
    String ocvId,
    String sopId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Get_SOP + sopId +'/consolidate',
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

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
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);

    ViewUMIRequest requestBody = new ViewUMIRequest(sopIds, creditId, loanId);

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Get_View_UMI,
      HTTP_METHOD.HTTP_POST,
      headers,
      Json.serialize(requestBody, true)
    );

    return response;
  }

  /**
   * @param creditId to retrieve redit assessment list
   * @param ocvId customer ocv id
   * @return `HttpCalloutResponse` the api response
   * @description fetches credit assessment list of sop from lex api through mule
   */
  public override HttpCalloutResponse getCreditAssessments(
    String creditId,
    String ocvId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('Content-Type', 'application/json');

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' +
      Label.MS_Get_Credit_Assessments +
      creditId,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

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
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('Content-Type', 'application/json');

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.MS_Submit_Credit_Reassessment,
      HTTP_METHOD.HTTP_POST,
      headers,
      payload
    );

    return response;
  }

  /**
   * @param creditId credit id from credit assessment
   * @param assessmentId id of assessment submitted for finalisation
   * @param ocvId customer ocv id
   * @return `HttpCalloutResponse` the api response
   * @description submtis the credit assessment for finalisation
   */
  public override HttpCalloutResponse finaliseAssessment(
    String creditId,
    String assessmentId,
    String ocvId
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('Content-Type', 'application/json');

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.MS_Submit_Credit_Finalisation,
      HTTP_METHOD.HTTP_POST,
      headers,
      '{"creditEnquiryId":"' +
      creditId +
      '", "id":"' +
      assessmentId +
      '"}'
    );

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
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('Content-Type', 'application/json');

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + Label.MS_Submit_Referral_Outcome,
      HTTP_METHOD.HTTP_POST,
      headers,
      payload
    );

    return response;
  }

  /**
   * @description Represents Request body for view UMI api
   */
  public class ViewUMIRequest {
    public List<String> sopIds;
    public String creditEnquiryId;
    public String loanAppId;
    /**
     * @description Constructor to set the fabric money
     * @param sopIds multiple sop ids related to Residential loan application.
     * @param creditId credit assessment id related to Residential loan application.
     * @param loanId Loan Id of the Residential loan application.
     */
    public ViewUMIRequest(List<String> sopIds, String creditId, String loanId) {
      this.sopIds = sopIds;
      this.creditEnquiryId = creditId;
      this.loanAppId = loanAppId;
    }
  }

  /**
   * @description Converts the salesforce datetime into FLEXCARDDATETIMEDISPLAYFORMAT
   * @param dt Input datetime to format.
   * @return `String` formatted string in required format.
   */
  public static string getFormatedDate(DateTime dt) {
    return dt != null ? dt.format(FLEXCARDDATETIMEDISPLAYFORMAT) : null;
  }

  /**
   * @description Converts the salesforce currency/decimal into formatted string
   * @param amt Input deimal to format.
   * @return `String` formatted string in required format.
   */
  public static string convertDecimalToString(Decimal amt) {
    if (amt == null) {
      return null;
    } else if (amt == 0) {
      return '$' + amt;
    } else {
      String str = '$';
      if (amt < 0) {
        amt = amt * -1;
        str = '-' + str;
      }
      str = str + amt.format();
      if (!str.contains('.')) {
        str = str + '.00';
      } else {
        str = str.substringAfter('.').length() < 2 ? str + '0' : str;
      }
      return str;
    }
  }

  /**
   * @description get the loan record for boh services
   * @param loanId the loan id to query for more information
   * @return `List<ResidentialLoanApplication>` List of residential loan application records
   */
  public static List<ResidentialLoanApplication> getLoanRecord(String loanId) {
    return [
      SELECT
        Id,
        Assessment_Outcome__c,
        Credit_ID__c,
        SOP_Id__c,
        Name,
        Account.OCV_ID__c
      FROM ResidentialLoanApplication
      WHERE Id = :loanId
      LIMIT 1
    ];
  }
}
