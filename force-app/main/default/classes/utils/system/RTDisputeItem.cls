/**
 * @author Karen Valeriano
 * @since August 2025
 * @description Holds cached DisputeItem Record Types.
 */
public with sharing class RTDisputeItem {
  static QueryRT base = QueryRT.of(DisputeItem.SObjectType);

  public static Id disputedTransaction = base.getId('Disputed_Transaction');
}
