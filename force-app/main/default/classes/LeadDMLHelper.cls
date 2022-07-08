/**
 * @author Adam Smith
 * @since 20220620
 * @description Class For handling Lead DML Operations
 */
public with sharing class LeadDMLHelper {
  /**
   * @description Queries the database for information about leads.
   * @param leadIds Set of Lead Ids to find.
   * @return List<Lead> resultant list of leads.
   */
  public static List<Lead> getLeadInfo(Set<Id> leadIds) {
    List<Lead> interactionLeads = new List<Lead>();
    if (Lead.SObjectType.getDescribe().isQueryable()) {
      interactionLeads = [
        SELECT Id, Name, FirstName, Email, MobilePhone
        FROM Lead
        WHERE Id IN :leadIds
      ];
    } else {
      CommonUtil.logAndThrowIAE(
        'LeadDMLHelper',
        'getLeadInfo',
        'Not enough permissions to query Leads.'
      );
    }
    return interactionLeads;
  }

  /**
   * @description Queries the database for information about leads.
   * @param leadIds Set of Lead Ids to find.
   * @return Map<Id,Lead> resultant map of leads.
   */
  public static Map<Id, Lead> getLeadInfoMap(Set<Id> leadIds) {
    Map<Id, Lead> leadMap = new Map<Id, Lead>();
    List<Lead> leads = getLeadInfo(leadIds);
    if (!leads.isEmpty()) {
      leadMap = new Map<Id, Lead>(leads);
    }
    return leadMap;
  }
}
