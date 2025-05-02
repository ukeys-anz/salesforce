/**
 * @author Ashwin Mohan
 * @since  04/25
 * @description OpportunityContactRoleSyncActions is class to handle all the Opportunity_Contact_Role_Sync__c Object Trigger Actions.
 */
public with sharing class OpportunityContactRoleSyncActions {
  public static Boolean isOCRSync = false;

  /**
   * @description insert OCR Records based on OCR Sync
   * @name insertOCRRecords
   * @param ocrSyncRecords list of OCR Sync records
   */
  public static void insertOCRRecords(
    List<Opportunity_Contact_Role_Sync__c> ocrSyncRecords
  ) {
    if (isOCRSync) {
      return;
    }
    List<Opportunity_Contact_Role_Sync__c> filteredOCRSyncRecords = ListUtil.filter(
        ocrSyncRecords
      )
      .isNull(Opportunity_Contact_Role_Sync__c.OpportunityContactRoleId__c)
      .toList();
    Set<Id> createdOcrIdSet = OpportunityContactRoleSyncActionsHelper.createOCRRecords(
      filteredOCRSyncRecords
    );
    OpportunityContactRoleSyncActionsHelper.populateOCRIdInOCRSync(
      createdOcrIdSet,
      filteredOCRSyncRecords
    );
  }

  /**
   * @description update OCR Records based on OCR Sync
   * @name updateOCRRecords
   * @param ocrSyncRecords list of OCR Sync records
   * @param oldMap oldmap
   */
  public static void updateOCRRecords(
    List<Opportunity_Contact_Role_Sync__c> ocrSyncRecords,
    Map<Id, Opportunity_Contact_Role_Sync__c> oldMap
  ) {
    if (isOCRSync) {
      return;
    }
    List<Opportunity_Contact_Role_Sync__c> filteredOCRSyncRecords = ListUtil.filter(
        ocrSyncRecords,
        oldMap
      )
      .isNotNull(Opportunity_Contact_Role_Sync__c.OpportunityContactRoleId__c)
      .changed(Opportunity_Contact_Role_Sync__c.Role__c)
      .toList();
    OpportunityContactRoleSyncActionsHelper.updateOCRRecords(
      filteredOCRSyncRecords
    );
  }

  /**
   * @description delete OCR Records based on OCR Sync
   * @name deleteOCRRecords
   * @param ocrSyncRecords list of OCR Sync records
   */
  public static void deleteOCRRecords(
    List<Opportunity_Contact_Role_Sync__c> ocrSyncRecords
  ) {
    if (isOCRSync) {
      return;
    }
    List<Opportunity_Contact_Role_Sync__c> filteredOCRSyncRecords = ListUtil.filter(
        ocrSyncRecords
      )
      .isNotNull(Opportunity_Contact_Role_Sync__c.OpportunityContactRoleId__c)
      .toList();
    OpportunityContactRoleSyncActionsHelper.deleteOCRRecords(
      filteredOCRSyncRecords
    );
  }
}
