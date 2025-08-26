/**
 * @author       : Naman Garg
 * @since        : Nov 2024
 * @description  : Test class for CommercialLeadActions
 **/
@isTest
public class CommercialLeadActionsTest {
  static Lib_MockProvider leadActionRepoMock;
  static Lib_MockProvider campMembActionRepoMock;
  static Lib_MockProvider taskMockProvider;
  static Lib_MockProvider userRepoMock;
  static Lib_MockProvider userActionsRepositoryMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    leadActionRepoMock = Lib_MockProvider.forType(LeadActionsRepository.class);
    campMembActionRepoMock = Lib_MockProvider.forType(
      CampaignMemberActionRepository.class
    );
    taskMockProvider = Lib_MockProvider.forType(TaskActionRepository.class);
    userRepoMock = Lib_MockProvider.forType(UserInfoRepository.class);
    userActionsRepositoryMock = Lib_MockProvider.forType(
      UserActionsRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
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
    leadActionRepoMock.mock(
      'getAccountAccountRelations',
      accountAccountRelationList
    );

    List<Account> accountMap = new List<Account>();
    accountmap.add(
      new Account(
        Id = relatedAccountIdNew,
        Name = 'testAccount',
        RecordTypeId = RTAccount.clgAccount,
        CLG__c = '1567'
      )
    );
    leadActionRepoMock.mock('getAccountList', accountMap);

    userRepoMock.mock('checkProfile', true);
    //WHEN calling a method
    Test.startTest();
    CommercialLeadActions.populateInfo(records, oldMap);
    Test.stopTest();

    //THEN it should update CLG Name & CLG Id on Lead
    Assert.areEqual(
      null,
      records[0].CLG_Name__c,
      'Should update a null CLG Name on lead on updation'
    );
  }

