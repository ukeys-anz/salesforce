/**
 * @author Naman Garg
 * @since  May 2025
 * @group CCRM (Commercial CRM)
 * @description CommercialLeadMappingEngineTest is class to helper class for CommercialLeadMappingEngine
 */
@isTest
public class CommercialLeadMappingEngineTest {
  static Lib_MockProvider leadActionsRepo;
  static void registerMocks() {
    leadActionsRepo = Lib_MockProvider.forType(LeadActionsRepository.class);
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

    Test.startTest();
    List<Account> accList = new CommercialLeadMappingEngine()
      .queryAccounts(prefillManualLeadWrap, relatedPartyIds);
    Test.stopTest();

    Assert.areEqual(1, accList.size(), 'Account list should not be empty');
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
      'No Contact Found',
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
      'Check for Commercial Contacts on profile',
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
