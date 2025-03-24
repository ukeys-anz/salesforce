/**
 * @author Kopal Goswami
 * @since 21/2025
 * @description  CaseGroupCaseConstants consists of all the constants used by case group cases
 */

public with sharing class CaseGroupCaseConstants {
  public static final String ACCOUNT_CLOSURE = 'Account Closure';
  public static final String COP = 'Confirmation Of Payee';
  public static final String COP_OPT_IN = 'Confirmation of Payee Opt-In';
  public static final String COP_OPT_OUT = 'Confirmation of Payee Opt-Out';

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

  /**
   * @description Fetch cases issue type and store in variable
   * @return variable with account closure and cop issue types
   */
  public static final Set<String> caseIssueTypes {
    get {
      if (caseIssueTypes == null) {
        caseIssueTypes = new Set<String>();
        caseIssueTypes.add(ACCOUNT_CLOSURE);
        caseIssueTypes.add(COP_OPT_IN);
        caseIssueTypes.add(COP_OPT_OUT);
      }
      return caseIssueTypes;
    }
    private set;
  }
}
