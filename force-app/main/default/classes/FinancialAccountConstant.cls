/**
 * @author Shivam Swaraj
 * @since 08/2024
 * @description  FinancialAccountConstant to store the constants related to FinancialAccount
 */
public with sharing class FinancialAccountConstant {
  //Hold the multi-party account's ownership value
  public static final String MULTI_PARTY = 'Multi-party';

  //Hold the joint account's ownership value
  public static final String JOINT = 'Joint';

  //Hold the single account's ownership value
  public static final String SOLE = 'Sole';

  /**
   * @description fetch ANZx financial account record types
   * @return Set<String> finserv roles to be included for balance calculation
   */
  public static Set<String> anzxFinservRoleTypes {
    get {
      if (anzxFinservRoleTypes == null) {
        anzxFinservRoleTypes = new Set<String>{
          'Additional Owner',
          'Primary Owner'
        };
      }
      return anzxFinservRoleTypes;
    }
    private set;
  }
}
