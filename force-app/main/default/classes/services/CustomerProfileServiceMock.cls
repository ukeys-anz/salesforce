public with sharing class CustomerProfileServiceMock extends Service{
    public CustomerProfileServiceMock() {
        response.statusCode = 200;
        response.successful = true;
    }

    @TestVisible
    private static final String CUSTOMER_INFO_SUCCESS_RESPONSE = '{"profile": {"firstname": "TestFirstName","lastname": "TestLastName","mobile": "TestMobile"}}';

    public override HttpCalloutResponse getCustomerInformation(String customerId, String customerIdentifier){
        if(!preset){
            response.body = CustomerProfileServiceMock.CUSTOMER_INFO_SUCCESS_RESPONSE;
        }
        return response;
    }
}
