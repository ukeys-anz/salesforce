/**
 * @author David Dawson
 * @date April 2020
 * @description Test class for {@link IDRCaseActions}
 * @group IDR(Internal Dispute Resolution)
 */

@isTest
private with sharing class IDRCaseActionsTest {
  static Case caseRecord = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    RecordTypeId = RTCase.customerComplaint
  );
  static Case caseRecord1 = new Case(
    Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType),
    RecordTypeId = RTCase.customerComplaint,
    IDR_Second_Issue__c = true,
    IDR_Third_Issue__c = true,
    IDR_Issue_Type_2__c = '9',
    IDR_Issue_Type_3__c = '2',
    IDR_Subsequent_Issue_2__c = '57',
    IDR_Subsequent_Issue_3__c = '14'
  );

  //data setup
  @isTest
  static void testFormatedCaseNumber() {
    Case c = new Case(RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID);
    insert c;
    c.CaseNumber__c = '00009999';
    update c;
    String caseNumberNotif = IDRCaseActions.getFormattedCaseNumberToNotify(c);
    System.assertEquals(
      '9999',
      caseNumberNotif,
      'Use CaseNumber__c instead of CaseNumber, and remove trailing zeros'
    );
  }

  @isTest
  static void testPicklistLabelFromValue() {
    System.assertEquals(
      'VIC',
      CommonUtil.getSinglePicklistLabel(Case.IDR_NC_State__c, '2'),
      'Key=2, Value=VIC'
    );
  }

  @isTest
  static void testNotificationsWithContactDetails() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          Status = 'Escalated',
          IDR_Escalated_to__c = '1',
          IDR_Escalation_Reason__c = '1',
          IDR_SwicthOff_3rd_Party_Notification__c = false,
          IDR_SwitchOff_Customer_Notification__c = false
        )
      );
    }
    insert newCases;
    List<Notification_Handler__c> nhList = [
      SELECT Id
      FROM Notification_Handler__c
    ];

    System.assertEquals(
      Integer.valueOf(Label.Test_Bulk_Size),
      nhList.size(),
      'Matching no of events'
    );
  }

  @isTest
  static void testNotificationsWithoutContactDetails() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = 'Open'
        )
      );
    }
    insert newCases;
    List<Notification_Handler__c> nhList = [
      SELECT Id
      FROM Notification_Handler__c
    ];

    System.assertEquals(0, nhList.size(), 'Matching no of events');
  }

  @isTest
  static void testPseudoAutoEscalation3Days() {
    //GIVEN new complaints created as OPEN
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = IDRConstants.OPEN_STATUS,
          isEscalated = false
        )
      );
    }
    insert newCases;

    //WHEN they are updated as auto-escalation would do (owner and escalated flag)
    Set<Id> caseIds = (new Map<Id, Case>(newCases)).keySet();
    newCases = [SELECT OwnerId, isEscalated FROM Case WHERE id IN :caseIds];
    for (Case c : newCases) {
      c.IsEscalated = true;
      c.IDR_Escalated_to__c = '1';
    }
    update newCases;

    //THEN escalation reason is updated accordingly
    Case c = [
      SELECT IDR_Escalation_Reason__c
      FROM Case
      WHERE id = :newCases[0].Id
    ];
    System.assertEquals(
      IDRCaseActions.DAY_5_ESCALATION_REASON,
      c.IDR_Escalation_Reason__c,
      'Escalation reason should be auto-escalated'
    );
  }

  @isTest
  static void testPseudoAutoEscalation5Days() {
    //GIVEN new complaints created as UNDER INVESTIGATION
    //GIVEN blank IDR_Escalation_Reason__c
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = IDRConstants.UNDER_INVESTIGATION_STATUS,
          isEscalated = false
        )
      );
    }
    insert newCases;

    //WHEN they are updated as auto-escalation would do (owner and escalated flag)
    Set<Id> caseIds = (new Map<Id, Case>(newCases)).keySet();
    newCases = [SELECT OwnerId, isEscalated FROM Case WHERE id IN :caseIds];
    for (Case c : newCases) {
      c.IsEscalated = true;
      c.IDR_Escalated_to__c = '1';
    }
    update newCases;

    //THEN escalation reason is updated accordingly
    Case c = [
      SELECT IDR_Escalation_Reason__c
      FROM Case
      WHERE id = :newCases[0].Id
    ];
    System.assertEquals(
      IDRCaseActions.DAY_5_ESCALATION_REASON,
      c.IDR_Escalation_Reason__c,
      'Escalation reason should be auto-escalated'
    );
  }

  @isTest
  static void testPseudoAutoEscalation5DaysWithComplaintReasonFilled() {
    //GIVEN new complaints created as OPEN Status
    //GIVEN IDR_Escalation_Reason__c = Indexing, the only allowed pre-filled escalation reason to be auto escalated for cases.
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          Status = IDRConstants.OPEN_STATUS,
          IDR_Escalation_Reason__C = IDRCaseActions.INDEXING_ESCALATION_REASON,
          isEscalated = false
        )
      );
    }
    insert newCases;

    //WHEN they are updated as auto-escalation would do (owner and escalated flag)
    Set<Id> caseIds = (new Map<Id, Case>(newCases)).keySet();
    newCases = [SELECT OwnerId, isEscalated FROM Case WHERE id IN :caseIds];
    for (Case c : newCases) {
      c.IsEscalated = true;
      c.IDR_Escalated_to__c = '1';
    }
    update newCases;

    //THEN escalation reason should not updated, as it has been pre-filled
    Case c = [
      SELECT IDR_Escalation_Reason__c, Status
      FROM Case
      WHERE id = :newCases[0].Id
    ];

    System.assertEquals(
      IDRConstants.ESCALATED_STATUS,
      c.Status,
      'Status should be escalated'
    );

    System.assertEquals(
      IDRCaseActions.INDEXING_ESCALATION_REASON,
      c.IDR_Escalation_Reason__c,
      'Escalation reason should be 18, the API named for Indexing.'
    );
  }

  @istest
  static void testCustomerNumberValidation() {
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890'
        )
      );
    }
    insert newCases;

    for (Case c : newCases) {
      c.IDR_Customer_Number__c = '0987654321';
    }
    try {
      update newCases;
    } catch (DMLexception e) {
      system.assert(
        e.getMessage().contains('This field can no longer be edited.'),
        'Error message should be as expected.'
      );
    }
  }

  @isTest
  static void testUpdateDateTimePsiTicked() {
    //GIVEN new PSIs
    Case[] newCases = new List<Case>();
    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID,
          IDR_Is_Common__c = 'yes',
          IDR_Systemic_Issue_Category__c = '1',
          IDR_Systemic_Issue_Description__c = 'Test'
        )
      );
    }
    //WHEN they're inserted
    insert newCases;
    //THEN Date/Time flag is populated
    Case c = [SELECT IDR_Datetime_PSI_Ticked__c FROM Case LIMIT 1];
    System.assert(
      c.IDR_Datetime_PSI_Ticked__c != null,
      'Date/Time flag should have been populated'
    );
    //AND WHEN they're unflagged
    for (Case newCase : newCases) {
      newCase.IDR_Is_Common__c = 'No';
    }
    update newCases;
    //THEN Date/Time flag is cleared
    c = [SELECT IDR_Datetime_PSI_Ticked__c FROM Case LIMIT 1];
    System.assert(
      c.IDR_Datetime_PSI_Ticked__c == null,
      'Date/Time flag should have been cleared'
    );
  }
  @isTest
  static void testUpdateKnowledgeKeyWordCaseFieldsonInsert() {
    Case testCase1 = caseRecord1;

    String issueType2 = getPicklistValuebyAPIName(
      Case.IDR_Issue_Type_2__c,
      '9'
    );
    String issueType3 = getPicklistValuebyAPIName(
      Case.IDR_Issue_Type_3__c,
      '2'
    );
    String subIssueType2 = getPicklistValuebyAPIName(
      Case.IDR_Subsequent_Issue_2__c,
      '57'
    );
    String subIssueType3 = getPicklistValuebyAPIName(
      Case.IDR_Subsequent_Issue_3__c,
      '14'
    );
    Test.startTest();
    IDRCaseActions.updateKnowledgeKeyWordCaseFields(
      new List<Case>{ testCase1 },
      new Map<Id, Case>{}
    );
    Test.stopTest();
    System.assertEquals(
      issueType2 + ' ' + subIssueType2,
      testCase1.IDR_Knowledge_Keyword_1__c,
      'Knowledge Keyword 1 will be updated based on Issue and SubIssue Types'
    );
    System.assertEquals(
      issueType3 + ' ' + subIssueType3,
      testCase1.IDR_Knowledge_Keyword_2__c,
      'Knowledge Keyword 2 will be updated based on Issue and SubIssue Types'
    );
  }

  @isTest
  static void testUpdateKnowledgeKeyWordCaseFieldsonUpdate() {
    Case testCase1 = caseRecord1;

    Case testCase2 = caseRecord;
    testCase2.Id = testCase1.Id;
    testCase2.IDR_Issue_Type_2__c = '18';
    testCase2.IDR_Issue_Type_3__c = '16';
    testCase2.IDR_Subsequent_Issue_2__c = '63';
    testCase2.IDR_Subsequent_Issue_3__c = '78';
    String issueType2 = getPicklistValuebyAPIName(
      Case.IDR_Issue_Type_2__c,
      '18'
    );
    String issueType3 = getPicklistValuebyAPIName(
      Case.IDR_Issue_Type_3__c,
      '16'
    );
    String subIssueType2 = getPicklistValuebyAPIName(
      Case.IDR_Subsequent_Issue_2__c,
      '63'
    );
    String subIssueType3 = getPicklistValuebyAPIName(
      Case.IDR_Subsequent_Issue_3__c,
      '78'
    );

    Test.startTest();
    IDRCaseActions.updateKnowledgeKeyWordCaseFields(
      new List<Case>{ testCase2 },
      new Map<Id, Case>{ testCase1.Id => testCase1 }
    );
    Test.stopTest();

    System.assertEquals(
      issueType2 + ' ' + subIssueType2,
      testCase2.IDR_Knowledge_Keyword_1__c,
      'Knowledge Keyword 1 will be updated based on Issue and SubIssue Types'
    );
    System.assertEquals(
      issueType3 + ' ' + subIssueType3,
      testCase2.IDR_Knowledge_Keyword_2__c,
      'Knowledge Keyword 2 will be updated based on Issue and SubIssue Types'
    );
  }

  @isTest
  static void testNotUpdateKnowledgeKeyWordCaseFields() {
    Case testCase1 = caseRecord1;

    Case testCase2 = caseRecord1;
    testCase2.Id = testCase1.Id;
    testCase2.Priority = IDRConstants.CASE_PRIORITY_STANDARD;

    String issueType2 = getPicklistValuebyAPIName(
      Case.IDR_Issue_Type_2__c,
      '9'
    );
    String issueType3 = getPicklistValuebyAPIName(
      Case.IDR_Issue_Type_3__c,
      '2'
    );
    String subIssueType2 = getPicklistValuebyAPIName(
      Case.IDR_Subsequent_Issue_2__c,
      '57'
    );
    String subIssueType3 = getPicklistValuebyAPIName(
      Case.IDR_Subsequent_Issue_3__c,
      '14'
    );

    Test.startTest();
    IDRCaseActions.updateKnowledgeKeyWordCaseFields(
      new List<Case>{ testCase2 },
      new Map<Id, Case>{ testCase1.Id => testCase1 }
    );
    Test.stopTest();

    System.assertEquals(
      issueType2 + ' ' + subIssueType2,
      testCase1.IDR_Knowledge_Keyword_1__c,
      'Knowledge KeyWord 1 will not be updated as there is no change in IssueType'
    );
    System.assertEquals(
      issueType3 + ' ' + subIssueType3,
      testCase1.IDR_Knowledge_Keyword_2__c,
      'Knowledge KeyWord 2 will not be updated as there is no change in IssueType'
    );
  }

  static String getPicklistValuebyAPIName(
    Schema.SObjectField fieldreference,
    String apiname
  ) {
    Schema.DescribeFieldResult field = fieldreference.getDescribe();

    for (Schema.PicklistEntry f : field.getPicklistValues()) {
      if (f.getValue() == apiName) {
        return f.getLabel();
      }
    }
    return null;
  }
  @isTest
  static void testProductAssetfinance() {
    String caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    Product_Family__c testProductFamily = new Product_Family__c();
    testProductFamily.Name = 'Asset finance';
    testProductFamily.Id = Lib_FakeIdGenerator.getMockId(
      Product_Family__c.SObjectType
    );

    Product2 testProduct = new Product2();
    testProduct.Name = 'Asset Finance';
    testProduct.IsActive = true;
    testProduct.IDR_Product_Family__r = testProductFamily;
    testProduct.Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);

    Product2 testProduct1 = new Product2();
    testProduct1.Name = 'ANZ Flyer Card';
    testProduct1.IsActive = true;
    testProduct1.Id = Lib_FakeIdGenerator.getMockId(Product2.SObjectType);

    QueryProducts.productsById = new Map<Id, Product2>{
      testProduct.Id => testProduct
    };

    Case oldCase = IDRTestDataFactory.createComplaint();
    oldCase.Type = '17';
    oldCase.IDR_Subsequent_Issue__c = '24';
    oldCase.Product__c = QueryProducts.productsById.get(testProduct.Id).Id;
    oldCase.IDR_Product_Family__r = QueryProducts.productsById.get(
        testProduct.Id
      )
      .IDR_Product_Family__r;
    oldCase.Id = caseRecordId;
    
    Case newCase = IDRTestDataFactory.createComplaint();
    newCase.Product__c = testProduct1.Id;
    newCase.Id = oldCase.Id;

    Case newCase1 = IDRTestDataFactory.createComplaint();
    newCase1.Product__c = testProduct1.Id;
    newCase1.Id = newCase.Id;

    Test.startTest();

    Boolean isProductAssetfinance = IDRCaseActions.isProductAssetfinance(
      newCase,
      oldCase
    );

    Boolean isNotProductAssetfinance = IDRCaseActions.isProductAssetfinance(
      newCase1,
      newCase
    );

    Test.stopTest();
    System.assertEquals(
      isProductAssetfinance,
      true,
      'When Product Family is Asset Finance and Issue Type is collections boolean should return true'
    );

    System.assertEquals(
      isNotProductAssetfinance,
      false,
      'When Product Family is not Asset Finance and Issue Type is collections boolean should return false'
    );
  }
  @isTest
  static void testIsCollectionsIssueChanged() {
    String caseRecordId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    Case testCase = IDRTestDataFactory.createComplaint();
    testCase.Id = caseRecordId;
    testCase.Type = '17';
    testCase.IDR_Subsequent_Issue__c = '24';
    testCase.IDR_Issue_Type_2__c = '17';
    testCase.IDR_Subsequent_Issue_2__c = '25';
    testCase.IDR_Issue_Type_3__c = '17';
    testCase.IDR_Subsequent_Issue_3__c = '26';

    Case testCase2 = IDRTestDataFactory.createComplaint();
    testCase2.Id = caseRecordId;
    testCase2.Type = '9';
    testCase2.IDR_Subsequent_Issue__c = '57';
    testCase2.IDR_Issue_Type_2__c = '13';
    testCase2.IDR_Subsequent_Issue_2__c = '2';
    testCase2.IDR_Issue_Type_3__c = '5';
    testCase2.IDR_Subsequent_Issue_3__c = '38';
    Test.startTest();
    Boolean isCollectionsIssueTypeChanged = IDRCaseActions.isCollectionIssueTypeChanged(
      testCase2,
      testCase
    );
    Boolean isIssueChangedtoCollections = IDRCaseActions.isCollectionIssueTypeChanged(
      testCase,
      testCase2
    );
    Test.stopTest();

    System.assertEquals(
      isCollectionsIssueTypeChanged,
      true,
      'Collections Issue Type cannot be updated on a Case'
    );

    System.assertEquals(
      isIssueChangedtoCollections,
      false,
      'Any other Issue Type can be changed to collections'
    );
  }
}
