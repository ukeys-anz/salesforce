/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description Mock implementation of Fabric Seal service, automatically injected if Non_Prod_Settings__c.MockCallouts__c is set or if the application is running in Tests
 * @group Services
 */
public with sharing class AccountClosureServiceMock extends AccountClosureService {

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
    public virtual override HttpCalloutResponse initiateAccountClosurePreChecks(
    String ocvId,
    List<AccountClosurePrecheckRequestModel> accountDetailsForPrechecks
    ) {
        super.response.statusCode = 200;
        super.response.successful = true;
        super.response.body = INITIATE_ACCOUNT_CLOSURE_SUCCESS;
        return super.response;
    }
}