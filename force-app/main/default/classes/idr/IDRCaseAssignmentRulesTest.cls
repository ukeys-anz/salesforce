/**
 * @author Olivier Saier
 * @date May 2021
 * @description Test class for {@link IDRCaseAssignmentRules} assignment rule test
 * @group IDR(Internal Dispute Resolution)
 */
@IsTest
private with sharing class IDRCaseAssignmentRulesTest {
  static Id testUserId = Lib_FakeIdGenerator.getMockId(User.SObjectType);

  static Case caseRecord1 = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
    Status = IDRConstants.OPEN_STATUS
  );
  static Case caseRecord2 = new Case(
    Id = caseRecord1.Id,
    RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
    Status = IDRConstants.ESCALATED_STATUS,
    OwnerId = testUserId
  );

  static Lib_MockProvider caseActionMock;
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    caseActionMock = Lib_MockProvider.forType(IDRCaseActionsRepository.class);
  }
  /**
   * @description : This is test method to call the main method to assign respective Owner
   */
  @IsTest
  private static void testassignCases() {
    Case oldcase = caseRecord1;
    Case newcase = caseRecord2;
    newcase.IDR_Product_Family__c = Lib_FakeIdGenerator.getMockId(
      Product_Family__c.SObjectType
    );
    IDRCaseAssignmentRules.assignCases(
      new List<Case>{ newcase },
      new Map<Id, Case>{ oldcase.Id => oldcase }
    );
    System.assertEquals(
      newcase.OwnerId,
      IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(newcase, oldcase),
      'Both Owner id should be same'
    );
  }
  /**
   * @description : This is to test if Product Family is assigned to escalated ANZ Plus Complaint to Customer Complaint.
   */
  @IsTest
  private static void testassignProductFamily() {
    Product2 product1 = new Product2(
      Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType)
    );
    Product2 product2 = new Product2(
      Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
      IDR_Product_Family__c = Lib_FakeIdGenerator.getMockId(
        Product_Family__c.SObjectType
      )
    );

    Map<Id, Product2> mockProducts = new Map<Id, Product2>{
      product1.Id => product1,
      product2.Id => product2
    };
    QueryProducts.productsById = mockProducts;
    Product2 newProduct = QueryProducts.productsById.get(product2.Id);

    Case oldCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = GetHelpConstants.COMPLAINT_RT_ID
    );

    Case newCase = caseRecord2;
    newCase.Product__c = newProduct.Id;

    IDRCaseAssignmentRules.assignProductFamily(
      new List<Case>{ newCase },
      new Map<Id, Case>{ oldCase.Id => oldCase }
    );
    System.assertEquals(
      newCase.IDR_Product_Family__c,
      newProduct.IDR_Product_Family__c,
      'Product Family should be updated on Case'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testAssignUnescalatedCases() {
    registerMocks();

    caseActionMock.mock('checkUserPermission', true);

    Case oldCase = caseRecord1;

    Case newcase = new Case(
      Id = oldcase.Id,
      RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
      Status = IDRConstants.ON_HOLD_STATUS,
      Type = '4',
      IDR_Subsequent_Issue__c = '21',
      IDR_Issue_Type_2__c = '4',
      IDR_Subsequent_Issue_2__c = '22',
      IDR_Issue_Type_3__c = '4',
      IDR_Subsequent_Issue_3__c = '23'
    );
    Test.startTest();
    IDRCaseAssignmentRules.assignUnescalatedCases(
      new List<Case>{ newcase },
      new Map<Id, Case>{ oldcase.Id => oldcase }
    );
    Test.stopTest();
    List<Case> cases = (List<Case>) dmlRepoMock.getHistory('updateRecords')
      .getParam('records');
    System.assertEquals(1, cases.size(), '1 Case should be updated');
    System.assertEquals(
      cases[0].OwnerId,
      QueryQueue.get('IDR_Everyday_Banking').Id,
      'Owner should be IDR_Everyday_Banking'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisCaseOwner() {
    Case oldCase = caseRecord1;

    Case newCase = caseRecord2;
    newCase.OwnerId = testUserId;
    newCase.Status = IDRConstants.UNDER_INVESTIGATION_STATUS;

    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      testUserId,
      'Owner should be records owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisCaseOwner1() {
    Case oldCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      Status = IDRConstants.ON_HOLD_STATUS
    );

    Case newCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      Status = IDRConstants.ESCALATED_STATUS,
      OwnerId = testUserId
    );

    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      testUserId,
      'Owner should be records owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisIDRCEO() {
    Case oldCase = caseRecord1;

    Case newCase = caseRecord2;
    newCase.Origin = '9';
    newCase.Status = IDRConstants.ESCALATED_STATUS;

    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('IDR_CEO').Id,
      'Owner should be IDR_CEO'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisEDRHardship() {
    Case oldCase = caseRecord1;

    Case newCase = caseRecord2;
    newCase.Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED;
    newCase.Type = '4';

    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('EDR_Hardship').Id,
      'Owner should be EDR_Hardship'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisIDRHardship() {
    Case oldCase = caseRecord1;

    Case newCase = caseRecord2;
    newCase.Type = '4';
    newCase.OwnerId = testUserId;

    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('IDR_Hardship').Id,
      'Owner should be IDR_Hardship'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisEarlyResLending() {
    Case oldCase = caseRecord1;

    Case newCase = caseRecord2;
    newCase.Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED;
    newCase.IDR_Subsequent_Issue__c = '38';

    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('Specialised_EarlyRes_Responsible_Lending').Id,
      'Owner should be Specialised_EarlyRes_Responsible_Lending'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnersisIDRResLending() {
    Case oldCase = caseRecord1;

    Case newCase = caseRecord2;
    newCase.IDR_Subsequent_Issue__c = '38';

    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('IDR_Responsible_Lending').Id,
      'Owner should be IDR_Responsible_Lending'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisEDRScams() {
    Case oldCase = caseRecord1;

    Case newCase = caseRecord2;
    newCase.Type = 'Scam';
    newCase.Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED;

    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('EDR_CM_Everyday_Banking_Wealth').Id,
      'Owner should be EDR Scams'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisEDRWealth() {
    Case oldCase = caseRecord1;
    Product_Family__c productFamily1 = new Product_Family__c(
      Id = Lib_FakeIdGenerator.getMockId(Product_Family__c.SObjectType)
    );
    Product_Family__c productFamily2 = new Product_Family__c(
      Id = Lib_FakeIdGenerator.getMockId(Product_Family__c.SObjectType),
      Name = 'Insurance/wealth products'
    );

    Map<Id, Product_Family__c> mockProductFamilies = new Map<Id, Product_Family__c>{
      productFamily1.Id => productFamily1,
      productFamily2.Id => productFamily2
    };

    QueryProductFamily.productFamilyById = mockProductFamilies;

    Product_Family__c newproductfamily = QueryProductFamily.productFamilyById.get(
      productFamily2.Id
    );

    Case newCase = caseRecord2;
    newCase.Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED;
    newCase.IDR_Product_Family__c = newproductfamily.Id;

    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('EDR_Wealth').Id,
      'Owner should be EDR Wealth'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @IsTest
  private static void testOwnerisEDREarlyRes() {
    Case oldCase = caseRecord1;

    Case newCase = caseRecord2;
    newCase.Origin = IDRConstants.CHANNEL_RECEIVED_AFCA_REFERRED;
    newCase.Type = 'Fraud';
    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('EDR_Early_Resolution').Id,
      'Owner should be EDR_Early_Resolution'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisCCRComplaints() {
    Case oldCase = caseRecord1;

    Case newCase = caseRecord2;
    newCase.Type = '19';
    newCase.IDR_Issue_Type_2__c = '19';
    newCase.IDR_Issue_Type_3__c = '19';
    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('CCR_Complaints').Id,
      'Owner should be CCR_Complaints'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisIDRANZPlus() {
    Case oldcase = caseRecord1;

    Product_Family__c productFamily1 = new Product_Family__c(
      Id = Lib_FakeIdGenerator.getMockId(Product_Family__c.SObjectType)
    );
    Product_Family__c productFamily2 = new Product_Family__c(
      Id = Lib_FakeIdGenerator.getMockId(Product_Family__c.SObjectType),
      IDR_Workbasket__c = 'IDR_ANZ_Plus'
    );

    Map<Id, Product_Family__c> mockProductFamilies = new Map<Id, Product_Family__c>{
      productFamily1.Id => productFamily1,
      productFamily2.Id => productFamily2
    };
    QueryProductFamily.productFamilyById = mockProductFamilies;

    Product_Family__c newproductfamily = QueryProductFamily.productFamilyById.get(
      productFamily2.Id
    );

    Case newcase = caseRecord2;
    newCase.IDR_Product_Family__c = newproductfamily.Id;

    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('IDR_ANZ_Plus').Id,
      'Owner should be IDR_ANZ_Plus'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisIDRSpare() {
    Case oldCase = caseRecord1;

    Case newCase = caseRecord2;
    newCase.Type = 'Fraud';
    newCase.IDR_Subsequent_Issue__c = '109';
    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('IDR_Spare').Id,
      'Owner should be IDR_Spare'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisIDRScams() {
    Case oldCase = caseRecord1;

    Case newCase = caseRecord2;
    newCase.Type = 'Fraud';
    newCase.IDR_Subsequent_Issue__c = '110';
    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('IDR_Scams').Id,
      'Owner should be IDR_Scams'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisIDRDecEstates() {
    Case oldCase = caseRecord1;

    Case newCase = caseRecord2;
    newCase.Type = '16';
    newCase.IDR_Subsequent_Issue__c = '80';
    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('IDR_Deceased_Estates').Id,
      'Owner should be IDR_Deceased_Estates'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisIDREarlyResUC() {
    Case oldCase = caseRecord1;

    Case newCase = caseRecord2;
    newCase.Origin = '8';
    newCase.IDR_Inbox_Email_Address__c = 'test';
    newCase.Type = '18';
    newCase.IDR_Subsequent_Issue__c = '11';
    newCase.IDR_Second_Issue__c = false;
    newCase.IDR_Third_Issue__c = false;
    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('IDR_Early_Resolution_Unassisted_Channel').Id,
      'Owner should be IDR_Early_Resolution_Unassisted_Channel'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testOwnerisIDREarlyRes() {
    Case oldCase = caseRecord1;

    Case newCase = caseRecord2;
    newCase.Type = '13';

    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldCase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('IDR_Early_Resolution').Id,
      'Owner should be IDR_Early_Resolution'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @IsTest
  private static void testOwnerisEverydayBanking() {
    Product2 product1 = new Product2(
      Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType)
    );
    Product2 product2 = new Product2(
      Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType),
      ANZ_Product_Code__c = '231'
    );

    Map<Id, Product2> mockProducts = new Map<Id, Product2>{
      product1.Id => product1,
      product2.Id => product2
    };
    QueryProducts.productsById = mockProducts;

    Product2 newProduct = QueryProducts.productsById.get(product2.Id);
    Case oldCase = caseRecord1;
    Case newCase = caseRecord2;
    newCase.Product__c = newProduct.Id;

    Id workbasketId = IDRCaseAssignmentRules.getOwnerIdForEscalatedCases(
      newCase,
      oldcase
    );
    System.assertEquals(
      workbasketId,
      QueryQueue.get('IDR_Everyday_Banking').Id,
      'Owner should be everyday banking'
    );
    System.assertNotEquals(
      workbasketId,
      newCase.OwnerId,
      'Owner should be updated and should not be the case owner'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testgetOwner() {
    Id testUserId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    Case oldCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      Status = IDRConstants.ESCALATED_STATUS
    );

    Case newCase = new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      Status = IDRConstants.ON_HOLD_STATUS,
      OwnerId = testUserId
    );

    Id workbasketId = IDRCaseAssignmentRules.getOwnerId(newCase, oldCase);

    System.AssertEquals(
      workbasketId,
      testUserId,
      'Owner Should be new Owner Id'
    );
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testisValidIssueType2() {
    Case newCase = caseRecord2;
    newCase.IDR_Issue_Type_2__c = '4';
    newCase.IDR_Subsequent_Issue_2__c = '21';

    Boolean isValidIssueType = IDRCaseAssignmentRules.isValidIssueType(newCase);

    System.AssertEquals(isValidIssueType, true, 'Boolean should return true');
  }
  /**
   * @description : This is the test method to get assign respective owner Id to Case.
   */
  @isTest
  private static void testisValidIssueType3() {
    Case newCase = caseRecord2;
    newCase.IDR_Issue_Type_3__c = '4';
    newCase.IDR_Subsequent_Issue_3__c = '21';

    Boolean isValidIssueType = IDRCaseAssignmentRules.isValidIssueType(newCase);

    System.AssertEquals(isValidIssueType, true, 'Boolean should return true');
  }
}
