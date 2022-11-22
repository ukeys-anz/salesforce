/**
 * @author Sreekanth Dadipineni
 * @since 09/2022
 * @description CCRMContactPointAddressActions related to handling ContactPointAddressActions object.
 * @runTests CCRMContactPointAddressActionsTest
 */

public with sharing class CCRMContactPointAddressActions {
  private static final String ADDRESS_EXISTS_ERROR = 'An address record is already available for {0}. Please edit the address below.';

  /**
   * @description Copy ParentId to Customer_Name__c field.
   * @name copyParentIdToCustomerName
   * @param records from the trigger
   */
  public static void copyParentIdToCustomerName(
    List<ContactPointAddress> records
  ) {
    for (ContactPointAddress record : records) {
      if (record.ParentId != null && record.Customer_Name__c == null) {
        record.Customer_Name__c = record.ParentId;
      }
    }
  }

  /**
   * @description Unlink parent prospect account when ActiveToDate value is set
   * @name unlinkProspectParentOnDeactivation
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in beforeUpdate.
   */
  public static void unlinkProspectParentOnDeactivation(
    List<ContactPointAddress> records,
    Map<Id, ContactPointAddress> oldMap
  ) {
    for (ContactPointAddress cpa : records) {
      if (oldMap.get(cpa.id).ActiveToDate == null && cpa.ActiveToDate != null) {
        cpa.ParentId = null;
      }
    }
  }

  /**
   * @description extract from a list of ContactPointAddress and return the records that are linked to prospect accounts
   * @param records the list of ContactPointAddress to check if they're belonged to prospect accounts
   * @return list of records that are linked to prospect accounts
   */
  public static List<ContactPointAddress> extractProspectCpa(
    List<ContactPointAddress> records
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (ContactPointAddress record : records) {
      if (record.Customer_Name__c != null) {
        accountIds.add(record.Customer_Name__c);
      }
    }

    Set<Id> prospectIds = CCRMAccountActions.extractProspectIds(accountIds);

    List<ContactPointAddress> results = new List<ContactPointAddress>();
    for (ContactPointAddress record : records) {
      if (prospectIds.contains(record.Customer_Name__c)) {
        results.add(record);
      }
    }

    return results;
  }

  /**
   * @description make sure Banker should only be able to add a new address if there is no existing address available for selected address type
   * @param records the list of records to check
   */
  public static void checkExistingAddressOnProspect(
    List<ContactPointAddress> records
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (ContactPointAddress record : records) {
      if (record.Customer_Name__c != null) {
        accountIds.add(record.Customer_Name__c);
      }
    }

    Map<Id, Set<String>> mapAccountIdToAddressTypes = new Map<Id, Set<String>>();
    for (ContactPointAddress record : [
      SELECT Id, Customer_Name__c, AddressType
      FROM ContactPointAddress
      WHERE
        Customer_Name__c IN :accountIds
        AND ActiveToDate = NULL
        AND Customer_Name__r.Is_Prospect__c = TRUE
      WITH SECURITY_ENFORCED
    ]) {
      if (mapAccountIdToAddressTypes.containsKey(record.Customer_Name__c)) {
        mapAccountIdToAddressTypes.get(record.Customer_Name__c)
          .add(record.AddressType);
      } else {
        mapAccountIdToAddressTypes.put(
          record.Customer_Name__c,
          new Set<String>{ record.AddressType }
        );
      }
    }

    for (ContactPointAddress record : records) {
      if (
        mapAccountIdToAddressTypes.get(record.Customer_Name__c)
          ?.contains(record.AddressType) == true
      ) {
        record.addError(
          String.format(
            ADDRESS_EXISTS_ERROR,
            new List<String>{ record.AddressType }
          )
        );
      }
    }
  }
}
