/**
 * @author Hrushikesh
 * @since April 2025
 * @description Holds cached Interaction Record Types.
 */
public with sharing class RTInteraction {
  static QueryRT base = QueryRT.of(Interaction.SObjectType);

  public static Id call = base.getId('General');
  public static Id message = base.getId('Message');
  public static Id inPerson = base.getId('Store');
  public static Id commercialInteraction = base.getId('CCRM_Interaction');
  public static Id rbmBrokerInteraction = base.getId('RBM_Broker_Interaction');
  public static Id mlcrmInteraction = base.getId('ML_Interaction');

  /**
   * @description Get the record type info for a given record type id
   * @param recordTypeId The record type id
   * @return The record type info
   */
  public static RecordTypeInfo get(Id recordTypeId) {
    return base.get(recordTypeId);
  }

  /**
   * @description Get the record type DeveloperName for a given record type id
   * @param recordTypeId The record type id
   * @return The record type developer name
   */
  public static String getDeveloperName(Id recordTypeId) {
    return base.get(recordTypeId).getDeveloperName();
  }
}
