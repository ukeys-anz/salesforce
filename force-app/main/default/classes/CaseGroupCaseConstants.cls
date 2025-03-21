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
