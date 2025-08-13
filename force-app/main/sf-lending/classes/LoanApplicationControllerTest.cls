/**
 * @author ramvilas
 * @since May 2025
 * @description Test class for {@link LoanApplicationController)
 */
@isTest
public class LoanApplicationControllerTest {
  static Lib_MockProvider loanAppAPIRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider loanAppMock;
  static Lib_MockProvider loanAppHelperMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    loanAppMock = Lib_MockProvider.forType(
        ResidentialLoanApplicationRepository.class
      )
      .mock('queryRLAByIdForLoanPreference', getRLA)
      .mock('queryRLAById', getRLA);
    loanAppAPIRepoMock = Lib_MockProvider.forType(
      LoanApplicationAPIRepository.class
    );
    loanAppHelperMock = Lib_MockProvider.forType(
        ResidentialLoanApplicationHelper.class
      )
      .mock('updateFieldsOnLoanCancellation', getRLA);
  }

  static LexLoanappV1b1_loanapplication_types.LoanApplication loanPrefAPIResp = (LexLoanappV1b1_loanapplication_types.LoanApplication) CalloutModel.deserialize(
    Service.getStaticResource('mock_GetLoanApplication'),
    LexLoanappV1b1_loanapplication_types.LoanApplication.class
  );

  @isTest
  static void testGetLoanPreferenceDetailsSuccess() {
    Id recordId = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    registerMocks();
    loanAppAPIRepoMock.mock('getLoanApplicationDetails', loanPrefAPIResp);

    Test.startTest();
    LexLoanappV1b1_loanapplication_types.LoanApplication response = LoanApplicationController.getLoanPreferenceDetails(
      recordId,
      true
    );

    Test.stopTest();
    Assert.isNotNull(response, 'Status code of the response should be 200');
    Assert.areEqual(
      'INTEREST_RATE_TYPE_VARIABLE',
      response.preferences[0].interestRateType,
      'Invalid Interest rate type Value '
    );
  }

  @isTest
  static void testgetLoanPreferenceDetailsException() {
    Id recordId = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    errorResponse.error = new CalloutException('callout failed');
    registerMocks();
    loanAppAPIRepoMock.mockException(
      'getLoanApplicationDetails',
      new LoanApplicationAPIRepository.ServerErrorLoanApplicationException(
        errorResponse,
        'getLoanApplication'
      )
    );

    try {
      Test.startTest();
      LoanApplicationController.getLoanPreferenceDetails(recordId, true);
      Test.stopTest();
      Assert.fail('Exception should be thrown.');
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
  }

  @isTest
  static void testCancelResidentialLoanAppSuccess() {
    registerMocks();
    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = Service.getStaticResource(
      'mock_cancelHomeLoanApplication'
    );
    successResponse.successful = true;
    successResponse.statusCode = 200;
    loanAppAPIRepoMock.mock('cancelResidentialLoanApp', successResponse);

    dmlRepoMock.mock(
      'doUpdate',
      TestUtil.getMockSaveResult('{"success":true}')
    );
    loanAppHelperMock.mock('postNotesToChatter', 'return postContentn string');

    Map<String, String> rlaObject = new Map<String, String>{
      'requestId' => '1234',
      'ocvId' => '12345',
      'Cancellation_Reason__c' => 'Credit Assessment expired',
      'Other_Cancellation_Reason__c' => 'test',
      'recordId' => Lib_FakeIdGenerator.getMockId(
        ResidentialLoanApplication.SObjectType
      )
    };

    Test.startTest();
    Boolean checkResult = LoanApplicationController.cancelResidentialLoanApplication(
      rlaObject
    );
    Test.stopTest();
    ResidentialLoanApplication rla = (ResidentialLoanApplication) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('record');

    Assert.isTrue(
      checkResult,
      'Residential Loan Application should be cancelled'
    );
    Assert.areEqual(
      rla.Cancellation_Reason__c,
      'Credit Assessment expired',
      'Residential Loan Application should be updated with cancellation reason as Credit Assessment expired'
    );
  }

  @isTest
  static void testCancelResidentialLoanApplicationException() {
    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    errorResponse.error = new CalloutException('callout failed');
    registerMocks();
    loanAppAPIRepoMock.mockException(
      'cancelResidentialLoanApp',
      new LoanApplicationAPIRepository.ServerErrorLoanApplicationException(
        errorResponse,
        'getLoanApplication'
      )
    );

    try {
      Map<String, String> rlaObject = new Map<String, String>{
        'requestId' => '1234',
        'ocvId' => '12345',
        'Cancellation_Reason__c' => 'Credit Assessment expired',
        'Other_Cancellation_Reason__c' => 'test',
        'recordId' => Lib_FakeIdGenerator.getMockId(
          ResidentialLoanApplication.SObjectType
        )
      };

      Test.startTest();
      LoanApplicationController.cancelResidentialLoanApplication(rlaObject);
      Test.stopTest();
      Assert.fail('Exception should be thrown.');
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
  }

  static ResidentialLoanApplication getRLA {
    get {
      return new ResidentialLoanApplication(
        Id = Lib_FakeIdGenerator.getMockId(
          ResidentialLoanApplication.SObjectType
        ),
        Assessment_Outcome__c = 'Approved',
        Status = 'STATE_REFERRED',
        Credit_ID__c = 'Test',
        SOP_Id__c = 'TestId',
        Name = 'Test Loan Application',
        Property_Use__c = 'LOAN_PRODUCT_TYPE_INVESTOR',
        ApplicationExtIdentifier = '1234',
        Account = new Account(
          Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
          FirstName = 'FakeNameB',
          OCV_ID__c = '11111231'
        )
      );
    }
  }
}
