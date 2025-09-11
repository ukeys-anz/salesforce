/**
 * @author ramvilas
 * @since May 2025
 * @description Test class for {@link LoanApplicationController)
 */
@isTest
public class LoanApplicationControllerTest {
  static Lib_MockProvider loanAppAPIRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider rlaRepoMock;

  static Id rlaIds = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.SObjectType
  );
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    rlaRepoMock = Lib_MockProvider.forType(
        ResidentialLoanApplicationRepository.class
      )
      .mock('queryRLAById', relatedRla);
    loanAppAPIRepoMock = Lib_MockProvider.forType(
      LoanApplicationAPIRepository.class
    );
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
  static void testgetLoanPreferenceDetailsException() {
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
      Assert.fail('Script-thrown exception');
    } catch (Exception ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
  }
  static ResidentialLoanApplication relatedRla {
    get {
      ResidentialLoanApplication rla = new ResidentialLoanApplication(
        Id = rlaIds,
        Assessment_Outcome__c = 'Approved',
        Status = 'STATE_REFERRED',
        Credit_ID__c = 'Test',
        SOP_Id__c = 'TestId',
        Name = 'TestRla',
        Account = new Account(
          Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
          FirstName = 'FakeNameB',
          OCV_ID__c = '276543221'
        )
      );
      return rla;
    }
  }
}
