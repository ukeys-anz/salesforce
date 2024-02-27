/**
 * @author Karen Valeriano
 * @since Nov 2023
 * @description Controller called from LWC to retrieve records for ContactPointAddress, ContactPointEmail or ContactPointPhone objects
 */
public with sharing class ContactPointObjectsController {
  static final String PERSONA_TYPE_BROKER = 'Broker';
  /**
   * @description process ContactPoint Object retrieval
   * @param objectApiName the ContactPoint object api name (e.g. ContactPointAddress, ContactPointEmail, ContactPointPhone)
   * @param recordId the Contact's recordId
   * @return List<SObject> ContactPoint records retrieved
   */
  @AuraEnabled(cacheable=true)
  public static List<SObject> getContactPointObjectRecords(
    String objectApiName,
    Id recordId
  ) {
    if (
      userHasQueryAccess() &&
      !String.isBlank(objectApiName) &&
      recordId != null
    ) {
      Id personAccountId = [
        SELECT Broker_Customer_Profile__c
        FROM Contact
        WHERE Id = :recordId
      ]
      .Broker_Customer_Profile__c;

      switch on objectApiName {
        when 'ContactPointPhone' {
          return getContactPointPhoneList(personAccountId);
        }
        when 'ContactPointAddress' {
          return getContactPointAddressList(personAccountId);
        }
        when 'ContactPointEmail' {
          return getContactPointEmailList(personAccountId);
        }
      }
    }

    return null;
  }

  /**
   * @description checks if current user has query access in all the contact and contactpoint objects
   * @return Boolean true if current user has access, otherwise false
   */
  private static Boolean userHasQueryAccess() {
    return (Contact.sObjectType.getDescribe().isAccessible() &&
    ContactPointAddress.sObjectType.getDescribe().isAccessible() &&
    ContactPointEmail.sObjectType.getDescribe().isAccessible() &&
    ContactPointPhone.sObjectType.getDescribe().isAccessible());
  }

  /**
   * @description get ContactPointPhone records
   * @param personAccountId the related accountId
   * @return List<ContactPointPhone> the ContactPointPhone records retrieved
   */
  private static List<ContactPointPhone> getContactPointPhoneList(
    Id personAccountId
  ) {
    return [
      SELECT
        Id,
        Persona_Type__c,
        TelephoneNumber,
        toLabel(PhoneType),
        toLabel(Preferred_Indicator__c),
        ParentId
      FROM ContactPointPhone
      WHERE
        ParentId = :personAccountId
        AND Persona_Type__c = :PERSONA_TYPE_BROKER
    ];
  }

  /**
   * @description get ContactPointAddress records
   * @param personAccountId the related accountId
   * @return List<ContactPointAddress> the ContactPointAddress records retrieved
   */
  private static List<ContactPointAddress> getContactPointAddressList(
    Id personAccountId
  ) {
    return [
      SELECT Id, AddressType, Address, IsDefault, Persona_Type__c, ParentId
      FROM ContactPointAddress
      WHERE
        ParentId = :personAccountId
        AND Persona_Type__c = :PERSONA_TYPE_BROKER
    ];
  }

  /**
   * @description get ContactPointEmail records
   * @param personAccountId the related accountId
   * @return List<ContactPointEmail> the ContactPointEmail records retrieved
   */
  private static List<ContactPointEmail> getContactPointEmailList(
    Id personAccountId
  ) {
    return [
      SELECT
        Id,
        EmailAddress,
        Persona_Type__c,
        ParentId,
        toLabel(Preferred_Indicator__c)
      FROM ContactPointEmail
      WHERE
        ParentId = :personAccountId
        AND Persona_Type__c = :PERSONA_TYPE_BROKER
    ];
  }
}
