/**
 * @author Ashwin Mohan
 * @since 10/2024
 * @description Test class for ReferrerActions
 */
@isTest
public class ReferrerActionsTest {
  static final String MLCRM_LEAD_RT_ID = RTLead.mlcrmLead;
  static final String INTERNAL_REFERRAL = 'Internal Referral';
  static final String EXTERNAL_REFERRAL = 'External Referral';
  static Lib_MockProvider userRepoMock;
  static Lib_MockProvider contactRepoMock;
  static void registerMocks() {
    userRepoMock = Lib_MockProvider.forType(UserActionsRepository.class);
    contactRepoMock = Lib_MockProvider.forType(ContactActionsRepository.class);
  }

  @isTest
  static void testReferrerPrefillWithInternalUser() {
    registerMocks();
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    User userRecord = new User(
      Id = userId,
      FirstName = 'Test',
      LastName = 'Name',
      Email = 'testemailuser@mail.com'
    );
    userRepoMock.mock(
      'getUserMapFromUserIds',
      new Map<Id, User>{ userId => userRecord }
    );
    Lead leadRecord = new Lead(
      LastName = 'testLead',
      FinServ__ReferredByUser__c = userId,
      RecordTypeId = MLCRM_LEAD_RT_ID
    );
    List<Lead> leads = new List<Lead>{ leadRecord };
    Test.startTest();
    ReferrerActions.referrerPrefill(leads, null);
    Test.stopTest();
    Assert.areEqual(
      leads[0].Referrer_Email__c,
      'testemailuser@mail.com',
      'Referrer email is not populated for internal referral'
    );
  }

  @isTest
  static void testReferrerPrefillWithExternalUser() {
    registerMocks();
    Id contactId = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    Contact contactRecord = new Contact(
      Id = contactId,
      LastName = 'Test',
      Email = 'testemailcontact@mail.com',
      MobilePhone = '99999999'
    );
    contactRepoMock.mock(
      'getContactMapById',
      new Map<Id, Contact>{ contactId => contactRecord }
    );
    Lead leadRecord = new Lead(
      LastName = 'testLead',
      FinServ__ReferredByContact__c = contactId,
      RecordTypeId = MLCRM_LEAD_RT_ID
    );
    List<Lead> leads = new List<Lead>{ leadRecord };
    Test.startTest();
    ReferrerActions.referrerPrefill(leads, null);
    Test.stopTest();
    Assert.areEqual(
      leads[0].Referrer_Email__c,
      'testemailcontact@mail.com',
      'Referrer email is populated is not populated for external referral'
    );
    Assert.areEqual(
      leads[0].Referrer_Phone__c,
      '99999999',
      'Mobile is not populated for external referral'
    );
  }

  @isTest
  static void testReferrerPrefillWithInternalUserEmail() {
    registerMocks();
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    User userRecord = new User(
      Id = userId,
      FirstName = 'Test',
      LastName = 'Name',
      Email = 'testemailuser@mail.com'
    );
    userRepoMock.mock('getUsersFromEmailIds', new List<User>{ userRecord });
    Lead leadRecord = new Lead(
      LastName = 'testLead',
      Referrer_Email__c = 'testemailuser@mail.com',
      RecordTypeId = MLCRM_LEAD_RT_ID,
      LeadSource = INTERNAL_REFERRAL
    );
    List<Lead> leads = new List<Lead>{ leadRecord };
    Test.startTest();
    ReferrerActions.referrerPrefill(leads, null);
    Test.stopTest();
    Assert.areEqual(
      leads[0].FinServ__ReferredByUser__c,
      userId,
      'Internal referral User is not populated when referral type is internal and referral email is populated'
    );
  }

