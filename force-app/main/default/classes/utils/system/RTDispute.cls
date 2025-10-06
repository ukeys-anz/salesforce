/**
 * @author Karen Valeriano
 * @since August 2025
 * @description Holds cached Dispute Record Types.
 */
public with sharing class RTDispute {
  static QueryRT base = QueryRT.of(Dispute.SObjectType);

  public static Id disputedTransaction = base.getId('Disputed_Transaction');
}
