/**
 * @author Ashish Kumar
 * @since  06/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description TerritorySharingActions is class to handle common functionality related to territory sharing.
 */
public with sharing class TerritorySharingActions {
  private static final TerritoryActionsRepository TERRITORY_REPOSITORY = (TerritoryActionsRepository) Lib_InstanceProvider.forType(
    TerritoryActionsRepository.class
  );
  private static final String SOBJECT_LEAD = 'Lead';

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
      for (Territory_Base_Sharing_Event__e eachEvent : records) {
        idsOfRecords.addAll(eachEvent.Record_Ids__c.split(';'));
        strObjectName = eachEvent.Trigger_Object__c;
      }

      if (idsOfRecords.isEmpty()) {
        return;
      }
      Territory_Based_Sharing_Config__mdt objTerritoryMtd = QueryTerritoryBasedSharingConfig.get(
        strObjectName
      );
      String strLookupFields = getLookupFields(objTerritoryMtd);
      String strWhereFilter = getWhereFilter(strObjectName, idsOfRecords);
      List<Sobject> lstOfSobject = TERRITORY_REPOSITORY.getSobjectRecord(
        objTerritoryMtd,
        strLookupFields,
        idsOfRecords,
        strWhereFilter
      );
      createShareRecords(lstOfSobject, objTerritoryMtd);
    } catch (Exception ex) {
      logException('subscribeTerritoryRecord', ex);
    }
  }

  /**
   * @description This method is used to prepare map sobject record to be shared based on scope
   * @name createShareRecords
   * @param lstOfSobject list of sobject records
   * @param objTerritoryMtd territory sharing metadata record
   * @US CC-1894
   */
  @testVisible
  private static void createShareRecords(
    List<Sobject> lstOfSobject,
    Territory_Based_Sharing_Config__mdt objTerritoryMtd
  ) {
    String sharingScope = objTerritoryMtd.Sharing_Scope__c;
    switch on sharingScope {
      when 'Territory' {
        TerritorySharingUtil.createShareRecordsByTerritory(
          lstOfSobject,
          objTerritoryMtd
        );
      }
      when 'Franchise' {
        TerritorySharingUtil.createShareRecordsByFranchise(
          lstOfSobject,
          objTerritoryMtd
        );
      }
      when 'Parent Object' {
        TerritorySharingUtil.createShareRecordsForParentObj(
          lstOfSobject,
          objTerritoryMtd
        );
      }
    }
  }

  /**
   * @description This method is used to lookup field to query if applicable
   * @name getLookupFields
   * @param objTerritoryMtd terrtiory metadaata record
   * @return String String of lookup fields
   * @US CC-1894
   */
  @testVisible
  private static String getLookupFields(
    Territory_Based_Sharing_Config__mdt objTerritoryMtd
  ) {
    if (objTerritoryMtd.Lookup_Fields__c == null) {
      return '';
    }
    return String.join(objTerritoryMtd.Lookup_Fields__c.split(';'), ',') + ',';
  }

  /**
   * @description This method is used to prepare where cluase filter
   * @name getWhereFilter
   * @param eachSobject each sobject name
   * @param idsOfRecords ids of sobject records
   * @return String String of where clause fields
   * @US CC-1894
   */
  @testVisible
  private static String getWhereFilter(
    String eachSobject,
    List<id> idsOfRecords
  ) {
    if (eachSobject == SOBJECT_LEAD) {
      return ' WHERE ID IN:idsOfRecords and status !=\'Expired\'';
    }
    return ' WHERE ID IN:idsOfRecords';
  }

  /**
   * @description This method is used to log exception
   * @name logException
   * @param methodName method name
   * @param ex exception object
   * @US CC-1894
   */
  @testVisible
  private static void logException(String methodName, Exception ex) {
    //log errors to application log
    CommonUtil.logAndThrowIAE(
      TerritorySharingActions.class.getName(),
      methodName,
      ex.getStackTraceString()
    );
  }
}