  @isTest
  static void testReferrerPrefillWithExternalUserEmail() {
    registerMocks();
    Id contactId = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    Contact contactRecord = new Contact(
      Id = contactId,
      LastName = 'Test',
      Email = 'testemailcontact@mail.com',
      MobilePhone = '99999999'
    );
    contactRepoMock.mock(
      'getContactsByEmail',
      new List<Contact>{ contactRecord }
    );
    Lead leadRecord = new Lead(
      LastName = 'testLead',
      Referrer_Email__c = 'testemailcontact@mail.com',
      RecordTypeId = MLCRM_LEAD_RT_ID,
      LeadSource = EXTERNAL_REFERRAL
    );
    List<Lead> leads = new List<Lead>{ leadRecord };
    Test.startTest();
    ReferrerActions.referrerPrefill(leads, null);
    Test.stopTest();
    Assert.areEqual(
      leads[0].FinServ__ReferredByContact__c,
      contactId,
      'External referral contact is not populated when referral type is external and referral email is populated'
    );
    Assert.areEqual(
      leads[0].Referrer_Phone__c,
      '99999999',
      'External referral mobile is not populated when referral type is external and referral email is populated'
    );
  }

  @isTest
  static void testFilterRecords() {
    Lead leadRecord = new Lead(
      LastName = 'testLead',
      Referrer_Email__c = 'testemailcontact@mail.com',
      RecordTypeId = MLCRM_LEAD_RT_ID,
      LeadSource = EXTERNAL_REFERRAL
    );
    List<Lead> leads = new List<Lead>{ leadRecord };
    Test.startTest();
    List<SObject> filteredLeads = ReferrerActions.filterRecords(leads, null);
    Test.stopTest();
    Assert.areEqual(
      1,
      filteredLeads.size(),
      'Count of filtered ML leads is not correct'
    );
  }

  @isTest
  static void testGetReferrerIds() {
    Id contactId = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    Lead leadRecord = new Lead(
      LastName = 'testLead',
      Referrer_Email__c = 'testemailcontact@mail.com',
      RecordTypeId = MLCRM_LEAD_RT_ID,
      LeadSource = EXTERNAL_REFERRAL,
      FinServ__ReferredByContact__c = contactId
    );
    List<Lead> leads = new List<Lead>{ leadRecord };
    Test.startTest();
    Set<Id> referrerIds = ReferrerActions.getReferrerIds(
      leads,
      null,
      'FinServ__ReferredByContact__c'
    );
    Test.stopTest();
    Assert.isTrue(
      referrerIds.contains(contactId),
      'External referrer id is not present in the set'
    );
  }

  @isTest
  static void testGetUpdatedEmailRecords() {
    Id contactId = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    Lead leadRecord = new Lead(
      LastName = 'testLead',
      Referrer_Email__c = 'testemailcontact@mail.com',
      RecordTypeId = MLCRM_LEAD_RT_ID,
      LeadSource = EXTERNAL_REFERRAL,
      FinServ__ReferredByContact__c = contactId
    );
    List<Lead> leads = new List<Lead>{ leadRecord };
    Test.startTest();
    List<SObject> emailUpdSobjects = ReferrerActions.getUpdatedEmailRecords(
      leads,
      null
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      emailUpdSobjects.size(),
      'Count of filtered records for email updated is not correct'
    );
  }

  @isTest
  static void testGetReferrerEmails() {
    Id contactId = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    Lead leadRecord = new Lead(
      LastName = 'testLead',
      Referrer_Email__c = 'testemailcontact@mail.com',
      RecordTypeId = MLCRM_LEAD_RT_ID,
      LeadSource = EXTERNAL_REFERRAL,
      FinServ__ReferredByContact__c = contactId
    );
    List<Lead> leads = new List<Lead>{ leadRecord };
    Test.startTest();
    Set<String> referrerEmails = ReferrerActions.getReferrerEmails(
      leads,
      EXTERNAL_REFERRAL
    );
    Test.stopTest();
    Assert.isTrue(
      referrerEmails.contains('testemailcontact@mail.com'),
      'Referrer email is not present in the set'
    );
  }

