/**
 * @author       : Mildeep Singh
 * @since        : August 2025
 * @description  : This is test class for CommercialA2ZReviewTriggerHandler
 **/
@isTest
private with sharing class CommercialA2ZReviewTriggerHandlerTest {
  @isTest
  static void isValidRecordTest() {
    // GIVEN A2ZReview Record

    A_Z_Review__c record = new A_Z_Review__c(
      Id = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType),
      RecordTypeId = QueryRT.of(A_Z_Review__c.SObjectType)
        .getId('Commercial_A_Z_Review')
    );
    CommercialA2ZReviewTriggerHandler handler = new CommercialA2ZReviewTriggerHandler();

    // WHEN calling isValidRecord
    Test.startTest();
    Boolean isA2zReviewRecord = handler.isValidRecord(record);
    Test.stopTest();

    // THEN it should return true value
    Assert.isTrue(isA2zReviewRecord, 'Record is not a valid A2ZReview Record');
  }

  @isTest
  static void beforeInsertTest() {
    //GIVEN records
    User ccrmBaseUser = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      FirstName = 'BaseUser',
      LastName = 'CCRM'
    );
    Account accRec = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    );
    Opportunity oppRec = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
      AccountId = accRec.Id,
      OwnerId = ccrmBaseUser.Id
    );
    Lead objLead = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      OwnerId = ccrmBaseUser.Id,
      FinServ__RelatedAccount__c = oppRec.AccountId,
      New_to_Bank__c = 'No'
    );
    List<A_Z_Review__c> records = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType),
        Name = 'Name 1234123412341234',
        OwnerId = ccrmBaseUser.Id,
        Business_Contact__c = 'Sample Contact',
        Existing_Business_Owner__c = 'Yes',
        Status__c = 'Completed',
        Opportunity__c = oppRec.Id,
        Business_Details__c = 'BD 1234123412341234',
        Personal_Banking__c = 'PB 1234123412341234',
        Transaction_Banking__c = 'TB 1234123412341234',
        Borrowing_OFI_Relationship__c = 'OFI Relo 1234123412341234'
      )
    };
    CommercialA2ZReviewTriggerHandler handler = new CommercialA2ZReviewTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeInsert();
    Test.stopTest();

    //Assert is should throw an error
    Assert.areEqual(
      records[0].Completed_Date__c,
      Date.Today(),
      'Completed date not updated when status changes'
    );

    Assert.areEqual(
      'Name ************1234',
      records[0].Name,
      'Redaction is Not Completed'
    );

    Assert.areEqual(
      'BD ************1234',
      records[0].Business_Details__c,
      'Redaction is Not Completed'
    );

    Assert.areEqual(
      'PB ************1234',
      records[0].Personal_Banking__c,
      'Redaction is Not Completed'
    );

    Assert.areEqual(
      'TB ************1234',
      records[0].Transaction_Banking__c,
      'Redaction is Not Completed'
    );

    Assert.areEqual(
      'OFI Relo ************1234',
      records[0].Borrowing_OFI_Relationship__c,
      'Redaction is Not Completed'
    );

    Assert.isNull(
      records[0].Business_Owner__c,
      'Business Owner is not set to null.'
    );
  }

  @isTest
  static void beforeUpdateTest() {
    //GIVEN records
    User ccrmBaseUser = new User(
      Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
      FirstName = 'BaseUser',
      LastName = 'CCRM'
    );
    Account accRec = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType)
    );
    Opportunity oppRec = new Opportunity(
      Id = Lib_FakeIdGenerator.getMockId(Opportunity.SObjectType),
      AccountId = accRec.Id,
      OwnerId = ccrmBaseUser.Id
    );
    Lead objLead = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      OwnerId = ccrmBaseUser.Id,
      FinServ__RelatedAccount__c = oppRec.AccountId,
      New_to_Bank__c = 'No'
    );
    Id a2zRevId = Lib_FakeIdGenerator.getMockId(A_Z_Review__c.SObjectType);
    List<A_Z_Review__c> records = new List<A_Z_Review__c>{
      new A_Z_Review__c(
        Id = a2zRevId,
        Name = 'Name 1234123412341234',
        OwnerId = ccrmBaseUser.Id,
        Business_Contact__c = 'Sample Contact',
        Existing_Business_Owner__c = 'Yes',
        Status__c = 'Completed',
        Opportunity__c = oppRec.Id,
        Business_Details__c = 'BD 1234123412341234',
        Personal_Banking__c = 'PB 1234123412341234',
        Transaction_Banking__c = 'TB 1234123412341234',
        Borrowing_OFI_Relationship__c = 'OFI Relo 1234123412341234'
      )
    };

    Map<Id, A_Z_Review__c> oldMap = new Map<Id, A_Z_Review__c>{
      a2zRevId => new A_Z_Review__c(
        Id = a2zRevId,
        Name = 'Name 1234123412341234',
        Existing_Business_Owner__c = 'No',
        Business_Contact__c = 'Sample Contact',
        OwnerId = ccrmBaseUser.Id,
        Status__c = 'In Progress',
        Opportunity__c = oppRec.Id
      )
    };
    CommercialA2ZReviewTriggerHandler handler = new CommercialA2ZReviewTriggerHandler();
    handler.records = records;

    //WHEN calling a method
    Test.startTest();
    handler.onBeforeUpdate(oldMap);
    Test.stopTest();

    //Assert is should throw an error
    Assert.areEqual(
      records[0].Completed_Date__c,
      Date.Today(),
      'Completed date not updated when status changes'
    );

    Assert.areEqual(
      'Name ************1234',
      records[0].Name,
      'Redaction is Not Completed'
    );

    Assert.areEqual(
      'BD ************1234',
      records[0].Business_Details__c,
      'Redaction is Not Completed'
    );

    Assert.areEqual(
      'PB ************1234',
      records[0].Personal_Banking__c,
      'Redaction is Not Completed'
    );

    Assert.areEqual(
      'TB ************1234',
      records[0].Transaction_Banking__c,
      'Redaction is Not Completed'
    );

    Assert.areEqual(
      'OFI Relo ************1234',
      records[0].Borrowing_OFI_Relationship__c,
      'Redaction is Not Completed'
    );

    Assert.isNull(
      records[0].Business_Owner__c,
      'Business Owner is not set to null.'
    );

    Assert.isNull(
      records[0].Business_Contact__c,
      'should set business contact to null'
    );
  }
}