  @isTest
  static void populateCLGforCLGAccountTest() {
    registerMocks();
    //GIVEN list of lead records and map of Account-Account relations
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id relatedAccountIdOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountIdNew = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Lead> records = new List<Lead>{
      new Lead(Id = leadId, FinServ__RelatedAccount__c = relatedAccountIdNew)
    };
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        Id = leadId,
        FinServ__RelatedAccount__c = relatedAccountIdOld
      )
    };

    leadActionRepoMock.mock(
      'getAccountAccountRelations',
      new List<FinServ__AccountAccountRelation__c>()
    );

    List<Account> accountMap = new List<Account>();
    accountmap.add(
      new Account(
        Id = relatedAccountIdNew,
        Name = 'testAccount',
        RecordTypeId = RTAccount.clgAccount,
        CLG__c = '1567'
      )
    );
    leadActionRepoMock.mock('getAccountList', accountMap);
    userRepoMock.mock('checkProfile', true);
    //WHEN calling a method
    Test.startTest();
    CommercialLeadActions.populateInfo(records, oldMap);
    Test.stopTest();

    //THEN it should update CLG Name & CLG Id on Lead
    Assert.areEqual(
      '1567',
      records[0].CLG_Id__c,
      'Should update a null CLG Name on lead on updation'
    );
  }

  @isTest
  static void populateCLGforNonCLGAccountTest() {
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
        FinServ__RelatedAccount__r = new Account(
          CLG__c = '1234',
          RecordTypeId = RTAccount.clgAccount
        )
      )
    };
    leadActionRepoMock.mock(
      'getAccountAccountRelations',
      accountAccountRelationList
    );

    List<Account> accountMap = new List<Account>();
    accountmap.add(
      new Account(
        Id = relatedAccountIdNew,
        Name = 'testAccount',
        CLG__c = '1567'
      )
    );
    leadActionRepoMock.mock('getAccountList', accountMap);
    userRepoMock.mock('checkProfile', true);
    //WHEN calling a method
    Test.startTest();
    CommercialLeadActions.populateInfo(records, oldMap);
    Test.stopTest();
    //THEN it should update CLG Name & CLG Id on Lead
    Assert.areEqual(
      '1234',
      records[0].CLG_Id__c,
      'Should update a null CLG Name on lead on updation'
    );
  }

  @isTest
  static void validateCLGTest() {
    registerMocks();
    //GIVEN list of lead records and map of Account-Account relations
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id relatedAccountIdOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountIdNew = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id noclgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Lead> records = new List<Lead>{
      new Lead(
        Id = leadId,
        FinServ__RelatedAccount__c = relatedAccountIdNew,
        CLG_Name__c = noclgAccountId
      )
    };
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        Id = leadId,
        FinServ__RelatedAccount__c = relatedAccountIdOld,
        CLG_Name__c = clgAccountId
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
    leadActionRepoMock.mock(
      'getAccountAccountRelations',
      accountAccountRelationList
    );

    List<Account> accountMap = new List<Account>();
    accountmap.add(
      new Account(
        Id = noclgAccountId,
        Name = 'testAccount',
        RecordTypeId = RTAccount.clgAccount,
        CLG__c = '1567'
      )
    );
    leadActionRepoMock.mock('getAccountList', accountMap);
    userRepoMock.mock('checkProfile', true);

    //WHEN calling a method
    Test.startTest();
    CommercialLeadActions.validateAndPopulateInfo(records, oldMap);
    Test.stopTest();
    //THEN it should update CLG Name & CLG Id on Lead
    Assert.isNotNull(
      records[0].CLG_Name__c,
      'Should update CLG Name on lead on updation with no validation error'
    );
  }

  @isTest
  static void validateCLGGetErrorTest() {
    String errorMessage = '';
    registerMocks();
    //GIVEN list of lead records and map of Account-Account relations
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id relatedAccountIdOld = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id relatedAccountIdNew = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id clgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Id noclgAccountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);

    List<Lead> records = new List<Lead>{
      new Lead(
        Id = leadId,
        FinServ__RelatedAccount__c = relatedAccountIdNew,
        CLG_Name__c = noclgAccountId
      )
    };
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        Id = leadId,
        FinServ__RelatedAccount__c = relatedAccountIdNew,
        CLG_Name__c = clgAccountId
      )
    };

    List<FinServ__AccountAccountRelation__c> accountAccountRelationList = new List<FinServ__AccountAccountRelation__c>{
      new FinServ__AccountAccountRelation__c(
        Id = Lib_FakeIdGenerator.getMockId(
          FinServ__AccountAccountRelation__c.SObjectType
        ),
        FinServ__Account__c = relatedAccountIdOld,
        FinServ__RelatedAccount__c = clgAccountId,
        FinServ__RelatedAccount__r = new Account(CLG__c = '1234')
      )
    };
    leadActionRepoMock.mock(
      'getAccountAccountRelations',
      accountAccountRelationList
    );

    List<Account> accountMap = new List<Account>();
    accountmap.add(
      new Account(
        Id = relatedAccountIdNew,
        Name = 'testAccount',
        RecordTypeId = RTAccount.clgAccount,
        CLG__c = '1567'
      )
    );
    leadActionRepoMock.mock('getAccountList', accountMap);
    userRepoMock.mock('checkProfile', true);

    //WHEN calling a method
    Test.startTest();
    CommercialLeadActions.validateAndPopulateInfo(records, oldMap);

    Test.stopTest();
    if (records[0].hasErrors()) {
      List<Database.Error> errors = records[0].getErrors();
      errorMessage = errors[0].getMessage();
    }
    //THEN it should update CLG Name & CLG Id on Lead
    Assert.areEqual(
      System.Label.Select_Related_CLG_Error_Message,
      errorMessage,
      'Should give validation error to select a related CLG only'
    );
  }

  @isTest
  static void testMapLeadStatusWithReferralStatus() {
    String mockLeadID = (String) Lib_FakeIdGenerator.getMockId(
      Lead.getSObjectType()
    );
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      mockLeadID => new Lead(
        Id = mockLeadID,
        RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID,
        Status = 'Assigned',
        FinServ__ReferredByUser__c = (String) Lib_FakeIdGenerator.getMockId(
          User.getSObjectType()
        )
      )
    };
    List<lead> leadList = new List<Lead>{
      new Lead(
        Id = mockLeadID,
        RecordTypeId = CCRMConstants.CCRM_LEAD_RT_ID,
        Status = 'Outcome',
        Referral_Status__c = 'In Progress',
        Lead_Outcome__c = 'Opportunity Identified'
      )
    };
    Test.startTest();
    CommercialLeadActions.mapLeadStatusWithReferralStatus(leadList, oldMap);
    Test.stopTest();
    Assert.areEqual(
      'In Progress',
      leadList[0].Referral_Status__c,
      'Referral status should be Qualified'
    );
  }

  @isTest
  static void populateRegisteredCompanyForIndividualTest() {
    //GIVEN Lead
    List<Lead> leadList = new List<Lead>{
      new Lead(
        RecordTypeId = RTLead.commercialLead,
        Entity_Type__c = 'Individual',
        Registered_Company__c = 'Yes'
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialLeadActions.populateRegisteredCompanyForIndividual(leadList);
    Test.stopTest();

    //THEN it should populate Registered Company field to No
    Assert.areEqual(
      'No',
      leadList[0].Registered_Company__c,
      'Should update the Registered company to No for entity type Individual'
    );
  }

  @isTest
  static void populateRegisteredCompanyForIndividualNegativeTest() {
    //GIVEN Lead
    List<Lead> leadList = new List<Lead>{
      new Lead(
        RecordTypeId = RTLead.commercialLead,
        Entity_Type__c = 'Sole Trader',
        Registered_Company__c = 'Yes'
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialLeadActions.populateRegisteredCompanyForIndividual(leadList);
    Test.stopTest();

    //THEN it should populate Registered Company field to No
    Assert.areEqual(
      'Yes',
      leadList[0].Registered_Company__c,
      'Should not update the Registered company to No for entity type other than Individual'
    );
  }

  @isTest
  static void updateExpirydateTest() {
    //GIVEN Lead List and old Map
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = leadId,
        RecordTypeId = RTLead.commercialLead,
        FinServ__ReferredByUser__c = userId
      )
    };

    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        RecordTypeId = RTLead.referralLead,
        Expiry_Date__c = System.Today(),
        FinServ__ReferredByUser__c = userId
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialLeadActions.updateExpirydate(leadList, oldMap);
    Test.stopTest();

    //THEN it should update Expiry date to 14 days
    Assert.areEqual(
      DateTimeUtils.getNextWeekdayDate(14),
      leadList[0].Expiry_Date__c,
      'Should update the expiry date.'
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

  @isTest
  static void testPopulatePrimaryContactMethodWork() {
    String mockLeadID = (String) Lib_FakeIdGenerator.getMockId(
      Lead.getSObjectType()
    );
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = mockLeadID,
        Lead_Originator__c = 'UNICA',
        Work_Phone__c = '+61412345678',
        Primary_Contact_Method__c = 'Mobile'
      )
    };
    Test.startTest();
    CommercialLeadActions.populatePrimaryContactMethod(leadList);
    Test.stopTest();
    Assert.areEqual(
      'Work Phone',
      leadList[0].Primary_Contact_Method__c,
      'Primary Contact Method should be work phone'
    );
  }

  @isTest
  static void testPopulatePrimaryContactMethodHome() {
    String mockLeadID = (String) Lib_FakeIdGenerator.getMockId(
      Lead.getSObjectType()
    );
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = mockLeadID,
        Lead_Originator__c = 'Adobe',
        Home_Phone__c = '+61412345678',
        Primary_Contact_Method__c = 'Mobile'
      )
    };
    Test.startTest();
    CommercialLeadActions.populatePrimaryContactMethod(leadList);
    Test.stopTest();
    Assert.areEqual(
      'Home Phone',
      leadList[0].Primary_Contact_Method__c,
      'Primary Contact Method should be home phone'
    );
  }

  @isTest
  static void testPopulatePrimaryContactMethodNull() {
    String mockLeadID = (String) Lib_FakeIdGenerator.getMockId(
      Lead.getSObjectType()
    );
    List<Lead> leadList = new List<Lead>{
      new Lead(
        Id = mockLeadID,
        Lead_Originator__c = 'UNICA',
        Primary_Contact_Method__c = 'Mobile'
      )
    };
    Test.startTest();
    CommercialLeadActions.populatePrimaryContactMethod(leadList);
    Test.stopTest();
    Assert.isNull(
      leadList[0].Primary_Contact_Method__c,
      'Primary Contact Method should be null'
    );
  }

  @isTest
  static void checkForExistingCustomerTest() {
    registerMocks();
    Id accId2 = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Account acc = new Account(
      Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
      Finserv__Status__c = 'New'
    );
    Lead lead1 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = RTLead.commercialLead,
      FinServ__RelatedAccount__c = accId2
    );
    Lead lead2 = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Lead.SObjectType),
      RecordTypeId = RTLead.commercialLead,
      FinServ__RelatedAccount__c = acc.Id
    );
    leadActionRepoMock.mock('getAccountRecords', new List<Account>{ acc });
    Test.startTest();
    CommercialLeadActions.checkForExistingCustomer(
      new List<Lead>{ lead1, lead2 },
      null
    );
    Test.stopTest();
    Assert.areEqual(
      lead1.New_to_Bank__c,
      'No',
      'checkForExistingCustomer is not updating lead record with No'
    );
    Assert.areEqual(
      lead2.New_to_Bank__c,
      'Yes',
      'checkForExistingCustomer is not updating lead record with Yes'
    );
  }

  @isTest
  static void testCheckIfSecondaryCustomerNeedsContainsCustomerNeeds() {
    String customerNeedsError = 'Secondary Customer Needs should not be the same as Customer Needs.';
    Lead lead;
    Map<Id, Lead> oldMap;
    List<Database.Error> errors;
    Database.Error error;

    lead = new Lead(
      Id = Lib_FakeIdGenerator.getMockId(Schema.Lead.getSObjectType()),
      FinServ__ExpressedInterest__c = 'Purchasing Property',
      Secondary_Customer_Needs__c = 'Purchasing Property',
      RecordTypeId = RTLead.commercialLead
    );

    oldMap = new Map<Id, Lead>{
      lead.Id => new Lead(
        Id = lead.Id,
        FinServ__ExpressedInterest__c = 'Other',
        RecordTypeId = RTLead.commercialLead
      )
    };

    Test.startTest();
    CommercialLeadActions.checkIfSecondaryCustomerNeedsContainsCustomerNeeds(
      new List<Lead>{ lead },
      oldMap
    );
    Test.stopTest();
    errors = lead.getErrors();
    error = errors.get(0);
    Assert.areEqual(1, errors.size(), 'Lead updated failed');
    Assert.areEqual(
      customerNeedsError,
      error.getMessage(),
      'Lead updated successfully'
    );
  }

  @isTest
  static void sendLeadOwnerUpdateToUnicaTest() {
    registerMocks();
    userActionsRepositoryMock.mock('isIntegrationUser', false);
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.SObjectType);
    Id userId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id updatedOwnerId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Id accId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    Map<Id, Account> mapOfAccount = new Map<Id, Account>{
      accId => new Account(
        Id = accId,
        Source_System_Name__c = 'CAP-CIS',
        Source_System_ID__c = '1245'
      )
    };
    userActionsRepositoryMock.mock(
      'getUserMapFromUserIds',
      new Map<Id, User>{
        userId => new User(id = updatedOwnerId, Lan_Id__c = 'test123')
      }
    );
    leadActionRepoMock.mock('getAccountRecords', mapOfAccount);
    Lead newLead = new Lead(
      Id = leadId,
      RecordTypeId = RTLead.commercialLead,
      Status = 'Complete',
      Lead_Originator__c = 'UNICA',
      ownerId = updatedOwnerId,
      FinServ__ReferredByUser__c = null
    );
    Lead oldLead = new Lead(
      Id = leadId,
      RecordTypeId = RTLead.commercialLead,
      Status = 'Complete',
      Lead_Originator__c = 'UNICA',
      ownerId = userId,
      FinServ__ReferredByUser__c = null
    );
    Map<Id, Lead> oldMap = new Map<Id, Lead>{ oldLead.Id => oldLead };
    Test.startTest();
    CommercialLeadActions.sendLeadOwnerUpdateToUnica(
      new List<Lead>{ newLead },
      oldMap
    );
    Test.stopTest();
    Assert.isNotNull(
      dmlRepoMock.getHistory('doPublish'),
      'sendLeadOwnerUpdateToUnica did not publish Event successfully'
    );
  }

  @isTest
  static void setCompanyToBlankForIndividualTest() {
    //GIVEN records, oldMap
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.getSObjectType());
    List<Lead> records = new List<Lead>{
      new Lead(Id = leadId, Entity_Type__c = 'Individual', Company = 'ANZ Corp')
    };
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        Id = leadId,
        Entity_Type__c = 'Sole Trader',
        Company = 'ANZ Corp'
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialLeadActions.setCompanyToBlankForIndividual(records, oldMap);
    Test.stopTest();

    //THEN it should set the company to blank
    Assert.isNull(records[0].Company, 'Company should set to blank');
  }

  @isTest
  static void setCompanyToBlankForIndividualNegativeTest() {
    //GIVEN records, oldMap
    Id leadId = Lib_FakeIdGenerator.getMockId(Lead.getSObjectType());
    List<Lead> records = new List<Lead>{
      new Lead(Id = leadId, Entity_Type__c = 'Trust', Company = 'ANZ Corp')
    };
    Map<Id, Lead> oldMap = new Map<Id, Lead>{
      leadId => new Lead(
        Id = leadId,
        Entity_Type__c = 'Sole Trader',
        Company = 'ANZ Corp'
      )
    };

    //WHEN calling a method
    Test.startTest();
    CommercialLeadActions.setCompanyToBlankForIndividual(records, oldMap);
    Test.stopTest();

    //THEN it should not set the company to blank
    Assert.isNotNull(records[0].Company, 'Company should not set to blank');
  }
}
