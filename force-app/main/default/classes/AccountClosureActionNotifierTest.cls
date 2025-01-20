/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description Test Class for AccountClosureActionNotifier
 */
@isTest
public with sharing class AccountClosureActionNotifierTest {
    private static final Id FAKER_PARENT_CASE_ID = Lib_FakeIdGenerator.getMockId(
        Case.getSObjectType()
    );

    static Lib_MockProvider accountClosureRepoMock;

    static void registerMocks() {
        accountClosureRepoMock = Lib_MockProvider.forType(
            AccountClosureRepository.class
        );
    }

    /**
     * @description test method for postFailureMessage when wrong failed reaons
     */
    @isTest
    public static void testPostFailureMessageNegative() {
        registerMocks();
        accountClosureRepoMock.mock(
            'getFailureMetadata',
            new List<AccountClosureErrorMetadata__mdt>()
        );
        Exception resultException;
        Test.startTest();
        try{
            AccountClosureActionNotifier.postFailureMessage(
            (String)FAKER_PARENT_CASE_ID,
            new Set<String>{'test'});
        }catch (Exception objException) {
            resultException = objException;
        }
        Test.stopTest();
        Assert.areEqual(
            resultException.getMessage(),
            'No Failed Reason Record Found',
            'Exception was expected'
        );
        
    }   
}