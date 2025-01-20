/**
 *
 * @author MLCRM Developer
 * @since 03/July/2024
 * @description Helper class for Lead conversion process class LeadDMLOperator
 */
public class LeadConversionActions {
  @TestVisible
  static final String ENTITY_TYPE_INDIVIDUAL = 'Individual';
  /**
   * @description getSuccessConvertedLeads to filter out success lead converted records
   * @param lcResults All list of lead records to be convert
   * @return lcSuccessResults Successful Converted Leads list records
   */
  public List<Database.LeadConvertResult> getSuccessConvertedLeads(
    List<Database.LeadConvertResult> lcResults
  ) {
    List<Database.LeadConvertResult> lcSuccessResults = new List<Database.LeadConvertResult>();
    for (Database.LeadConvertResult lcr : lcResults) {
      if (!lcr.isSuccess()) {
        continue;
      }
      lcSuccessResults.add(lcr);
    }
    return lcSuccessResults;
  }
  /**
   * @description getConvertedLeads to filter out successful leads
   * @param lcResults Lead conversion result
   * @param matchingLeadsByAccIdMap account and lead records map from lead conversion
   * @return convertedLeads leads which are successfully converted
   */
  public List<Lead> getConvertedLeads(
    List<Database.LeadConvertResult> lcResults,
    Map<Id, List<Lead>> matchingLeadsByAccIdMap
  ) {
    List<Lead> convertedLeads = new List<Lead>();
    for (Database.LeadConvertResult lcr : lcResults) {
      convertedLeads.addAll(matchingLeadsByAccIdMap.get(lcr.getAccountId()));
    }
    return convertedLeads;
  }
  /**
   * @description getLeadListForUnicaAdobeOnLC to filter out leads to send to unica and adobe
   * @param convertedLeads Lead records
   * @return leadIdSet lead ids to send to unica and adobe
   */
  public Set<Id> getLeadListForUnicaAdobeOnLC(List<Lead> convertedLeads) {
    Set<Id> leadIdSet = new Set<Id>();
    for (Lead leadRecord : convertedLeads) {
      if (
        CCRMLeadUtil.isCCRMLeadType(leadRecord) ||
        (CCRMLeadUtil.isMLCRMLeadType(leadRecord) &&
        leadRecord.Lead_Originator__c != MLCRMConstants.ORIGINATOR_MLCRM)
      ) {
        leadIdSet.add(leadRecord.id);
      }
    }
    return leadIdSet;
  }
  /**
   * @description getCCRMLeadsMap to filter out leads to send to unica and adobe
   * @param convertedLeads Lead records
   * @return leadMap
   */
  public Map<Id, Lead> getCCRMLeadsMap(List<Lead> convertedLeads) {
    Map<Id, Lead> leadMap = new Map<Id, Lead>();
    for (Lead leadRecord : convertedLeads) {
      if (CCRMLeadUtil.isCCRMLeadType(leadRecord)) {
        leadMap.put(leadRecord.id, leadRecord);
      }
    }
    return leadMap;
  }
  /**
   * @description getDCRMLeadsMap to filter out leads to send to unica and adobe
   * @param convertedLeads Lead records
   * @return leadMap
   */
  public Map<Id, Lead> getDCRMLeadsMap(List<Lead> convertedLeads) {
    Map<Id, Lead> leadMap = new Map<Id, Lead>();
    for (Lead leadRecord : convertedLeads) {
      if (
        CCRMLeadUtil.isMLCRMLeadType(leadRecord) ||
        CCRMLeadUtil.isCCRMLeadType(leadRecord)
      ) {
        leadMap.put(leadRecord.id, leadRecord);
      }
    }
    return leadMap;
  }
  /**
   * @description doesAutoMisMatchTaskRequired to check if auto auto Mismatch task creation is needed
   * @param convertedLeads Lead records
   * @return autoMisMatchTaskRequired
   */
  public Boolean isAutoMisMatchTaskRequired(List<Lead> convertedLeads) {
    for (Lead leadRecord : convertedLeads) {
      if (
        leadRecord.RecordTypeId ==
        QueryRT.of(Lead.getSObjectType()).getId('MLCRM_Lead') ||
        (leadRecord.RecordTypeId ==
        QueryRT.of(Lead.getSObjectType()).getId('CCRM_Lead') &&
        leadRecord.Entity_Type__c == ENTITY_TYPE_INDIVIDUAL)
      ) {
        return true;
      }
    }
    return false;
  }
  /**
   * @description getContactsToDelete to filter out contact to delete
   * @param lcResults Lead conversion result
   * @param mapDCRMLeads leadMap
   * @return contactIds contact list to delete
   */
  public Set<ID> getContactsToDelete(
    List<Database.LeadConvertResult> lcResults,
    Map<Id, Lead> mapDCRMLeads
  ) {
    Set<ID> contactIds = new Set<ID>();
    if (mapDCRMLeads.isEmpty()) {
      return contactIds;
    }
    for (Database.LeadConvertResult lcr : lcResults) {
      if (mapDCRMLeads.containsKey(lcr.getLeadId())) {
        contactIds.add(lcr.getContactId());
      }
    }
    return contactIds;
  }
  /**
   * @description getMapOfAccountIdWithCCRMLead to filter out ccrm leads for transfer A2Z Review To Opportunity
   * @param lcResults Lead conversion result
   * @param mapCCRMLeads leadMap
   * @return mapOfAccountIdWithLead map CCRM lead id with AccountId
   */
  public Map<Id, Id> getMapOfAccountIdWithCCRMLead(
    List<Database.LeadConvertResult> lcResults,
    Map<Id, Lead> mapCCRMLeads
  ) {
    Map<Id, Id> mapOfAccountIdWithLead = new Map<Id, Id>();
    if (mapCCRMLeads.isEmpty()) {
      return mapOfAccountIdWithLead;
    }
    for (Database.LeadConvertResult lcr : lcResults) {
      if (mapCCRMLeads.containsKey(lcr.getLeadId())) {
        mapOfAccountIdWithLead.put(lcr.getLeadId(), lcr.getAccountId());
      }
    }
    return mapOfAccountIdWithLead;
  }
}
