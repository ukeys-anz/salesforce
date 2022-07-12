/**
 * @author Boobalakrishnan Duraisamy
 * @since Apr 2022
 * @description extended service class for CCRM Validate Address QAS Experian API
 * @group Service
 */
public with sharing class CCRMValidateAddressService extends Service {
  /**
   * @param lookupString search address value entered by the user
   * @return HttpCalloutResponse
   * @description fetches valid addresses
   */
  public override HttpCalloutResponse getAddresses(String lookupString) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    String endPoint =
      'callout:SF_MS_CCRM' +
      Label.MS_Get_Qas_Address +
      lookupString +
      '&country=AUS&limit=10&engine=Intuitive';
    return calloutService.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
  }

  /**
   * @param encodedAddressId
   * @return HttpCalloutResponse
   * @description fetches valid addresses
   */
  public override HttpCalloutResponse getSelectedAddress(
    String encodedAddressId
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    String endPoint =
      'callout:SF_MS_CCRM' +
      Label.MS_Get_Qas_AddressById +
      encodedAddressId;
    return calloutService.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
  }
}
