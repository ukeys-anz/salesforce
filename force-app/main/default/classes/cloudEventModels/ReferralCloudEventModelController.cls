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

  /**
   * @description This method is used to publish cloud events when there is a change in referral status on Lead. It checks for the referral status change and maps it to iKnow status before publishing the event.
   * @param leads List of leads being processed
   * @param oldMap Map of old lead records
   * @return List<CloudEventModel> List of cloud events to be published
   */
  public static List<CloudEventModel> publishLeadReferralStatusUpdateEvents(
    List<Lead> leads,
    Map<Id, Lead> oldMap
  ) {
    List<CloudEventModel> events = new List<CloudEventModel>();

    Set<Id> leadOwnerIds = ListUtil.getIds(leads, Lead.OwnerId);
    Map<Id, User> leadOwnerMap = new Map<Id, User>(
      COMMERCIAL_REFERRAL_LEAD_REPOSITORY.getUsers(leadOwnerIds)
    );

    List<Referral_and_Opportunity_Status_mapping__mdt> leadMetadataList = ReferralStatusMapper.getMappingByObject(
      'Lead'
    );
    for (Lead lead : leads) {
      User currLeadOwner = leadOwnerMap.get(lead.OwnerId);
      CloudEventModel.CloudEventSystemModel systemData = new CloudEventModel.CloudEventSystemModel(
        lead.lastModifiedDate,
        currLeadOwner
      );
      String mappedStatus;
      String mappedStage;
      for (
        Referral_and_Opportunity_Status_mapping__mdt leadMetadata : leadMetadataList
      ) {
        if (
          leadMetadata.Channel__c == lead.Channel__c &&
          leadMetadata.CRM_Referral_Status__c == lead.Referral_Status__c
        ) {
          mappedStatus = leadMetadata.iKnow_Status__c;
          mappedStage = leadMetadata.iKnow_Stage__c;
          continue;
        }
      }

      events.add(
        new ReferralCloudEventModel(
          lead.External_Id__c,
          systemData,
          mappedStatus,
          mappedStage
        )
      );
    }
    return events;
  }

  /**
   * @description This method is used to publish cloud events when there is a change in referral status on Opportunity.
   * @param opportunities List of opportunities being processed
   * @param validReferrals Map of Lead records containing the External_Id__c needed for iKnow
   * @return Map<String, Lead> validReferrals of cloud events to be published
   */
  public static List<CloudEventModel> publishOppReferralStatusUpdateEvents(
    List<Opportunity> opportunities,
    Map<String, Lead> validReferrals
  ) {
    List<CloudEventModel> eventModels = new List<CloudEventModel>();
    Set<Id> ownerIds = ListUtil.getIds(opportunities, Opportunity.OwnerId);
    Map<Id, User> userMap = new Map<Id, User>(
      COMMERCIAL_REFERRAL_LEAD_REPOSITORY.getUsers(ownerIds)
    );

    List<Referral_and_Opportunity_Status_mapping__mdt> oppMetadataList = ReferralStatusMapper.getMappingByObject(
      'Opportunity'
    );
    for (Opportunity opp : opportunities) {
      Lead referralLead = validReferrals.get(opp.Lead_Id__c);
      String externalId = referralLead?.External_Id__c;
      User currLeadOwner = userMap.get(opp.OwnerId);
      CloudEventModel.CloudEventSystemModel systemData = new CloudEventModel.CloudEventSystemModel(
        opp.lastModifiedDate,
        currLeadOwner
      );
      String mappedStatus;
      String mappedStage;
      for (
        Referral_and_Opportunity_Status_mapping__mdt oppMetadata : oppMetadataList
      ) {
        if (
          oppMetadata.Channel__c == referralLead?.Channel__c &&
          oppMetadata.CRM_Opportunity_Stage__c == opp.StageName
        ) {
          mappedStatus = oppMetadata.iKnow_Status__c;
          mappedStage = oppMetadata.iKnow_Stage__c;
          continue;
        }
      }

      eventModels.add(
        new ReferralCloudEventModel(
          externalId,
          systemData,
          mappedStatus,
          mappedStage
        )
      );
    }
    return eventModels;
  }
}
