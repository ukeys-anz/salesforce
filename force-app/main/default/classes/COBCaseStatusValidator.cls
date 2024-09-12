/**
 * @author Batya Aisman Sufrin
 * @since 02/2023
 * @description COBCaseStatusValidator Validates COB case statuses transitions
 */
public with sharing class COBCaseStatusValidator {
  private static final COBCaseRepository COB_CASE_REPO = (COBCaseRepository) Lib_InstanceProvider.forType(
    COBCaseRepository.class
  );

  @TestVisible
  private static final String ERROR_STATUS_CHANGE_NOT_ALLOWED = 'You are not allowed to change the status from \'\'{0}\'\' to \'\'{1}\'\'{2}.';
  @TestVisible
  private static final String CLOSED_STATUSES_ERROR = 'You are not allowed to change status of a closed COB record';
  @TestVisible
  private static final String FAILED_DVS_MESSAGE = ', because Equifax DVS Result is FAIL. Please escalate to Join Lead if a bypass is needed';
  @TestVisible
  private static final String BLOCKED_STATUS_UPDATE_ERROR = 'Can\'t update ID Ops case status when there is an open Fraud Check Case. ';

  //Invalid COB Case statuses transions for ID Ops Assistance record type
  public static final Map<String, List<String>> ID_OPS_STATUSES_INVALID_TRANSITION_MAP = new Map<String, List<String>>{
    COBCaseConstants.COB_DAON_FALLOUT_STATUS => new List<String>{
      COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS,
      COBCaseConstants.COB_ID_CHECK_OK_STATUS,
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
    },
    COBCaseConstants.COB_ID_OPS_DAON_OK_STATUS => new List<String>{
      COBCaseConstants.COB_DAON_FALLOUT_STATUS,
      COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS,
      COBCaseConstants.COB_ID_CHECK_OK_STATUS,
      COBCaseConstants.COB_FAILED_OK_STATUS,
      COBCaseConstants.COB_POTENTIAL_FRAUD_STATUS,
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
    },
    COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS => new List<String>{
      COBCaseConstants.COB_DAON_FALLOUT_STATUS,
      COBCaseConstants.COB_ID_OPS_DAON_OK_STATUS,
      COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
    }
  };

  //Invalid COB Case statuses transions for Fraud Check record type
  public static final Map<String, List<String>> FRAUD_CHECK_STATUSES_INVALID_TRANSITION_MAP = new Map<String, List<String>>{
    COBCaseConstants.COB_DAON_FALLOUT_STATUS => new List<String>{
      COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS
    },
    COBCaseConstants.COB_EQUIFAX_FALLOUT_STATUS => new List<String>{
      COBCaseConstants.COB_DAON_FALLOUT_STATUS
    }
  };

  //A map for Invalid COB Case statuses transions by record type
  public static final Map<Id, Map<String, List<String>>> INVALID_TRANSITION_MAP_PER_RECORD_TYPE = new Map<Id, Map<String, List<String>>>{
    RTCase.idOpsAssistance => ID_OPS_STATUSES_INVALID_TRANSITION_MAP,
    RTCase.fraudCheck => FRAUD_CHECK_STATUSES_INVALID_TRANSITION_MAP
  };

  //Closed COB Case statuses for ID Ops Assistance record type
  public static final List<String> ID_OPS_CLOSED_STATUSES = new List<String>{
    COBCaseConstants.COB_ID_CHECK_OK_STATUS,
    COBCaseConstants.COB_FAILED_OK_STATUS,
    COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
  };

  //Closed COB Case statuses for Fraud Check record type
  public static final List<String> FRAUD_CHECK_CLOSED_STATUSES = new List<String>{
    COBCaseConstants.COB_NOT_A_FRAUD_STATUS,
    COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS
  };

  //A map for Closed COB Case statuses by record type
  public static final Map<Id, List<String>> CLOSED_STATUSES_MAP_PER_RECORD_TYPE = new Map<Id, List<String>>{
    RTCase.idOpsAssistance => ID_OPS_CLOSED_STATUSES,
    RTCase.fraudCheck => FRAUD_CHECK_CLOSED_STATUSES
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
    Map<String, List<String>> invalidTransitionMap = INVALID_TRANSITION_MAP_PER_RECORD_TYPE.get(
      cobCase.RecordTypeId
    );
    if (
      invalidTransitionMap?.get(currentStatus)?.contains(cobCase.Status) ==
      true && !isInWatchList(cobCase)
    ) {
      return String.format(
        ERROR_STATUS_CHANGE_NOT_ALLOWED,
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
      cobCase.Status == COBCaseConstants.COB_ID_CHECK_OK_STATUS &&
      COB_CASE_REPO.isCurrentUserJoinLead() == false &&
      COB_CASE_REPO.isCobEquifaxDvsPass(cobCase.Id) == false
    ) {
      return String.format(
        ERROR_STATUS_CHANGE_NOT_ALLOWED,
        new List<String>{ currentStatus, cobCase.Status, FAILED_DVS_MESSAGE }
      );
    }

    if (COB_CASE_REPO.queryCountOpenChildren(cobCase.id) > 0) {
      return BLOCKED_STATUS_UPDATE_ERROR;
    }

    return '';
  }

  /**
   * @description Checks whether the case is 'Daon Fallout' that contains 'Watchlist' Subject
   * @param cobCase Case record
   * @return Boolean True if case is in Watchlist and has status being updated from 'Daon Fallout' to 'Confirmed Fraud'
   */
  public static Boolean isInWatchList(Case cobCase) {
    return String.IsNotBlank(cobCase.Subject) &&
      cobCase.Subject.contains(
        COBCaseConstants.DAON_FALLOUT_WATCHLIST_HIT_SUBJECT
      ) &&
      cobCase.Status == COBCaseConstants.COB_CONFIRMED_FRAUD_STATUS;
  }
}
