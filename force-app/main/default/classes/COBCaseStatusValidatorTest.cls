/**
 * @description Test class for {@link COBCaseStatusValidator}
 * @author Batya Aisman Sufrin
 * @since 02/2023
 */
@isTest
public with sharing class COBCaseStatusValidatorTest {
  private static final Faker FAKER = new Faker('AU');
  private static final String EMPTY_STR = '';
  private static final String FAILED_REASON = 'Selfie fail - selfie image is not clear enough to match';
  private static final String DAON_FALLOUT_NO_MATCH_SUBJECT = 'ID Ops Assistance - Daon Fallout: NO_MATCH';
  private static Lib_MockProvider cobCaseRepoMock;

  static void registerMocks() {
    cobCaseRepoMock = Lib_MockProvider.forType(COBCaseRepository.class);
  }

  static Id cobIdOpsCaseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

  static Case cobIdOpsCase = new Case(
    Id = cobIdOpsCaseId,
    RecordTypeId = RTCase.idOpsAssistance,
    Status = COBCaseConstants.COB_DAON_FALLOUT_STATUS,
    Subject = DAON_FALLOUT_NO_MATCH_SUBJECT,
    PersonaId__c = FAKER.randomString(15),
    Status_Update_Error__c = 'Previous case status update error'
  );

  static Case cobFraudCheckCase = new Case(
    RecordTypeId = RTCase.fraudCheck,
    Status = COBCaseConstants.COB_DAON_FALLOUT_STATUS,
    Subject = DAON_FALLOUT_NO_MATCH_SUBJECT,
    PersonaId__c = FAKER.randomString(15),
    Status_Update_Error__c = 'Previous case status update error'
  );

  @isTest
  private static void testValidateCaseStatusChangeValidTransition() {
    registerMocks();
    cobCaseRepoMock.mock('queryCountOpenChildren', 0);

    cobIdOpsCase.Status = COBCaseConstants.COB_FAILED_OK_STATUS;
    cobIdOpsCase.OnboardingVerificationFailedReason__c = FAILED_REASON;

    Test.startTest();
    String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
      COBCaseConstants.COB_DAON_FALLOUT_STATUS,
      cobIdOpsCase
    );
    Test.stopTest();

    Assert.isFalse(
      cobCaseRepoMock.getHistories('queryCountOpenChildren').isEmpty(),
      'queryCountOpenChildren should have been called.'
    );
    Id parentCaseId = (Id) cobCaseRepoMock.getHistory('queryCountOpenChildren')
      .getParam('parentCaseId');
    Assert.isNotNull(
      parentCaseId,
      'queryCountOpenChildren method should have received parentCaseId.'
    );

    Assert.areEqual(
      '',
      errorMsg,
      'No error message should be generated for valid case status transion.'
    );
  }

  @isTest
  private static void testValidateCaseStatusChangeIDOpsWatchlistHit() {
    registerMocks();
    cobCaseRepoMock.mock('queryCountOpenChildren', 0);

    cobIdOpsCase.Subject = COBCaseConstants.DAON_FALLOUT_WATCHLIST_HIT_SUBJECT;
    cobIdOpsCase.Status = COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS;

    Test.startTest();
    String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
      COBCaseConstants.COB_DAON_FALLOUT_STATUS,
      cobIdOpsCase
    );
    Test.stopTest();

    Assert.areEqual(
      EMPTY_STR,
      errorMsg,
      'Update should be allowed. There should be no error'
    );
  }

  @isTest
  private static void testValidateCaseStatusChangeInvalidTransitionIDOps() {
    Map<String, List<String>> invalidTransitionMap = COBCaseStatusValidator.ID_OPS_STATUSES_INVALID_TRANSITION_MAP;

    for (String sourceStatus : invalidTransitionMap.keySet()) {
      for (String destinationStatus : invalidTransitionMap.get(sourceStatus)) {
        cobIdOpsCase.Status = destinationStatus;

        String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
          sourceStatus,
          cobIdOpsCase
        );

        String expectedErrorMessage = String.format(
          COBCaseStatusValidator.ERROR_STATUS_CHANGE_NOT_ALLOWED,
          new List<String>{ sourceStatus, destinationStatus, '' }
        );
        Assert.areEqual(
          expectedErrorMessage,
          errorMsg,
          'Error message should be: ' + expectedErrorMessage
        );
      }
    }
  }

  @isTest
  private static void testValidateCaseStatusChangeInvalidTransitionFraudCheck() {
    Map<String, List<String>> invalidTransitionMap = COBCaseStatusValidator.FRAUD_CHECK_STATUSES_INVALID_TRANSITION_MAP;

    for (String sourceStatus : invalidTransitionMap.keySet()) {
      for (String destinationStatus : invalidTransitionMap.get(sourceStatus)) {
        cobFraudCheckCase.Status = destinationStatus;

        String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
          sourceStatus,
          cobFraudCheckCase
        );

        String expectedErrorMessage = String.format(
          COBCaseStatusValidator.ERROR_STATUS_CHANGE_NOT_ALLOWED,
          new List<String>{ sourceStatus, destinationStatus, '' }
        );
        Assert.areEqual(
          expectedErrorMessage,
          errorMsg,
          'Error message should be: ' + expectedErrorMessage
        );
      }
    }
  }

  @isTest
  private static void testValidateCaseStatusChangeClosedIDOps() {
    List<String> closedStatuses = COBCaseStatusValidator.ID_OPS_CLOSED_STATUSES;

    for (String sourceStatus : closedStatuses) {
      String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
        sourceStatus,
        cobIdOpsCase
      );

      Assert.areEqual(
        COBCaseStatusValidator.CLOSED_STATUSES_ERROR,
        errorMsg,
        'Error message should be: ' +
        COBCaseStatusValidator.CLOSED_STATUSES_ERROR
      );
    }
  }

  @isTest
  private static void testValidateCaseStatusChangeClosedFraudCheck() {
    List<String> closedStatuses = COBCaseStatusValidator.FRAUD_CHECK_CLOSED_STATUSES;

    for (String sourceStatus : closedStatuses) {
      String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
        sourceStatus,
        cobFraudCheckCase
      );

      Assert.areEqual(
        COBCaseStatusValidator.CLOSED_STATUSES_ERROR,
        errorMsg,
        'Error message should be: ' +
        COBCaseStatusValidator.CLOSED_STATUSES_ERROR
      );
    }
  }

  @isTest
  private static void testValidateCaseStatusChangeDVSPassFraudXAgent() {
    registerMocks();
    //user is not Join Lead
    cobCaseRepoMock.mock('isCurrentUserJoinLead', false);
    //mock cob with DVS = PASS
    cobCaseRepoMock.mock('isCobEquifaxDvsPass', true);

    cobIdOpsCase.Status = COBCaseConstants.COB_ID_CHECK_OK_STATUS;

    Test.startTest();
    String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
      COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS,
      cobIdOpsCase
    );
    Test.stopTest();

    Assert.areEqual(
      '',
      errorMsg,
      'FraudX Agent should be able to bypass Equifax when DVS PASS.'
    );
  }

  @isTest
  private static void testValidateCaseStatusChangeDVSFailedJoinLead() {
    registerMocks();
    //user is Join Lead
    cobCaseRepoMock.mock('isCurrentUserJoinLead', true);
    //mock cob with DVS != PASS
    cobCaseRepoMock.mock('isCobEquifaxDvsPass', false);

    cobIdOpsCase.Status = COBCaseConstants.COB_ID_CHECK_OK_STATUS;

    Test.startTest();
    String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
      COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS,
      cobIdOpsCase
    );
    Test.stopTest();

    Assert.areEqual(
      '',
      errorMsg,
      'Join Lead should be able to bypass Equifax when DVS FAIL.'
    );
  }

  @isTest
  private static void testValidateCaseStatusChangeDVSFailedFraudXAgent() {
    registerMocks();
    //user is not Join Lead
    cobCaseRepoMock.mock('isCurrentUserJoinLead', false);
    //mock cob with DVS != PASS
    cobCaseRepoMock.mock('isCobEquifaxDvsPass', false);

    String sourceStatus = COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS;
    String destinationStatus = COBCaseConstants.COB_ID_CHECK_OK_STATUS;

    cobIdOpsCase.Status = destinationStatus;

    Test.startTest();
    String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
      sourceStatus,
      cobIdOpsCase
    );
    Test.stopTest();

    String expectedErrorMessage = String.format(
      COBCaseStatusValidator.ERROR_STATUS_CHANGE_NOT_ALLOWED,
      new List<String>{
        sourceStatus,
        destinationStatus,
        COBCaseStatusValidator.FAILED_DVS_MESSAGE
      }
    );
    Assert.areEqual(
      expectedErrorMessage,
      errorMsg,
      'Error message should be: ' + expectedErrorMessage
    );
  }

  @isTest
  private static void testValidateStatusOnParentWithOpenChild() {
    registerMocks();
    cobCaseRepoMock.mock('queryCountOpenChildren', 1);

    Test.startTest();
    String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
      COBCaseConstants.COB_DAON_FALLOUT_STATUS,
      cobIdOpsCase
    );
    Test.stopTest();

    Assert.isFalse(
      cobCaseRepoMock.getHistories('queryCountOpenChildren').isEmpty(),
      'queryCountOpenChildren should have been called.'
    );
    Id parentCaseId = (Id) cobCaseRepoMock.getHistory('queryCountOpenChildren')
      .getParam('parentCaseId');
    Assert.isNotNull(
      parentCaseId,
      'queryCountOpenChildren method should have received parentCaseId.'
    );
    Assert.areEqual(
      COBCaseStatusValidator.BLOCKED_STATUS_UPDATE_ERROR,
      errorMsg,
      'Error message should be: ' +
      COBCaseStatusValidator.BLOCKED_STATUS_UPDATE_ERROR
    );
  }
}
