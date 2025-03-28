/**
 * @author Kopal Goswami
 * @since 21/2025
 * @description  CaseGroupCaseConstants consists of all the constants used by case group cases
 */

public with sharing class CaseGroupCaseConstants {
  public static final String ACCOUNT_CLOSURE = 'Account Closure';
  public static final String CASE_GROUP = 'Case Group';
  public static final String COP = 'Confirmation Of Payee';
  public static final String COP_OPT_IN = 'Confirmation of Payee Opt-In';
  public static final String COP_OPT_OUT = 'Confirmation of Payee Opt-Out';

  //Hold the multi-party account's ownership value
  public static final String MULTI_PARTY = 'Multi-party';

  //Hold the joint account's ownership value
  public static final String JOINT = 'Joint';

  //Hold the single account's ownership value
  public static final String SINGLE = 'Single';

  //ANZx Case Group Statuses
  public static final String OPEN_STATUS = 'Open';
  public static final String CLOSED_STATUS = 'Closed';
  public static final String WITHDRAWN_STATUS = 'Withdrawn';
  public static final String ESCALATED_STATUS = 'Escalated';
  public static final String ONHOLD_STATUS = 'On-Hold';

  //ANZx Case Sub Status
  public static final String PROCESSING = 'Processing';
  public static final String FAILED = 'Failed';
  public static final String SUCCESS = 'Success';

  public static final Map<String, String> FIN_ACCOUNT_TYPE = new Map<String, String>{
    'Single' => 'Individual',
    'Multi-party' => 'Joint'
  };

  public static final Map<String, String> COP_STATUS = new Map<String, String>{
    'Opt-Out' => 'Opt-In',
    'Opt-In' => 'Opt-Out'
  };

  public static final Map<String, String> FIN_ACCOUNT_TYPE_FOR_UI = new Map<String, String>{
    'Single' => 'Sole',
    'Multi-party' => 'Joint'
  };

  public static final Map<String, String> CAPS_COP_STATUS = new Map<String, String>{
    'OPT-OUT' => 'Opt-Out',
    'OPT-IN' => 'Opt-In'
  };

  public static final Map<String, String> COP_STATUS_MAP = new Map<String, String>{
    'ACCOUNT_COP_STATUS_OPT_IN' => 'Opt-In',
    'ACCOUNT_COP_STATUS_OPT_OUT' => 'Opt-Out'
  };

  public static final Map<String, String> COP_STATUS_UPDATE_MAP = new Map<String, String>{
    'Confirmation of Payee Opt-In' => 'ACCOUNT_COP_STATUS_OPT_IN',
    'Confirmation of Payee Opt-Out' => 'ACCOUNT_COP_STATUS_OPT_OUT'
  };

  public static final Map<String, String> OPTOUT_REASON_MAP = new Map<String, String>{
    'Victim / survivor of abuse' => 'COP_STATUS_REASON_VICTIM_OR_OSURVIVOR_OF_ABUSE',
    'Profession requiring discretion' => 'COP_STATUS_REASON_PROFESSION_REQUIRING_DISCRETION',
    'Transition gender' => 'COP_STATUS_REASON_TRANSITION_GENDER',
    'Change to relationship partner' => 'COP_STATUS_REASON_CHANGE_TOR_ELATIONSHIP_PARTNER'
  };

  //Set of Case  issue type for account closure, cop opt in  and cop opr out
  public static final Set<String> CASE_ISSUE_TYPES = new Set<String>{
    ACCOUNT_CLOSURE,
    COP_OPT_IN,
    COP_OPT_OUT
  };

  public static final Set<Id> ENTITLEMENT_RT_IDS = new Set<Id>{
    RTCase.caseGroup
  };

  public static final Set<String> ENTITLEMENT_CASE_ISSUE_TYPES = new Set<String>{
    COP_OPT_IN,
    COP_OPT_OUT
  };

  /**
   * @description Check if a case is entitled to have entitlment
   * @param record The case record to check
   * @return if the case have entitlement enabled
   */
  public static Boolean isEntitlementEnabled(Case record) {
    return ENTITLEMENT_RT_IDS.contains(record.RecordTypeId) &&
      ENTITLEMENT_CASE_ISSUE_TYPES.contains(record.Type);
  }
}
