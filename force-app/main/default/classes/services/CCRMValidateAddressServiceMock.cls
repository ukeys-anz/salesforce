/**
 * @author Boobalakrishnan Duraisamy
 * @since Apr 2022
 * @description extended service class for mocking CCRM Validate Address Callout
 * @group Service
 */
public with sharing class CCRMValidateAddressServiceMock extends Service {
  /**
   * @description constructor which sets default status code and successful
   */
  public CCRMValidateAddressServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  /**
   * @param globalAddressKey selected address id
   * @return HttpCalloutResponse
   * @description fetches address details
   */
  public override HttpCalloutResponse getSelectedAddressWithANZLayoutV3(
    String globalAddressKey
  ) {
    if (!preset) {
      StaticResource sr = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_ccrmQaSelectedAddressResponse'
        WITH SECURITY_ENFORCED
      ];
      response.body = sr.Body.toString();
    }
    return response;
  }

  /**
   * @param lookupString from address search bar
   * @return HttpCalloutResponse
   * @description fetches valid addresses
   */
  public override HttpCalloutResponse getAddressesV3(String lookupString) {
    if (!preset) {
      StaticResource sr = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_ccrmQasSuccessResponse'
        WITH SECURITY_ENFORCED
      ];
      response.body = sr.Body.toString();
    }
    return response;
  }

  /**
   * @param globalAddressKey selected address id
   * @return HttpCalloutResponse
   * @description fetches address details
   */
  public override HttpCalloutResponse getSelectedAddressV3(
    String globalAddressKey
  ) {
    if (!preset) {
      StaticResource sr = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_ccrmQasSelectedAddressResponseV2'
        WITH SECURITY_ENFORCED
      ];
      response.body = sr.Body.toString();
    }
    return response;
  }
  
  /**
   * @param state
   * @param postcode
   * @param suburb
   * @return HttpCalloutResponse
   * @description validate manual address details 
   */
  public override HttpCalloutResponse getValidateAddressV3(
    String state,
    Integer postcode,
    String suburb
  ) {
    if (!preset) {
      StaticResource sr = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_ccrmValidateAddressResponseV3'
        WITH SECURITY_ENFORCED
      ];
      response.body = sr.Body.toString();
    }
    return response;
  }

   /**
   * @param postcode
   * @return HttpCalloutResponse
   * @description validate manual address details
   */
  public override HttpCalloutResponse getPostcodeLookupV3(
    Integer postcode
  ) {
    if (!preset) {
      StaticResource sr = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_ccrmValidateAddressResponseV3'
        WITH SECURITY_ENFORCED
      ];
      response.body = sr.Body.toString();
    }
    return response;
  }
}
