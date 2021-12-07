/**
 * @author Adnan
 * @since Sep 2021
 * @description extended service class for mocking CMOS customer search callout
 * @group Service
 */
public with sharing class IDRCustomerProfileServiceMock extends Service {
  /**
   * @description constructor which sets default status code and successful
   */
  public IDRCustomerProfileServiceMock() {
    response.statusCode = 200;
    response.successful = true;
  }

  @TestVisible
  private static final String CUSTOMER_INFO_SUCCESS_RESPONSE =
    '{' +
    '  \"profile\": {' +
    '    \"customerId\": \"4021733054\",' +
    '    \"ocvId\": \"1000001034\",' +
    '    \"cpId\": null,' +
    '    \"complainantType\": \"Individual\",' +
    '    \"businessName\": null,' +
    '    \"companyName\": null,' +
    '    \"firstName\": \"PATRICK ABBISOGNI\",' +
    '    \"mobile\": \"+61499999999\",' +
    '    \"phone\": \"+61499999999\",' +
    '    \"gender\": \"M\",' +
    '    \"email\": \"MASKED@ANZ.TESTING.COM\",' +
    '    \"dob\": \"2007-01-01\",' +
    '    \"age\": \"14\",' +
    '    \"suburb\": \"SUNNYBANK HILLS\",' +
    '    \"street\": \"22 EASTCOURT L\",' +
    '    \"state\": \"AU-QL\",' +
    '    \"postCode\": \"4109\",' +
    '    \"country\": \"AUS\"' +
    '  },' +
    '  \"relationshipManager\": {' +
    '    \"details\": {' +
    '      \"name\": \"TestName\",' +
    '      \"phoneNumber\": \"0401354444\",' +
    '      \"address\": [' +
    '        {' +
    '          \"addressLine1\": \"Test Address Line 1\",' +
    '          \"addressLine2\": \"Test Address Line 2\"' +
    '        }' +
    '      ]' +
    '    },' +
    '    \"error\": null' +
    '  },' +
    '  \"accounts\": [' +
    '    {' +
    '      \"accountNumber\": \"708405438\",' +
    '      \"productCode\": \"CAP-CIS:DDA\",' +
    '      \"subProductCode\": \"CAP-CIS:DDABC\"' +
    '    },' +
    '    {' +
    '      \"accountNumber\": \"708405431\",' +
    '      \"productCode\": \"CAP-CIS:DDS\",' +
    '      \"subProductCode\": \"CAP-CIS:DDEFG\"' +
    '    }' +
    '  ]' +
    '}';

  /**
   * @param customerId customer id to be searched
   * @param customerIdentifier customer identifier
   * @return HttpCalloutResponse the api response
   * @description fetches customer info fake response
   */
  public override HttpCalloutResponse getCustomerInformation(
    String customerId,
    String customerIdentifier
  ) {
    if (!preset) {
      response.body = IDRCustomerProfileServiceMock.CUSTOMER_INFO_SUCCESS_RESPONSE;
    }
    return response;
  }
}
