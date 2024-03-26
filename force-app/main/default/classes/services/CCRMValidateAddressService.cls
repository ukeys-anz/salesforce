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
  public override HttpCalloutResponse getAddressesV3(String lookupString) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('Content-Type', 'application/json');
    String endPoint = 'callout:SF_MS_CCRM' + Label.MS_Get_Qas_Address_V3;
    return calloutService.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(
        new Map<String, Object>{
          'country_iso' => 'AUS',
          'datasets' => new List<String>{ 'au-address' },
          'max_suggestions' => 10,
          'components' => new Map<String, Object>{
            'unspecified' => new List<String>{ lookupString }
          }
        }
      )
    );
  }

  /**
   * @param globalAddressKey
   * @return HttpCalloutResponse
   * @description fetches valid addresses
   */
  public override HttpCalloutResponse getSelectedAddressV3(
    String globalAddressKey
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('Content-Type', 'application/json');
    headers.put('Add-Components', 'true');
    String endPoint =
      'callout:SF_MS_CCRM' +
      Label.MS_Get_Qas_AddressById_V3 +
      globalAddressKey;
    return calloutService.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(
        new Map<String, Object>{ 'layouts' => new List<String>{ 'default' } }
      )
    );
  }

  /**
   * @param globalAddressKey
   * @return HttpCalloutResponse
   * @description fetches valid addresses
   */
  public override HttpCalloutResponse getSelectedAddressWithANZLayoutV3(
    String globalAddressKey
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('Content-Type', 'application/json');
    headers.put('Add-Components', 'true');
    String endPoint =
      'callout:SF_MS_CCRM' +
      Label.MS_Get_Qas_AddressById_V3 +
      globalAddressKey;
    return calloutService.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(
        new Map<String, Object>{
          'layouts' => new List<String>{ 'ANZ-DataServiceHub-Gen-V1-NE' }
        }
      )
    );
  }

  /**
   * @param state
   * @param postcode
   * @param suburb
   * @return HttpCalloutResponse
   * @description validates manual address based on state,postcode,suburb
   */
  public override HttpCalloutResponse getValidateAddressV3(
    String state,
    Integer postcode,
    String suburb
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('Content-Type', 'application/json');
    headers.put('x-correlation-id', UniqueIdUtil.getTraceId());
    CCRMValidateAddressRequestBodyWrapper objWrapper = new CCRMValidateAddressRequestBodyWrapper();
    objWrapper.state = state;
    objWrapper.postcode = postcode;
    objWrapper.suburb = suburb;
    String endPoint = 'callout:SF_MS_CCRM' + Label.MS_Validate_Address_V3;
    return calloutService.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(objWrapper)
    );
  }
  /**
   * @param postcode
   * @return HttpCalloutResponse
   * @description validates manual address based on postalcode
   */
  public override HttpCalloutResponse getPostcodeLookupV3(
    Integer postcode
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('Content-Type', 'application/json');
    headers.put('x-correlation-id', UniqueIdUtil.getTraceId());
    String endPoint =
      'callout:SF_MS_CCRM' +
      Label.MS_Postcode_Lookup_V3 +
      postcode;
    return calloutService.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
  }
}
