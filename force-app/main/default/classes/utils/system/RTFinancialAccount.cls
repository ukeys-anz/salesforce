/**
 * @author Arpit Pittie
 * @since Oct 2024
 * @description Holds cached Case Record Types.
 */
public class RTFinancialAccount {
  static QueryRT base = QueryRT.of(FinServ__FinancialAccount__c.SObjectType);

  public static Id bankAccount = base.getId('BankingAccount');
}
