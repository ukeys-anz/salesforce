/**
 * @author MLCRM Developer
 * @since  14/October/2024
 * @description OpportunityContactRoleActions is class to handle all the MLCRM Opportunity Actions
 */
public with sharing class OpportunityContactRoleActions {
  public static final String INSUFFICIENT_ERROR_MESSAGE = 'You don\'t have sufficient privileges to delete this record. Please contact system administrator';
  public static final String DUPLICATE_OCR_ERROR = 'Opportunity Contact Role for the same customer already exists';
  private static final OpportunityActionsRepository OPPORTUNITY_REPOSITORY = (OpportunityActionsRepository) Lib_InstanceProvider.forType(
    OpportunityActionsRepository.class
  );
  private static final OpportunityContactRoleActionsRepository OCR_REPOSITORY = (OpportunityContactRoleActionsRepository) Lib_InstanceProvider.forType(
    OpportunityContactRoleActionsRepository.class
  );
  private static final String STR_APPLICANT = 'Applicant';

  /**
   * @description This method is used to set role of ML OCR to Applicant
   * @name defaultRoleForMlOppContactRole
   * @param records list of OpportunityContactRole sobject records
   * @US CC-10213
   */
  public static void defaultRoleForMlOppContactRole(
    List<OpportunityContactRole> records
  ) {
    List<Opportunity> oppList = getParentOpportunities(records);
    List<Opportunity> lstOfMlOppty = ListUtil.filter(oppList)
      .equals(Opportunity.RecordTypeId, RTOpportunity.mlOpportunity)
      .toList();
    if (lstOfMlOppty.isEmpty()) {
      return;
    }
    Set<Id> mlOpptyIdSet = ListUtil.getIds(lstOfMlOppty, Opportunity.Id);
    defaultOCRRole(mlOpptyIdSet, records);
  }

  /**
   * @description This method is used to set role of ML OCR to Applicant
   * @name defaultOCRRole
   * @param mlOpptyIdSet set of Opportunity sobject ids
   * @param records list of OpportunityContactRole sobject records
   * @US CC-10213
   */
  @testVisible
  private static void defaultOCRRole(
    Set<Id> mlOpptyIdSet,
    List<OpportunityContactRole> records
  ) {
    for (OpportunityContactRole objRole : records) {
      if (
        mlOpptyIdSet.contains(objRole.opportunityId) && objRole.Role == null
      ) {
        objRole.Role = STR_APPLICANT;
      }
    }
  }

  /**
   * @description This method is used to prevent deletion of primary applicant opportunitycontactrole record
   * @name restrictApplicantDeletion
   * @param oldRecords list of Opportunity sobject records
   * @US CC-10214
   */
  public static void restrictApplicantDeletion(
    List<OpportunityContactRole> oldRecords
  ) {
    if (UserInfo.getProfileId() == QueryProfile.systemAdmin.Id) {
      return;
    }
    List<Opportunity> lstOfOpp = getParentOpportunities(oldRecords);
    List<Opportunity> lstOfMlOppty = ListUtil.filter(lstOfOpp)
      .equals(Opportunity.RecordTypeId, RTOpportunity.mlOpportunity)
      .toList();
    if (lstOfMlOppty.isEmpty()) {
      return;
    }

    Map<Id, Opportunity> mapofOpp = (Map<Id, Opportunity>) ListUtil.mapBy(
      lstOfOpp,
      Opportunity.Id.getDescribe().getSObjectField()
    );

    List<OpportunityContactRole> lstOfContactRole = filterPrimaryApplicant(
      oldRecords,
      mapofOpp
    );
    CommonUtil.raiseSobjectError(lstOfContactRole, INSUFFICIENT_ERROR_MESSAGE);
  }

  /**
   * @description This method is used to filter primary applicant record
   * @name filterPrimaryApplicant
   * @param oldRecords list of Opportunity sobject records
   * @param mapofOpp map of Opportunity sobject records
   * @return List<OpportunityContactRole> list of Opportunity contact role sobject records
   * @US CC-10214
   */
  @testVisible
  private static List<OpportunityContactRole> filterPrimaryApplicant(
    List<OpportunityContactRole> oldRecords,
    Map<Id, Opportunity> mapofOpp
  ) {
    List<OpportunityContactRole> lstOfContactRole = new List<OpportunityContactRole>();
    for (OpportunityContactRole objContactRole : oldRecords) {
      if (
        mapOfOpp.containsKey(objContactRole.opportunityId) &&
        objContactRole.contactId ==
        mapOfOpp.get(objContactRole.opportunityId).Account.personcontactId &&
        mapofOpp.get(objContactRole.opportunityId).recordTypeId ==
        RTOpportunity.mlOpportunity
      ) {
        lstOfContactRole.add(objContactRole);
      }
    }
    return lstOfContactRole;
  }

  /**
   * @description This method is used to restrict creation of duplicate oCR record.
   * @name preventDuplicateOpportunityContactRole
   * @param records list of OCR records
   * @param oldRecordMap map of old OCR sobject records
   * @US CC-10219
   */
  public static void preventDuplicateOpportunityContactRole(
    List<OpportunityContactRole> records,
    Map<Id, OpportunityContactRole> oldRecordMap
  ) {
    List<Opportunity> oppList = getParentOpportunities(records);
    Map<Id, Opportunity> mapofOpp = (Map<Id, Opportunity>) ListUtil.mapBy(
      oppList,
      Opportunity.Id.getDescribe().getSObjectField()
    );
    List<OpportunityContactRole> ocrList = getFilteredMLOCRRecords(
      records,
      oldRecordMap,
      mapOfOpp
    );
    Set<Id> contactIdSet = ListUtil.getIds(
      ocrList,
      OpportunityContactRole.ContactId
    );
    Set<String> duplicateContactKeysSet = getDuplicateContactKeys(contactIdSet);
    List<OpportunityContactRole> errorOCRList = getDuplicateOCRRecords(
      ocrList,
      duplicateContactKeysSet
    );
    CommonUtil.raiseSobjectError(errorOCRList, DUPLICATE_OCR_ERROR);
  }

  /**
   * @description This method is used to get duplicate OCR records.
   * @name getDuplicateOCRRecords
   * @param ocrList filtered list of OCR records
   * @param duplicateContactKeysSet set of duplicate contact ids
   * @return List<OpportunityContactRole>
   * @US CC-10219
   */
  @testvisible
  private static List<OpportunityContactRole> getDuplicateOCRRecords(
    List<OpportunityContactRole> ocrList,
    Set<String> duplicateContactKeysSet
  ) {
    List<OpportunityContactRole> errorOCRList = new List<OpportunityContactRole>();
    for (OpportunityContactRole ocr : ocrList) {
      if (
        !duplicateContactKeysSet.contains(
          ocr.OpportunityId + '-' + ocr.ContactId
        )
      ) {
        duplicateContactKeysSet.add(ocr.OpportunityId + '-' + ocr.ContactId);
        continue;
      }
      errorOCRList.add(ocr);
    }
    return errorOCRList;
  }

  /**
   * @description This method is used to get filtered OCR records based on recordtype of opportunity
   * @name getFilteredMLOCRRecords
   * @param records ocr records
   * @param oldRecordMap old map
   * @param mapOfOpp map of parent opportunities
   * @return List<OpportunityContactRole>
   * @US CC-10219
   */
  @testVisible
  private static List<OpportunityContactRole> getFilteredMLOCRRecords(
    List<OpportunityContactRole> records,
    Map<Id, OpportunityContactRole> oldRecordMap,
    Map<Id, Opportunity> mapOfOpp
  ) {
    List<OpportunityContactRole> mlcrmOCRList = new List<OpportunityContactRole>();
    for (OpportunityContactRole ocr : records) {
      Opportunity parentOpp = mapOfOpp.get(ocr.OpportunityId);
      if (parentOpp?.RecordTypeId != RTOpportunity.mlOpportunity) {
        continue;
      }
      mlcrmOCRList.add(ocr);
    }
    if (oldRecordMap == null) {
      return mlcrmOCRList;
    }
    return ListUtil.filter(mlcrmOCRList, oldRecordMap)
      .changed(OpportunityContactRole.ContactId)
      .toList();
  }

  /**
   * @description This method is used extract list of parent opportunities
   * @name getParentOpportunities
   * @param records ocr records
   * @return List<Opportunity>
   * @US CC-10219
   */
  @testVisible
  private static List<Opportunity> getParentOpportunities(
    List<OpportunityContactRole> records
  ) {
    Set<Id> idsOfOpp = ListUtil.getIds(
      records,
      OpportunityContactRole.OpportunityId.getDescribe().getSObjectField()
    );
    List<Opportunity> lstOfOpp = OPPORTUNITY_REPOSITORY.getOpportunity(
      idsOfOpp
    );
    return lstOfOpp;
  }

  /**
   * @description This method is used to get duplicate contact Ids.
   * @name getDuplicateContactKeys
   * @param contactIdSet ocr records
   * @return Set<Id>
   * @US CC-10219
   */
  @testvisible
  private static Set<String> getDuplicateContactKeys(Set<Id> contactIdSet) {
    List<OpportunityContactRole> duplicateOCRList = OCR_REPOSITORY.getOppContactRoleByContacts(
      contactIdSet
    );
    Set<String> duplicateContactKeysSet = new Set<String>();
    for (OpportunityContactRole ocr : duplicateOCRList) {
      duplicateContactKeysSet.add(ocr.OpportunityId + '-' + ocr.ContactId);
    }
    return duplicateContactKeysSet;
  }
}
