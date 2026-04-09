/**
 * @author Ali Mujtaba | Salesforce | 31-10-2025
 * @since October 2025
 * @description Test class for ApplicationFormActions actions
 */
@isTest
private class ApplicationFormHelperTest {
  /**
   * @description Setup common test data
   */
  @testSetup
  public static void setup() {
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
  private static final Id FAKER_CON_ID = Lib_FakeIdGenerator.getMockId(
    Contact.getSObjectType()
  );
  static Lib_MockProvider commAppFormProductMock;
  static Lib_MockProvider contactRepoMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    commAppFormProductMock = Lib_MockProvider.forType(
      CommercialAppFormProductActionsRepo.class
    );
    contactRepoMock = Lib_MockProvider.forType(
      CommercialContactRepository.class
    );
  }

  static List<ApplicationForm> createAppForm() {
    List<ApplicationForm> testAF = new List<ApplicationForm>();
    testAF.add(
      new ApplicationForm(
        Id = FAKER_AF_ID,
        OpportunityId = FAKER_OPP_ID,
        Assisted_Broker_TPMI_SAO__c = 'mock-tpmi-sao-id',
        RecordTypeId = RTApplicationForm.ambitApplication
      )
    );
    return testAF;
  }

  static List<ApplicationFormProduct> createAppFormProd() {
    ApplicationForm af = new ApplicationForm(
      Id = FAKER_AF_ID,
      OpportunityId = FAKER_OPP_ID,
      Assisted_Broker_TPMI_SAO__c = 'mock-tpmi-sao-id',
      RecordTypeId = RTApplicationForm.ambitApplication
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
        Id = FAKER_CON_ID,
        AssetFinanceTPMISAO__c = 'mock-tpmi-sao-id'
      )
    );
    return contactList;
  }

  @isTest
  static void testGetBkolaApplicationFormProd() {
    registerMocks();
    commAppFormProductMock.mock(
      'getBkolaAppFormProductByAppForm',
      createAppFormProd()
    );
    List<ApplicationForm> afMockList = new List<ApplicationForm>{
      new ApplicationForm(Id = FAKER_AF_ID, OpportunityId = FAKER_OPP_ID)
    };
    Test.startTest();
    List<ApplicationFormProduct> afpList = ApplicationFormHelper.getBkolaApplicationFormProd(
      afMockList
    );
    Test.stopTest();
    Assert.areEqual(
      1,
      afpList.size(),
      'Retrieved one application form product record'
    );
  }

  /**
   * @description test updateAssistedBrokerOnOpp
   * @author Ali Mujtaba | Salesforce | 02-11-2025
   **/
  @isTest
  static void testUpdateAssistedBrokerOnOpp() {
    registerMocks();
    List<ApplicationFormProduct> afpMockList = createAppFormProd();

    Test.startTest();
    ApplicationFormHelper.updateAssistedBrokerOnOpp(afpMockList);
    Test.stopTest();
    dmlRepoMock.getHistory('doUpdate').getParam('records');
    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );
  }

  /**
   * @description test updateCustomerOnOpp
   * @author Ali Mujtaba | Salesforce | 02-11-2025
   **/
  @isTest
  static void testUpdateCustomerOnOpp() {
    registerMocks();
    List<ApplicationFormProduct> afpMockList = createAppFormProd();

    Test.startTest();
    ApplicationFormHelper.updateCustomerOnOpp(afpMockList);
    Test.stopTest();
    dmlRepoMock.getHistory('doUpdate').getParam('records');
    Assert.isNotNull(
      dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );
  }

  /**
   * @description test collectTpmisaoIds
   * @author Ali Mujtaba | Salesforce | 02-11-2025
   **/
  @isTest
  static void testCollectTpmisaoIds() {
    List<ApplicationForm> afMockList = createAppForm();

    Test.startTest();
    Set<String> tpmisaoIds = ApplicationFormHelper.collectTpmisaoIds(
      afMockList
    );
    Test.stopTest();
    Assert.areEqual(1, tpmisaoIds.size(), 'Retrieved one tpmisao id');
  }

  /**
   * @description test prepareMapOfTpmisaoWithBroker for AssetFinanceTPMISAO__c
   * @author Ali Mujtaba | Salesforce | 02-11-2025
   **/
  @isTest
  static void testGetBrokers() {
    registerMocks();
    contactRepoMock.mock('getBrokersByTpmisao', createContact());
    Set<String> tpmisaoIds = new Set<String>{ 'mock-tpmi-sao-id' };
    Test.startTest();
    List<Contact> contacts = ApplicationFormHelper.getBrokers(tpmisaoIds);
    Test.stopTest();
    Assert.areEqual(1, contacts.size(), 'Retrieved one contact record');
  }

  /**
   * @description test prepareMapOfTpmisaoWithBroker for AssetFinanceTPMISAO__c
   * @author Ali Mujtaba | Salesforce | 02-11-2025
   **/
  @isTest
  static void testPrepareMapOfTpmisaoWithBrokerAF() {
    registerMocks();
    List<Contact> contacts = createContact();
    Set<String> tpmisaoIds = new Set<String>{ 'mock-tpmi-sao-id' };
    Map<String, Id> expectedMap = new Map<String, Id>{
      'mock-tpmi-sao-id' => contacts[0].Id
    };
    Test.startTest();
    Map<String, Id> actualMap = ApplicationFormHelper.prepareMapOfTpmisaoWithBroker(
      tpmisaoIds,
      contacts
    );
    Test.stopTest();
    Assert.areEqual(
      expectedMap,
      actualMap,
      'Assisted broker has been updated on Application Form record'
    );
  }

  /**
   * @description test prepareMapOfTpmisaoWithBroker for CommercialTPMISAO__c
   * @author Ali Mujtaba | Salesforce | 02-11-2025
   **/
  @isTest
  static void testPrepareMapOfTpmisaoWithBrokerComm() {
    registerMocks();
    List<Contact> contacts = createContact();
    contacts[0].AssetFinanceTPMISAO__c = null;
    contacts[0].CommercialTPMISAO__c = 'mock-comm-tpmi-sao-id';
    Set<String> tpmisaoIds = new Set<String>{ 'mock-comm-tpmi-sao-id' };
    Map<String, Id> expectedMap = new Map<String, Id>{
      'mock-comm-tpmi-sao-id' => contacts[0].Id
    };
    Test.startTest();
    Map<String, Id> actualMap = ApplicationFormHelper.prepareMapOfTpmisaoWithBroker(
      tpmisaoIds,
      contacts
    );
    Test.stopTest();
    Assert.areEqual(
      expectedMap,
      actualMap,
      'Assisted broker has been updated on Application Form record'
    );
  }

  /**
   * @description test prepareMapOfTpmisaoWithBroker for RetailTPMISAO__c
   * @author Ali Mujtaba | Salesforce | 02-11-2025
   **/
  @isTest
  static void testPrepareMapOfTpmisaoWithBrokerRetail() {
    registerMocks();
    List<Contact> contacts = createContact();
    contacts[0].AssetFinanceTPMISAO__c = null;
    contacts[0].RetailTPMISAO__c = 'mock-retail-tpmi-sao-id';
    Set<String> tpmisaoIds = new Set<String>{ 'mock-retail-tpmi-sao-id' };
    Map<String, Id> expectedMap = new Map<String, Id>{
      'mock-retail-tpmi-sao-id' => contacts[0].Id
    };
    Test.startTest();
    Map<String, Id> actualMap = ApplicationFormHelper.prepareMapOfTpmisaoWithBroker(
      tpmisaoIds,
      contacts
    );
    Test.stopTest();
    Assert.areEqual(
      expectedMap,
      actualMap,
      'Assisted broker has been updated on Application Form record'
    );
  }

  /**
   * @description test updateAssistedBrokerOnAppForm
   * @author Ali Mujtaba | Salesforce | 02-11-2025
   **/
  @isTest
  static void testUpdateAssistedBrokerOnAppForm() {
    registerMocks();
    List<Contact> contacts = createContact();
    List<ApplicationForm> afMockList = createAppForm();
    Set<String> tpmisaoIds = new Set<String>{ 'mock-tpmi-sao-id' };
    Test.startTest();
    Map<String, Id> mapTpmisaoWithBroker = ApplicationFormHelper.prepareMapOfTpmisaoWithBroker(
      tpmisaoIds,
      contacts
    );
    ApplicationFormHelper.updateAssistedBrokerOnAppForm(
      mapTpmisaoWithBroker,
      afMockList
    );
    Test.stopTest();
    Assert.areEqual(
      contacts[0].Id,
      afMockList[0].Assisted_Broker__c,
      'Assisted broker has been updated on Application Form record'
    );
  }

  /**
   * @description test blockCustomerModificationOnAppForm error message
   * @author Ali Mujtaba | Salesforce | 02-11-2025
   **/
  @isTest
  static void testBlockCustomerModificationOnAppForm() {
    List<ApplicationForm> afMockList = createAppForm();
    List<ApplicationFormProduct> afpMockList = createAppFormProd();
    User userWithoutPS = TestUtil.getUserByFirstName(
      'AMBIT_Test_User_Without_PS'
    );
    Test.startTest();
    System.runAs(userWithoutPS) {
      ApplicationFormHelper.blockCustomerModificationOnAppForm(
        afMockList,
        afpMockList
      );
    }
    Test.stopTest();
    Assert.areEqual(1, afMockList[0].getErrors().size(), 'Expected error');
    Assert.areEqual(
      ApplicationFormHelper.PREVENT_CUSTOMER_CHANGE_ERROR_MSG,
      afMockList[0].getErrors()[0].getMessage(),
      'Expected error message'
    );
  }

  /**
   * @description test validateAmbitIntegrationUserAccess without PS
   * @author Ali Mujtaba | Salesforce | 02-11-2025
   **/
  @isTest
  static void testValidateAmbitIntegrationUserAccessWithoutPS() {
    Boolean result;
    User userWithoutPS = TestUtil.getUserByFirstName(
      'AMBIT_Test_User_Without_PS'
    );
    Test.startTest();
    System.runAs(userWithoutPS) {
      result = ApplicationFormHelper.validateAmbitIntegrationUserAccess();
    }
    Test.stopTest();
    Assert.areEqual(
      false,
      result,
      'Expected false when user does not have AMBIT PS'
    );
  }

  /**
   * @description test validateAmbitIntegrationUserAccess with PS
   * @author Ali Mujtaba | Salesforce | 02-11-2025
   **/
  @isTest
  static void testValidateAmbitIntegrationUserAccessWithPS() {
    Boolean result;
    User userWithPS = TestUtil.getUserByFirstName('AMBIT_Test_User_With_PS');
    Test.startTest();
    System.runAs(userWithPS) {
      result = ApplicationFormHelper.validateAmbitIntegrationUserAccess();
    }
    Test.stopTest();
    Assert.areEqual(true, result, 'Expected true when user has AMBIT PS');
  }

  /**
   * @description updateApplicationFormValues should be no-op on empty list (no DML)
   * @author Agentforce
   **/
  @isTest
  static void testUpdateApplicationFormValuesNoOpOnEmptyList() {
    ApplicationFormHelperTest.registerMocks();
    List<ApplicationForm> emptyList = new List<ApplicationForm>();
    Test.startTest();
    ApplicationFormHelper.updateApplicationFormValues(emptyList);
    Test.stopTest();
    Assert.isNull(
      ApplicationFormHelperTest.dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should not have been invoked for empty input'
    );
  }

  /**
   * @description updateApplicationFormValues preserves existing Assisted_Broker__c and appends Sync Status
   * - If Assisted_Broker__c already populated, it must not be overwritten by Opportunity.Broker_Name__c
   * - Sync_Status__c should include BrokerConstants.SYNC_STATUS_BROKER_ORG (appended if not present)
   * @author Agentforce
   **/
  @isTest
  static void testUpdateApplicationFormValuesPreservesExistingBrokerAndAppendsSyncStatus() {
    ApplicationFormHelperTest.registerMocks();

    // Existing Assisted Broker on AF should be preserved
    Id existingBrokerId = '003000000000001AAA';
    Id differentBrokerId = '003000000000002AAA';

    // Build AF with existing Assisted_Broker__c and some existing Sync_Status__c value
    ApplicationForm af = new ApplicationForm(
      Id = FAKER_AF_ID,
      OpportunityId = FAKER_OPP_ID,
      Assisted_Broker__c = existingBrokerId,
      Sync_Status__c = 'Some_Other_Status__c'
    );

    // Provide related Opportunity having a different Broker_Name__c
    Opportunity opp = new Opportunity(
      Id = FAKER_OPP_ID,
      Broker_Name__c = differentBrokerId
    );
    af.Opportunity = opp;

    List<ApplicationForm> input = new List<ApplicationForm>{ af };

    Test.startTest();
    ApplicationFormHelper.updateApplicationFormValues(input);
    Test.stopTest();

    // Verify Assisted_Broker__c not overwritten
    Assert.areEqual(
      existingBrokerId,
      input[0].Assisted_Broker__c,
      'Existing Assisted_Broker__c should not be overwritten'
    );

    // Verify Sync_Status__c includes the SYNC_STATUS_BROKER_ORG value
    String expectedToken = BrokerConstants.SYNC_STATUS_BROKER_ORG;
    System.assertEquals(
      true,
      input[0].Sync_Status__c != null &&
      input[0].Sync_Status__c.contains(expectedToken),
      'Sync_Status__c should contain the Broker Org sync token'
    );

    // Verify DML invoked with the record to update
    Assert.isNotNull(
      ApplicationFormHelperTest.dmlRepoMock.getHistory('doUpdate'),
      'doUpdate should have been invoked'
    );
  }
}
