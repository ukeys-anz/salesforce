/**
 *
 * @author Tan Phan
 * @since 05/2023
 * @description Contains unit-tests for {@link CCRMFinancialAccountRoleActions}
 */
@IsTest
private class CCRMFinancialAccountRoleActionsTest {
  static Faker faker = new Faker('AU');

  @TestSetup
  static void makeData() {
    User integrationUser = CCRMTestDataFactory.getCCRMIntegrationUser();
    System.runAs(new User(Id = UserInfo.getUserId())) {
      CCRMTestDataFactory.createBusinessAccount();
      CCRMTestDataFactory.createSystemCustomer();
    }
  }

  @IsTest
  static void testMapRoleTypeToRole() {
    //GIVEN Financial Account Role record with only Role_Type__c specified
    FinServ__FinancialAccountRole__c farPrimary = new FinServ__FinancialAccountRole__c(
      Role_Type__c = 'SOL'
    );
    FinServ__FinancialAccountRole__c farAdditional = new FinServ__FinancialAccountRole__c(
      Role_Type__c = 'INVALID'
    );
    //WHEN the record is inserted

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      CCRMFinancialAccountRoleActions.mapRoleTypeToRole(
        new List<FinServ__FinancialAccountRole__c>{ farPrimary, farAdditional }
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
      'Additional Owner',
      farAdditional.FinServ__Role__c,
      'Role should be updated to Additional Owner when no mapping exists for the given role type'
    );
  }

  @IsTest
  static void testSetRecordType() {
    Financial_Account_Settings__c faSettings = Financial_Account_Settings__c.getOrgDefaults();
    Account normalFaOwner = [
      SELECT Id
      FROM Account
      WHERE Name = 'Test Pty Ltd'
    ];
    FinServ__FinancialAccountRole__c farNormal = new FinServ__FinancialAccountRole__c(
      FinServ__RelatedAccount__c = normalFaOwner.Id,
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
      FinServ__RelatedAccount__c = normalFaOwner.Id
    );

    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      CCRMFinancialAccountRoleActions.setRecordType(
        new List<FinServ__FinancialAccountRole__c>{
          farNormal,
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
    Assert.areEqual(
      CCRMConstants.FAR_SYSTEM_RT_ID,
      farWithNullExternalId.RecordTypeId,
      'FAR Record Type should be System Role if external ID is null'
    );
    Assert.areEqual(
      CCRMConstants.FAR_CONTACT_RT_ID,
      farNormal.RecordTypeId,
      'FAR Record Type should be set to Contact Role if external ID has value and related to a real customer'
    );
  }

  @IsTest
  static void testUpdatePrimaryOwner() {
    Financial_Account_Settings__c faSettings = Financial_Account_Settings__c.getOrgDefaults();
    Account normalFaOwner = [
      SELECT Id, Name
      FROM Account
      WHERE Name = 'Test Pty Ltd'
    ];

    //GIVEN a Financial Account initially created without Primary Owner
    FinServ__FinancialAccount__c fa = new FinServ__FinancialAccount__c();
    insert fa;

    //WHEN a new FAR with role Primary Owner is created for the above FA
    FinServ__FinancialAccountRole__c newFar = new FinServ__FinancialAccountRole__c(
      RecordTypeId = CCRMConstants.FAR_CONTACT_RT_ID,
      FinServ__FinancialAccount__c = fa.Id,
      FinServ__RelatedAccount__c = normalFaOwner.Id,
      // FinServ__Role__c = 'Primary Owner',
      Role_Type__c = 'SOL',
      External_Id__c = faker.randomString(10)
    );
    Test.startTest();
    System.runAs(CCRMTestDataFactory.getCCRMIntegrationUser()) {
      insert newFar;
    }
    Test.stopTest();

    //THEN the FA primary owner will be updated to the new Account specified in the new FAR
    fa = [
      SELECT Finserv__PrimaryOwner__r.Name
      FROM FinServ__FinancialAccount__c
      WHERE Id = :fa.Id
    ];
    Assert.areEqual(
      normalFaOwner.Name,
      fa.Finserv__PrimaryOwner__r.Name,
      'FA primary owner should be updated to the new Account'
    );
    newFar = [
      SELECT FinServ__Role__c
      FROM FinServ__FinancialAccountRole__c
      WHERE Id = :newFar.Id
    ];
    Assert.areEqual(
      'Primary Owner',
      newFar.FinServ__Role__c,
      'FAR Role should be updated to Primary Owner'
    );
  }

  @IsTest
  static void testDeleteInactiveRecords() {
    Financial_Account_Settings__c faSettings = Financial_Account_Settings__c.getOrgDefaults();
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

      far.FinServ__Editable__c = true;
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
