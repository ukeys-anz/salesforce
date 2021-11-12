/**
 * @author Adnan
 * @since Oct 2021
 * @description test class for IDRCustomerInformationModel class
 * @group Models
 */
@isTest
public with sharing class IDRCustomerInformationModelTest {
  @isTest
  static void testParse() {
    String json =
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
    IDRCustomerInformationModel obj = IDRCustomerInformationModel.parse(json);
    System.assert(obj != null);
  }
}
