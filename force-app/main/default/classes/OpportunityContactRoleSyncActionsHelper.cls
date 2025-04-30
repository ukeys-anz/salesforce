/**
 * @author Ashwin Mohan
 * @since  04/2025
 * @description OpportunityContactRoleSyncActionsHelper is helper class for OpportunityContactRoleSyncActions.
 */
public with sharing class OpportunityContactRoleSyncActionsHelper {
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final OCRSyncActionsRepository OCRSYNCACTIONS_REPOSITORY = (OCRSyncActionsRepository) Lib_InstanceProvider.forType(
    OCRSyncActionsRepository.class
  );

  /**
   * @description create OCR Records based on OCR Sync
   * @name createOCRRecords
   * @param ocrSyncRecords list of OCR Sync records
   * @return Set<Id> created OCR Record Id Set
   */
  public static Set<Id> createOCRRecords(
    List<Opportunity_Contact_Role_Sync__c> ocrSyncRecords
  ) {
    List<OpportunityContactRole> ocrRecordsToCreate = new List<OpportunityContactRole>();
    Set<Id> ocrIdSet = new Set<Id>();
    Map<String, Opportunity> mapOfOppByLoanAppRef = getOpportunityMapByLoanAppRef(
      ocrSyncRecords
    );
    Map<String, Account> mapOfCustomerByCapId = getCustomerMapByCapId(
      ocrSyncRecords
    );
    for (Opportunity_Contact_Role_Sync__c ocrSyncRec : ocrSyncRecords) {
      ocrRecordsToCreate.add(
        new OpportunityContactRole(
          Role = ocrSyncRec.Role__c,
          OpportunityId = mapOfOppByLoanAppRef.get(ocrSyncRec.OpportunityId__c)
            ?.Id,
          ContactId = mapOfCustomerByCapId.get(ocrSyncRec.ContactId__c)
            ?.PersonContactId
        )
      );
    }
    OpportunityContactRoleSyncActions.isOCRSync = true;
    List<Database.SaveResult> results = DML.doInsert(
      ocrRecordsToCreate,
      new DmlConfig().allowPartial().withoutSharing()
    );
    // for Test
    if (results == null) {
      return new Set<Id>();
    }
    for (Database.SaveResult sr : results) {
      if (!sr.isSuccess()) {
        continue;
      }
      ocrIdSet.add(sr.getId());
    }
    return ocrIdSet;
  }

  /**
   * @description to get opportunity by loan app reference stamped in OCR Sync record
   * @name getOpportunityMapByLoanAppRef
   * @param ocrSyncRecords list of OCR Sync records
   * @return Map<String, Opportunity>
   */
  private static Map<String, Opportunity> getOpportunityMapByLoanAppRef(
    List<Opportunity_Contact_Role_Sync__c> ocrSyncRecords
  ) {
    Set<String> loanAppRefSet = ListUtil.getStrings(
      ocrSyncRecords,
      Opportunity_Contact_Role_Sync__c.OpportunityId__c
    );
    List<Opportunity> oppList = OCRSYNCACTIONS_REPOSITORY.getOpportunityFromLoanAppRef(
      loanAppRefSet
    );
    return (Map<String, Opportunity>) ListUtil.mapBy(
      oppList,
      Opportunity.Loanapp_Reference__c
    );
  }

  /**
   * @description to get customer by CAP External Id stamped in OCR Sync record
   * @name getCustomerMapByCapId
   * @param ocrSyncRecords list of OCR Sync records
   * @return Map<String, Account>
   */
  private static Map<String, Account> getCustomerMapByCapId(
    List<Opportunity_Contact_Role_Sync__c> ocrSyncRecords
  ) {
    Set<String> capIdSet = ListUtil.getStrings(
      ocrSyncRecords,
      Opportunity_Contact_Role_Sync__c.ContactId__c
    );
    List<Account> customerList = OCRSYNCACTIONS_REPOSITORY.getCustomerFromCapId(
      capIdSet
    );
    return (Map<String, Account>) ListUtil.mapBy(
      customerList,
      Account.External_Id__c
    );
  }

  /**
   * @description populate the created OCR Id in OCR Sync Record
   * @name populateOCRIdInOCRSync
   * @param ocrIdSet set of OCR Record Ids
   * @param ocrSyncRecords list of OCR Sync Records
   */
  public static void populateOCRIdInOCRSync(
    Set<Id> ocrIdSet,
    List<Opportunity_Contact_Role_Sync__c> ocrSyncRecords
  ) {
    List<Opportunity_Contact_Role_Sync__c> ocrSyncRecsToUpdate = new List<Opportunity_Contact_Role_Sync__c>();
    if (ocrIdSet.isEmpty()) {
      return;
    }
    Map<String, OpportunityContactRole> mapOfOCRByExternalId = (Map<String, OpportunityContactRole>) ListUtil.mapBy(
      OCRSYNCACTIONS_REPOSITORY.getOpportunityContactRoles(ocrIdSet),
      OpportunityContactRole.ExternalId__c
    );
    for (Opportunity_Contact_Role_Sync__c ocrSyncRec : ocrSyncRecords) {
      Opportunity_Contact_Role_Sync__c ocrSyncRecToUpdate = new Opportunity_Contact_Role_Sync__c(
        Id = ocrSyncRec.Id,
        OpportunityContactRoleId__c = mapOfOCRByExternalId.get(
            ocrSyncRec.ExternalId__c
          )
          ?.Id
      );
      ocrSyncRecsToUpdate.add(ocrSyncRecToUpdate);
    }
    OpportunityContactRoleSyncActions.isOCRSync = true;
    DML.doUpdate(ocrSyncRecsToUpdate, new DmlConfig().allowPartial());
  }

  /**
   * @description update OCR Records based on OCR Sync Records
   * @name updateOCRRecords
   * @param ocrSyncRecords list of OCR Sync records
   */
  public static void updateOCRRecords(
    List<Opportunity_Contact_Role_Sync__c> ocrSyncRecords
  ) {
    List<OpportunityContactRole> ocrRecordsToUpdate = new List<OpportunityContactRole>();
    for (Opportunity_Contact_Role_Sync__c ocrSyncRec : ocrSyncRecords) {
      ocrRecordsToUpdate.add(
        new OpportunityContactRole(
          Id = (Id) ocrSyncRec.OpportunityContactRoleId__c,
          Role = ocrSyncRec.Role__c
        )
      );
    }
    OpportunityContactRoleSyncActions.isOCRSync = true;
    DML.doUpdate(
      ocrRecordsToUpdate,
      new DmlConfig().allowPartial().withoutSharing()
    );
  }

  /**
   * @description delete OCR Records if OCR Sync Records are Deleted
   * @name deleteOCRRecords
   * @param ocrSyncRecords list of OCR Sync records
   */
  public static void deleteOCRRecords(
    List<Opportunity_Contact_Role_Sync__c> ocrSyncRecords
  ) {
    List<OpportunityContactRole> ocrRecordsToDelete = new List<OpportunityContactRole>();
    for (Opportunity_Contact_Role_Sync__c ocrSyncRec : ocrSyncRecords) {
      ocrRecordsToDelete.add(
        new OpportunityContactRole(
          Id = (Id) ocrSyncRec.OpportunityContactRoleId__c
        )
      );
    }
    OpportunityContactRoleSyncActions.isOCRSync = true;
    DML.doDelete(
      ocrRecordsToDelete,
      new DmlConfig().allowPartial().withoutSharing()
    );
  }
}
