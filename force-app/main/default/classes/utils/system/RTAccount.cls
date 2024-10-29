/**
 * @author Ayushi Gupta
 * @since Sept 2024
 * @description Holds cached Account Record Types.
 */
public class RTAccount {
  static QueryRT base = QueryRT.of(Account.SObjectType);

  public static Id businessAccount = base.getId('Business_Account');
}
