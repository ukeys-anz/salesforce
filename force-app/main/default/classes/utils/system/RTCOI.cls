/**
 * @author Naman Garg
 * @since Nov 2024
 * @description Holds cached COI Record Types.
 */
public class RTCOI {
  static QueryRT base = QueryRT.of(Circle_Of_Influence__c.SObjectType);

  public static Id companyMember = base.getId('Company_Member');
}
