/**
 * @description Test class for LoanApplicantQueryController.
 * @author Peter Charalambous
 * @since 07/2025
 */
@isTest
public class LoanApplicantQueryControllerTest {
  static Lib_MockProvider loanApplicantRepoMock;

  static void registerMocks() {
    loanApplicantRepoMock = Lib_MockProvider.forType(
      LoanApplicantRepository.class
    );
  }

  @isTest
  static void testGetLoanApplicantByPersonaIdSuccess() {
    registerMocks();
    // Prepare mock LoanApplicant
    LoanApplicant mockApplicant = new LoanApplicant(
      Id = Lib_FakeIdGenerator.getMockId(LoanApplicant.SObjectType),
      Name = 'Test Applicant'
    );
    // Mock repository method
    loanApplicantRepoMock.mock('getLoanApplicantByPersonaId', mockApplicant);

    Map<String, Object> args = new Map<String, Object>{
      'personaId' => 'PERSONA-123'
    };

    Test.startTest();
    LoanApplicantQueryController controller = new LoanApplicantQueryController();
    Object result = controller.call('getLoanApplicantByPersonaId', args);
    Test.stopTest();

    Assert.areNotEqual(
      null,
      result,
      'Returned LoanApplicant should not be null'
    );
    Assert.areEqual(
      mockApplicant.Id,
      ((LoanApplicant) result).Id,
      'Returned LoanApplicant Id should match mock'
    );
    Assert.areEqual(
      'Test Applicant',
      ((LoanApplicant) result).Name,
      'Returned LoanApplicant Name should match mock'
    );
  }

  @isTest
  static void testAuraHandledException() {
    registerMocks();
    // Make the repository throw an exception
    loanApplicantRepoMock.mockException(
      'getLoanApplicantByPersonaId',
      new QueryException('Mocked failure')
    );

    Map<String, Object> args = new Map<String, Object>{
      'personaId' => 'PERSONA-FAIL'
    };

    LoanApplicantQueryController controller = new LoanApplicantQueryController();
    Boolean thrown = false;
    try {
      controller.call('getLoanApplicantByPersonaId', args);
    } catch (AuraHandledException e) {
      thrown = true;
      Assert.isTrue(
        e.getMessage().contains('Failed to retrieve LoanApplicant details'),
        'Should throw custom error message'
      );
    }
    Assert.isTrue(thrown, 'Exception should be thrown on repository failure');
  }
}
