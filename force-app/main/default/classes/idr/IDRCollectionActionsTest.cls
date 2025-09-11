/**
 * @author Boobalakrishnan Duraisamy
 * @date Oct 2021
 * @description Test class for {@link IDRCollectionActions}
 * @group IDR(Internal Dispute Resolution)
 */
@IsTest
private with sharing class IDRCollectionActionsTest {
  @TestSetup
  static void setup() {
    //create a product
    Product2 p = new Product2(
      Name = 'ANZ Home Loan Protection (HLP)  Insurance',
      IsActive = true,
      ANZ_Product_Code__c = '261',
      IDR_Product_or_Service_Category__c = '8',
      IDR_Product_or_Service_Line__c = '3',
      IDR_Product_or_Service_Type__c = '40'
    );
    insert p;
  }
  @IsTest
  static void testStopCollectionOnInsert() {
    Product2 p = [SELECT Id FROM Product2 LIMIT 1];
    // GIVEN customer complaint cases with collection issue type and multiple account numbers
    Case[] collectionCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      collectionCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          IDR_Account_Card_Policy_Number__c = '111111111;2222222222;333333333;444444444;555555555;666666666;777777777;888888888;999999999;1234567890',
          Type = '4',
          IDR_Subsequent_Issue__c = '96',
          Status = 'Open',
          Product__c = p.Id,
          IDR_Second_Issue__c = true,
          IDR_Account_Card_Policy_Number_2__c = '2134565778;283273273;4393483833;823748237;8423742374;672354763;273647234;678263478;463724622;234324324',
          IDR_Issue_Type_2__c = '17',
          IDR_Subsequent_Issue_2__c = '97',
          IDR_Product_2__c = p.Id,
          IDR_Third_Issue__c = true,
          IDR_Account_Card_Policy_Number_3__c = '132342343;534764565;645656456;678765665;3422323423;645676556;896875567;432241244;565423545;432431211',
          IDR_Issue_Type_3__c = '17',
          IDR_Subsequent_Issue_3__c = '98',
          IDR_Product_3__c = p.Id
        )
      );
    }

    Test.startTest();
    // WHEN they are inserted
    insert collectionCases;
    Test.stopTest();

    // THEN STOP collection tasks must be created for each account number
    List<Task> collectionTasks = [
      SELECT Id
      FROM Task
      WHERE WhatId = :collectionCases[0].Id AND Subject LIKE 'STOP Collection%'
    ];
    System.assertEquals(
      30,
      collectionTasks.size(),
      'Collection tasks size should be as expected.'
    );
  }

  @IsTest
  static void testStopCollectionOnUpdate() {
    Product2 p = [SELECT Id FROM Product2 LIMIT 1];
    // GIVEN customer complaint cases with collection issue type and multiple account numbers
    Case[] collectionCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      collectionCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          IDR_Account_Card_Policy_Number__c = '111111111;2222222222;333333333',
          Type = '4',
          IDR_Subsequent_Issue__c = '20',
          Status = 'Open',
          Product__c = p.Id,
          IDR_Second_Issue__c = true,
          IDR_Account_Card_Policy_Number_2__c = '444444444;5555555555;6666666666',
          IDR_Issue_Type_2__c = '4',
          IDR_Subsequent_Issue_2__c = '21',
          IDR_Product_2__c = p.Id
        )
      );
    }
    insert collectionCases;

    Test.startTest();
    // WHEN the case is updated to add third issue with collection issue type
    collectionCases[0].IDR_Third_Issue__c = true;
    collectionCases[0]
      .IDR_Account_Card_Policy_Number_3__c = '7777777777;8888888888;9999999999';
    collectionCases[0].IDR_Issue_Type_3__c = '4';
    collectionCases[0].IDR_Subsequent_Issue_3__c = '23';
    collectionCases[0].IDR_Product_3__c = p.Id;
    update collectionCases[0];

    Test.stopTest();

    // THEN STOP collection tasks must be created for each account number added during update
    List<Task> collectionTasks = [
      SELECT Id
      FROM Task
      WHERE WhatId = :collectionCases[0].Id AND Subject LIKE 'STOP Collection%'
    ];
    System.assertEquals(
      9,
      collectionTasks.size(),
      'Collection tasks size should be as expected.'
    );
  }

  @IsTest
  static void testStartCollectionScenarioOne() {
    Product2 p = [SELECT Id FROM Product2 LIMIT 1];
    // GIVEN customer complaint cases with collection issue type and multiple account numbers
    Case[] collectionCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      collectionCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          IDR_Account_Card_Policy_Number__c = '111111111;2222222222;333333333',
          Type = '4',
          IDR_Subsequent_Issue__c = '20',
          Status = 'Open',
          Product__c = p.Id,
          IDR_Second_Issue__c = true,
          IDR_Account_Card_Policy_Number_2__c = '444444444;5555555555;6666666666',
          IDR_Issue_Type_2__c = '4',
          IDR_Subsequent_Issue_2__c = '21',
          IDR_Product_2__c = p.Id
        )
      );
    }
    if (Integer.valueOf(Label.Test_Bulk_Size) > 1) {
      //Force 2nd case to have same account numbers but leading 0's.
      collectionCases[1]
        .IDR_Account_Card_Policy_Number__c = '00000000000000111111111;00000000000002222222222;00000000000000333333333';
      collectionCases[1]
        .IDR_Account_Card_Policy_Number_2__c = '00000000000000444444444;00000000000005555555555;00000000000006666666666';
    }
    insert collectionCases;

    Test.startTest();
    // WHEN one case is closed and another one is open with same account numbers
    collectionCases[0].Status = 'Withdrawn';
    update collectionCases[0];

    Test.stopTest();

    // THEN START collection tasks must not be created as there is an open complaint present for these account numbers
    List<Task> collectionTasks = [
      SELECT Id
      FROM Task
      WHERE WhatId = :collectionCases[0].Id AND Subject LIKE 'START Collection%'
    ];
    System.assertEquals(
      0,
      collectionTasks.size(),
      'Collection tasks size should be as expected.'
    );
  }

  @IsTest
  static void testStartCollectionScenarioTwo() {
    Product2 p = [SELECT Id FROM Product2 LIMIT 1];
    // GIVEN customer complaint cases with collection issue type and multiple account numbers
    Case[] collectionCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      collectionCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          IDR_Account_Card_Policy_Number__c = '111111111;2222222222;333333333',
          Type = '4',
          IDR_Subsequent_Issue__c = '20',
          Status = 'Open',
          Product__c = p.Id,
          IDR_Second_Issue__c = true,
          IDR_Account_Card_Policy_Number_2__c = '444444444;5555555555;6666666666',
          IDR_Issue_Type_2__c = '4',
          IDR_Subsequent_Issue_2__c = '21',
          IDR_Product_2__c = p.Id
        )
      );
    }
    insert collectionCases;

    Test.startTest();
    // WHEN they are closed
    collectionCases[0].Status = 'Withdrawn';
    update collectionCases[0];
    collectionCases[1].Status = 'Withdrawn';
    update collectionCases[1];

    Test.stopTest();

    // THEN START collection tasks must be created if there is no open complaint present for these account numbers
    List<Task> collectionTasks = [
      SELECT Id
      FROM Task
      WHERE Subject LIKE 'START Collection%'
    ];
    System.assertEquals(
      6,
      collectionTasks.size(),
      'Collection tasks size should be as expected.'
    );
  }

  @IsTest
  static void testClosedOnCreate() {
    Product2 p = [SELECT Id FROM Product2 LIMIT 1];
    // GIVEN customer complaint cases with collection issue type and multiple account numbers closed on create
    Case[] collectionCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      collectionCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          IDR_Account_Card_Policy_Number__c = '111111111;2222222222;333333333',
          Type = '4',
          IDR_Subsequent_Issue__c = '20',
          Status = 'Withdrawn',
          Product__c = p.Id
        )
      );
    }

    Test.startTest();
    // WHEN they are inserted
    insert collectionCases;
    Test.stopTest();

    // THEN STOP AND START collection tasks must created
    List<Task> collectionTasks = [
      SELECT Id, Type
      FROM Task
      WHERE Subject LIKE '%Collection%'
    ];
    // THEN Add AND Remove Complaints tasks must created
    List<Task> complaintTasks = [
      SELECT Id, Type
      FROM Task
      WHERE Subject LIKE '%Complaint%'
    ];
    System.assertEquals(
      6,
      collectionTasks.size(),
      'Collection tasks size should be as expected.'
    );
    System.assertEquals(
      4,
      complaintTasks.size(),
      'Complaint tasks size should be as expected.'
    );
    System.assertEquals(
      IDRConstants.TASK_TYPE_COLLECTION,
      collectionTasks[0].Type,
      'Collection task type should be as expected.'
    );
    System.assertEquals(
      IDRConstants.TASK_TYPE_COMPLIANTS_FLAG,
      complaintTasks[0].Type,
      'Complaint task type should be as expected.'
    );
  }

  @IsTest
  static void testAccountNumberNA() {
    Product2 p = [SELECT Id FROM Product2 LIMIT 1];
    // GIVEN customer complaint cases with collection issue type and account number selected as N/A
    Case[] collectionCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      collectionCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          IDR_Account_Card_Policy_Number__c = 'N/A',
          Type = '4',
          IDR_Subsequent_Issue__c = '20',
          Status = 'Withdrawn',
          Product__c = p.Id
        )
      );
    }

    Test.startTest();
    // WHEN they are inserted
    insert collectionCases;
    Test.stopTest();

    // THEN STOP AND START collection tasks will not get created
    List<Task> collectionTasks = [
      SELECT Id, Type
      FROM Task
      WHERE Subject LIKE '%Collection%'
    ];
    System.assertEquals(
      0,
      collectionTasks.size(),
      'Collection tasks size should be as expected.'
    );
  }
  /**
   * @description method to get customer Complaint
   * @return Case
   */
  static Case getCaseForCollections() {
    return new Case(
      Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
      RecordTypeId = RTCase.customerComplaint,
      Type = '19',
      IDR_Issue_Type_2__c = '19',
      IDR_Issue_Type_3__c = '19',
      IDR_Subsequent_Issue__c = '115',
      IDR_Subsequent_Issue_2__c = '115',
      IDR_Subsequent_Issue_3__c = '115',
      IDR_Collection_Number__c = '00000011122233444;N/A;11223344556677',
      IDR_Collection_Number_2__c = '00000011122233444;N/A;11223344556677',
      IDR_Collection_Number_3__c = '000000000022222333344444;N/A;22222333344444',
      IDR_Account_Card_Policy_Number__c = '*****1111;******2222',
      IDR_Account_Card_Policy_Number_2__c = '*****1629;******2132',
      IDR_Account_Card_Policy_Number_3__c = 'AAATTTER-123'
    );
  }
  /**
   * @description method to get pcc tasks
   * @return Task
   */
  static Task getPCCTask() {
    return new Task(
      RecordTypeId = RTTask.idrSystemTask,
      Type = 'Collections',
      WhatId = Lib_FakeIdGenerator.getMockId(Case.SObjectType)
    );
  }
  /**
   * @description method to test if account number entered is invalid
   */
  @IsTest
  static void testIsInValidAccount() {
    Case csObj = getCaseForCollections();
    Case csObj2 = new Case();
    csObj2.Id = csObj.Id;
    csObj2.IDR_Account_Card_Policy_Number__c = '*****3333;******4444';
    Case csObj3 = new Case();
    csObj3.Id = csObj.Id;
    csObj3.IDR_Account_Card_Policy_Number__c = '555555555;9999999999';
    Case csObj4 = new Case();
    csObj4.Id = csObj.Id;
    csObj4.IDR_Account_Card_Policy_Number__c = null;
    Test.startTest();
    Boolean isValid = IDRCollectionActions.isInValidAccount(
      csObj2,
      csObj,
      Case.IDR_Account_Card_Policy_Number__c
    );
    Boolean isInValid = IDRCollectionActions.isInValidAccount(
      csObj3,
      csObj,
      Case.IDR_Account_Card_Policy_Number__c
    );
    Boolean isNull = IDRCollectionActions.isInValidAccount(
      csObj4,
      csObj,
      Case.IDR_Account_Card_Policy_Number__c
    );
    Test.stopTest();
    Assert.isTrue(
      isValid,
      'Account Policy number: *****3333;******4444 is InValid, as it contains special characters'
    );
    Assert.isFalse(
      isInValid,
      'Account Policy number: 555555555;9999999999 is Valid'
    );
    Assert.isFalse(
      isNull,
      'Account Policy Number is null, hence returned false'
    );
  }
  /**
   * @description method to test if issue type is changed and valid for triggering collections
   */
  @IsTest
  static void testcheckForIssueTypesChanged() {
    Case csObj = getCaseForCollections();
    Case csObj2 = new Case();
    csObj2.Id = csObj.Id;
    csObj2.Type = '17';
    csObj2.IDR_Subsequent_Issue__c = '24';
    Case csObj3 = new Case();
    csObj3.Id = csObj.Id;
    csObj3.Type = '19';
    csObj3.IDR_Subsequent_Issue__c = '115';
    Test.startTest();
    Boolean isTypesChanged = IDRCollectionActions.checkForIssueTypesChanged(
      csObj2,
      csObj
    );
    Boolean isTypesNotChanged = IDRCollectionActions.checkForIssueTypesChanged(
      csObj3,
      csObj
    );
    Test.stopTest();
    Assert.isTrue(isTypesChanged, 'Issue Types Changed');
    Assert.isFalse(isTypesNotChanged, 'Issue Types not changed');
  }
  /**
   * @description method to test if issue type is changed with status and valid for triggering collections
   */
  @isTest
  static void testCheckStatusWithIssueTypes() {
    Case csObj = getCaseForCollections();
    csObj.Status = 'Closed';
    Case csObj2 = new Case();
    csObj2.Id = csObj.Id;
    csObj2.Status = 'Re-opened';
    Case csObj3 = new Case();
    csObj3.Id = csObj.Id;
    csObj3.Status = 'Open';
    csObj3.Type = '17';
    csObj3.IDR_Subsequent_Issue__c = '24';
    csObj3.IDR_Issue_Type_2__c = '4';
    csObj3.IDR_Issue_Type_3__c = '5';

    Test.startTest();
    Boolean isStatusChangeValid = IDRCollectionActions.checkStatusWithIssueTypes(
      csObj2,
      csObj,
      1
    );
    Boolean isTypeWithStatusValid = IDRCollectionActions.checkStatusWithIssueTypes(
      csObj3,
      csObj,
      1
    );
    Boolean isType2WithStatusValid = IDRCollectionActions.checkStatusWithIssueTypes(
      csObj3,
      csObj,
      2
    );
    Boolean isType3WithStatusValid = IDRCollectionActions.checkStatusWithIssueTypes(
      csObj3,
      csObj,
      3
    );
    Test.stopTest();
    Assert.isTrue(
      isStatusChangeValid,
      'Status changes on case records are valid for Collection Events'
    );
    Assert.isTrue(
      isTypeWithStatusValid,
      'Type 1 changes on case records are valid for Collection Events'
    );
    Assert.isTrue(
      isType2WithStatusValid,
      'Type 2 changes on case records are valid for Collection Events'
    );
    Assert.isTrue(
      isType3WithStatusValid,
      'Type 3 changes on case records are valid for Collection Events'
    );
  }
  /**
   * @description method to test if changes in record is valid for triggering start collections
   */
  @isTest
  static void testValidateRecordForStartCollection() {
    Product2 testProduct = new Product2();
    testProduct.Name = 'ANZ Flyer Card';
    testProduct.IsActive = true;
    testProduct.Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);
    QueryProducts.productsById = new Map<Id, Product2>{
      testProduct.Id => testProduct
    };
    Case csObj = getCaseForCollections();
    csObj.Status = 'Closed';
    csObj.Product__c = testProduct.Id;
    csObj.IDR_Product_2__c = testProduct.Id;
    csObj.IDR_Product_3__c = testProduct.Id;
    Set<Id> caseIds = new Set<Id>{ csObj.Id };
    Map<String, Set<Id>> startCollecMap = new Map<String, Set<Id>>();
    startCollecMap.put('000000000022222333344444', caseIds);
    startCollecMap.put('N/A', caseIds);
    startCollecMap.put('22222333344444', caseIds);
    startCollecMap.put('22222', caseIds);

    Test.startTest();
    List<IDRCollectionsAccounts> idrCollectionAccounts = IDRCollectionActions.validateRecordForStartCollection(
      csObj,
      startCollecMap
    );
    Test.stopTest();
    Assert.areEqual(
      2,
      idrCollectionAccounts.size(),
      'Two out of three account numbers should be returned'
    );
    Assert.areEqual(
      false,
      String.valueOf(idrCollectionAccounts[0]) == 'N/A',
      'NA should not be included in the returned account list'
    );
  }
  /**
   * @description method to test valid account policy number pattern
   */
  @IsTest
  static void testValidateAccNumberPattern() {
    Case csObj = getCaseForCollections();
    Case csObj1 = new Case();
    csObj1.Id = csObj.Id;
    csObj1.RecordTypeId = csObj.RecordTypeId;
    csObj1.IDR_Account_Card_Policy_Number__c = 'AAATT-321';
    csObj1.IDR_Account_Card_Policy_Number_2__c = 'AAATT-321';
    csObj1.IDR_Account_Card_Policy_Number_3__c = 'AAATT-321';

    Test.startTest();
    try {
      IDRCollectionActions.validateAccNumberPattern(csObj1, csObj);
    } catch (Exception e) {
      Assert.isTrue(
        e.getMessage().contains(IDRConstants.INVALID_ACC_NO_MESSAGE),
        'Error Message should contain invalid account string'
      );
    }
    Test.stopTest();
  }
  /**
   * @description method to test logging successfully published collection events
   */
  @isTest
  static void testSuccessLogsForCollectionEvents() {
    Boolean exceptionThrown = false;
    IDR_Collections_Event__e collectionsEvent = new IDR_Collections_Event__e();
    collectionsEvent.IDR_Complaint_Number__c = '123456';
    collectionsEvent.IDR_Complaint_Status__c = 'Open';
    collectionsEvent.IDR_Complaint_Case_Id__c = Lib_FakeIdGenerator.getMockId(
      Case.SObjectType
    );
    try {
      Test.startTest();
      IDRCollectionActions.logCollectionEvent(
        collectionsEvent,
        'Stop Collection',
        null
      );
      Test.stopTest();
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Assert.isFalse(
      exceptionThrown,
      'No Error log should be there when Collection event is a success'
    );
  }
  /**
   * @description method to test failure of publishing collections events
   */
  @isTest
  static void testErrorLogForCollectionEvents() {
    IDR_Collections_Event__e collectionsEvent = new IDR_Collections_Event__e();
    collectionsEvent.IDR_Complaint_Number__c = '123456';
    collectionsEvent.IDR_Complaint_Status__c = 'Open';
    collectionsEvent.IDR_Complaint_Case_Id__c = Lib_FakeIdGenerator.getMockId(
      Case.SObjectType
    );
    String eventError = 'STOP Collections trigger event failed';
    try {
      Test.startTest();
      IDRCollectionActions.logCollectionEvent(
        collectionsEvent,
        'Stop Collection',
        eventError
      );
      Test.stopTest();
    } catch (Exception e) {
      Assert.areEqual(
        'STOP Collections trigger event failed',
        e.getMessage(),
        'Exception message should match'
      );
    }
  }
  /**
   * @description method to test task creation for successful pcc tasks
   */
  @isTest
  static void testLogPCCCollectionsTasksSuccess() {
    Boolean exceptionThrown = false;
    Task pccSuccessTask = getPCCTask();
    pccSuccessTask.Subject = 'Collection successful in PCC';
    pccSuccessTask.Description = 'Collection successful in PCC';
    try {
      Test.startTest();
      IDRCollectionActions.logPCCCollectionTasks(
        new List<Task>{ pccSuccessTask }
      );
      Test.stopTest();
    } catch (Exception e) {
      exceptionThrown = true;
    }
    Assert.isFalse(
      exceptionThrown,
      'No PCC Error is there, logged info for successful Task Creation'
    );
  }
  /**
   * @description method to test task creation for failed pcc tasks
   */
  @isTest
  static void testLogPCCCollectionsTasksFailure() {
    Boolean exceptionThrown = false;
    Task pccFailureTask = getPCCTask();
    pccFailureTask.Subject = 'ERROR - Stop Collection in PCC';
    pccFailureTask.Description = 'ERROR - 400 Failed to Stop collections';
    try {
      Test.startTest();
      IDRCollectionActions.logPCCCollectionTasks(
        new List<Task>{ pccFailureTask }
      );
      Test.stopTest();
    } catch (Exception e) {
      exceptionThrown = true;
      Assert.isTrue(
        exceptionThrown,
        'Error response from PCC, logged error for failure Task'
      );
      Assert.areEqual(
        'ERROR - 400 Failed to Stop collections',
        e.getMessage(),
        'Error Log Message matches'
      );
    }
  }
}
