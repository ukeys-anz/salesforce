/**
 * @author Somya Tiwari
 * @since  03/2024
 * @description IDR_CaseReportingCalculationsTest is test class for IDR_CaseReportingCalculations
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
public with sharing class IDR_CaseReportingCalculationsTest {
  @isTest
  static void testGetRecordsToProcessInsert() {
    List<Case> insertCases = new List<Case>();
    Case caseRecordNewVersion1 = new Case();
    caseRecordNewVersion1.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecordNewVersion1.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecordNewVersion1.Status = 'Open';
    insertCases.add(caseRecordNewVersion1);
    Case caseRecordNewVersion2 = new Case();
    caseRecordNewVersion2.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecordNewVersion2.RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;
    caseRecordNewVersion2.Status = 'Open';
    insertCases.add(caseRecordNewVersion2);
    Case caseRecordNewVersion3 = new Case();
    caseRecordNewVersion3.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecordNewVersion3.RecordTypeId = IDRConstants.CFMS_MIGRATED_CASE_RT_ID;
    caseRecordNewVersion3.Status = 'Closed';
    insertCases.add(caseRecordNewVersion3);
    Test.startTest();
    List<Case> onInsertFilteredCase = IDR_CaseReportingCalculations.getRecordsToProcess(
      insertCases,
      new Map<ID, Case>()
    );
    Test.StopTest();
    Assert.areEqual(
      2,
      onInsertFilteredCase.size(),
      '2 Cases must be processed'
    );
    Assert.areEqual(
      caseRecordNewVersion1.Id,
      onInsertFilteredCase[0].Id,
      'Case Record 1 must be processed'
    );
    Assert.areEqual(
      caseRecordNewVersion2.Id,
      onInsertFilteredCase[1].Id,
      'Case Record 2 must be processed'
    );
  }
  @isTest
  static void testGetRecordsToProcessUpdate() {
    List<Case> updateCases = new List<Case>();
    Case caseRecordOldVersion1 = new Case();
    caseRecordOldVersion1.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecordOldVersion1.RecordTypeId = IDRConstants.CFMS_MIGRATED_CASE_RT_ID;
    caseRecordOldVersion1.Status = 'Open';
    Case caseRecordOldVersion2 = new Case();
    caseRecordOldVersion2.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecordOldVersion2.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecordOldVersion2.Status = 'Re-opened';
    Case caseRecordOldVersion3 = new Case();
    caseRecordOldVersion3.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecordOldVersion3.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecordOldVersion3.Status = 'Provisionally Closed';
    Case caseRecordNewVersion1 = new Case();
    caseRecordNewVersion1.Id = caseRecordOldVersion1.Id;
    caseRecordNewVersion1.RecordTypeId = IDRConstants.CFMS_MIGRATED_CASE_RT_ID;
    caseRecordNewVersion1.Status = 'Closed';
    updateCases.add(caseRecordNewVersion1);
    Case caseRecordNewVersion2 = new Case();
    caseRecordNewVersion2.Id = caseRecordOldVersion2.Id;
    caseRecordNewVersion2.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecordNewVersion2.Status = 'Closed';
    updateCases.add(caseRecordNewVersion2);
    Case caseRecordNewVersion3 = new Case();
    caseRecordNewVersion3.Id = caseRecordOldVersion3.Id;
    caseRecordNewVersion3.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecordNewVersion3.Status = 'Closed';
    updateCases.add(caseRecordNewVersion3);
    Map<ID, Case> oldMap = new Map<ID, Case>();
    oldMap.put(caseRecordOldVersion1.Id, caseRecordOldVersion1);
    oldMap.put(caseRecordOldVersion2.Id, caseRecordOldVersion2);
    oldMap.put(caseRecordOldVersion3.Id, caseRecordOldVersion3);
    Test.startTest();
    List<Case> onUpdateFilteredCase = IDR_CaseReportingCalculations.getRecordsToProcess(
      updateCases,
      oldMap
    );
    Test.StopTest();
    Assert.areEqual(
      1,
      onUpdateFilteredCase.size(),
      '1 Cases must be filtered out of 3 on Update'
    );
    Assert.areEqual(
      caseRecordOldVersion2.Id,
      onUpdateFilteredCase[0].Id,
      'Re Opened to Closed Case must be returned'
    );
  }
  @isTest
  static void testUpdateCaseReportingFieldUpdateToDateOpenField() {
    List<Case> recordsToProcess = new List<Case>();
    Map<ID, Case> oldMap = new Map<ID, Case>();
    Case caseRecord1 = new Case();
    caseRecord1.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecord1.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecord1.Status = 'Open';
    recordsToProcess.add(caseRecord1);
    Case caseRecord2 = new Case();
    caseRecord2.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecord2.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecord2.Status = 'Re-opened';
    recordsToProcess.add(caseRecord2);
    Map<ID, Case_Reporting_Field__c> caseIdToFieldMap = IDR_CaseReportingCalculations.getReportingFieldForCases(
      recordsToProcess
    );
    for (ID caseId : caseIdToFieldMap.keySet()) {
      Case_Reporting_Field__c crf = caseIdToFieldMap.get(caseId);
      crf.Case_Last_Opened_RG271__c = DateTime.now();
      crf.Case_Last_Opened__c = DateTime.now();
      caseIdToFieldMap.put(caseId, crf);
    }
    Test.startTest();
    List<Case_Reporting_Field__c> crfList = IDR_CaseReportingCalculations.updateCaseReportingField(
      recordsToProcess,
      oldMap,
      caseIdToFieldMap
    );
    Test.StopTest();
    Assert.areEqual(
      2,
      crfList.size(),
      '2 Case Reporting Fields must be generated'
    );
    Assert.areEqual(
      caseRecord1.Id,
      crfList[0].Case__c,
      'Case Reporting Fields for Case 1 must be processed'
    );
    Assert.areEqual(
      caseRecord2.Id,
      crfList[1].Case__c,
      'Case Reporting Fields for Case 2 must be processed'
    );
  }
  @isTest
  static void testUpdateCaseReportingFieldUpdateTotalOpenTime() {
    List<Case> recordsToProcess = new List<Case>();
    Map<ID, Case> oldMap = new Map<ID, Case>();
    Case caseRecordNewVersion1 = new Case();
    caseRecordNewVersion1.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecordNewVersion1.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecordNewVersion1.Status = 'Closed';
    recordsToProcess.add(caseRecordNewVersion1);
    Case caseRecordNewVersion2 = new Case();
    caseRecordNewVersion2.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecordNewVersion2.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecordNewVersion2.Status = 'Closed';
    recordsToProcess.add(caseRecordNewVersion2);
    Case caseRecordOldVersion1 = new Case();
    caseRecordOldVersion1.Id = caseRecordNewVersion1.Id;
    caseRecordOldVersion1.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecordOldVersion1.Status = 'Open';
    oldMap.put(caseRecordOldVersion1.Id, caseRecordOldVersion1);
    Case caseRecordOldVersion2 = new Case();
    caseRecordOldVersion2.Id = caseRecordNewVersion2.Id;
    caseRecordOldVersion2.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecordOldVersion2.Status = 'Re-opened';
    oldMap.put(caseRecordOldVersion2.Id, caseRecordOldVersion2);
    Map<ID, Case_Reporting_Field__c> caseIdToFieldMap = IDR_CaseReportingCalculations.getReportingFieldForCases(
      recordsToProcess
    );
    for (ID caseId : caseIdToFieldMap.keySet()) {
      Case_Reporting_Field__c crf = caseIdToFieldMap.get(caseId);
      crf.Case_Last_Opened_RG271__c = DateTime.now();
      crf.Case_Last_Opened__c = DateTime.now();
      caseIdToFieldMap.put(caseId, crf);
    }
    Test.startTest();
    List<Case_Reporting_Field__c> reportingFields = IDR_CaseReportingCalculations.updateCaseReportingField(
      recordsToProcess,
      oldMap,
      caseIdToFieldMap
    );
    Test.StopTest();
    Assert.areEqual(
      2,
      reportingFields.size(),
      'We must get 2 Reporting Fields to Update'
    );
    Assert.areEqual(
      caseRecordNewVersion1.Id,
      reportingFields[0].Case__c,
      'Case Reporting Fields for Case 1 must be processed'
    );
    Assert.areEqual(
      caseRecordNewVersion2.Id,
      reportingFields[1].Case__c,
      'Case Reporting Fields for Case 2 must be processed'
    );
  }

  @isTest
  static void testGetReportingFieldForCases() {
    List<Case> recordsToProcess = new List<Case>();
    Map<ID, Case> oldMap = new Map<ID, Case>();
    Case caseRecord1 = new Case();
    caseRecord1.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecord1.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecord1.Status = 'Closed';
    recordsToProcess.add(caseRecord1);
    Case caseRecord2 = new Case();
    caseRecord2.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecord2.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecord2.Status = 'Closed';
    recordsToProcess.add(caseRecord2);
    Test.startTest();
    Map<ID, Case_Reporting_Field__c> caseReportingFieldMap = IDR_CaseReportingCalculations.getReportingFieldForCases(
      recordsToProcess
    );
    Test.StopTest();
    Assert.areEqual(
      2,
      caseReportingFieldMap.keySet().size(),
      'We must get 2 Reporting Fields to Update'
    );
  }
}
