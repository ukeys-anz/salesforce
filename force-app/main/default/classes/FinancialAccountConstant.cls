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

  //Hold the Origin value for the products associated to ANZ Plus Financial Account
  public static final String ANZ_PLUS_ORIGIN = 'PRODUCT_ORIGIN_ANZX';

  /**
   * @description Set<String> finserv roles to be included for balance calculation
   */
  public static final Set<String> FINSERV_ROLE_TYPES = new Set<String>{
    'Additional Owner',
    'Primary Owner'
  };
}
