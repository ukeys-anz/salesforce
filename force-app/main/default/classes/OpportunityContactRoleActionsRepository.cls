/**
 * @author MLCRM Developer
 * @since 07/2024
 * @description This class provide SOQL,DML and mocking helper for class related to OpportunityContactRole.
 */
public with sharing class OpportunityContactRoleActionsRepository {
  /**
   * @description getOppContactRole method return map of OpportunityContactRole associated to the given ids of the opportunity
   * @param idsOfOpp Id of the Opportunity
   * @return Map<Id,OpportunityContactRole> map of OpportunityContactRole List
   */
  public List<OpportunityContactRole> getOppContactRole(Set<ID> idsOfOpp) {
    if (idsOfOpp.isEmpty()) {
      return new List<OpportunityContactRole>();
    }
    return [
      SELECT Id, contact.accountid, Role, opportunityId
      FROM OpportunityContactRole
      WHERE OpportunityId IN :idsOfOpp
      WITH USER_MODE
    ];
  }

  /**
   * @description getOppContactRoleByContacts method return list of OpportunityContactRole associated to the given ids of the contacts
   * @param idsOfContact Id of the Contacts
   * @return List<OpportunityContactRole> map of OpportunityContactRole List
   */

  public List<OpportunityContactRole> getOppContactRoleByContacts(
    Set<ID> idsOfContact
  ) {
    if (idsOfContact.isEmpty()) {
      return new List<OpportunityContactRole>();
    }
    return [
      SELECT Id, ContactId, OpportunityId, Role
      FROM OpportunityContactRole
      WHERE ContactId IN :idsOfContact
      WITH USER_MODE
    ];
  }
}
