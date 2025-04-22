/**
 *
 * @author Tan Phan
 * @since 05/2023
 * @description Contains unit-tests for {@link CCRMFinancialAccountRoleActions}
 */
@IsTest
private class CCRMFinancialAccountRoleActionsTest {
  static Faker faker = new Faker('AU');
  static Lib_MockProvider financialAccountRoleRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    financialAccountRoleRepoMock = Lib_MockProvider.forType(
      FinancialAccountRoleRepository.class
    );
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @TestSetup
  static void makeData() {
    CCRMTestDataFactory.getCCRMIntegrationUser();
    System.runAs(new User(Id = UserInfo.getUserId())) {
      CCRMTestDataFactory.CreatePersonAccount();
      CCRMTestDataFactory.createBusinessAccount();
      CCRMTestDataFactory.createSystemCustomer();
    }
  }

  @IsTest
  static void testDeactivateDuplicateRecordsInsert() {
    registerMocks();
    Id accId = Lib_FakeIdGenerator.getMockId(Account.getSobjectType());
    Id faId = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.getSobjectType()
    );
    Id farId = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccountRole__c.getSobjectType()
    );
    Id far2Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccountRole__c.getSobjectType()
    );

    //GIVEN Financial Account Role Record
    FinServ__FinancialAccount__c fa = new FinServ__FinancialAccount__c(
      Id = faId,
      Account_Key__c = 'accountkey123'
    );
    Account acc = new Account(Id = accId, External_Id__c = 'externalid123');
    List<FinServ__FinancialAccountRole__c> farList = new List<FinServ__FinancialAccountRole__c>{
      new FinServ__FinancialAccountRole__c(
        Id = farId,
        FinServ__Role__c = 'Primary Owner',
        FinServ__RelatedAccount__r = acc,
        FinServ__FinancialAccount__r = fa,
        FinServ__Active__c = true
      )
    };
    FinServ__FinancialAccountRole__c far2Rec = new FinServ__FinancialAccountRole__c(
      Id = far2Id,
      FinServ__Role__c = 'Additional Owner',
      FinServ__RelatedAccount__r = acc,
      FinServ__FinancialAccount__r = fa,
      FinServ__Active__c = true
    );
    List<FinServ__FinancialAccountRole__c> farMockList = new List<FinServ__FinancialAccountRole__c>{
      far2Rec,
      farList[0]
    };

    financialAccountRoleRepoMock.mock(
      'getActiveFinancialAccountRoleRecords',
      farMockList
    );

    List<Database.UpsertResult> upsertResult = new List<Database.UpsertResult>{
      TestUtil.getMockUpsertResult(
        '{"id":"0039p00000O5p46AAB","success":true,"errors":[]}'
      )
    };
    dmlRepoMock.mock('updateRecords', upsertResult);

    //WHEN calling deactivateDuplicateRecords method
    Test.startTest();
    CCRMFinancialAccountRoleActions.deactivateDuplicateRecords(farList, null);
    Test.stopTest();

    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );

    List<FinServ__FinancialAccountRole__c> updateRecordList = (List<FinServ__FinancialAccountRole__c>) dmlRepoMock.getHistory(
        'doUpdate'
      )
      .getParam('records');

    //THEN It should insert new Financial Account Role Record and Update Existing FAR Record to inActive
    Assert.isFalse(
      updateRecordList[0].FinServ__Active__c,
      'More than one Active Financial Account Roles'
    );
  }

  @IsTest
  static void testMapRoleTypeToRole() {
    //GIVEN Financial Account Role record with only Role_Type__c specified
    FinServ__FinancialAccountRole__c farPrimary = new FinServ__FinancialAccountRole__c(
      Role_Type__c = 'SOL'
    );
    FinServ__FinancialAccountRole__c farOther = new FinServ__FinancialAccountRole__c(
      Role_Type__c = 'INVALID'
    );
    //WHEN the record is inserted

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      CCRMFinancialAccountRoleActions.mapRoleTypeToRole(
        new List<FinServ__FinancialAccountRole__c>{ farPrimary, farOther }
      );
    }
    Test.stopTest();
    //THEN the FinServ__Role__c should be populated accordingly
    Assert.areEqual(
      'Primary Owner',
      farPrimary.FinServ__Role__c,
      'Role should be updated to Primary Owner'
    );
    Assert.areEqual(
      'Other',
      farOther.FinServ__Role__c,
      'Role should be updated to Other Owner when no mapping exists for the given role type'
    );
  }

  @IsTest
  static void testSetRecordType() {
    Financial_Account_Settings__c faSettings = Financial_Account_Settings__c.getOrgDefaults();
    Account orgFaOwner = [
      SELECT Id
      FROM Account
      WHERE RecordTypeId = :CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID
      LIMIT 1
    ];
    Account individualFaOwner = [
      SELECT Id
      FROM Account
      WHERE RecordTypeId = :CCRMConstants.ACCOUNT_PERSON_RT_ID
    ];
    FinServ__FinancialAccountRole__c orgFar = new FinServ__FinancialAccountRole__c(
      FinServ__RelatedAccount__c = orgFaOwner.Id,
      FinServ__Active__c = true,
      External_Id__c = faker.randomString(10)
    );
    FinServ__FinancialAccountRole__c individualFar = new FinServ__FinancialAccountRole__c(
      FinServ__RelatedAccount__c = individualFaOwner.Id,
      FinServ__Active__c = true,
      External_Id__c = faker.randomString(10)
    );
    FinServ__FinancialAccountRole__c farWithSystemRelatedCustomer = new FinServ__FinancialAccountRole__c(
      FinServ__RelatedAccount__c = faSettings.System_Customer_Id__c,
      FinServ__Active__c = true,
      External_Id__c = faker.randomString(10)
    );
    FinServ__FinancialAccountRole__c farWithNullExternalId = new FinServ__FinancialAccountRole__c(
      RecordTypeId = CCRMConstants.FAR_CONTACT_RT_ID,
      FinServ__Active__c = true,
      FinServ__RelatedAccount__c = orgFaOwner.Id
    );

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      CCRMFinancialAccountRoleActions.setRecordType(
        new List<FinServ__FinancialAccountRole__c>{
          orgFar,
          individualFar,
          farWithSystemRelatedCustomer,
          farWithNullExternalId
        }
      );
    }
    Test.stopTest();

    Assert.areEqual(
      CCRMConstants.FAR_SYSTEM_RT_ID,
      farWithSystemRelatedCustomer.RecordTypeId,
      'FAR Record Type should be System Role if related customer is System'
    );
    Assert.isNull(
      farWithSystemRelatedCustomer.External_Id__c,
      'FAR External ID should be null when Record Type is updated to System Role'
    );
    Assert.areEqual(
      CCRMConstants.FAR_SYSTEM_RT_ID,
      farWithNullExternalId.RecordTypeId,
      'FAR Record Type should be System Role if external ID is null'
    );
    Assert.areEqual(
      CCRMConstants.FAR_ACCOUNT_RT_ID,
      orgFar.RecordTypeId,
      'FAR Record Type should be set to Account Role if external ID has value and related to a real non-individual customer'
    );
    Assert.areEqual(
      CCRMConstants.FAR_CONTACT_RT_ID,
      individualFar.RecordTypeId,
      'FAR Record Type should be set to Contact Role if external ID has value and related to a real individual customer'
    );
  }

  @IsTest
  static void testGetFinancialAccountsToUpdate() {
    Id accountId = Lib_FakeIdGenerator.getMockId(Account.SObjectType);
    FinServ__FinancialAccount__c financialAccount = new FinServ__FinancialAccount__c();
    financialAccount.Id = Lib_FakeIdGenerator.getMockId(
      FinServ__FinancialAccount__c.SObjectType
    );
    financialAccount.FinServ__PrimaryOwner__c = accountId;

    FinServ__FinancialAccountRole__c testFinAccountRole = new FinServ__FinancialAccountRole__c();
    testFinAccountRole.FinServ__FinancialAccount__c = financialAccount.Id;

    //Tests when there is no Financial Account exists for the Financial Account Role record
    Map<Id, FinServ__FinancialAccount__c> financialAccountsMap = new Map<Id, FinServ__FinancialAccount__c>();
    List<FinServ__FinancialAccount__c> finAccountsToUpdate = CCRMFinancialAccountRoleActions.getFinancialAccountsToUpdate(
      new List<FinServ__FinancialAccountRole__c>{ testFinAccountRole },
      financialAccountsMap
    );
    Assert.areEqual(
      0,
      finAccountsToUpdate.size(),
      'Financial Account should not be updated as there is no Financial Account exists for FAR record'
    );

    //Tests when FAR's related account and FinAccount's Primary Owner are same
    financialAccountsMap = new Map<Id, FinServ__FinancialAccount__c>{
      financialAccount.Id => financialAccount
    };
    testFinAccountRole.FinServ__RelatedAccount__c = accountId;
    finAccountsToUpdate = CCRMFinancialAccountRoleActions.getFinancialAccountsToUpdate(
      new List<FinServ__FinancialAccountRole__c>{ testFinAccountRole },
      financialAccountsMap
    );
    Assert.areEqual(
      0,
      finAccountsToUpdate.size(),
      'Financial Account should not be updated as FAR\'s Related Account already matches the Financial Account\'s primary owner'
    );

    //Tests when FAR's related account and FinAccount's Primary Owner are different
    testFinAccountRole.FinServ__RelatedAccount__c = Lib_FakeIdGenerator.getMockId(
      Account.SObjectType
    );
    finAccountsToUpdate = CCRMFinancialAccountRoleActions.getFinancialAccountsToUpdate(
      new List<FinServ__FinancialAccountRole__c>{ testFinAccountRole },
      financialAccountsMap
    );
    Assert.areEqual(
      1,
      finAccountsToUpdate.size(),
      'FAR record should should be updated'
    );

    //Below LOC tests an orchestration function
    CCRMFinancialAccountRoleActions.updateFinancialAccountOwner(
      new List<FinServ__FinancialAccountRole__c>{ testFinAccountRole }
    );
  }

  @IsTest
  static void testDeleteInactiveRecords() {
    Account normalFaOwner = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Test Pty Ltd'
    ];

    //GIVEN a Financial Account with a few linked FAR
    FinServ__FinancialAccount__c fa = new FinServ__FinancialAccount__c();
    insert fa;

    FinServ__FinancialAccountRole__c deactivatedFar = new FinServ__FinancialAccountRole__c(
      RecordTypeId = CCRMConstants.FAR_CONTACT_RT_ID,
      FinServ__FinancialAccount__c = fa.Id,
      FinServ__RelatedAccount__c = normalFaOwner.Id,
      Finserv__Role__c = 'Additional Owner',
      External_Id__c = faker.randomString(10)
    );
    FinServ__FinancialAccountRole__c endDatedFar = new FinServ__FinancialAccountRole__c(
      RecordTypeId = CCRMConstants.FAR_CONTACT_RT_ID,
      FinServ__FinancialAccount__c = fa.Id,
      FinServ__RelatedAccount__c = normalFaOwner.Id,
      Finserv__Role__c = 'Administrator',
      External_Id__c = faker.randomString(10)
    );
    FinServ__FinancialAccountRole__c manualFar = new FinServ__FinancialAccountRole__c(
      RecordTypeId = CCRMConstants.FAR_CONTACT_RT_ID,
      FinServ__FinancialAccount__c = fa.Id,
      FinServ__RelatedAccount__c = normalFaOwner.Id,
      Finserv__Role__c = 'Advisor'
    );

    insert new List<FinServ__FinancialAccountRole__c>{
      deactivatedFar,
      endDatedFar
    };

    //WHEN a FAR is either deactivated or end-dated, or a FAR is inserted without External ID
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      Test.startTest();
      deactivatedFar.FinServ__Active__c = false;
      endDatedFar.FinServ__EndDate__c = System.today();
      upsert new List<FinServ__FinancialAccountRole__c>{
        deactivatedFar,
        endDatedFar,
        manualFar
      };
      Test.stopTest();
    }

    //THEN the deactived FAR should be deleted
    Assert.areEqual(
      CCRMConstants.FAR_SYSTEM_RT_ID,
      [
        SELECT RecordTypeId
        FROM FinServ__FinancialAccountRole__c
        WHERE Id = :deactivatedFar.Id
      ]
      .RecordTypeId,
      'Inactive FAR record type should be set to System Role'
    );
    //AND the end-dated FAR should be deleted
    Assert.areEqual(
      CCRMConstants.FAR_SYSTEM_RT_ID,
      [
        SELECT RecordTypeId
        FROM FinServ__FinancialAccountRole__c
        WHERE Id = :endDatedFar.Id
      ]
      .RecordTypeId,
      'End-dated FAR record type should be set to System Role'
    );
    //AND the newly inserted FAR without external ID should be deleted
    Assert.areEqual(
      CCRMConstants.FAR_SYSTEM_RT_ID,
      [
        SELECT RecordTypeId
        FROM FinServ__FinancialAccountRole__c
        WHERE
          FinServ__FinancialAccount__c = :fa.Id
          AND Finserv__Role__c = 'Advisor'
      ]
      .RecordTypeId,
      'Manually created FAR without external ID record type should be set to System Role'
    );
  }

  @IsTest
  static void testDeactivateLastPrimaryOwner() {
    Financial_Account_Settings__c faSettings = Financial_Account_Settings__c.getOrgDefaults();
    Account normalFaOwner = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Test Pty Ltd'
    ];

    FinServ__FinancialAccount__c fa = new FinServ__FinancialAccount__c(
      FinServ__PrimaryOwner__c = normalFaOwner.Id
    );
    insert fa;

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      FinServ__FinancialAccountRole__c far = [
        SELECT Id
        FROM FinServ__FinancialAccountRole__c
        WHERE FinServ__FinancialAccount__c = :fa.Id
      ];

      far.FinServ__EndDate__c = System.today();
      update far;
    }
    Test.stopTest();

    fa = [
      SELECT FinServ__PrimaryOwner__c
      FROM FinServ__FinancialAccount__c
      WHERE Id = :fa.Id
    ];
    Assert.areEqual(
      faSettings.System_Customer_Id__c,
      fa.FinServ__PrimaryOwner__c,
      'Primary Owner should be set to System'
    );
    Assert.isTrue(
      [
        SELECT COUNT()
        FROM FinServ__FinancialAccountRole__c
        WHERE
          RecordTypeId = :CCRMConstants.FAR_SYSTEM_RT_ID
          AND FinServ__RelatedAccount__c = :faSettings.System_Customer_Id__c
          AND FinServ__Active__c = TRUE
      ] == 1,
      'A System FAR should be created when last Primary Owner FAR is end-dated'
    );
  }
}