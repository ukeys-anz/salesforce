/**
 * @author Naman Garg
 * @since  May 2025
 * @group CCRM (Commercial CRM)
 * @description CommercialLeadMappingEngineHelperTest is class to helper class for CommercialLeadMappingEngineHelper
 */
@isTest
public class CommercialLeadMappingEngineHelperTest {
  @isTest
  static void formAccountToLeadMappingMapTest() {
    //GIVEN accId, records, mapAccountsRecordTypeId
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = accId,
        RecordTypeId = RTLead.commercialLead,
        Lead_Originator__c = 'CCRM'
      )
    };

    Map<Id, Account> mapAccountsRecordTypeId = new Map<Id, Account>{
      accId => new Account(Id = accId, RecordTypeId = RTAccount.businessAccount)
    };

    //WHEN calling a method
    Test.startTest();
    CommercialLeadMappingEngine.PrefillManualLeadWrapper prefillManualLeadWrap = new CommercialLeadMappingEngineHelper()
      .formAccountToLeadMappingMap(records, mapAccountsRecordTypeId);
    Test.stopTest();

    //THEN it should successfully assert
    Assert.isNotNull(
      prefillManualLeadWrap.query,
      'should able to form the query with the account fields'
    );
    Assert.isNotNull(
      prefillManualLeadWrap.accountToLeadMapping,
      'should able to form a map of account to Lead mapping'
    );
  }

  @isTest
  static void formAccountToLeadMappingMapNegativeTest() {
    //GIVEN accId, records, mapAccountsRecordTypeId
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = accId,
        RecordTypeId = RTLead.commercialLead,
        Lead_Originator__c = 'CCRM'
      )
    };

    Map<Id, Account> mapAccountsRecordTypeId = new Map<Id, Account>{
      accId => new Account(Id = accId)
    };

    //WHEN calling a method
    Test.startTest();
    CommercialLeadMappingEngine.PrefillManualLeadWrapper prefillManualLeadWrap = new CommercialLeadMappingEngineHelper()
      .formAccountToLeadMappingMap(records, mapAccountsRecordTypeId);
    Test.stopTest();

    //THEN it should successfully assert
    Assert.isTrue(
      String.isBlank(prefillManualLeadWrap.query),
      'should not able to form the query with the account fields'
    );
  }

  @isTest
  static void formManualAccountToLeadMappingMapTest() {
    //GIVEN accId, record, accountType, prefillManualLeadWrap
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Lead record = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      FinServ__RelatedAccount__c = accId,
      RecordTypeId = RTLead.commercialLead,
      Lead_Originator__c = 'CCRM'
    );

    String accountType = 'Customer';

    CommercialLeadMappingEngine.PrefillManualLeadWrapper prefillManualLeadWrap = new CommercialLeadMappingEngine.PrefillManualLeadWrapper();

    //WHEN calling a method
    Test.startTest();
    CommercialLeadMappingEngineHelper.formManualAccountToLeadMappingMap(
      record,
      accountType,
      prefillManualLeadWrap
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.isNotNull(
      prefillManualLeadWrap.accountToLeadMappingWithAccount,
      'should able to form a map of accountType and account to Lead mapping'
    );
  }

  @isTest
  static void formAccountContactToLeadMappingMapErrorTest() {
    //GIVEN records, accountMap
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        RecordTypeId = RTLead.commercialLead
      )
    };
    Map<String, Account> accountMap = new Map<String, Account>();

    //WHEN calling a method
    Test.startTest();
    new CommercialLeadMappingEngineHelper()
      .formAccountContactToLeadMappingMap(records, accountMap);
    Test.stopTest();

    //THEN it should successfully assert
    Assert.areEqual(
      true,
      records[0].hasErrors(),
      'should throw an error as Customer Id, Business Id and CLG Id is blank'
    );
  }

  @isTest
  static void formAccountContactToLeadMappingMapTest() {
    //GIVEN accId, records, accountMap
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        RecordTypeId = RTLead.commercialLead,
        Customer_ID__c = '1234',
        Lead_Originator__c = 'CCRM'
      )
    };

    Map<String, Account> accountMap = new Map<String, Account>{
      '1234' => new Account(Id = accId, RecordTypeId = RTAccount.clgAccount)
    };

    //WHEN calling a method
    Test.startTest();
    CommercialLeadMappingEngine.PrefillUnicaLeadWrapper prefillUnicaLeadWrap = new CommercialLeadMappingEngineHelper()
      .formAccountContactToLeadMappingMap(records, accountMap);
    Test.stopTest();

    //THEN it should successfully assert
    Assert.isNotNull(
      prefillUnicaLeadWrap.accountFields,
      'should able to get the account fields'
    );
    Assert.isNotNull(
      prefillUnicaLeadWrap.contactFields,
      'should able to get the contact fields'
    );
  }

  @isTest
  static void formUnicaAccountToLeadMappingMapTest() {
    //GIVEN accId, record, accountType, prefillUnicaLeadWrap
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Lead record = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      FinServ__RelatedAccount__c = accId,
      RecordTypeId = RTLead.commercialLead,
      Lead_Originator__c = 'CCRM'
    );

    String accountType = 'CLG';

    CommercialLeadMappingEngine.PrefillUnicaLeadWrapper prefillUnicaLeadWrap = new CommercialLeadMappingEngine.PrefillUnicaLeadWrapper();

    //WHEN calling a method
    Test.startTest();
    CommercialLeadMappingEngineHelper.formUnicaAccountToLeadMappingMap(
      record,
      accountType,
      prefillUnicaLeadWrap
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.isNotNull(
      prefillUnicaLeadWrap.accountToLeadMappingWithAccount,
      'should able to form a map of accountType and account to Lead mapping for UNICA'
    );
  }

  @isTest
  static void formUnicaContactToLeadMappingMapTest() {
    //GIVEN accId, record, accountType, prefillUnicaLeadWrap
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Lead record = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      FinServ__RelatedAccount__c = accId,
      RecordTypeId = RTLead.commercialLead,
      Lead_Originator__c = 'CCRM'
    );

    String accountType = 'Customer';

    CommercialLeadMappingEngine.PrefillUnicaLeadWrapper prefillUnicaLeadWrap = new CommercialLeadMappingEngine.PrefillUnicaLeadWrapper();

    //WHEN calling a method
    Test.startTest();
    CommercialLeadMappingEngineHelper.formUnicaContactToLeadMappingMap(
      record,
      accountType,
      prefillUnicaLeadWrap
    );
    Test.stopTest();

    //THEN it should successfully assert
    Assert.isNotNull(
      prefillUnicaLeadWrap.contactToLeadMappingWithContact,
      'should able to form a map of accountType and Contact to Lead mapping for UNICA'
    );
  }
}
