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
}
