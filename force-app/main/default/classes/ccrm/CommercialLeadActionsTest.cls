/**
 * @author       : Naman Garg
 * @since        : Nov 2024
 * @description  : Test class for CommercialLeadActions
 **/

@isTest
public class CommercialLeadActionsTest {
  static Lib_MockProvider leadRepoMock;
  static Lib_MockProvider userRepoMock;
  static void registerMocks() {
    leadRepoMock = Lib_MockProvider.forType(LeadActionsRepository.class);
    userRepoMock = Lib_MockProvider.forType(UserInfoRepository.class);
  }

  @isTest
  static void testRestrictImagesInRichTextFields() {
    //GIVEN List of lead Record
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        RecordTypeId = RTLead.commercialLead
      )
    };

    //WHEN calling a restrictImagesInRichTextFields method
    Test.startTest();
    CommercialLeadActions.restrictImagesInRichTextFields(leadList, null);
    Test.stopTest();

    //THEN it shouldn't throw any error
    Assert.isFalse(
      leadList[0].hasErrors(),
      'Error while inserting Lead record with Image.'
    );
  }

  @isTest
  static void extractAccountIdsInsertTest() {
    //GIVEN list of lead records
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
        FinServ__RelatedAccount__c = Lib_FakeIdGenerator.getMockId(
          Account.SObjectType
        )
      )
    };

    //WHEN calling a method
    Test.startTest();
    Set<Id> accountIdsSet = CommercialLeadActions.extractAccountIds(
      records,
      null
    );
    Test.stopTest();

    //THEN it should fetch 1 accountId
    Assert.areEqual(1, accountIdsSet.size(), 'Should fetch 1 accountId');
  }

  @isTest
  static void extractAccountIdsUpdateTest() {
    //GIVEN list of lead records, old Map of lead records
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = leadId,
        FinServ__RelatedAccount__c = Lib_FakeIdGenerator.getMockId(
          Account.SObjectType
        )
      )
    };
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        Id = leadId,
        FinServ__RelatedAccount__c = Lib_FakeIdGenerator.getMockId(
          Account.SObjectType
        )
      )
    };

    //WHEN calling a method
    Test.startTest();
    Set<Id> accountIdsSet = CommercialLeadActions.extractAccountIds(
      records,
      oldMap
    );
    Test.stopTest();

    //THEN it should fetch 1 accountId
    Assert.areEqual(
      1,
      accountIdsSet.size(),
      'Should fetch 1 accountId on update'
    );
  }

  @isTest
  static void populateCLGAccountTest() {
    //GIVEN list of lead records and map of Account-Account relations
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id relatedAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(Id = leadId, FinServ__RelatedAccount__c = relatedAccountId)
    };
    Map<Id, FinServ__AccountAccountRelation__c> accountToAARMap = new Map<Id, FinServ__AccountAccountRelation__c>{
      relatedAccountId => new FinServ__AccountAccountRelation__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__AccountAccountRelation__c.SObjectType
        ),
        FinServ__Account__c = relatedAccountId,
        FinServ__RelatedAccount__c = clgAccountId,
        FinServ__RelatedAccount__r = new Account(CLG__c = '1234')
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialLeadActions.populateCLGAccount(records, accountToAARMap);
    Test.stopTest();

    //THEN it should update CLG Name & CLG Id on Lead
    Assert.areEqual(
      clgAccountId,
      records[0].CLG_Name__c,
      'Should update CLG Name on lead'
    );
    Assert.areEqual(
      '1234',
      records[0].CLG_ID__c,
      'Should update CLG Id on lead'
    );
  }

  @isTest
  static void populateCLGTest() {
    registerMocks();
    //GIVEN list of lead records and map of Account-Account relations
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id relatedAccountIdOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountIdNew = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Lead> records = new List<Lead>{
      new Lead(Id = leadId, FinServ__RelatedAccount__c = relatedAccountIdNew)
    };
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        Id = leadId,
        FinServ__RelatedAccount__c = relatedAccountIdOld
      )
    };

    List<FinServ__AccountAccountRelation__c> accountAccountRelationList = new List<FinServ__AccountAccountRelation__c>{
      new FinServ__AccountAccountRelation__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__AccountAccountRelation__c.SObjectType
        ),
        FinServ__Account__c = relatedAccountIdNew,
        FinServ__RelatedAccount__c = clgAccountId,
        FinServ__RelatedAccount__r = new Account(CLG__c = '1234')
      )
    };
    leadRepoMock.mock('getAccountAccountRelations', accountAccountRelationList);

    //WHEN calling a method
    Test.startTest();
    CommercialLeadActions.populateCLG(records, oldMap);
    Test.stopTest();

    //THEN it should update CLG Name & CLG Id on Lead
    Assert.areEqual(
      clgAccountId,
      records[0].CLG_Name__c,
      'Should update CLG Name on lead on updation'
    );
    Assert.areEqual(
      '1234',
      records[0].CLG_ID__c,
      'Should update CLG Id on lead on updation'
    );
  }

  @isTest
  static void setSkipValidationOnOwnerChangeTest() {
    registerMocks();
    //GIVEN records, oldMap
    String copyLeadId = 'copyLeadId';
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    List<Lead> records = new List<Lead>{
      new Lead(
        Id = leadId,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Skip_Validations__c = copyLeadId
      )
    };

    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        Id = leadId,
        OwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        Skip_Validations__c = copyLeadId
      )
    };

    userRepoMock.mock('checkProfile', true);

    //WHEN calling a method
    Test.startTest();
    CommercialLeadActions.setSkipValidationOnOwnerChange(records, oldMap);
    Test.stopTest();

    //THEN it should update Skip_Validations__c to 'SkipValidation'
    Assert.areEqual(
      'SkipValidation',
      records[0].Skip_Validations__c,
      'should update Skip Validation flag to SkipValidation'
    );
  }

  @isTest
  static void setSkipValidationOnOwnerChangeNegativeTest() {
    registerMocks();
    //GIVEN records, oldMap
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id ownerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    String copyLeadId = 'copyLeadId';
    List<Lead> records = new List<Lead>{
      new Lead(Id = leadId, OwnerId = ownerId, Skip_Validations__c = copyLeadId)
    };

    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        Id = leadId,
        OwnerId = ownerId,
        Skip_Validations__c = copyLeadId
      )
    };

    userRepoMock.mock('checkProfile', true);

    //WHEN calling a method
    Test.startTest();
    CommercialLeadActions.setSkipValidationOnOwnerChange(records, oldMap);
    Test.stopTest();

    //THEN it should remain to 'copyLeadId'
    Assert.areEqual(
      copyLeadId,
      records[0].Skip_Validations__c,
      'Skip Validation should remain to copyLeadId'
    );
  }
}
