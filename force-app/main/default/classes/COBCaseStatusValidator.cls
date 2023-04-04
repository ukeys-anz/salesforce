/**
 * @author Batya Aisman Sufrin
 * @since 02/2023
 * @description COBCaseStatusValidator Validates COB case statuses transitions
 */
public with sharing class COBCaseStatusValidator {
  @TestVisible
  private static final String CLOSED_STATUSES_ERROR = 'You are not allowed to change status of a closed COB record';
  @TestVisible
  private static final String FAILED_DVS_MESSAGE = ', because Equifax DVS Result is FAIL. Please escalate to Join Lead if a bypass is needed';
  @TestVisible
  private static final String BLOCKED_STATUS_UPDATE_ERROR = 'Can\'t update ID Ops case status when there is an open Fraud Check Case. ';
  @TestVisible
  private static final String EQUIFAX_DVS_PASS = 'PASS';

  //Invalid COB Case statuses transions for ID Ops Assistance record type
  public static final Map<String, List<String>> ID_OPS_STATUSES_INVALID_TRANSITION_MAP = new Map<String, List<String>>{
    GetHelpConstants.COB_DAON_FAILED_STATUS => new List<String>{
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.COB_EQUIFAX_PASSED_STATUS,
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
    },
    GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS => new List<String>{
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.COB_EQUIFAX_PASSED_STATUS,
      GetHelpConstants.COB_FAILED_OK_STATUS,
      GetHelpConstants.COB_POTENTIAL_FRAUD_STATUS,
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
    },
    GetHelpConstants.COB_EQUIFAX_FAILED_STATUS => new List<String>{
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS,
      GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
    }
  };

  //Invalid COB Case statuses transions for Fraud Check record type
  public static final Map<String, List<String>> FRAUD_CHECK_STATUSES_INVALID_TRANSITION_MAP = new Map<String, List<String>>{
    GetHelpConstants.COB_DAON_FAILED_STATUS => new List<String>{
      GetHelpConstants.COB_EQUIFAX_FAILED_STATUS,
      GetHelpConstants.COB_EQUIFAX_PASSED_STATUS
    },
    GetHelpConstants.COB_EQUIFAX_FAILED_STATUS => new List<String>{
      GetHelpConstants.COB_DAON_FAILED_STATUS,
      GetHelpConstants.COB_FRAUD_CHECK_DAON_APPROVED_STATUS
    }
  };

  //A map for Invalid COB Case statuses transions by record type
  public static final Map<Id, Map<String, List<String>>> INVALID_TRANSITION_MAP_PER_RECORD_TYPE = new Map<Id, Map<String, List<String>>>{
    GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID => ID_OPS_STATUSES_INVALID_TRANSITION_MAP,
    GetHelpConstants.FRAUD_CHECK_RT_ID => FRAUD_CHECK_STATUSES_INVALID_TRANSITION_MAP
  };

  //Closed COB Case statuses for ID Ops Assistance record type
  public static final List<String> ID_OPS_CLOSED_STATUSES = new List<String>{
    GetHelpConstants.COB_EQUIFAX_PASSED_STATUS,
    GetHelpConstants.COB_FAILED_OK_STATUS,
    GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
  };

  //Closed COB Case statuses for Fraud Check record type
  public static final List<String> FRAUD_CHECK_CLOSED_STATUSES = new List<String>{
    GetHelpConstants.COB_FRAUD_CHECK_DAON_APPROVED_STATUS,
    GetHelpConstants.COB_EQUIFAX_PASSED_STATUS,
    GetHelpConstants.COB_FAILED_OK_STATUS,
    GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
  };

  //A map for Closed COB Case statuses by record type
  public static final Map<Id, List<String>> CLOSED_STATUSES_MAP_PER_RECORD_TYPE = new Map<Id, List<String>>{
    GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID => ID_OPS_CLOSED_STATUSES,
    GetHelpConstants.FRAUD_CHECK_RT_ID => FRAUD_CHECK_CLOSED_STATUSES
  };

  /**
   * @description Validate COB Case status change
   * @param currentStatus Current status to validate a case transition
   * @param cobCase Case with new status
   * @return String Error message - Empty if the transion is valid, otherwise a message for invalid transition
   */
  public static String validateCaseStatusChange(
    String currentStatus,
    Case cobCase
  ) {
    String errorTemplate = 'You are not allowed to change the status from \'\'{0}\'\' to \'\'{1}\'\'{2}.';
    Map<String, List<String>> invalidTransitionMap = INVALID_TRANSITION_MAP_PER_RECORD_TYPE.get(
      cobCase.RecordTypeId
    );
    if (
      invalidTransitionMap?.get(currentStatus)?.contains(cobCase.Status) == true
    ) {
      return String.format(
        errorTemplate,
        new List<String>{ currentStatus, cobCase.Status, '' }
      );
    }

    List<String> closedStatuses = CLOSED_STATUSES_MAP_PER_RECORD_TYPE.get(
      cobCase.RecordTypeId
    );
    if (closedStatuses?.contains(currentStatus) == true) {
      return CLOSED_STATUSES_ERROR;
    }

    if (
      cobCase.Status == GetHelpConstants.COB_EQUIFAX_PASSED_STATUS &&
      isCurrentUserJoinLead() == false &&
      isCobEquifaxDVSPass(cobCase.Id) == false
    ) {
      return String.format(
        errorTemplate,
        new List<String>{ currentStatus, cobCase.Status, FAILED_DVS_MESSAGE }
      );
    }

    Case idOpsCaseWithOpenChildren = getParentCaseWithOpenChildren(cobCase.id);
    if (idOpsCaseWithOpenChildren?.Cases?.isEmpty() == false) {
      return BLOCKED_STATUS_UPDATE_ERROR;
    }

    return '';
  }

  /**
   * @description Get parent case with open child cases
   * @param parentCaseId Parent case ids
   * @return Case Parent case with child cases
   */
  @TestVisible
  private static Case getParentCaseWithOpenChildren(Id parentCaseId) {
    if (PermissionUtils.canQuery('Case') == false) {
      return null;
    }

    return [
      SELECT Id, (SELECT Id FROM Cases WHERE IsClosed = FALSE)
      FROM Case
      WHERE Id = :parentCaseId
    ];
  }

  /**
   * @description Check whether the logged in user has Join Leasd role
   * @return Boolean True if a user is Join Lead, false otherwise
   */
  @TestVisible
  private static Boolean isCurrentUserJoinLead() {
    return UserInfo.GetUserRoleId() ==
      CommonUtil.getUserRoleByDevName('Join_Lead').Id;
  }

  /**
   * @description Checks whether the case's (with cobCaseId) Customer Onboarding Application has an Equifax DVS Result == PASS
   * @param cobCaseId Case ids
   * @return Boolean True if case's (with cobCaseId) Customer Onboarding Application has an Equifax DVS Result == PASS, false otherwise
   */
  private static Boolean isCobEquifaxDVSPass(Id cobCaseId) {
    if (
      PermissionUtils.canQuery('CustomerOnboardingApplication__c') == false ||
      PermissionUtils.canQuery('Case') == false
    ) {
      return false;
    }

    List<Case> cases = [
      SELECT Id, CustomerOnboardingApplication__r.EquifaxDVSResult__c
      FROM Case
      WHERE
        Id = :cobCaseId
        AND CustomerOnboardingApplication__r.EquifaxDVSResult__c = :EQUIFAX_DVS_PASS
    ];

    return cases.size() > 0;
  }
}
