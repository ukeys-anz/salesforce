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
   * @param lookupString from address search bar
   * @return HttpCalloutResponse
   * @description fetches valid addresses
   */
  public override HttpCalloutResponse getAddresses(String lookupString) {
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
   * @param encodedAddressId selected address id
   * @return HttpCalloutResponse
   * @description fetches address details
   */
  public override HttpCalloutResponse getSelectedAddress(
    String encodedAddressId
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
  public override HttpCalloutResponse getAddressesV2(String lookupString) {
    if (!preset) {
      StaticResource sr = [
        SELECT Body
        FROM StaticResource
        WHERE Name = 'mock_ccrmQasSuccessResponseV2'
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
  public override HttpCalloutResponse getSelectedAddressV2(
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
}
