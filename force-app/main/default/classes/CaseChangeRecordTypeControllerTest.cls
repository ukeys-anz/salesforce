@isTest
public with sharing class CaseChangeRecordTypeControllerTest {
  /**
   * @description handle getting an unauthenticated enquiry case, try cloning the record, preparing a new -
   * - record and will return the oldRecord and newRecord.
   * @param typeValue new value for typeValue | if the value is an empty string, it will not change it
   * @param priorityValue new value for priority | if the value is an empty string, it will not change it
   * @param rtId new value for RecordTypeId
   * @return `List<Case>` will return oldRecord and new prepared one.
   */
  private static List<Case> prepareNewRecord(
    String typeValue,
    String priorityValue,
    String rtId
  ) {
    // Given : we have a Unauthenticated Enquiry case
    Case oldRecord = [
      SELECT Id, ANZx_Customer__c, RecordTypeId, Type
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID
      LIMIT 1
    ];

    // Then: a newRecord will be cloned from oldRecord by same id -
    // - and Type, Priority and RecordTypeId will be changed if the value is not ''
    Case newRecord = oldRecord.clone(true, true);
    if (typeValue != '') {
      newRecord.Type = typeValue;
    }
    if (priorityValue != '') {
      newRecord.Priority = priorityValue;
    }
    newRecord.RecordTypeId = rtId;
    List<Case> cList = new List<Case>{ newRecord, oldRecord };
    return cList;
  }

  @TestSetup
  static void setup() {
    List<Case> caseList = new List<Case>();

    Case oldRecord = new case();
    oldRecord.RecordTypeId = GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID;
    oldRecord.Origin = 'ANZ Plus Web';
    oldRecord.Priority = 'Standard';
    oldRecord.Type = CommonUtil.getSinglePicklistValue(Case.Type, 'Other');
    oldRecord.ANZx_Customer__c = true;
    oldRecord.IDR_Product_Category__c = 'Not product related';
    caseList.add(oldRecord);

    insert caseList;
  }

  @istest
  static void testChangeRTToGeneralEnquiryWithNullTypeAndPriority() {
    // This test is for testing the trigger | To check if the class will work with trigger or not
    // Suppose oldRecord is unauthenticated enquiry and update is to change the record type to general enquiry -
    // - and Type and Priority fields are null
    Case oldRecord = [
      SELECT Id, ANZx_Customer__c, RecordTypeId
      FROM Case
      WHERE RecordTypeId = :GetHelpConstants.UNAUTHENTICATED_ENQUIRY_RT_ID
      LIMIT 1
    ];

    // When I update the case with Type and Priority to be null
    oldRecord.Type = '';
    oldRecord.Priority = '';
    oldRecord.RecordTypeId = GetHelpConstants.GENERAL_INQUIRY_RT_ID;

    String errorMSG;
    Test.startTest();
    try {
      update oldRecord;
    } catch (Exception e) {
      errorMSG = e.getMessage();
    }
    Test.stopTest();
    // Then I should get an error
    System.assert(
      errorMSG.contains(
        CaseChangeRecordTypeController.CHANGE_ISSUE_TYPE_AND_PRIORITY_VALUES
      ),
      'The error message should be as expected.'
    );
  }

  @istest
  static void testChangeRTToGeneralEnquiryWithNullType() {
    // Suppose oldRecord is unauthenticated enquiry and update is to change the record type to general enquiry -
    // - and Type field is null
    Test.startTest();
    List<Case> cList = prepareNewRecord(
      null,
      'High',
      GetHelpConstants.GENERAL_INQUIRY_RT_ID
    );
    List<Case> caseList = new List<Case>{ cList[0] };
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{ cList[1].Id => cList[1] };

    // Then: It will try to update the case
    CaseChangeRecordTypeController.recordTypeChangeValidation(
      caseList,
      oldCaseMap
    );

    // Then: It will return the errors on the record. If there is no error, then there will be no error.
    List<Database.Error> errors = caseList[0].getErrors();

    Test.stopTest();
    // Then I should get an error
    System.assert(
      errors[0]
        .getMessage()
        .contains(CaseChangeRecordTypeController.CHANGE_ISSUE_TYPE_VALUE),
      'The error message should be as expected.'
    );
  }

  @istest
  static void testChangeRTToGeneralEnquiryWithNullPriority() {
    // Suppose oldRecord is unauthenticated enquiry and update is to change the record type to general enquiry -
    // - and Priority field is null
    Test.startTest();
    List<Case> cList = prepareNewRecord(
      'Cards',
      null,
      GetHelpConstants.GENERAL_INQUIRY_RT_ID
    );
    List<Case> caseList = new List<Case>{ cList[0] };
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{ cList[1].Id => cList[1] };

    // Then: It will try to update the case
    CaseChangeRecordTypeController.recordTypeChangeValidation(
      caseList,
      oldCaseMap
    );

    // Then: It will return the errors on the record. If there is no error, then there will be no error.
    List<Database.Error> errors = caseList[0].getErrors();
    Test.stopTest();
    // Then I should get an error
    System.assert(
      errors[0]
        .getMessage()
        .contains(CaseChangeRecordTypeController.CHANGE_PRIORITY_VALUE),
      'The error message should be as expected.'
    );
  }

  @istest
  static void testChangeRTToGeneralEnquirySuccess() {
    // Suppose oldRecord is unauthenticated enquiry and update is to change the record type to general enquiry -
    // - with Type and Priority are not null.
    Test.startTest();
    List<Case> cList = prepareNewRecord(
      'Cards',
      'High',
      GetHelpConstants.GENERAL_INQUIRY_RT_ID
    );
    List<Case> caseList = new List<Case>{ cList[0] };
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{ cList[1].Id => cList[1] };

    // Then: It will try to update the case
    CaseChangeRecordTypeController.recordTypeChangeValidation(
      caseList,
      oldCaseMap
    );

    // Then: It will return the errors on the record. If there is no error, then there will be no error.
    List<Database.Error> errors = caseList[0].getErrors();
    Test.stopTest();
    // Then The record should be updated
    System.assert(
      errors.size() == 0,
      'The record should be updated successfully.'
    );
  }

  @istest
  static void testChangeRTToANZXComplaintWithNullType() {
    // Suppose oldRecord is unauthenticated enquiry and update is to change the record type to anz plus complaint -
    // - and type field is null
    Test.startTest();
    List<Case> cList = prepareNewRecord(
      null,
      '',
      GetHelpConstants.COMPLAINT_RT_ID
    );
    List<Case> caseList = new List<Case>{ cList[0] };
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{ cList[1].Id => cList[1] };

    // Then: It will try to update the case
    CaseChangeRecordTypeController.recordTypeChangeValidation(
      caseList,
      oldCaseMap
    );

    // Then: It will return the errors on the record. If there is no error, then there will be no error.
    List<Database.Error> errors = caseList[0].getErrors();
    Test.stopTest();
    // Then I should get an error
    System.assert(
      errors[0]
        .getMessage()
        .contains(CaseChangeRecordTypeController.CHANGE_ISSUE_TYPE_VALUE),
      'The error message should be as expected.'
    );
  }

  @istest
  static void testChangeRTToANZXComplaintSuccess() {
    // Suppose oldRecord is unauthenticated enquiry and update is to change the record type to anz plus complaint -
    // - and type field is not null
    Test.startTest();
    List<Case> cList = prepareNewRecord(
      'Collections',
      '',
      GetHelpConstants.COMPLAINT_RT_ID
    );
    List<Case> caseList = new List<Case>{ cList[0] };
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{ cList[1].Id => cList[1] };

    // Then: It will try to update the case
    CaseChangeRecordTypeController.recordTypeChangeValidation(
      caseList,
      oldCaseMap
    );

    // Then: It will return the errors on the record. If there is no error, then there will be no error.
    List<Database.Error> errors = caseList[0].getErrors();
    Test.stopTest();
    // Then the record should be updated
    System.assert(
      errors.size() == 0,
      'The record should be updated successfully.'
    );
  }

  @istest
  static void testChangeRTToNonCustomerComplaintWithNullType() {
    // Suppose oldRecord is unauthenticated enquiry and update is to change the record type to non customer complaint -
    // - and type field is null
    Test.startTest();
    List<Case> cList = prepareNewRecord(
      null,
      '',
      GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID
    );
    List<Case> caseList = new List<Case>{ cList[0] };
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{ cList[1].Id => cList[1] };

    // Then: It will try to update the case
    CaseChangeRecordTypeController.recordTypeChangeValidation(
      caseList,
      oldCaseMap
    );

    // Then: It will return the errors on the record. If there is no error, then there will be no error.
    List<Database.Error> errors = caseList[0].getErrors();
    Test.stopTest();
    // Then I should get an error
    System.assert(
      errors[0]
        .getMessage()
        .contains(CaseChangeRecordTypeController.CHANGE_ISSUE_TYPE_VALUE),
      'The error message should be as expected.'
    );
  }

  @istest
  static void testChangeRTToNonCustomerComplaintSuccess() {
    // Suppose oldRecord is unauthenticated enquiry and update is to change the record type to non customer complaint -
    // - and type field is not null
    Test.startTest();
    List<Case> cList = prepareNewRecord(
      'Collections',
      '',
      GetHelpConstants.NON_CUSTOMER_COMPLAINT_RT_ID
    );
    List<Case> caseList = new List<Case>{ cList[0] };
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{ cList[1].Id => cList[1] };

    // Then: It will try to update the case
    CaseChangeRecordTypeController.recordTypeChangeValidation(
      caseList,
      oldCaseMap
    );

    // Then: It will return the errors on the record. If there is no error, then there will be no error.
    List<Database.Error> errors = caseList[0].getErrors();
    Test.stopTest();
    // Then the record should be updated.
    System.assert(errors.size() == 0, 'The record should be updated.');
  }
}
