/**
 * @author Grace Anusha
 * @since Feb 2025
 * @description Holds cached Broker Relation Record Types.
 */
public class RTBrokerRelation {
  static QueryRT base = QueryRT.of(Broker_Relation__c.SObjectType);
  public static Id brokerSet = base.getId('Broker_Set');
  public static Id officeGroup = base.getId('Office_Group');
}
