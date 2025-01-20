/**
 * @author Shivam Swaraj
 * @since December 2024
 * @description Test Class for AccountClosureController
 */
@isTest
public with sharing class AccountClosureControllerTest {
    private static final Id FAKER_PARENT_CASE_ID = Lib_FakeIdGenerator.getMockId(
        Case.getSObjectType()
    );

    private static final Id FAKER_CHILD_CASE_ID = Lib_FakeIdGenerator.getMockId(
        Case.getSObjectType()
      );
    
    private static final Id FAKER_ACCOUNT_ID = Lib_FakeIdGenerator.getMockId(
        Account.getSObjectType()
    );
    
    private static final String MOCK_CASE_NUMBER = '03771916';
    static Lib_MockProvider accountClosureRepoMock;
    static Lib_MockProvider dmlRepoMock;

    static void registerMocks() {
        accountClosureRepoMock = Lib_MockProvider.forType(
            AccountClosureRepository.class
        );
        dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    }

    /**
   * @description test method for fetchEligibleChildCasesForPrecheck when successful
   */
    @isTest
    public static void testFetchEligibleCasesForPrecheckSuccess() {
        registerMocks();
        accountClosureRepoMock.mock(
            'queryEligibleChildCaseRecords',
            mockQueryEligibleChildCases(MOCK_CASE_NUMBER)
        );
        Test.startTest();
        List<Case> eligibleCases = AccountClosureController.fetchEligibleCasesForPrecheck(FAKER_PARENT_CASE_ID);
        Test.stopTest();

        Assert.isTrue(
            eligibleCases.size()>0,
            'There should be one eligible child case for precheck'
        );
    }
    /**
    * @description test method for fetchEligibleChildCasesForPrecheck when unsuccessful
    */
    @isTest
    public static void testFetchEligibleCasesForPrecheckNoCases() {
        Exception resultException;
        Test.startTest();
        try {
            AccountClosureController.fetchEligibleCasesForPrecheck(FAKER_CHILD_CASE_ID);
        } catch (Exception objException) {
            resultException = objException;
        }
        Test.stopTest();
        Assert.areEqual(
            resultException.getMessage(),
            'No Eligible Cases Found',
            'Exception was expected'
        );
    }
    
    /**
    * @description test method for initiateAccountClosurePrecheck when successful
    */
    @isTest
    public static void testInitiateAccountClosurePrecheckSuccess() {
        registerMocks();
        accountClosureRepoMock.mock(
            'queryCaseDetails',
            mockCaseRecord(MOCK_CASE_NUMBER,'')
        );
        Test.startTest();
        List<FabricSealResponseModel> response = AccountClosureController.initiateAccountClosurePrecheck(
             FAKER_PARENT_CASE_ID,
             mockQueryEligibleChildCases(MOCK_CASE_NUMBER));
        Test.stopTest();
        Assert.isTrue(
            response.size()>0,
            'Fabric Seal Response Successful'
        );
    }
    
    /**
    * @description test method for initiateAccountClosurePrecheck when unsuccessful
    */
    @isTest
    public static void testInitiateAccountClosurePrecheckFailure() {
        registerMocks();
        accountClosureRepoMock.mock(
            'queryCaseDetails',
            mockCaseRecord(MOCK_CASE_NUMBER,'')
        );
        Exception resultException;
        Test.startTest();
            try{
            AccountClosureController.initiateAccountClosurePrecheck(
                FAKER_PARENT_CASE_ID,
                new List<Case>());  
            }catch (Exception objException) {
            resultException = objException;
        }
        
        Test.stopTest();
        Assert.areEqual(
            resultException.getMessage(),
            'Parent Case And Eligible Cases Required',
            'Exception was expected'
        );
    }

    /**
    * @description test method for processResponsesAndUpdateCases when successful
    */
     @isTest
    public static void testProcessResponsesAndUpdateCasesSuccess() {
        registerMocks();
        accountClosureRepoMock.mock(
            'queryCaseDetails',
            mockCaseRecord(MOCK_CASE_NUMBER,'')
        );
        accountClosureRepoMock.mock(
            'getFailureMetadata',
            mockMetaDataRecord()
        );
        accountClosureRepoMock.mock(
            'queryChildCasesDetailsPostPrecheck',
            mockQueryChildCasesPostPrecheck(MOCK_CASE_NUMBER,GetHelpConstants.PROCESSING)
        );
        
        Test.startTest();
        List<FabricSealResponseModel> response = AccountClosureController.initiateAccountClosurePrecheck(
                FAKER_PARENT_CASE_ID,
                mockQueryEligibleChildCases(MOCK_CASE_NUMBER));
        AccountClosureController.processResponsesAndUpdateCases(
            new List<FabricSealResponseModel>{response[0]},
                mockQueryEligibleChildCases(MOCK_CASE_NUMBER));
            List<Case> caseUpdated = (List<Case>)dmlRepoMock.getHistory('doUpdate')
        .getParam('records');
        Test.stopTest();
        Assert.isTrue(
            caseUpdated.size()>0,
            'Case Updated Successfully'
        );
    }
    /**
    * @description test method for processResponsesAndUpdateCases when unsuccessful
    */
    @isTest
    public static void testProcessResponsesAndUpdateCasesFailure() {
        registerMocks();
        String mockFailedCase = '03771913';
        accountClosureRepoMock.mock(
            'queryCaseDetails',
            mockCaseRecord(mockFailedCase,'')
        );
        accountClosureRepoMock.mock(
            'getFailureMetadata',
            mockMetaDataRecord()
        );
        Exception resultException;
        Test.startTest();
        try{
            List<FabricSealResponseModel> response = AccountClosureController.initiateAccountClosurePrecheck(
                FAKER_PARENT_CASE_ID,
                mockQueryEligibleChildCases(mockFailedCase));
            AccountClosureController.processResponsesAndUpdateCases(
                new List<FabricSealResponseModel>{response[1]},
                mockQueryEligibleChildCases(mockFailedCase));
        }
        catch (Exception objException) {
            resultException = objException;
        }
        Test.stopTest();
        Assert.isNull(
        dmlRepoMock.getHistory('doUpdate'),
        'doUpdate should not have been invoked because ConnectApi error'
        );	
    }
    
    /**
    * @description test method for processResponsesAndUpdateCases when technical error
    */
    @isTest
    public static void testProcessResponsesAndUpdateCasesError() {
        registerMocks();
        String mockFailedCase = '03771919';
        accountClosureRepoMock.mock(
            'queryCaseDetails',
            mockCaseRecord(mockFailedCase,'')
        );
        accountClosureRepoMock.mock(
            'getFailureMetadata',
            mockMetaDataRecord()
        );
        Exception resultException;
        Test.startTest();
        try{
            List<FabricSealResponseModel> response = AccountClosureController.initiateAccountClosurePrecheck(
                FAKER_PARENT_CASE_ID,
                mockQueryEligibleChildCases(mockFailedCase));
            AccountClosureController.processResponsesAndUpdateCases(
                new List<FabricSealResponseModel>{response[2]},
                mockQueryEligibleChildCases(mockFailedCase));
        }
        catch (Exception objException) {
            resultException = objException;
        }
        Test.stopTest();
        Assert.isNull(
            dmlRepoMock.getHistory('doUpdate'),
            'doUpdate should not have been invoked because ConnectApi error'
        );
    }


    private static List<Case> mockQueryEligibleChildCases(String mockCaseNumber){
        List<Case> childcases = new  List<Case>();
        childcases.add(mockCaseRecord(mockCaseNumber,''));
        return childcases;
    }
    
    private static List<Case> mockQueryChildCasesPostPrecheck(String caseNumber, String subStatus){
        List<Case> childcases = new  List<Case>();
        childcases.add(mockCaseRecord(caseNumber,subStatus));
        return childcases;
    }

    private static Case mockCaseRecord(String caseNumber, String subStatus){
        Case caseRecord = (Case) TestUtil.setFields(
        new Case(
          Id = FAKER_CHILD_CASE_ID,
          Account = createMockAccount('OCVID887766'),
          Status = GetHelpConstants.ESCALATED_STATUS,
          Sub_Status__c = subStatus,
          OwnerId = UserInfo.getUserId(),
          ParentId = FAKER_PARENT_CASE_ID,
          RecordTypeId = RTCase.accountClosure,
          FinServ__FinancialAccount__c = Lib_FakeIdGenerator.getMockId(
            FinServ__FinancialAccount__c.getSObjectType()
          ),
          ProductId = Lib_FakeIdGenerator.getMockId(
            Product2.getSObjectType()
          )
        ),
        new Map<String, Object>{ 'CaseNumber' => caseNumber }
      );
       return caseRecord;
    }
    
    /**
   * @description helper method to create a person account
   * @param ocvId the OCVId
   * @return Account a Person Account with Name and OCV as provided
   */
    private static Account createMockAccount(
        String ocvId
    ) {
        Account testAccount = TestDataFactory.createPersonAccount(ocvId, false);
        testAccount.Id = FAKER_ACCOUNT_ID;
        return testAccount;
    }

   /**
   * @description helper method to create mock metadata records
   * @return List<AccountClosureErrorMetadata__mdt>
   */
    public static List<AccountClosureErrorMetadata__mdt> mockMetaDataRecord(){
        List<AccountClosureErrorMetadata__mdt> mockMetaData = new List<AccountClosureErrorMetadata__mdt>();
        AccountClosureErrorMetadata__mdt dummyRecord1 = new AccountClosureErrorMetadata__mdt
           (Failure_Reason__c='techError',
            Chatter_Post__c='Actions',
            Label ='Technical Error',
            Type__c = 'Failure Reason / Action');
        mockMetaData.add(dummyRecord1);
        AccountClosureErrorMetadata__mdt dummyRecord2 = new AccountClosureErrorMetadata__mdt
           (Failure_Reason__c='restraints',
            Chatter_Post__c='New',
            Label ='Restraint',
            Type__c = 'Failure Reason / Action');
        mockMetaData.add(dummyRecord2);   
        return mockMetaData;
    }
}