/**
 * @author ramvilas
 * @date May 2025
 * @description Test class for {@link HomeLoanHistoryAPIRepository}
 * @group repository
 */

@isTest
public inherited sharing class HomeLoanHistoryAPIRepositoryTest {
  static Lib_MockProvider homeLoanHistoryServiceMock;

  static void registerMocks() {
    homeLoanHistoryServiceMock = Lib_MockProvider.forType(
      HomeLoanHistoryService.class
    );
  }

  /**
   * @description Add required PermissionSet
   */
  @testSetup
  public static void setup() {
    TestUtil.addPermissionSets(new List<String>{ 'BoH_Read_Only' });
  }

  @isTest
  static void testListOfLoanAccountChangeSuccess() {
    registerMocks();

    HttpCalloutResponse successResponse = new HttpCalloutResponse();
    successResponse.body = Service.getStaticResource(
      'mock_listOfLoanAccountChanges'
    );
    successResponse.successful = true;
    successResponse.statusCode = 200;
    homeLoanHistoryServiceMock.mock(
      'getListOfLoanAccountChanges',
      successResponse
    );

    String ocvId = '11111231';
    String loanAccNumber = '8321158';

    Test.startTest();
    HomeLoanHistoryAPIRepository homeLoanApi = new HomeLoanHistoryAPIRepository();
    LoanAccountChangesModel responseModel = homeLoanApi.getListOfLoanAccountChanges(
      ocvId,
      loanAccNumber
    );
    Test.stopTest();

    Assert.areEqual(
      'STATE_APPROVED',
      responseModel.changes[0].approval.state,
      'Response Approve state is incorrect'
    );
  }

  @isTest
  static void testListOfLoanAccountChangeFailure() {
    registerMocks();

    HttpCalloutResponse errorResponse = new HttpCalloutResponse();
    errorResponse.error = new CalloutException('callout failed');
    errorResponse.successful = false;
    errorResponse.statusCode = 500;
    homeLoanHistoryServiceMock.mock(
      'getListOfLoanAccountChanges',
      errorResponse
    );

    String ocvId = '11111231';
    String loanAccNumber = '8321158';

    Exception resultException;

    Test.startTest();
    try {
      HomeLoanHistoryAPIRepository homeLoanApi = new HomeLoanHistoryAPIRepository();
      homeLoanApi.getListOfLoanAccountChanges(ocvId, loanAccNumber);
    } catch (Exception ex) {
      resultException = ex;
    }
    Test.stopTest();

    Assert.isTrue(
      resultException instanceof homeLoanHistoryAPIRepository.ServerErrorGetLoanAccountChangeException,
      'Exception should be thrown.'
    );
    Assert.areEqual(
      'callout failed',
      resultException.getMessage(),
      'Should throw invalid details exception'
    );
  }
}
