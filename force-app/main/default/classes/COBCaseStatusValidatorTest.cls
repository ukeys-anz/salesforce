/**
 * @description Test class for {@link COBCaseStatusValidator}
 * @author Batya Aisman Sufrin
 * @since 02/2023
 */
@isTest
public with sharing class COBCaseStatusValidatorTest {
  private static List<String> cobRecordTypes = new List<String>{
    GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID,
    GetHelpConstants.FRAUD_CHECK_RT_ID
  };

  @testSetup
  static void setup() {
    Case idOpsCase = createCobCase(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );
    insert idOpsCase;

    Case openFraudCheckCase = createCobCase(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.FRAUD_CHECK_RT_ID
    );
    insert openFraudCheckCase;

    Case closedFraudCheckCase = createCobCase(
      GetHelpConstants.COB_FRAUD_CHECK_DAON_APPROVED_STATUS,
      GetHelpConstants.FRAUD_CHECK_RT_ID
    );
    insert closedFraudCheckCase;
  }

  private static Case createCobCase(String status, String recordTypeId) {
    return new Case(Status = status, RecordTypeId = recordTypeId);
  }

  private static Case getCOBCase(String status, String recordtype) {
    return [
      SELECT Id, Status, RecordTypeId, ParentId
      FROM Case
      WHERE Status = :status AND RecordTypeId = :recordtype
    ];
  }

  @isTest
  private static void testGetParentCaseWithOpenChildren() {
    Case idOpsCase = getCOBCase(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );

    Case fraudCheckCase = getCOBCase(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.FRAUD_CHECK_RT_ID
    );
    fraudCheckCase.ParentId = idOpsCase.Id;

    Test.startTest();
    update fraudCheckCase;

    Case parentCase = COBCaseStatusValidator.getParentCaseWithOpenChildren(
      idOpsCase.id
    );
    Test.stopTest();

    Assert.areNotEqual(
      null,
      parentCase,
      'There should be only one parent case'
    );

    Assert.areEqual(
      1,
      parentCase.Cases.size(),
      'There should be only one child case'
    );
  }

  @isTest
  private static void testGetParentCaseWithoutChildCase() {
    Case idOpsCase = getCOBCase(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );

    Test.startTest();
    Case parentCase = COBCaseStatusValidator.getParentCaseWithOpenChildren(
      idOpsCase.id
    );
    Test.stopTest();

    Assert.areNotEqual(
      null,
      parentCase,
      'There should be only one parent case'
    );

    Assert.isTrue(parentCase.Cases.isEmpty(), 'There should be no child cases');
  }

  @isTest
  private static void testGetParentCaseWithClosedChildCase() {
    Case idOpsCase = getCOBCase(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );

    Case fraudCheckCase = getCOBCase(
      GetHelpConstants.COB_FRAUD_CHECK_DAON_APPROVED_STATUS,
      GetHelpConstants.FRAUD_CHECK_RT_ID
    );
    fraudCheckCase.ParentId = idOpsCase.Id;

    Test.startTest();
    update fraudCheckCase;

    Case parentCase = COBCaseStatusValidator.getParentCaseWithOpenChildren(
      idOpsCase.id
    );
    Test.stopTest();

    Assert.areNotEqual(
      null,
      parentCase,
      'There should be only one parent case'
    );

    Assert.isTrue(parentCase.Cases.isEmpty(), 'There should be no child cases');
  }

  @isTest
  private static void testValidateStatusOnParentWithOpenChild() {
    Case idOpsCase = getCOBCase(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );
    String currentStatus = idOpsCase.Status;

    Case fraudCheckCase = getCOBCase(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.FRAUD_CHECK_RT_ID
    );
    fraudCheckCase.ParentId = idOpsCase.Id;

    Test.startTest();
    update fraudCheckCase;

    String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
      currentStatus,
      idOpsCase
    );
    Test.stopTest();

    Assert.areEqual(
      COBCaseStatusValidator.BLOCKED_STATUS_UPDATE_ERROR,
      errorMsg,
      'Error message should be: ' +
      COBCaseStatusValidator.BLOCKED_STATUS_UPDATE_ERROR
    );
  }

  @isTest
  private static void testValidateCaseStatusChangeValidTransion() {
    Case cobCase = getCOBCase(
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
    );
    String currentStatus = cobCase.Status;
    cobCase.Status = GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS;

    String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
      currentStatus,
      cobCase
    );

    Assert.areEqual('', errorMsg, 'Error message should be empty.');
  }

  @isTest
  private static void testCaseStatusChangeInvalidTransitionIDOps() {
    String errorTemplate = 'You are not allowed to change the status from \'\'{0}\'\' to \'\'{1}\'\'.';

    Map<String, List<String>> invalidTransitionMap = COBCaseStatusValidator.ID_OPS_STATUSES_INVALID_TRANSITION_MAP;

    for (String sourceStatus : invalidTransitionMap.keySet()) {
      Case cobCase = createCobCase(
        sourceStatus,
        GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
      );

      for (String destinationStatus : invalidTransitionMap.get(sourceStatus)) {
        cobCase.Status = destinationStatus;

        String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
          sourceStatus,
          cobCase
        );

        String expectedErrorMessage = String.format(
          errorTemplate,
          new List<String>{ sourceStatus, destinationStatus }
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
  private static void testCaseStatusChangeInvalidTransitionFraudCheck() {
    String errorTemplate = 'You are not allowed to change the status from \'\'{0}\'\' to \'\'{1}\'\'.';

    Map<String, List<String>> invalidTransitionMap = COBCaseStatusValidator.FRAUD_CHECK_STATUSES_INVALID_TRANSITION_MAP;

    for (String sourceStatus : invalidTransitionMap.keySet()) {
      Case cobCase = createCobCase(
        sourceStatus,
        GetHelpConstants.FRAUD_CHECK_RT_ID
      );

      for (String destinationStatus : invalidTransitionMap.get(sourceStatus)) {
        cobCase.Status = destinationStatus;

        String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
          sourceStatus,
          cobCase
        );

        String expectedErrorMessage = String.format(
          errorTemplate,
          new List<String>{ sourceStatus, destinationStatus }
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
      Case cobCase = createCobCase(
        sourceStatus,
        GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
      );
      cobCase.Status = GetHelpConstants.COB_DAON_FAILED_STATUS;

      String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
        sourceStatus,
        cobCase
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
      Case cobCase = createCobCase(
        sourceStatus,
        GetHelpConstants.FRAUD_CHECK_RT_ID
      );
      cobCase.Status = GetHelpConstants.COB_DAON_FAILED_STATUS;

      String errorMsg = COBCaseStatusValidator.validateCaseStatusChange(
        sourceStatus,
        cobCase
      );

      Assert.areEqual(
        COBCaseStatusValidator.CLOSED_STATUSES_ERROR,
        errorMsg,
        'Error message should be: ' +
        COBCaseStatusValidator.CLOSED_STATUSES_ERROR
      );
    }
  }
}
