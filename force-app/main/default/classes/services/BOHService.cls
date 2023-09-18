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
   */
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
      '?income-verification=' +
      verificationStr,
      HTTP_METHOD.HTTP_POST,
      headers,
      incomeBody
    );
    return response;
  }

  /**
   * @param verification whether the income is verified
   * @param ocvId ocv id of the customer account
   * @param incomeBody post data of income information
   * @return `HttpCalloutResponse` the api response
   * @description update income
   */
  public override HttpCalloutResponse updateIncome(
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
      System.Label.MS_Update_Income +
      '?income-verification=' +
      verificationStr,
      HTTP_METHOD.HTTP_PATCH,
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

  /**
   * @param sopId sop id to retrieve customer information
   * @param ocvId ocv id of the customer account
   * @param deleIncomeModel delete income model
   * @return `HttpCalloutResponse` the api response
   * @description delete income from sop
   */
  public override HttpCalloutResponse deleteIncome(
    String sopId,
    String ocvId,
    String deleIncomeModel
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvID, headers);
    headers.put('Content-Type', 'application/json');

    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Delete_Income +
      '?etag=' +
      SOPDeleteIncomeModel.parse(deleIncomeModel).etag,
      HTTP_METHOD.HTTP_DELETE,
      headers,
      deleIncomeModel
    );

    return response;
  }

  /**
   * @description sets the Credit_Reassess_Required__c = true to fire the toast
   * @param loanId the loan id to update
   */
  public static void setToReassessmentIsRequired(String loanId) {
    update new ResidentialLoanApplication(
      Id = loanId,
      Credit_Reassess_Required__c = true
    );
  }
}
