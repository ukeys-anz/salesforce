/**
 * @author Ashish Kumar
 * @since  08/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description CustomerRelationNotesTriggerActions is class to handle all the MLCRM (Mobile Lending CRM) Actions
 */
public with sharing class CustomerRelationNotesTriggerActions {
  private static final CustomerRelationshipsRepository CUSTOMER_RELATIONSHIP_REPOSITORY = (CustomerRelationshipsRepository) Lib_InstanceProvider.forType(
    CustomerRelationshipsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final AccountActionsRepository ACCOUNT_REPOSITORY = (AccountActionsRepository) Lib_InstanceProvider.forType(
    AccountActionsRepository.class
  );
  private static final Set<SObjectField> CUSTOMER_RELATIONSHIP_FIELDS = new Set<SObjectField>{
    Account.FirstName,
    Account.MiddleName,
    Account.LastName,
    Account.Salutation,
    Account.Suffix
  };

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
      DML_REPOSITORY.doInsert(
        objRelation,
        new DmlConfig().allowPartial().systemMode()
      );
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

  /**
   * @description Update Customer_Name__c field on Customer_Relationship__c object
   * @name updateCustomerName
   * @param oldMap A Map of Customer_Relationship__c records.
   * @param records list Customer_Relationship__c records.
   */
  public static void updateCustomerName(
    Map<id, Customer_Relationship__c> oldMap,
    List<Customer_Relationship__c> records
  ) {
    List<Customer_Relationship__c> listOfSobjects = ListUtil.filter(records, oldMap)
        .changed(Customer_Relationship__c.Customer__c)
        .toList();
    set<Id> accIdsSet = ListUtil.getIds(
      listOfSobjects,
      Customer_Relationship__c.Customer__c
    );
    Map<Id, Account> mapOfAccount = ACCOUNT_REPOSITORY.getAccountByIds(
      accIdsSet
    );
    for (Customer_Relationship__c obj : listOfSobjects) {
      if (mapOfAccount.get(obj.Customer__c) == null) {
        obj.Customer_Name__c = '';
        continue;
      }
      obj.Customer_Name__c =
        mapOfAccount.get(obj.Customer__c).Salutation +
        ' ' +
        mapOfAccount.get(obj.Customer__c).Name;
    }
  }
  /**
   * @description get set of updated customer's id's who specific fields got updated
   * @name getUpdatedCustomersIds
   * @param oldMap A Map of AccountId and Account.
   * @param records list of updated Account records.
   */
  public static void getUpdatedCustomersIds(
    Map<Id, Account> oldMap,
    List<Account> records
  ) {
    if (System.isFuture() || System.isBatch()) {
      return;
    }
    List<Account> listOfSobjects = ListUtil.filter(records, oldMap)
      .equals(Account.RecordTypeId, RTAccount.personAccount)
      .anyChanged(CUSTOMER_RELATIONSHIP_FIELDS)
      .toList();

    Set<id> setOfAccountIds = ListUtil.getIds(
      listOfSobjects,
      Customer_Relationship__c.Customer__r.Id
    );
    if (setOfAccountIds.isEmpty()) { 
      return;
    }
    updateCustomerNameOnCustomerRelationship(setOfAccountIds);
  }
  /**
   * @description Executes asynchronously to update Customer_Name__c field on Customer_Relationship__c object
   * @name updateCustomerNameOnCustomerRelationship
   * @param setOfAccountIds set of accountIds.
   */
  @future
  public static void updateCustomerNameOnCustomerRelationship(
    Set<id> setOfAccountIds
  ) {
    List<Customer_Relationship__c> listOfCustomerRelationship = CUSTOMER_RELATIONSHIP_REPOSITORY.getCustomerRelationshipByAccountIds(
      setOfAccountIds
    );
    for (
      Customer_Relationship__c customerRelationship : listOfCustomerRelationship
    ) {
      customerRelationship.Customer_Name__c =
        customerRelationship.Customer__r.Salutation +
        ' ' +
        customerRelationship.Customer__r.Name;
    }
    DML_REPOSITORY.doUpdate(
      listOfCustomerRelationship,
      new DmlConfig().allowPartial().systemMode()
    );
  }
}