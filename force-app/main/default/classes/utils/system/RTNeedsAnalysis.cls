/**
 * @author Mildeep Singh
 * @since Aug 2025
 * @description Holds cached Needs_Analysis__c Record Types.
 */
public class RTNeedsAnalysis {
  static QueryRT base = QueryRT.of(Needs_Analysis__c.SObjectType);

  public static Id transactionalBankingNeedsAnalysis = base.getId(
    'Transactional_Banking'
  );
}