  @isTest
  static void testPopulateInternalReferrerByEmail() {
    registerMocks();
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    User userRecord = new User(
      Id = userId,
      FirstName = 'Test',
      LastName = 'Name',
      Email = 'testemailuser@mail.com'
    );
    userRepoMock.mock('getUsersFromEmailIds', new List<User>{ userRecord });
    Lead leadRecord = new Lead(
      LastName = 'testLead',
      Referrer_Email__c = 'testemailuser@mail.com',
      RecordTypeId = MLCRM_LEAD_RT_ID,
      LeadSource = INTERNAL_REFERRAL
    );
    List<Lead> leads = new List<Lead>{ leadRecord };
    Test.startTest();
    ReferrerActions.populateInternalReferrerByEmail(
      new Set<String>{ 'testemailuser@mail.com' },
      leads
    );
    Test.stopTest();
    Assert.areEqual(
      leads[0].FinServ__ReferredByUser__c,
      userId,
      'User Id is not populated for internal referral email'
    );
  }

  @isTest
  static void testPopulateExternalReferrerByEmail() {
    registerMocks();
    Id contactId = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    Contact contactRecord = new Contact(
      Id = contactId,
      LastName = 'Test',
      Email = 'testemailcontact@mail.com',
      MobilePhone = '99999999'
    );
    contactRepoMock.mock(
      'getContactsByEmail',
      new List<Contact>{ contactRecord }
    );
    Lead leadRecord = new Lead(
      LastName = 'testLead',
      Referrer_Email__c = 'testemailcontact@mail.com',
      RecordTypeId = MLCRM_LEAD_RT_ID,
      LeadSource = EXTERNAL_REFERRAL
    );
    List<Lead> leads = new List<Lead>{ leadRecord };
    Test.startTest();
    ReferrerActions.populateExternalReferrerByEmail(
      new Set<String>{ 'testemailcontact@mail.com' },
      leads
    );
    Test.stopTest();
    Assert.areEqual(
      leads[0].FinServ__ReferredByContact__c,
      contactId,
      'Contact is not populated for external referral email'
    );
    Assert.areEqual(
      leads[0].Referrer_Phone__c,
      '99999999',
      'Mobile is not populated for external referral email'
    );
  }

  @isTest
  static void testPopulateInternalReferrerByLookupId() {
    registerMocks();
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    User userRecord = new User(
      Id = userId,
      FirstName = 'Test',
      LastName = 'Name',
      Email = 'testemailuser@mail.com'
    );
    userRepoMock.mock(
      'getUserMapFromUserIds',
      new Map<Id, User>{ userId => userRecord }
    );
    Lead leadRecord = new Lead(
      LastName = 'testLead',
      FinServ__ReferredByUser__c = userId,
      RecordTypeId = MLCRM_LEAD_RT_ID
    );
    List<Lead> leads = new List<Lead>{ leadRecord };
    Test.startTest();
    ReferrerActions.populateInternalReferrerByLookupId(
      new Set<Id>{ userId },
      leads
    );
    Test.stopTest();
    Assert.areEqual(
      leads[0].Referrer_Email__c,
      'testemailuser@mail.com',
      'Referrer email is not populated for internal referral user'
    );
  }

  @isTest
  static void testPopulateExternalReferrerByLookupId() {
    registerMocks();
    Id contactId = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    Contact contactRecord = new Contact(
      Id = contactId,
      LastName = 'Test',
      Email = 'testemailcontact@mail.com',
      MobilePhone = '99999999'
    );
    contactRepoMock.mock(
      'getContactMapById',
      new Map<Id, Contact>{ contactId => contactRecord }
    );
    Lead leadRecord = new Lead(
      LastName = 'testLead',
      FinServ__ReferredByContact__c = contactId,
      RecordTypeId = MLCRM_LEAD_RT_ID
    );
    List<Lead> leads = new List<Lead>{ leadRecord };
    Test.startTest();
    ReferrerActions.populateExternalReferrerByLookupId(
      new Set<Id>{ contactId },
      leads
    );
    Test.stopTest();
    Assert.areEqual(
      leads[0].Referrer_Email__c,
      'testemailcontact@mail.com',
      'Referrer email is not populated for external referral contact'
    );
    Assert.areEqual(
      leads[0].Referrer_Phone__c,
      '99999999',
      'Mobile is not populated for external referral contact'
    );
  }
}
