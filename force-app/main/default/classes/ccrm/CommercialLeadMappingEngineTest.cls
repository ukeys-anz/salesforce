/**
 * @author Naman Garg
 * @since  May 2025
 * @group CCRM (Commercial CRM)
 * @description CommercialLeadMappingEngineTest is class to helper class for CommercialLeadMappingEngine
 */
@isTest
public class CommercialLeadMappingEngineTest {
  static Lib_MockProvider leadActionsRepo;
  static Lib_MockProvider leadMappingEngineHelperMock;
  static Lib_MockProvider leadMappingEngineMock;
  static void registerMocks() {
    leadActionsRepo = Lib_MockProvider.forType(LeadActionsRepository.class);
    leadMappingEngineHelperMock = Lib_MockProvider.forType(
      CommercialLeadMappingEngineHelper.class
    );
    leadMappingEngineMock = Lib_MockProvider.forType(
      CommercialLeadMappingEngine.class
    );
  }

  @isTest
  static void prefillManualLeadsFromAccountTest() {
    registerMocks();
    //GIVEN mappingEngine, prefillManualLeadWrap, relatedPartyIds, records, accList, indList, mapAccountsRecordTypeId
    CommercialLeadMappingEngine mappingEngine = new CommercialLeadMappingEngine();
    CommercialLeadMappingEngine.PrefillManualLeadWrapper prefillManualLeadWrap = new CommercialLeadMappingEngine.PrefillManualLeadWrapper();

    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Set<String> relatedPartyIds = new Set<String>{ (String) accId };
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = accId,
        RecordTypeId = RTLead.commercialLead,
        Lead_Originator__c = 'CCRM'
      )
    };

    List<Account> accList = new List<Account>{
      new Account(
        Id = accId,
        RecordTypeId = RTAccount.personAccount,
        BillingCity = 'Melbourne',
        BillingCountry = 'Australia',
        Phone = '049123123'
      )
    };

    List<Industry__c> indList = new List<Industry__c>{
      new Industry__c(
        Id = Lib_FakeIdGenerator.getMockId(Industry__c.SObjectType),
        Name = 'Plant Industry',
        Code__c = '001',
        IsActive__c = true
      )
    };

    mappingEngine.mapAccountsRecordTypeId = new Map<Id, Account>{
      accId => new Account(Id = accId, RecordTypeId = RTAccount.personAccount)
    };
    leadActionsRepo.mock(
      'getAccountsByRelatedPartyIds',
      mappingEngine.mapAccountsRecordTypeId
    );

    prefillManualLeadWrap.query = 'BillingCity,BillingCountry,Phone,';
    prefillManualLeadWrap.accountToLeadMapping = new Map<String, String>{
      'BillingCity' => 'City',
      'BillingCountry' => 'Country',
      'Phone' => 'Work_Phone__c'
    };
    prefillManualLeadWrap.accountToLeadMappingClone = prefillManualLeadWrap.accountToLeadMapping;
    prefillManualLeadWrap.accountToLeadMappingWithAccount = new Map<String, Map<String, String>>{
      'Customer' => new Map<String, String>{
        'BillingCity' => 'City',
        'BillingCountry' => 'Country',
        'Phone' => 'Work_Phone__c'
      }
    };
    leadMappingEngineHelperMock.mock(
      'formAccountToLeadMappingMap',
      prefillManualLeadWrap
    );

    leadActionsRepo.mock('getAccounts', accList);

    leadActionsRepo.mock('getIndustries', indList);

    //WHEN calling a method
    Test.startTest();
    mappingEngine.prefillManualLeadsFromAccount(records, relatedPartyIds);
    Test.stopTest();

    //THEN it should assert correctly
    Assert.areEqual(
      'Melbourne',
      records[0].City,
      'Lead\'s City should get populated from account'
    );
  }

  @isTest
  static void queryAccountsTest() {
    registerMocks();
    //GIVEN prefillManualLeadWrap, relatedPartyIds, accListMock
    CommercialLeadMappingEngine.PrefillManualLeadWrapper prefillManualLeadWrap = new CommercialLeadMappingEngine.PrefillManualLeadWrapper();

    prefillManualLeadWrap.accountToLeadMappingWithAccount = new Map<String, Map<String, String>>{
      'Customer' => new Map<String, String>{
        'ABN__c' => 'ABN__c',
        'Industry__c' => 'Industry__c'
      }
    };
    prefillManualLeadWrap.query = 'ABN__c, ACN__c,';

    Set<String> relatedPartyIds = new Set<String>{
      Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    };

    List<Account> accListMock = new List<Account>{
      new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Name = 'Test Account'
      )
    };

    leadActionsRepo.mock('getAccounts', accListMock);

    //WHEN calling a method
    Test.startTest();
    List<Account> accList = new CommercialLeadMappingEngine()
      .queryAccounts(prefillManualLeadWrap, relatedPartyIds);
    Test.stopTest();

    //THEN it should assert successfully
    Assert.areEqual(1, accList.size(), 'Account list should not be empty');
  }

  @isTest
  static void queryAccountsNullTest() {
    //GIVEN prefillManualLeadWrap
    CommercialLeadMappingEngine.PrefillManualLeadWrapper prefillManualLeadWrap = new CommercialLeadMappingEngine.PrefillManualLeadWrapper();

    //WHEN calling a method
    Test.startTest();
    List<Account> accList = new CommercialLeadMappingEngine()
      .queryAccounts(prefillManualLeadWrap, new Set<String>());
    Test.stopTest();

    //THEN it should assert correctly
    Assert.areEqual(0, accList.size(), 'Account List should be empty');
  }

  @isTest
  static void mapAccountFieldsToLeadTest() {
    //GIVEN accId, mapAccountsRecordTypeId, accountToLeadMappingWithAccount, leadList, accountsMap
    CommercialLeadMappingEngine mappingEngine = new CommercialLeadMappingEngine();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    mappingEngine.mapAccountsRecordTypeId = new Map<Id, Account>{
      accId => new Account(Id = accId, RecordTypeId = RTAccount.personAccount)
    };
    Map<string, Map<string, string>> accountToLeadMappingWithAccount = new Map<string, Map<string, string>>{
      'Customer' => new Map<String, String>{
        'ABN__c' => 'ABN__c',
        'Industry__c' => 'Industry__c'
      }
    };

    mappingEngine.leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = accId
      )
    };

    mappingEngine.accountsMap = new Map<Id, Account>{
      accId => new Account(Id = accId, ABN__c = '0131314224')
    };

    //WHEN calling a method
    Test.startTest();
    mappingEngine.mapAccountFieldsToLead(accountToLeadMappingWithAccount);
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      '0131314224',
      mappingEngine.leadList[0].ABN__c,
      'should populate ABN value from account'
    );
  }

  @isTest
  static void setLeadDefaultDataTest() {
    //GIVEN accId, mapAccountsRecordTypeId, filteredLeadList
    CommercialLeadMappingEngine mappingEngine = new CommercialLeadMappingEngine();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    mappingEngine.mapAccountsRecordTypeId = new Map<Id, Account>{
      accId => new Account(Id = accId, RecordTypeId = RTAccount.businessAccount)
    };
    List<Lead> filteredLeadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = accId
      )
    };

    //WHEN calling a method
    Test.startTest();
    mappingEngine.setLeadDefaultData(filteredLeadList);
    Test.stopTest();

    //THEN it should assert successfully
    Assert.areEqual(
      'Yes',
      filteredLeadList[0].Registered_Company__c,
      'should set register company to yes'
    );
    Assert.areEqual(
      'No',
      filteredLeadList[0].New_To_Bank__c,
      'should set New To Bank to No'
    );
  }

  @isTest
  static void setLeadDefaultDataCLGTest() {
    //GIVEN accId, mapAccountsRecordTypeId, filteredLeadList
    CommercialLeadMappingEngine mappingEngine = new CommercialLeadMappingEngine();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    mappingEngine.mapAccountsRecordTypeId = new Map<Id, Account>{
      accId => new Account(Id = accId, RecordTypeId = RTAccount.clgAccount)
    };
    List<Lead> filteredLeadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = accId
      )
    };

    //WHEN calling a method
    Test.startTest();
    mappingEngine.setLeadDefaultData(filteredLeadList);
    Test.stopTest();

    //THEN it should assert successfully
    Assert.areEqual(
      'No',
      filteredLeadList[0].Registered_Company__c,
      'should set register company to No'
    );
    Assert.areEqual(
      'No',
      filteredLeadList[0].New_To_Bank__c,
      'should set New To Bank to No'
    );
  }

  @isTest
  static void prefillIndustryTest() {
    //GIVEN accId, filteredLeadList, accountsMap
    CommercialLeadMappingEngine mappingEngine = new CommercialLeadMappingEngine();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Lead> filteredLeadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = accId
      )
    };
    mappingEngine.accountsMap = new Map<Id, Account>{
      accId => new Account(
        Id = accId,
        Industry__c = Lib_FakeIdGenerator.getMockId(Industry__c.SObjectType)
      )
    };

    //WHEN calling a method
    Test.startTest();
    mappingEngine.prefillIndustry(filteredLeadList);
    Test.stopTest();

    //THEN it should successfully assert
    Assert.isNotNull(
      filteredLeadList[0].Industry__c,
      'lead industry should not be null'
    );
  }

  @isTest
  static void prefillUnicaLeadsTest() {
    registerMocks();
    //GIVEN leadList, accountMap, prefillUnicaWrap
    CommercialLeadMappingEngine mappingEngine = new CommercialLeadMappingEngine();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id aarId = Lib_FakeIdGenerator.getMockId(
      FinServ__AccountAccountRelation__c.SObjectType
    );
    Id contactId = Lib_FakeIdGenerator.getMockId(Contact.SObjectType);
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        RecordTypeId = RTLead.commercialLead,
        Finserv__RelatedAccount__c = accId
      )
    };

    Map<String, Account> accountMap = new Map<String, Account>{
      accId => new Account(Id = accId, RecordTypeId = RTAccount.personAccount)
    };

    List<Account> accList = new List<Account>{
      new Account(
        Id = accId,
        RecordTypeId = RTAccount.personAccount,
        BillingCity = 'Melbourne',
        BillingCountry = 'Australia',
        Phone = '049123123'
      )
    };

    CommercialLeadMappingEngine.PrefillUnicaLeadWrapper prefillUnicaWrap = new CommercialLeadMappingEngine.PrefillUnicaLeadWrapper();
    prefillUnicaWrap.accountFields = 'Id';
    prefillUnicaWrap.accountToLeadMappingWithAccount = new Map<String, Map<String, String>>{
      'Customer' => new Map<String, String>{
        'BillingCity' => 'City',
        'BillingCountry' => 'Country'
      }
    };
    prefillUnicaWrap.contactFields = 'BillingCountry';
    prefillUnicaWrap.contactToLeadMapping = new Map<String, String>{
      'FirstName' => 'FirstName',
      'LastName' => 'LastName',
      'BillingCity' => 'City',
      'BillingCountry' => 'Country'
    };
    prefillUnicaWrap.contactToLeadMappingClone = prefillUnicaWrap.contactToLeadMapping;
    prefillUnicaWrap.contactToLeadMappingWithContact = new Map<String, Map<String, String>>{
      'Customer' => new Map<String, String>{
        'FirstName' => 'FirstName',
        'LastName' => 'LastName',
        'BillingCity' => 'City',
        'BillingCountry' => 'Country'
      }
    };
    leadMappingEngineHelperMock.mock(
      'formAccountContactToLeadMappingMap',
      prefillUnicaWrap
    );

    CommercialLeadMappingEngine.PrefillManualLeadWrapper prefillManualLeadWrap = new CommercialLeadMappingEngine.PrefillManualLeadWrapper();
    prefillManualLeadWrap.query = 'BillingCity,BillingCountry,Phone,';
    prefillManualLeadWrap.accountToLeadMapping = new Map<String, String>{
      'BillingCity' => 'City',
      'BillingCountry' => 'Country',
      'Phone' => 'Work_Phone__c'
    };
    prefillManualLeadWrap.accountToLeadMappingClone = prefillManualLeadWrap.accountToLeadMapping;
    prefillManualLeadWrap.accountToLeadMappingWithAccount = new Map<String, Map<String, String>>{
      'Customer' => new Map<String, String>{
        'BillingCity' => 'City',
        'BillingCountry' => 'Country',
        'Phone' => 'Work_Phone__c'
      }
    };
    List<Industry__c> indList = new List<Industry__c>{
      new Industry__c(
        Id = Lib_FakeIdGenerator.getMockId(Industry__c.SObjectType),
        Name = 'Plant Industry',
        Code__c = '001',
        IsActive__c = true
      )
    };

    mappingEngine.mapAccountsRecordTypeId = new Map<Id, Account>{
      accId => new Account(Id = accId, RecordTypeId = RTAccount.personAccount)
    };
    leadActionsRepo.mock(
      'getAccountsByRelatedPartyIds',
      mappingEngine.mapAccountsRecordTypeId
    );

    prefillManualLeadWrap.query = 'BillingCity,BillingCountry,Phone,';
    prefillManualLeadWrap.accountToLeadMapping = new Map<String, String>{
      'BillingCity' => 'City',
      'BillingCountry' => 'Country',
      'Phone' => 'Work_Phone__c'
    };
    prefillManualLeadWrap.accountToLeadMappingClone = prefillManualLeadWrap.accountToLeadMapping;
    prefillManualLeadWrap.accountToLeadMappingWithAccount = new Map<String, Map<String, String>>{
      'Customer' => new Map<String, String>{
        'BillingCity' => 'City',
        'BillingCountry' => 'Country',
        'Phone' => 'Work_Phone__c'
      }
    };
    leadMappingEngineHelperMock.mock(
      'formAccountToLeadMappingMap',
      prefillManualLeadWrap
    );

    leadActionsRepo.mock('getAccounts', accList);

    leadActionsRepo.mock('getIndustries', indList);

    Map<Id, FinServ__AccountAccountRelation__c> mapOfAccountToAccountRelations = new Map<Id, FinServ__AccountAccountRelation__c>{
      accId => new FinServ__AccountAccountRelation__c(
        Id = aarId,
        FinServ__Account__c = accId,
        FinServ__Account__r = new Account(
          Id = accId,
          RecordTypeId = RTAccount.personAccount
        ),
        FinServ__RelatedAccount__c = relatedAccId,
        FinServ__RelatedAccount__r = new Account(
          Id = relatedAccId,
          RecordTypeId = RTAccount.clgAccount
        )
      )
    };
    leadActionsRepo.mock(
      'getAccountAccountRelationsRecords',
      mapOfAccountToAccountRelations.values()
    );

    Account accRecord = (Account) TestUtil.setFields(
      new Account(
        Id = accId,
        RecordTypeId = RTAccount.personAccount,
        Name = 'Sample Account'
      ),
      new Map<String, List<Contact>>{
        'Contacts' => new List<Contact>{
          new Contact(
            Id = contactId,
            FirstName = 'Sample',
            LastName = 'Contact',
            AccountId = accId
          )
        }
      }
    );

    leadActionsRepo.mock(
      'getAccountsAndRelatedContacts',
      new List<Account>{ accRecord }
    );

    //WHEN calling a method
    Test.startTest();
    mappingEngine.prefillUnicaLeads(leadList, accountMap);
    Test.stopTest();

    //THEN it should assert successfully
    Assert.areEqual(
      'Sample',
      leadList[0].FirstName,
      'should populate First Name from contact'
    );
    Assert.areEqual(
      'Contact',
      leadList[0].LastName,
      'should populate First Name from contact'
    );
  }

  @isTest
  static void mapCorrespondingClgAccountTest() {
    //GIVEN mapOfAccountToAccountRelations, leadList
    CommercialLeadMappingEngine mappingEngine = new CommercialLeadMappingEngine();
    Id aarId = Lib_FakeIdGenerator.getMockId(
      FinServ__AccountAccountRelation__c.SObjectType
    );
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Map<Id, FinServ__AccountAccountRelation__c> mapOfAccountToAccountRelations = new Map<Id, FinServ__AccountAccountRelation__c>{
      accId => new FinServ__AccountAccountRelation__c(
        Id = aarId,
        FinServ__Account__c = accId,
        FinServ__Account__r = new Account(
          Id = accId,
          RecordTypeId = RTAccount.businessAccount
        ),
        FinServ__RelatedAccount__c = relatedAccId,
        FinServ__RelatedAccount__r = new Account(
          Id = relatedAccId,
          RecordTypeId = RTAccount.clgAccount
        )
      )
    };

    mappingEngine.leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = accId
      )
    };

    //WHEN calling a method
    Test.startTest();
    mappingEngine.mapCorrespondingClgAccount(mapOfAccountToAccountRelations);
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      relatedAccId,
      mappingEngine.leadList[0].CLG_Name__c,
      'should populate CLG Name from AAR'
    );
  }

  @isTest
  static void mapCorrespondingClgAccountCustomerTest() {
    //GIVEN mapOfAccountToAccountRelations, mapIndustries, leadList
    CommercialLeadMappingEngine mappingEngine = new CommercialLeadMappingEngine();
    Id aarId = Lib_FakeIdGenerator.getMockId(
      FinServ__AccountAccountRelation__c.SObjectType
    );
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id industryId = Lib_FakeIdGenerator.getMockId(Industry__c.SObjectType);
    mappingEngine.mapIndustries = new Map<String, Industry__c>{
      'Plant' => new Industry__c(Id = industryId)
    };
    Map<Id, FinServ__AccountAccountRelation__c> mapOfAccountToAccountRelations = new Map<Id, FinServ__AccountAccountRelation__c>{
      accId => new FinServ__AccountAccountRelation__c(
        Id = aarId,
        FinServ__Account__c = accId,
        FinServ__Account__r = new Account(
          Id = accId,
          RecordTypeId = RTAccount.personAccount
        ),
        FinServ__RelatedAccount__c = relatedAccId,
        FinServ__RelatedAccount__r = new Account(
          Id = relatedAccId,
          RecordTypeId = RTAccount.clgAccount,
          Industry = 'Plant'
        )
      )
    };

    mappingEngine.leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = accId
      )
    };

    //WHEN calling a method
    Test.startTest();
    mappingEngine.mapCorrespondingClgAccount(mapOfAccountToAccountRelations);
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      relatedAccId,
      mappingEngine.leadList[0].CLG_Name__c,
      'should populate CLG Name from AAR'
    );

    Assert.areEqual(
      industryId,
      mappingEngine.leadList[0].Industry__c,
      'should populate Industry from AAR'
    );
  }

  @isTest
  static void queryAccountAndRelatedContactsTest() {
    registerMocks();
    //GIVEN prefillUnicaLeadWrap, relatedPartyIds, accListMock
    CommercialLeadMappingEngine.PrefillUnicaLeadWrapper prefillUnicaLeadWrap = new CommercialLeadMappingEngine.PrefillUnicaLeadWrapper();
    prefillUnicaLeadWrap.accountFields = 'ABN__c';
    prefillUnicaLeadWrap.contactFields = 'FirstName';
    prefillUnicaLeadWrap.accountToLeadMappingWithAccount = new Map<String, Map<String, String>>{
      'Customer' => new Map<String, String>()
    };
    prefillUnicaLeadWrap.contactToLeadMappingWithContact = new Map<String, Map<String, String>>{
      'Customer' => new Map<String, String>()
    };

    Set<String> relatedPartyIds = new Set<String>{
      (String) Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    };

    List<Account> accListMock = new List<Account>{
      new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Name = 'Test Account'
      )
    };

    leadActionsRepo.mock('getAccountsAndRelatedContacts', accListMock);

    //WHEN calling a method
    Test.startTest();
    List<Account> accList = new CommercialLeadMappingEngine()
      .queryAccountAndRelatedContacts(prefillUnicaLeadWrap, relatedPartyIds);
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(1, accList.size(), 'should contains 1 record');
  }

  @isTest
  static void queryAccountAndRelatedContactsNullTest() {
    registerMocks();
    //GIVEN prefillUnicaLeadWrap, relatedPartyIds, accListMock
    CommercialLeadMappingEngine.PrefillUnicaLeadWrapper prefillUnicaLeadWrap = new CommercialLeadMappingEngine.PrefillUnicaLeadWrapper();

    Set<String> relatedPartyIds = new Set<String>{
      (String) Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    };

    //WHEN calling a method
    Test.startTest();
    List<Account> accList = new CommercialLeadMappingEngine()
      .queryAccountAndRelatedContacts(prefillUnicaLeadWrap, relatedPartyIds);
    Test.stopTest();

    //THEN it should successfully assert
    Assert.isNull(accList, 'Account List should be null');
  }

  @isTest
  static void queryAccountAndRelatedContactsNull2Test() {
    registerMocks();
    //GIVEN prefillUnicaLeadWrap, relatedPartyIds, accListMock
    CommercialLeadMappingEngine.PrefillUnicaLeadWrapper prefillUnicaLeadWrap = new CommercialLeadMappingEngine.PrefillUnicaLeadWrapper();
    prefillUnicaLeadWrap.accountToLeadMappingWithAccount = new Map<String, Map<String, String>>{
      'Customer' => new Map<String, String>()
    };

    Set<String> relatedPartyIds = new Set<String>{
      (String) Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    };

    //WHEN calling a method
    Test.startTest();
    List<Account> accList = new CommercialLeadMappingEngine()
      .queryAccountAndRelatedContacts(prefillUnicaLeadWrap, relatedPartyIds);
    Test.stopTest();

    //THEN it should successfully assert
    Assert.isNull(accList, 'Acc List should be null');
  }

  @isTest
  static void getContactForMappingTest() {
    //GIVEN accId, leadList, accountsMap
    CommercialLeadMappingEngine mappingEngine = new CommercialLeadMappingEngine();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = accId
      )
    };

    mappingEngine.accountsMap = new Map<Id, Account>{
      accId => new Account(Id = accId)
    };

    //WHEN calling a method
    Test.startTest();
    Map<Id, Contact> accIdToContactMap = mappingEngine.getContactForMapping(
      leadList
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      1,
      accIdToContactMap.size(),
      'should able to populate the map of accId to contact'
    );
  }

  @isTest
  static void mapContactFieldsToLeadNoContactTest() {
    //GIVEN accId, contactToLeadMappingWithContact, accIdToContactMap, leadList
    CommercialLeadMappingEngine mappingEngine = new CommercialLeadMappingEngine();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id accId1 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    Map<String, Map<String, String>> contactToLeadMappingWithContact = new Map<String, Map<String, String>>{
      'Customer' => new Map<String, String>()
    };

    Map<Id, Contact> accIdToContactMap = new Map<Id, Contact>{
      accId1 => new Contact(
        Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
        FirstName = 'Sample Contact',
        AccountId = accId1
      )
    };

    mappingEngine.leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = accId,
        FinServ__RelatedAccount__r = new Account(
          Id = accId,
          RecordTypeId = RTAccount.personAccount
        )
      )
    };

    mappingEngine.mapAccountsRecordTypeId = new Map<Id, Account>{
      accId => new Account(Id = accId, RecordTypeId = RTAccount.personAccount)
    };

    //WHEN calling a method
    Test.startTest();
    mappingEngine.mapContactFieldsToLead(
      contactToLeadMappingWithContact,
      accIdToContactMap
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      '<Insert ',
      mappingEngine.leadList[0].FirstName,
      'FirstName should be No Contact Found'
    );
  }

  @isTest
  static void mapContactFieldsToLeadCommContactTest() {
    //GIVEN accId, contactToLeadMappingWithContact, accIdToContactMap, leadList
    CommercialLeadMappingEngine mappingEngine = new CommercialLeadMappingEngine();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    Map<String, Map<String, String>> contactToLeadMappingWithContact = new Map<String, Map<String, String>>{
      'Customer' => new Map<String, String>()
    };

    Map<Id, Contact> accIdToContactMap = new Map<Id, Contact>{
      accId => new Contact(
        Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
        FirstName = 'Sample Contact',
        AccountId = accId
      )
    };

    mappingEngine.leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = accId,
        FinServ__RelatedAccount__r = new Account(
          Id = accId,
          RecordTypeId = RTAccount.personAccount
        )
      )
    };

    mappingEngine.mapAccountsRecordTypeId = new Map<Id, Account>{
      accId => new Account(Id = accId, RecordTypeId = RTAccount.personAccount)
    };

    //WHEN calling a method
    Test.startTest();
    mappingEngine.mapContactFieldsToLead(
      contactToLeadMappingWithContact,
      accIdToContactMap
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      '<Insert ',
      mappingEngine.leadList[0].FirstName,
      'FirstName should be Check for Commercial Contacts on profile'
    );
  }

  @isTest
  static void mapContactFieldsToLeadTest() {
    //GIVEN accId, contactToLeadMappingWithContact, accIdToContactMap, leadList
    CommercialLeadMappingEngine mappingEngine = new CommercialLeadMappingEngine();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    Map<String, Map<String, String>> contactToLeadMappingWithContact = new Map<String, Map<String, String>>{
      'Customer' => new Map<String, String>{
        'Is_preferred_Contact__c' => 'Is_preferred_Contact__c',
        'FirstName' => 'FirstName'
      }
    };

    Map<Id, Contact> accIdToContactMap = new Map<Id, Contact>{
      accId => new Contact(
        Id = Lib_FakeIdGenerator.getMockId(Contact.SObjectType),
        FirstName = 'Sample Contact',
        AccountId = accId
      )
    };

    mappingEngine.leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = accId,
        FinServ__RelatedAccount__r = new Account(
          Id = accId,
          RecordTypeId = RTAccount.personAccount
        )
      )
    };

    mappingEngine.mapAccountsRecordTypeId = new Map<Id, Account>{
      accId => new Account(Id = accId, RecordTypeId = RTAccount.personAccount)
    };

    //WHEN calling a method
    Test.startTest();
    mappingEngine.mapContactFieldsToLead(
      contactToLeadMappingWithContact,
      accIdToContactMap
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      'Sample Contact',
      mappingEngine.leadList[0].FirstName,
      'should populate the name from Contact'
    );
  }

  @isTest
  static void getAccountsBySourceSystemIdTest() {
    registerMocks();

    //GIVEN records, accList
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Customer_ID__c = '1234',
        RecordTypeId = RTLead.commercialLead,
        Lead_Originator__c = 'UNICA'
      )
    };

    List<Account> accList = new List<Account>{
      new Account(
        Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
        Source_System_ID__c = '1234'
      )
    };

    leadActionsRepo.mock('getRelatedAccounts', accList);

    //WHEN calling a method
    Test.startTest();
    Map<String, Account> mapAccountRecord = new CommercialLeadMappingEngine()
      .getAccountsBySourceSystemId(records);
    Test.stopTest();

    //THEN it should successfully assert
    Assert.isNotNull(
      mapAccountRecord.size(),
      'Map of account should not be empty'
    );
  }

  @isTest
  static void getSourceSystemIdsTest() {
    //GIVEN filteredLeadList
    List<Lead> filteredLeadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        Customer_ID__c = '1234',
        RecordTypeId = RTLead.commercialLead,
        Lead_Originator__c = 'CCRM'
      )
    };

    //WHEN calling a method
    Test.startTest();
    Set<String> accountIds = CommercialLeadMappingEngine.getSourceSystemIds(
      filteredLeadList
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      filteredLeadList[0].Customer_ID__c,
      accountIds.iterator().next(),
      'should contains customer Id'
    );
  }
}
