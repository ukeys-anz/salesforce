/**
 * @author Ashish Kumar
 * @since  06/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description MLCRMSharingUtil is class to handle common functionality related to territory sharing.
 */
public with sharing class MLCRMTerritorySharingActions {
  /**
   * @description This method is used to subscribe to territory record
   * @name subscribeTerritoryRecord
   * @param records new list of platform event records
   * @author Ashish Kumar
   * @US CC-1894
   */
  public static void subscribeTerritoryRecord(
    List<Territory_Base_Sharing_Event__e> records
  ) {
    try {
      List<Id> idsOfRecords = new List<Id>();
      String strObjectName;
      //Subscribing to territory share platform event to create share record for objects.
      for (Territory_Base_Sharing_Event__e objTerritorySharing : records) {
        idsOfRecords.addAll(objTerritorySharing.Record_Ids__c.split(';'));
        strObjectName = objTerritorySharing.Trigger_Object__c;
      }
      Territory_Based_Sharing_Config__mdt objTerritoryMtd = MLCRMSharingUtil.getTerritoryRecords(
        strObjectName
      );
      if (!idsOfRecords.isEmpty()) {
        String strQuery =
          'SELECT Id,' +
          String.escapeSingleQuotes(objTerritoryMtd.Territory_Field__c) +
          ',OwnerId FROM ' +
          String.escapeSingleQuotes(strObjectName) +
          ' WHERE ID IN:idsOfRecords';
        //Method to create share record based on territory
        MLCRMSharingUtil.createTerritoryShareRecords(
          Database.query(strQuery),
          objTerritoryMtd.Sharing_Object__c,
          strObjectName
        );
      }
    } catch (Exception ex) {
      //log errors to application log
      CommonUtil.logAndThrowIAE(
        MLCRMTerritorySharingActions.class.getName(),
        'subscribeTerritoryRecord',
        ex.getStackTraceString()
      );
    }
  }
}
