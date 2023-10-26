/**
 * @author Arpit
 * @since July 2023
 * @description Service class for PayTo
 * @group Services
 */
public with sharing class PayToService extends Service {
  public static final String IDTYPE_PAYID = 'OcvId';

  /**
   * @param ocvId ocv Id
   * @param status status
   * @param pageNumber page number of the list to fetch
   * @return `HttpCalloutResponse` the api response
   * @description fetches Manadate List from fabric through mule
   */
  public override HttpCalloutResponse getMandateList(
    String ocvId,
    Integer status,
    Integer pageNumber
  ) {
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('Content-type', 'application/json');

    GetMandateListRequest requestBody = new GetMandateListRequest(
      status,
      Integer.valueOf(System.Label.MS_Get_Mandate_List_Page_Size),
      pageNumber
    );

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      System.Label.MS_Get_Mandate_List, // create a label
      HTTP_METHOD.HTTP_POST,
      headers,
      Json.serialize(requestBody, true)
    );

    return response;
  }

  /**
   * @description Represents Request body for Get Mandate List API
   */
  public class GetMandateListRequest {
    public Integer status;
    public Integer pageSize;
    public Integer pageNumber;
    /**
     * @description Constructor to set the fabric request
     * @param status id type which is sent to get the mandate
     * @param pageSize page size for each request
     * @param pageNumber page number of the list to fetch
     */
    public GetMandateListRequest(
      Integer status,
      Integer pageSize,
      Integer pageNumber
    ) {
      this.status = status;
      this.pageSize = pageSize;
      this.pageNumber = pageNumber;
    }
  }

  /**
   * @param mandateId mandate Id
   * @param ocvId ocv Id
   * @param status status
   * @return `HttpCalloutResponse` the api response
   * @description Changes mandate status in fabric through mule
   */
  public override HttpCalloutResponse changeMandateStatus(
    String mandateId,
    String ocvId,
    String status
  ) {
    Map<String, String> headers = new Map<String, String>();
    String endpoint;
    setCalloutCommonHeaders(Service.IdType.OCVID, ocvId, headers);
    headers.put('Content-type', 'application/json');

    ChangeStatusMandateRequest requestBody = new ChangeStatusMandateRequest(
      mandateId
    );

    if (status == 'Cancel') {
      endpoint = System.Label.MS_Cancel_Mandate;
    } else if (status == 'Pause') {
      endpoint = System.Label.MS_Pause_Mandate; // Create New Label
    } else if (status == 'Resume') {
      endpoint = System.Label.MS_Resume_Mandate; // Create New Label
    }

    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    HttpCalloutResponse response = calloutService.makeRestCallout(
      endpoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      Json.serialize(requestBody, true)
    );

    return response;
  }

  /**
   * @description Represents Request body for Cancel Mandate List API
   */
  public class ChangeStatusMandateRequest {
    public String mandate;

    /**
     * @description constructor with 1 parameter
     * @param mandateId to set mandate Id
     */
    public ChangeStatusMandateRequest(String mandateId) {
      this.mandate = mandateId;
    }
  }
}
