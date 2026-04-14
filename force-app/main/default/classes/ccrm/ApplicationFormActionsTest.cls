/**
 * @author Ali Mujtaba | Salesforce | 03-11-2025
 * @since November 2025
 * @description Test class for ApplicationFormActions actions
 */
@isTest
private class ApplicationFormActionsTest {
  /**
   * @description Setup common test data
   */
  @testSetup
  private static void setup() {
    List<User> testUserList = new List<User>();
    List<PermissionSetAssignment> psAssigments = new List<PermissionSetAssignment>();

    Profile stdUserProfile = CommonUtil.getProfileByName('ANZx Standard User');
    UserRole anzxRole = CommonUtil.getUserRoleByDevName('ANZx');

    // Create AMBIT Test User with Permission
    User u1 = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'AMBIT_Test_User_With_PS',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => anzxRole.Id
      }
    );
    testUserList.add(u1);

    // Create AMBIT Test User without Permission
    User u2 = TestUtil.createTestUser(
      new Map<String, Object>{
        'FirstName' => 'AMBIT_Test_User_Without_PS',
        'ProfileId' => stdUserProfile.Id,
        'UserRoleId' => anzxRole.Id
      }
    );
    testUserList.add(u2);
    insert testUserList;

    // Add AMBIT related PS on test users
    PermissionSet ps = CommonUtil.getPermissionSetByName('AMBIT_Data_Sync');
    psAssigments.add(TestUtil.createPSAssignment(u1.id, ps.Id));
    insert psAssigments;
  }

  private static final Id FAKER_AF_ID = Lib_FakeIdGenerator.getMockId(
    ApplicationForm.getSObjectType()
  );
  private static final Id FAKER_AFP_ID = Lib_FakeIdGenerator.getMockId(
    ApplicationFormProduct.getSObjectType()
  );
  private static final Id FAKER_OPP_ID = Lib_FakeIdGenerator.getMockId(
    Opportunity.getSObjectType()
  );
  private static final Id BROKER_CONTACT_ID_ONE = Lib_FakeIdGenerator.getMockId(
    Contact.getSObjectType()
  );
  private static final Id BROKER_CONTACT_ID_TWO = Lib_FakeIdGenerator.getMockId(
    Contact.getSObjectType()
  );
  private static final Id FAKER_ACC_ID = Lib_FakeIdGenerator.getMockId(
    Account.getSObjectType()
  );

  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider commAppFormProductMock;
  static Lib_MockProvider contactRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    commAppFormProductMock = Lib_MockProvider.forType(
      CommercialAppFormProductActionsRepo.class
    );
    contactRepoMock = Lib_MockProvider.forType(
      CommercialContactRepository.class
    );
  }

  static List<ApplicationForm> createAppForm(
    Id brokerId,
    Id customerId,
    String tpmisao
  ) {
    List<ApplicationForm> testAF = new List<ApplicationForm>();
    testAF.add(
      new ApplicationForm(
        Id = FAKER_AF_ID,
        OpportunityId = FAKER_OPP_ID,
        Assisted_Broker_TPMI_SAO__c = tpmisao,
        RecordTypeId = RTApplicationForm.ambitApplication,
        Assisted_Broker__c = brokerId,
        AccountId = customerId,
        Application_Number__c = 'test-app-no'
      )
    );
    return testAF;
  }

  static List<ApplicationFormProduct> createAppFormProd(
    Id brokerId,
    Id customerId,
    String tpmisao
  ) {
    ApplicationForm af = new ApplicationForm(
      Id = FAKER_AF_ID,
      OpportunityId = FAKER_OPP_ID,
      Assisted_Broker_TPMI_SAO__c = tpmisao,
      RecordTypeId = RTApplicationForm.ambitApplication,
      Assisted_Broker__c = brokerId,
      AccountId = customerId,
      Application_Number__c = 'test-app-no'
    );
    List<ApplicationFormProduct> testAFP = new List<ApplicationFormProduct>();
    testAFP.add(
      new ApplicationFormProduct(
        Id = FAKER_AFP_ID,
        Application_Source__c = 'BKOLA',
        ApplicationFormId = af.Id
      )
    );
    return testAFP;
  }

  static List<Contact> createContact() {
    List<Contact> contactList = new List<Contact>();
    contactList.add(
      new Contact(
        Id = BROKER_CONTACT_ID_ONE,
        AssetFinanceTPMISAO__c = 'updated-mock-tpmi-sao-id'
      )
    );
    return contactList;
  }
  @isTest
  static void testUpdateBrokerOnApplicationForm() {
    registerMocks();
    commAppFormProductMock.mock(
      'getBkolaAppFormProductByAppForm',
      createAppFormProd(BROKER_CONTACT_ID_ONE, null, 'updated-mock-tpmi-sao-id')
    );
    contactRepoMock.mock('getBrokersByTpmisao', createContact());
    List<ApplicationForm> newAFList = createAppForm(
      BROKER_CONTACT_ID_ONE,
      null,
      'updated-mock-tpmi-sao-id'
    );
    List<ApplicationForm> oldAFList = createAppForm(
      BROKER_CONTACT_ID_TWO,
      null,
      'mock-tpmi-sao-id'
    );
    Map<Id, ApplicationForm> oldAFMap = new Map<Id, ApplicationForm>{
      oldAFList.get(0).Id => oldAFList.get(0)
    };
    User userWithPS = TestUtil.getUserByFirstName('AMBIT_Test_User_With_PS');
    Test.startTest();
    System.runAs(userWithPS) {
      ApplicationFormActions.updateBrokerOnApplicationForm(newAFList, oldAFMap);
    }
    Test.stopTest();
    Assert.areNotEqual(
      oldAFList[0].Assisted_Broker__c,
      newAFList[0].Assisted_Broker__c,
      'Assisted broker has been updated'
    );
  }

  @isTest
  static void testUpdateBrokerOnApplicationFormWithNullVal() {
    Test.startTest();
    ApplicationFormActions.updateBrokerOnApplicationForm(null, null);
    Test.stopTest();
    System.assert(true, 'Failed updateBrokerOnApplicationForm method');
  }

  @isTest
  static void testUpdateBrokerOnApplicationFormWithoutPS() {
    User userWithoutPS = TestUtil.getUserByFirstName(
      'AMBIT_Test_User_Without_PS'
    );
    Test.startTest();
    System.runAs(userWithoutPS) {
      ApplicationFormActions.updateBrokerOnApplicationForm(null, null);
    }
    Test.stopTest();
    System.assert(
      true,
      'No action permormed on updateBrokerOnApplicationForm method'
    );
  }

  @isTest
  static void testPreventCustomerChangeOnAppForm() {
    registerMocks();
    commAppFormProductMock.mock(
      'getBkolaAppFormProductByAppForm',
      createAppFormProd(BROKER_CONTACT_ID_ONE, FAKER_ACC_ID, 'mock-tpmi-sao-id')
    );
    List<ApplicationForm> afMockList = createAppForm(
      BROKER_CONTACT_ID_ONE,
      FAKER_ACC_ID,
      'mock-tpmi-sao-id'
    );
    List<ApplicationForm> oldAFList = createAppForm(
      BROKER_CONTACT_ID_ONE,
      null,
      'mock-tpmi-sao-id'
    );
    Map<Id, ApplicationForm> oldAFMap = new Map<Id, ApplicationForm>{
      oldAFList.get(0).Id => oldAFList.get(0)
    };
    User userWithoutPS = TestUtil.getUserByFirstName(
      'AMBIT_Test_User_Without_PS'
    );
    Test.startTest();
    System.runAs(userWithoutPS) {
      ApplicationFormActions.preventCustomerChangeOnAppForm(
        afMockList,
        oldAFMap
      );
    }
    Test.stopTest();
    System.assert(true, 'Completed preventCustomerChangeOnAppForm method');
  }
  @isTest
  static void testUpdateSourceSystemIdInsertAndSyncChange() {
    // Arrange Insert scenario: record qualifies on insert
    List<ApplicationForm> insertList = createAppForm(
      BROKER_CONTACT_ID_ONE,
      FAKER_ACC_ID,
      'mock-tpmi-sao-id'
    );
    insertList[0].Source_System_Id__c = null;
    insertList[0].Sync_Status__c = BrokerConstants.SYNC_STATUS_BROKER_ORG;

    // Arrange Sync Change scenario: start with non-BROKER_ORG, then change to BROKER_ORG
    List<ApplicationForm> newAFList = createAppForm(
      BROKER_CONTACT_ID_ONE,
      FAKER_ACC_ID,
      'mock-tpmi-sao-id'
    );
    newAFList[0].Source_System_Id__c = null;
    newAFList[0].Sync_Status__c = BrokerConstants.SYNC_STATUS_BROKER_ORG;

    List<ApplicationForm> oldAFList = createAppForm(
      BROKER_CONTACT_ID_ONE,
      FAKER_ACC_ID,
      'mock-tpmi-sao-id'
    );
    oldAFList[0].Sync_Status__c = 'OLD_STATUS';

    Map<Id, ApplicationForm> oldAFMap = new Map<Id, ApplicationForm>{
      oldAFList[0].Id => oldAFList[0]
    };

    // Act: call insert handler
    Test.startTest();
    ApplicationFormActions.updateSourceSystemIdOnSyncChange(insertList, null);
    // Act: call sync-change handler
    ApplicationFormActions.updateSourceSystemIdOnSyncChange(
      newAFList,
      oldAFMap
    );
    Test.stopTest();

    // Assert Insert path
    System.assertEquals(
      insertList[0].OpportunityId + '-' + insertList[0].Assisted_Broker__c,
      insertList[0].Source_System_Id__c,
      'Insert path: Source_System_Id__c should be set when Sync_Status__c = BROKER_ORG and field is blank'
    );

    // Assert Sync Change path
    System.assertEquals(
      newAFList[0].OpportunityId + '-' + newAFList[0].Assisted_Broker__c,
      newAFList[0].Source_System_Id__c,
      'Sync change path: Source_System_Id__c should be set when Sync_Status__c changes to BROKER_ORG and field is blank'
    );
  }
}
