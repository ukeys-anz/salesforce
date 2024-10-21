/**
 * @author Ayushi Gupta
 * @since Oct 2024
 * @description Holds cached Opportunity Record Types.
 */
public class RTOpportunity {
  static QueryRT base = QueryRT.of(Opportunity.SObjectType);

  public static Id commercialOpportunity = base.getId('Commercial_Opportunity');
}
