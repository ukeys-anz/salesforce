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

  private static final CustomerRelationshipsRepository CR_REPOSITORY = (CustomerRelationshipsRepository) Lib_InstanceProvider.forType(
    CustomerRelationshipsRepository.class
  );

  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final UserInfoRepository USER_INFO_REPO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  private static List<Opportunity> parentOpportunityList = new List<Opportunity>();

  private static final String STR_APPLICANT = 'Applicant';

  /**
   * @description This method is used to set role of ML OCR to Applicant
   * @name defaultRoleForOppContactRole
   * @param records list of OpportunityContactRole sobject records
   * @US CC-10213
   */
  public static void defaultRoleForOppContactRole(
    List<OpportunityContactRole> records
  ) {
    List<OpportunityContactRole> filteredRecords = ListUtil.filter(records)
      .isNull(OpportunityContactRole.Role)
      .toList();
    ListUtil.setField(
      filteredRecords,
      OpportunityContactRole.Role,
      STR_APPLICANT
    );
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
    if (USER_INFO_REPO.checkProfile('System Administrator')) {
      return;
    }
    List<Opportunity> lstOfOpp = getParentOpportunities(oldRecords);
    Map<Id, Opportunity> mapofOpp = (Map<Id, Opportunity>) ListUtil.mapBy(
      lstOfOpp,
      Opportunity.Id
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
    List<OpportunityContactRole> filteredRecords = ListUtil.filter(
        records,
        oldRecordMap
      )
      .changed(OpportunityContactRole.ContactId)
      .toList();
    Set<Id> contactIdSet = ListUtil.getIds(
      filteredRecords,
      OpportunityContactRole.ContactId
    );
    Set<String> duplicateContactKeysSet = getDuplicateContactKeys(contactIdSet);
    List<OpportunityContactRole> errorOCRList = getDuplicateOCRRecords(
      filteredRecords,
      duplicateContactKeysSet
    );
    CommonUtil.raiseSobjectError(errorOCRList, DUPLICATE_OCR_ERROR);
  }

  /**
   * @description This method is used to create/update OCR Sync records whenever OCR is created
   * @name insertOpportunityContactRoleSyncRecords
   * @param newOcrList list of OCR records
   */
  public static void insertOpportunityContactRoleSyncRecords(
    List<OpportunityContactRole> newOcrList
  ) {
    if (OpportunityContactRoleSyncActions.isOCRSync) {
      return;
    }
    Map<Id, OpportunityContactRole> filteredOCRRecordsMap = new Map<Id, OpportunityContactRole>(
      OCR_REPOSITORY.getDetailedOCRRecords(newOcrList)
    );
    List<Opportunity_Contact_Role_Sync__c> ocrSyncList = new List<Opportunity_Contact_Role_Sync__c>();
    for (OpportunityContactRole ocr : newOcrList) {
      ocrSyncList.add(createOcrSyncInstance(filteredOCRRecordsMap.get(ocr.Id)));
    }
    OpportunityContactRoleSyncActions.isOCRSync = true;
    DML.doInsert(
      ocrSyncList,
      new DmlConfig().systemMode().withoutSharing().allowPartial()
    );
  }

  /**
   * @description This method is used to update OCR Sync records whenever OCR is updated
   * @name updateOpportunityContactRoleSyncRecords
   * @param newOcrList list of OCR records
   * @param oldMap map of OCR records
   */
  public static void updateOpportunityContactRoleSyncRecords(
    List<OpportunityContactRole> newOcrList,
    Map<Id, OpportunityContactRole> oldMap
  ) {
    if (OpportunityContactRoleSyncActions.isOCRSync) {
      return;
    }
    Map<Id, OpportunityContactRole> filteredOCRMap = new Map<Id, OpportunityContactRole>(
      (List<OpportunityContactRole>) ListUtil.filter(newOcrList, oldMap)
        .changed(OpportunityContactRole.Role)
        .toList()
    );
    List<Opportunity_Contact_Role_Sync__c> ocrSyncList = OPPORTUNITY_REPOSITORY.getOCRSyncByOCRIds(
      filteredOCRMap.keySet()
    );
    for (Opportunity_Contact_Role_Sync__c ocrSync : ocrSyncList) {
      ocrSync.Role__c = filteredOCRMap.get(ocrSync.OpportunityContactRoleId__c)
        ?.Role;
    }
    OpportunityContactRoleSyncActions.isOCRSync = true;
    DML.doUpdate(ocrSyncList);
  }

  /**
   * @description This method is used to delete OCR Sync records whenever OCR is deleted
   * @name deleteOpportunityContactRoleSyncRecords
   * @param oldOcrList list of OCR records
   */
  public static void deleteOpportunityContactRoleSyncRecords(
    List<OpportunityContactRole> oldOcrList
  ) {
    if (OpportunityContactRoleSyncActions.isOCRSync) {
      return;
    }
    Set<Id> ocrIds = ListUtil.getIds(oldOcrList, OpportunityContactRole.Id);
    List<Opportunity_Contact_Role_Sync__c> ocrSyncListToDelete = OCR_REPOSITORY.getOpportunityContactRoleSyncRecords(
      ocrIds
    );
    OpportunityContactRoleSyncActions.isOCRSync = true;
    DML.doDelete(ocrSyncListToDelete, new DmlConfig().allowPartial());
  }

  /**
   * @description This method is used to return an instance of Opportunity_Contact_Role_Sync__c
   * @name createOcrSyncInstance
   * @param ocr OCR record
   * @return Opportunity_Contact_Role_Sync__c
   */
  @testVisible
  private static Opportunity_Contact_Role_Sync__c createOcrSyncInstance(
    OpportunityContactRole ocr
  ) {
    if (ocr == null) {
      return null;
    }
    Opportunity_Contact_Role_Sync__c ocrSync = new Opportunity_Contact_Role_Sync__c(
      OpportunityId__c = ocr.Opportunity.Loanapp_Reference__c,
      ContactId__c = ocr.Contact.Account.External_Id__c,
      ExternalId__c = String.isNotBlank(ocr.Opportunity.Loanapp_Reference__c)
        ? ocr.ExternalId__c
        : null,
      Role__c = ocr.Role,
      OpportunityContactRoleId__c = ocr.Id
    );
    return ocrSync;
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
    if (!parentOpportunityList.isEmpty()) {
      return parentOpportunityList;
    }
    Set<Id> idsOfOpp = ListUtil.getIds(
      records,
      OpportunityContactRole.OpportunityId
    );
    parentOpportunityList = OPPORTUNITY_REPOSITORY.getOpportunity(idsOfOpp);
    return parentOpportunityList;
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

  /**
   * @description This method is used to auto create CRRs.
   * @param records ocr records
   * @US CC-16047
   */
  public static void createCustomerRelationshipRecords(
    List<OpportunityContactRole> records
  ) {
    List<OpportunityContactRole> insertedRecords = OCR_REPOSITORY.getInsertedOCRs(
      records
    );
    Set<Id> customerIds = OpportunityContactRoleActionsHelper.getCustomerIds(
      insertedRecords
    );
    //query existing customer relationship records.
    List<Customer_Relationship__c> existingCustomerRelationships = CR_REPOSITORY.getCustomerRelationshipByCustomerIds(
      customerIds
    );

    Map<String, Customer_Relationship__c> existingCRRMap = OpportunityActionsHelper.getExistingCRRMap(
      existingCustomerRelationships
    );
    List<Customer_Relationship__c> crrsToInsert = OpportunityContactRoleActionsHelper.insertCustomerRelationships(
      insertedRecords,
      existingCRRMap
    );
    DML.doInsert(
      crrsToInsert,
      new DmlConfig().allowPartial().withoutSharing().systemMode()
    );
  }
  /**
   * @description This method is used to filtered Out ML records
   * @name filteredRecords
   * @param records list of OpportunityContactRole sobject records
   * @return List<OpportunityContactRole>
   */
  public static List<OpportunityContactRole> filteredRecords(
    List<OpportunityContactRole> records
  ) {
    List<Opportunity> oppList = getParentOpportunities(records);
    List<Opportunity> lstOfMLOppty = ListUtil.filter(oppList)
      .equals(Opportunity.RecordTypeId, RTOpportunity.mlOpportunity)
      .toList();
    Set<Id> mlOpptyIdSet = ListUtil.getIds(lstOfMlOppty, Opportunity.Id);
    List<OpportunityContactRole> filteredList = ListUtil.filter(records)
      .equals(OpportunityContactRole.OpportunityId, mlOpptyIdSet)
      .toList();
    return filteredList;
  }
}
