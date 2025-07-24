/**
 * @author       : Advait Yermalkar
 * @since        : 02-25-2025
 * @description  : This class helps to generate ReferralCloudEventModel
 *                 Cloud Events are Published from Lead trigger After Insert for Retail referals
 **/
public with sharing class ReferralCloudEventModelController {
  private static final CommercialReferralLeadRepository COMMERCIAL_REFERRAL_LEAD_REPOSITORY = (CommercialReferralLeadRepository) Lib_InstanceProvider.forType(
    CommercialReferralLeadRepository.class
  );

  /**
   * @description create cloud events for Interactions
   * @param theLeads
   * @return List<CloudEventModel>
   **/
  public static List<CloudEventModel> createCloudEvents(List<Lead> theLeads) {
    Set<Id> leadOwnerIds = ListUtil.getIds(theLeads, Lead.OwnerId);
    Set<Id> leadReferreredByIds = ListUtil.getIds(
      theLeads,
      Lead.FinServ__ReferredByUser__c
    );

    Set<Id> allOwnerIds = new Set<Id>(leadOwnerIds);
    allOwnerIds.addAll(leadReferreredByIds);
    Map<Id, User> leadOwnerMap = new Map<Id, User>(
      COMMERCIAL_REFERRAL_LEAD_REPOSITORY.getUsers(allOwnerIds)
    );

    Set<Id> existingCustomerIds = ListUtil.getIds(
      theLeads,
      Lead.FinServ__RelatedAccount__c
    );
    Map<Id, Account> existingCustomerMap = new Map<Id, Account>(
      COMMERCIAL_REFERRAL_LEAD_REPOSITORY.getCustomers(existingCustomerIds)
    );

    return formCloudEventList(theLeads, leadOwnerMap, existingCustomerMap);
  }

  /**
   * @description This is used to form the cloud event list
   * @param theLeads List of Leads
   * @param leadOwnerMap Map of Lead Owner
   * @param existingCustomerMap Map of account
   * @return List<CloudEventModel>
   */
  private static List<CloudEventModel> formCloudEventList(
    List<Lead> theLeads,
    Map<Id, User> leadOwnerMap,
    Map<Id, Account> existingCustomerMap
  ) {
    List<CloudEventModel> cloudEvents = new List<CloudEventModel>();
    for (Lead currentLead : theLeads) {
      User currLeadOwner = leadOwnerMap.get(currentLead.OwnerId);
      CloudEventModel.CloudEventSystemModel systemdata = new CloudEventModel.CloudEventSystemModel(
        currentLead.lastModifiedDate,
        currLeadOwner
      );
      CloudEventModel ceModel = new ReferralCloudEventModel(
        currentLead,
        systemdata,
        leadOwnerMap,
        existingCustomerMap
      );
      cloudEvents.add(ceModel);
    }
    return cloudEvents;
  }
}
