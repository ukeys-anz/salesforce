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
      System.Label.MS_Get_SOP +
      sopId +
      '/consolidate',
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }

  /**
   * @param verification whether the income is verified
   * @param ocvId ocv id of the customer account
   * @param incomeBody post data of income information
   * @return `HttpCalloutResponse` the api response
   * @description create income
   */
  public override HttpCalloutResponse createIncome(
    String verification,
    String ocvId,
    String incomeBody
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
    headers.put('Content-Type', 'application/json');
    String verificationStr = 'unverify';
    if (verification == 'Yes') {
      verificationStr = 'verify';
    }

    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Create_Income +
      '?income-verification' +
      verificationStr,
      HTTP_METHOD.HTTP_POST,
      headers,
      incomeBody
    );
    return response;
  }

  /**
   * @param sopIds sop id
   * @param creditId credit id
   * @param ocvId ocv id of the primary loan application
   * @param termMonths Loan term in months
   * @param loanAmount Loan amount
   * @return `HttpCalloutResponse` the api response
   * @description fetches UMI assessments from sop and gearbox api through mule
   */
  public override HttpCalloutResponse getUMIAssessments(
    List<String> sopIds,
    String creditId,
    String ocvId,
    Integer termMonths,
    Decimal loanAmount
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('Content-Type', 'application/json');

    ViewUMIRequest requestBody = new ViewUMIRequest(
      sopIds,
      creditId,
      termMonths,
      loanAmount
    );

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Fabric' + System.Label.MS_Get_View_UMI,
      HTTP_METHOD.HTTP_POST,
      headers,
      Json.serialize(requestBody, true)
    );

    return response;
  }
  /**
   * @description Represents Request body for view UMI api
   */
  public class ViewUMIRequest {
    public List<String> sopIds;
    public String creditEnquiryId;
    public Integer termMonths;
    public FabricType.FabricMoney loanAmount;
    /**
     * @description Constructor to set the fabric money
     * @param sopIds multiple sop ids related to Residential loan application.
     * @param creditId credit assessment id related to Residential loan application.
     * @param termMonths Loan term in months
     * @param loanAmount Loan amount
     */
    public ViewUMIRequest(
      List<String> sopIds,
      String creditId,
      Integer termMonths,
      Decimal loanAmount
    ) {
      this.sopIds = sopIds;
      this.creditEnquiryId = creditId;
      this.termMonths = termMonths;
      this.loanAmount = new FabricType.FabricMoney('AUD', loanAmount);
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
        Status,
        Credit_ID__c,
        SOP_Id__c,
        Name,
        Account.OCV_ID__c
      FROM ResidentialLoanApplication
      WHERE Id = :loanId
      LIMIT 1
    ];
  }

  /**
   * @param ocvId ocv id of the customer account
   * @param sopId sop id to retrieve customer information
   * @return `HttpCalloutResponse` the api response
   * @description fetches customer information of sop from lex api through mule
   */
  public override HttpCalloutResponse getSOP(String ocvId, String sopId) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Get_SOP + sopId,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );

    return response;
  }
}
