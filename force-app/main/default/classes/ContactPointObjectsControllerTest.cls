/**
 * @author Karen Valeriano
 * @since November 2023
 * @description test class for ContactPointObjectsController class
 */
@isTest
public with sharing class ContactPointObjectsControllerTest {
  // Account - Person Account RT Id
  public static final Id ACCOUNT_PERSON_ACCOUNT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('PersonAccount')
    .getRecordTypeId();

  // Contact - Broker RT Id
  public static final Id CONTACT_BROKER_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Broker')
    .getRecordTypeId();

  // ContactPointPhone - Individual RT Id
  public static final Id CONTACTPOINTPHONE_INDIVIDUAL_RT_ID = Schema.SObjectType.ContactPointPhone.getRecordTypeInfosByDeveloperName()
    .get('Individual')
    .getRecordTypeId();

  // ContactPointEmail - Individual RT Id
  public static final Id CONTACTPOINTEMAIL_INDIVIDUAL_RT_ID = Schema.SObjectType.ContactPointEmail.getRecordTypeInfosByDeveloperName()
    .get('Individual')
    .getRecordTypeId();

  // ContactPointAddress - Individual RT Id
  public static final Id CONTACTPOINTADDRESS_INDIVIDUAL_RT_ID = Schema.SObjectType.ContactPointAddress.getRecordTypeInfosByDeveloperName()
    .get('Individual')
    .getRecordTypeId();

  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');

    //Add PersonAccount
    Account personAccount = new Account(
      FirstName = 'Person',
      LastName = 'AccountName',
      OCV_Id__c = faker.randomString(10),
      RecordTypeId = ACCOUNT_PERSON_ACCOUNT_RT_ID
    );
    insert personAccount;

    //Add a Broker Contact
    Contact broker = new Contact(
      FirstName = 'Person',
      LastName = 'BrokerContact',
      Broker_Customer_Profile__c = personAccount.Id,
      RecordTypeId = CONTACT_BROKER_RT_ID
    );
    insert broker;

    //Add ContactPointPhone records, each one will have different Persona Type
    List<ContactPointPhone> phoneList = new List<ContactPointPhone>{
      new ContactPointPhone(
        ParentId = personAccount.Id,
        TelephoneNumber = '04' + faker.randomInteger(8),
        RecordTypeId = CONTACTPOINTPHONE_INDIVIDUAL_RT_ID,
        Persona_Type__c = 'Broker'
      ),
      new ContactPointPhone(
        ParentId = personAccount.Id,
        TelephoneNumber = '04' + faker.randomInteger(8),
        RecordTypeId = CONTACTPOINTPHONE_INDIVIDUAL_RT_ID,
        Persona_Type__c = 'Broker'
      )
    };
    insert phoneList;

    //Add ContactPointEmail records, each one will have different Persona Type
    List<ContactPointEmail> emailList = new List<ContactPointEmail>{
      new ContactPointEmail(
        ParentId = personAccount.Id,
        EmailAddress = faker.randomString(10) + '@' + 'broker.com',
        RecordTypeId = CONTACTPOINTEMAIL_INDIVIDUAL_RT_ID,
        Persona_Type__c = 'Broker'
      ),
      new ContactPointEmail(
        ParentId = personAccount.Id,
        EmailAddress = faker.randomString(10) + '@' + 'customer.com',
        RecordTypeId = CONTACTPOINTEMAIL_INDIVIDUAL_RT_ID,
        Persona_Type__c = 'Customer'
      )
    };
    insert emailList;

    //Add ContactPointAddress records, each one will have different Persona Type
    List<ContactPointAddress> addressList = new List<ContactPointAddress>{
      new ContactPointAddress(
        ParentId = personAccount.Id,
        Name = personAccount.Name + ' - ' + faker.randomString(5),
        RecordTypeId = CONTACTPOINTADDRESS_INDIVIDUAL_RT_ID,
        Persona_Type__c = 'Broker'
      ),
      new ContactPointAddress(
        ParentId = personAccount.Id,
        Name = personAccount.Name + ' - ' + faker.randomString(5),
        RecordTypeId = CONTACTPOINTADDRESS_INDIVIDUAL_RT_ID,
        Persona_Type__c = 'Customer'
      )
    };
    insert addressList;
  }

  /**
   * @description Test retrieval of ContactPointPhone records
   */
  @isTest
  static void testGetContactPointPhoneRecords() {
    // GIVEN that a Broker Contact record is created
    List<Contact> brokerContact = [
      SELECT Id
      FROM Contact
      WHERE FirstName = 'Person' AND LastName = 'BrokerContact'
    ];

    // WHEN the record is retrieved by ContactId and ContactPointPhone object api name
    Test.startTest();
    List<ContactPointPhone> phoneNumbers = ContactPointObjectsController.getContactPointObjectRecords(
      'ContactPointPhone',
      brokerContact[0].Id
    );
    Test.stopTest();

    // THEN phone records will be retrieved
    System.assert(
      phoneNumbers.size() > 0,
      'There should be associated phone number records'
    );

    // AND only records with Persona_Type__c is retrieved
    System.assert(
      phoneNumbers[0].Persona_Type__c == 'Broker',
      'Only records with Persona_Type__c = Broker should be retrieved'
    );
  }

  /**
   * @description Test retrieval of ContactPointEmail records
   */
  @isTest
  static void testGetContactPointEmailRecords() {
    // GIVEN that a Broker Contact record is created
    List<Contact> brokerContact = [
      SELECT Id
      FROM Contact
      WHERE FirstName = 'Person' AND LastName = 'BrokerContact'
    ];

    // WHEN the record is retrieved by ContactId and ContactPointEmail object api name
    Test.startTest();
    List<ContactPointEmail> emailAddresses = ContactPointObjectsController.getContactPointObjectRecords(
      'ContactPointEmail',
      brokerContact[0].Id
    );
    Test.stopTest();

    // THEN phone records will be retrieved
    System.assert(
      emailAddresses.size() > 0,
      'There should be associated email address records'
    );

    // AND only records with Persona_Type__c is retrieved
    System.assert(
      emailAddresses[0].Persona_Type__c == 'Broker',
      'Only records with Persona_Type__c = Broker should be retrieved'
    );
  }

  /**
   * @description Test retrieval of ContactPointAddress records
   */
  @isTest
  static void testGetContactPointAddressRecords() {
    // GIVEN that a Broker Contact record is created
    List<Contact> brokerContact = [
      SELECT Id
      FROM Contact
      WHERE FirstName = 'Person' AND LastName = 'BrokerContact'
    ];

    // WHEN the record is retrieved by ContactId and ContactPointAddress object api name
    Test.startTest();
    List<ContactPointAddress> addresses = ContactPointObjectsController.getContactPointObjectRecords(
      'ContactPointAddress',
      brokerContact[0].Id
    );
    Test.stopTest();

    // THEN phone records will be retrieved
    System.assert(
      addresses.size() > 0,
      'There should be associated address records'
    );

    // AND only records with Persona_Type__c is retrieved
    System.assert(
      addresses[0].Persona_Type__c == 'Broker',
      'Only records with Persona_Type__c = Broker should be retrieved'
    );
  }

  /**
   * @description Test retrieval of ContactPoint object records without recordId and objectApiName values
   */
  @isTest
  static void testRetrievalWithoutPassedParameters() {
    // GIVEN that NO ObjectAPIName and RecordId provided
    Id recordId = null;
    String objectApiName = null;

    // WHEN the record is retrieved with null parameters
    Test.startTest();
    List<SObject> records = ContactPointObjectsController.getContactPointObjectRecords(
      objectApiName,
      recordId
    );
    Test.stopTest();

    // THEN null records will be returned
    System.assert(records == null, 'No records should be retrieved');
  }
}
