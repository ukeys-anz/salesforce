@isTest
public with sharing class CloneLeadControllerTest {
  static Lib_MockProvider cloneLeadRepoMock;
  static Lib_MockProvider dmlMockProvider;
  private static final String CAMPAIGN_CODE = 'IKCMP-1579';

  static void registerMocks() {
    cloneLeadRepoMock = Lib_MockProvider.forType(CloneLeadRepository.class);
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void testCloneLeadRecordSuccessfulClone() {
    registerMocks();
    Lead leadRecord = getDefaultLead();

    cloneLeadRepoMock.mock(
      new Map<String, Object>{ 'getLeadRecordByQuery' => leadRecord }
    );
    dmlMockProvider.mock(
      'doInsert',
      TestUtil.getMockSaveResult(
        '{"success":true,"id":"00QBn00000OgAOXMA3","errors":[]}'
      )
    );
    Test.startTest();
    CloneLeadController.cloneLeadRecord(leadRecord.Id);
    Test.stopTest();

    // Assert: Verify values copied over

    Lead insertedLead = (Lead) dmlMockProvider.getHistory('doInsert')
      .getParam('record');
    Assert.isNotNull(insertedLead, 'Lead should have been updated.');
    Assert.areEqual(
      leadRecord.Company,
      insertedLead.Company,
      'Company not copied correctly'
    );
    Assert.areEqual(
      CAMPAIGN_CODE,
      insertedLead.Campaign_Code__c,
      'Campaign Code not Populated correctly'
    );
    Assert.isNull(
      insertedLead.FinServ__ExpressedInterest__c,
      'Expressed Interest should be null'
    );
    Assert.areEqual(
      leadRecord.Id,
      insertedLead.Previous_Lead__c,
      'Previous Lead not set'
    );
    Assert.areEqual(
      UserInfo.getUserId(),
      insertedLead.OwnerId,
      'Owner not set correctly'
    );
  }

  @isTest
  static void testCopyFieldSetValues() {
    registerMocks();
    Lead oldLead = getDefaultLead();
    Lead newLead = new Lead();

    Schema.FieldSet fieldSet = SObjectType.Lead.FieldSets.CCRM_Clone_Lead_Fields;

    Test.startTest();
    CloneLeadController.copyFieldSetValues(oldLead, newLead, fieldSet);
    Test.stopTest();

    // Verify a few key fields copied
    Assert.areEqual(
      oldLead.Company,
      newLead.Company,
      'Company should be copied'
    );
    Assert.areEqual(oldLead.ABN__c, newLead.ABN__c, 'ABN should be copied');
    Assert.areEqual(
      oldLead.FirstName,
      newLead.FirstName,
      'FirstName should be copied'
    );
  }

  @isTest
  static void testCloneLeadETBRecord() {
    registerMocks();
    Lead leadRecord = getDefaultLead();
    leadRecord.New_to_Bank__c = 'No'; // Not cloneable

    cloneLeadRepoMock.mock(
      new Map<String, Object>{ 'getLeadRecordByQuery' => leadRecord }
    );

    Test.startTest();
    try {
      CloneLeadController.cloneLeadRecord(leadRecord.Id);
      Assert.fail('Exception was expected for non-NTB lead');
    } catch (AuraHandledException ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testCloneLeadRecordNotProspect() {
    registerMocks();
    Lead leadRecord = getDefaultLead();
    Account associatedAccount = (Account) TestUtil.setFields(
      new Account(Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType)),
      new Map<String, Object>{ 'FinServ__Status__c' => 'Active' }
    );
    leadRecord.finserv__RelatedAccount__r = associatedAccount;

    cloneLeadRepoMock.mock(
      new Map<String, Object>{ 'getLeadRecordByQuery' => leadRecord }
    );

    Test.startTest();
    try {
      CloneLeadController.cloneLeadRecord(leadRecord.Id);
      Assert.fail('Exception was expected for non-prospect account');
    } catch (AuraHandledException ex) {
      Assert.isInstanceOfType(
        ex,
        AuraHandledException.class,
        'Exception should be an instanceof AuraHandledException.'
      );
    }
    Test.stopTest();
  }

  static Lead getDefaultLead() {
    Lead newLead = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      Company = 'SUNDAY',
      ABN__c = '85 968 906 272',
      ACN__c = '000 000 019',
      Industry__c = Lib_FakeIdGenerator.getMockId(Industry__c.SObjectType),
      New_to_Bank__c = 'Yes',
      Registered_Company__c = 'Yes',
      Entity_Type__c = '01',
      CLG_Name__c = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      CLG_ID__c = '4025948102',
      CPID__c = 'L0810',
      CPID_Owner__c = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      // Address Fields
      Street = '15 Geodorun Street',
      City = 'Howard Springs',
      State = 'NT',
      PostalCode = '0835',
      Country = 'AU',
      Latitude = null,
      Longitude = null,
      GeocodeAccuracy = null,
      // Contact Info
      FirstName = 'John',
      MiddleName = 'Man',
      LastName = 'Doe',
      Salutation = 'Dr.',
      Suffix = 'JR',
      Email = 'test@test.com',
      MobilePhone = '+61434434434',
      Home_Phone__c = '+61312312312',
      Work_Phone__c = '+61312344444',
      Primary_Contact_Method__c = 'Mobile',
      // Additional Info
      Campaign_Code__c = 'IKCMP-1500',
      OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      Previous_Lead__c = null,
      FinServ__ExpressedInterest__c = 'Commercial Lending',
      LeadSource = 'Internal Referral'
    );
    return newLead;
  }
}
