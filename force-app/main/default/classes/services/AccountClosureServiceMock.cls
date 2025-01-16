/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description Mock implementation of Fabric Seal service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class AccountClosureServiceMock extends AccountClosureService {
    /**
     * @description constructor which sets default status code and successful
     */
    public AccountClosureServiceMock() {
    response.statusCode = 200;
    response.successful = true;
    }

    @TestVisible
    private static final String INITIATE_ACCOUNT_CLOSURE_SUCCESS = getStaticResource(
    'mock_AccountClosurePrecheckSuccess'
    );

    /**
     * @param ocvId customer ocvId
     * @param accountDetailsForPrechecks input list of case and account details to be sent to Fabric Seal
     * @return `HttpCalloutResponse` method response
     * @description stravinsky package closure api
     */
    public override HttpCalloutResponse initiateAccountClosurePreChecks(
    String ocvId,
    List<FabricSealRequestModel> accountDetailsForPrechecks
    ) {
    if (!preset) {
        response.body = INITIATE_ACCOUNT_CLOSURE_SUCCESS;
    }
    return response;
    }
}