/**
 * @author Ashish Kumar
 * @since  08/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description CustomerRelationNotesTriggerActions is class to handle all the MLCRM (Mobile Lending CRM) Actions
 */
public with sharing class CustomerRelationNotesTriggerActions {
  /**
   * @description This method to update is new flag checkbox to false during implicit update while lead creation
   * @name validatePrimaryRelationshipNotes
   * @param oldMap Map of old map
   * @param records List of customer relationship records
   * @author Ashish Kumar
   * @US CC-2175
   */
  public static void validatePrimaryRelationshipNotes(
    Map<Id, Customer_Relationship__c> oldMap,
    List<Customer_Relationship__c> records
  ) {
    Set<Id> idsOfPrimaryOwner = new Set<Id>();
    Set<Id> idsOfCustomer = new Set<Id>();
    String strNotesPrimaryKey;
    for (Customer_Relationship__c objRelationship : records) {
      if (
        (oldMap == null ||
        (oldMap != null &&
        (oldMap.get(objRelationship.Id).Relationship_To_Franchise__c !=
        objRelationship.Relationship_To_Franchise__c ||
        oldMap.get(objRelationship.Id).OwnerId != objRelationship.OwnerId ||
        oldMap.get(objRelationship.Id).Territory__c !=
        objRelationship.Territory__c)))
      ) {
        idsOfCustomer.add(objRelationship.Customer__c);
      }
    }
    if (!idsOfCustomer.isEmpty()) {
      Map<String, Integer> mapOfPrimaryNotes = new Map<String, Integer>();
      for (Customer_Relationship__c objRelation : [
        SELECT Id, Customer__c, Territory__r.Primary_Franchise_Owner__c
        FROM Customer_Relationship__c
        WHERE
          Customer__c IN :idsOfCustomer
          AND Relationship_To_Franchise__c = 'Primary'
      ]) {
        strNotesPrimaryKey =
          String.valueOf(objRelation.Customer__c) +
          String.valueOf(objRelation.Territory__r.Primary_Franchise_Owner__c);
        if (!mapOfPrimaryNotes.containsKey(strNotesPrimaryKey)) {
          mapOfPrimaryNotes.put(strNotesPrimaryKey, 1);
        } else {
          Integer counter = mapOfPrimaryNotes.get(strNotesPrimaryKey);
          mapOfPrimaryNotes.put(strNotesPrimaryKey, counter + 1);
        }
        if (objRelation.Territory__r.Primary_Franchise_Owner__c != null) {
          idsOfPrimaryOwner.add(
            objRelation.Territory__r.Primary_Franchise_Owner__c
          );
        }
      }

      Map<Id, Territory__c> mapOfTerritory = new Map<Id, Territory__c>(
        [
          SELECT Id, Primary_Franchise_Owner__c
          FROM Territory__c
          WHERE Primary_Franchise_Owner__c IN :idsOfPrimaryOwner
        ]
      );
      for (Customer_Relationship__c objRelationship : records) {
        String strFranchiseOwnerId = mapOfTerritory.get(
            objRelationship.Territory__c
          )
          ?.Primary_Franchise_Owner__c;
        if (
          oldMap == null &&
          strFranchiseOwnerId != null &&
          !mapOfPrimaryNotes.containsKey(
            objRelationship.Customer__c + strFranchiseOwnerId
          )
        ) {
          objRelationship.addError(LABEL.MLCRM_Minimum_Primary_Notes_Error);
        } else if (
          strFranchiseOwnerId != null &&
          mapOfPrimaryNotes.containsKey(
            objRelationship.Customer__c + strFranchiseOwnerId
          ) &&
          mapOfPrimaryNotes.get(
            objRelationship.Customer__c + strFranchiseOwnerId
          ) > 1
        ) {
          objRelationship.addError(LABEL.MLCRM_Maximum_Primary_Notes_Error);
        }
      }
    }
  }

  /**
   * @description public without sharing class to bypass user sharing setting in lead conversion process
   */
  public without sharing class CustomerRelationshipCreator {
    /**
     * @description CC-2175 create CustomerRelationship against shell prospect after receiving response from cap API
     * @name createCustomerRelationship
     * @param shellProspectAccountId shell prospect created after response from cap ocv maintain party API.
     * @param reqRecord source SObject record i.e lead, Opportunity
     */
    public void createCustomerRelationship(
      Id shellProspectAccountId,
      OCVRequestPayloadWrapper reqRecord
    ) {
      ID recordId = ID.valueOf(reqRecord.strRecordId);
      List<SObject> records = new List<SObject>(
        database.query(buildQueryForCRDetails(recordId))
      );

      List<Customer_Relationship__c> lstOfPrimaryNotes = getExistingCustomerRelationships(
        shellProspectAccountId,
        records
      );
      if (!lstOfPrimaryNotes.isEmpty()) {
        return;
      }
      Customer_Relationship__c objRelation = autoCustomerRelationshipCreation(
        shellProspectAccountId,
        reqRecord,
        (ID) records[0].get('Territory__c')
      );
      Database.SaveResult result = Database.insert(objRelation, false);
    }

    /**
     * @description CC-2175 create CustomerRelationship against shell prospect after receiving response from cap API
     * @name getExistingCustomerRelationships
     * @param shellProspectAccountId prospect record id
     * @param records List<Sobject> record
     * @return List<Customer_Relationship__c>
     */
    @TestVisible
    private List<Customer_Relationship__c> getExistingCustomerRelationships(
      Id shellProspectAccountId,
      List<SObject> records
    ) {
      Id strPrimaryOwnerId = (Id) records[0]
        .getSobject('Territory__r')
        ?.get('Primary_Franchise_Owner__c');
      List<Customer_Relationship__c> lstOfPrimaryNotes = [
        SELECT Id
        FROM Customer_Relationship__c
        WHERE
          Relationship_To_Franchise__c = 'Primary'
          AND Territory__r.Primary_Franchise_Owner__c = :strPrimaryOwnerId
          AND Customer__c = :shellProspectAccountId
        LIMIT 1
      ];
      return lstOfPrimaryNotes;
    }

    /**
     * @description CC-2175 create CustomerRelationship against shell prospect after receiving response from cap API
     * @name autoCustomerRelationshipCreation
     * @param shellProspectAccountId propect id
     * @param reqRecord shell prospect created after response from cap ocv maintain party API.
     * @param strTerritoryId territory id
     * @return Customer_Relationship__c
     */
    @TestVisible
    private Customer_Relationship__c autoCustomerRelationshipCreation(
      Id shellProspectAccountId,
      OCVRequestPayloadWrapper reqRecord,
      Id strTerritoryId
    ) {
      Customer_Relationship__c objRelation = new Customer_Relationship__c();
      objRelation.Preferred_Name__c =
        reqRecord?.strFirstName +
        ' ' +
        reqRecord?.strLastName;
      if (!String.isBlank(reqRecord.strMiddleName)) {
        objRelation.Preferred_Name__c += ' ' + reqRecord.strMiddleName;
      }
      objRelation.Customer__c = shellProspectAccountId;
      objRelation.Territory__c = strTerritoryId;
      objRelation.OwnerId = reqRecord.strOwnerId;
      objRelation.Relationship_To_Franchise__c = MLCRMConstants.PRIMARY;
      objRelation.Date_Relationship_Commenced__c = System.today();
      return objRelation;
    }
  }

  /**
   * @description CC-2175 create CustomerRelationship against shell prospect after receiving response from cap API
   * @name buildQueryForCRDetails
   * @param recordId sobject recordId from where we need to get territory details
   * @return String
   */
  @TestVisible
  private static String buildQueryForCRDetails(Id recordId) {
    String recordQuery = 'Select Id, Territory__c,Territory__r.Primary_Franchise_Owner__c From ';
    if (
      recordId.getSObjectType().getDescribe().getName() ==
      MLCRMConstants.SOBJECT_LEAD
    ) {
      recordQuery += 'Lead WHERE Id = :recordId AND Territory__r.Primary_Franchise_Owner__c != null';
    } else if (
      recordId.getSObjectType().getDescribe().getName() ==
      MLCRMConstants.SOBJECT_OPPORTUNITY
    ) {
      recordQuery += 'Opportunity WHERE Id = :recordId AND Territory__r.Primary_Franchise_Owner__c != null';
    }
    return recordQuery;
  }
}
