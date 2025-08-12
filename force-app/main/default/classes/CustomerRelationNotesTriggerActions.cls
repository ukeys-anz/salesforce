/**
 * @author Ashish Kumar
 * @since  08/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description CustomerRelationNotesTriggerActions is class to handle all the MLCRM (Mobile Lending CRM) Actions
 */
public with sharing class CustomerRelationNotesTriggerActions {
  private static final String RELATIONSHIP_TO_FRANCHISE = 'Primary';

  private static final CustomerRelationshipsRepository CUSTOMER_RELATIONSHIP_REPOSITORY = (CustomerRelationshipsRepository) Lib_InstanceProvider.forType(
    CustomerRelationshipsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final AccountActionsRepository ACCOUNT_REPOSITORY = (AccountActionsRepository) Lib_InstanceProvider.forType(
    AccountActionsRepository.class
  );
  private static final Set<SObjectField> CUSTOMER_FIELDS = new Set<SObjectField>{
    Account.FirstName,
    Account.MiddleName,
    Account.LastName,
    Account.Salutation,
    Account.Suffix
  };
  private static final Set<SObjectField> CUSTOMER_RELATIONSHIP_FIELDS = new Set<SObjectField>{
    Customer_Relationship__c.Relationship_To_Franchise__c,
    Customer_Relationship__c.OwnerId,
    Customer_Relationship__c.Territory__c
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
    List<Customer_Relationship__c> custRelRecords = ListUtil.filter(
        records,
        oldMap
      )
      .anyChanged(CUSTOMER_RELATIONSHIP_FIELDS)
      .toList();
    Set<Id> idsOfCustomer = ListUtil.getIds(
      custRelRecords,
      Customer_Relationship__c.Customer__c
    );
    Set<Id> idsOfPrimaryOwner = new Set<Id>();
    Map<String, Integer> mapOfPrimaryNotes = new Map<String, Integer>();
    for (
      Customer_Relationship__c objRelation : CUSTOMER_RELATIONSHIP_REPOSITORY.getCustomerRelationshipByCustomerIds(
        idsOfCustomer
      )
    ) {
      String strNotesPrimaryKey =
        String.valueOf(objRelation.Customer__c) +
        String.valueOf(objRelation.Territory__r.Primary_Franchise_Owner__c);

      mapOfPrimaryNotes.put(
        strNotesPrimaryKey,
        (mapOfPrimaryNotes.get(strNotesPrimaryKey) ?? 0) + 1
      );

      if (objRelation.Territory__r.Primary_Franchise_Owner__c == null) {
        continue;
      }
      idsOfPrimaryOwner.add(
        objRelation.Territory__r.Primary_Franchise_Owner__c
      );
    }

    Map<Id, Territory__c> mapOfTerritory = CUSTOMER_RELATIONSHIP_REPOSITORY.getTerritoriesbyPrimaryFranchiseOwnerIds(
      idsOfPrimaryOwner
    );

    for (Customer_Relationship__c objRelationship : records) {
      String strFranchiseOwnerId = mapOfTerritory.get(
          objRelationship.Territory__c
        )
        ?.Primary_Franchise_Owner__c;
      if (strFranchiseOwnerId == null) {
        continue;
      }

      Integer counter = mapOfPrimaryNotes.get(
        objRelationship.Customer__c + strFranchiseOwnerId
      ) ?? 0;
      if (oldMap == null && counter < 1) {
        objRelationship.addError(LABEL.Minimum_Primary_Notes_Error);
      } else if (counter > 1) {
        objRelationship.addError(LABEL.Maximum_Primary_Notes_Error);
      }
    }
  }

  /**
   * @description CC-2175 create CustomerRelationship against shell prospect after receiving response from cap API
   * @name createCustomerRelationship
   * @param shellProspectAccountId shell prospect created after response from cap ocv maintain party API.
   * @param reqRecord source SObject record i.e lead, Opportunity
   */
  public static void createCustomerRelationship(
    Id shellProspectAccountId,
    OCVRequestPayloadWrapper reqRecord
  ) {
    ID recordId = ID.valueOf(reqRecord.strRecordId);
    List<SObject> records = CUSTOMER_RELATIONSHIP_REPOSITORY.getCRDetails(
      recordId
    );
    Customer_Relationship__c primaryNote = getExistingCustomerRelationships(
      shellProspectAccountId,
      records
    );
    if (primaryNote != null) {
      return;
    }
    Customer_Relationship__c objRelation = autoCustomerRelationshipCreation(
      shellProspectAccountId,
      reqRecord,
      (ID) records[0].get('Territory__c')
    );
    DML_REPOSITORY.doInsert(
      objRelation,
      new DmlConfig().allowPartial().withoutSharing().systemMode()
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
  private static Customer_Relationship__c getExistingCustomerRelationships(
    Id shellProspectAccountId,
    List<SObject> records
  ) {
    if (records.isEmpty()) {
      return null;
    }
    Id strPrimaryOwnerId = (Id) records[0]
      .getSobject('Territory__r')
      ?.get('Primary_Franchise_Owner__c');
    List<Customer_Relationship__c> lstprimaryNote = CUSTOMER_RELATIONSHIP_REPOSITORY.getCustRelationshipIdofShellProspectAccount(
      strPrimaryOwnerId,
      shellProspectAccountId
    );
    if (lstprimaryNote.isEmpty()) {
      return null;
    }
    return lstprimaryNote[0];
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
  private static Customer_Relationship__c autoCustomerRelationshipCreation(
    Id shellProspectAccountId,
    OCVRequestPayloadWrapper reqRecord,
    Id strTerritoryId
  ) {
    Customer_Relationship__c objRelation = new Customer_Relationship__c();
    List<String> lstOfPreferredName = new List<String>();
    if (reqRecord.strFirstName != null) {
      lstOfPreferredName.add(reqRecord.strFirstName);
    }
    if (reqRecord.strMiddleName != null) {
      lstOfPreferredName.add(reqRecord.strMiddleName);
    }
    lstOfPreferredName.add(reqRecord.strLastName);
    objRelation.Preferred_Name__c = String.join(lstOfPreferredName, ' ');
    objRelation.Customer__c = shellProspectAccountId;
    objRelation.Territory__c = strTerritoryId;
    objRelation.OwnerId = reqRecord.strOwnerId;
    objRelation.Relationship_To_Franchise__c = RELATIONSHIP_TO_FRANCHISE;
    objRelation.Date_Relationship_Commenced__c = System.today();
    return objRelation;
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
    List<Customer_Relationship__c> filteredRecords = ListUtil.filter(
        records,
        oldMap
      )
      .changed(Customer_Relationship__c.Customer__c)
      .toList();
    set<Id> accIdsSet = ListUtil.getIds(
      filteredRecords,
      Customer_Relationship__c.Customer__c
    );
    Map<Id, Account> mapOfAccount = ACCOUNT_REPOSITORY.getAccountByIds(
      accIdsSet
    );
    for (Customer_Relationship__c obj : filteredRecords) {
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
      new DmlConfig().allowPartial().withoutSharing().systemMode()
    );
  }
}
