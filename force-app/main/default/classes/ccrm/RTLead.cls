/**
 * @author Naman Garg
 * @since Nov 2024
 * @description Holds cached Lead Record Types.
 */
public class RTLead {
  static QueryRT base = QueryRT.of(Lead.SObjectType);

  public static Id commercialLead = base.getId('CCRM_Lead');
}
