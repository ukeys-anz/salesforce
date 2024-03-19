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
    Case caseRecord1 = new Case();
    caseRecord1.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecord1.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecord1.Status = 'Open';
    insertCases.add(caseRecord1);
    Case caseRecord2 = new Case();
    caseRecord2.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecord2.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecord2.Status = 'Open';
    insertCases.add(caseRecord2);
    Case caseRecord8 = new Case();
    caseRecord8.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecord8.RecordTypeId = IDRConstants.CFMS_MIGRATED_CASE_RT_ID;
    caseRecord8.Status = 'Closed';
    insertCases.add(caseRecord8);
    Test.startTest();
    List<Case> onInsertFilteredCase = IDR_CaseReportingCalculations.getRecordsToProcess(
      insertCases,
      new Map<ID, Case>()
    );
    Test.StopTest();
    Assert.areEqual(
      2,
      onInsertFilteredCase.size(),
      'All Insert Cases must be processed'
    );
  }
  @isTest
  static void testGetRecordsToProcessUpdate() {
    List<Case> updateCases = new List<Case>();
    Case caseRecord2 = new Case();
    caseRecord2.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecord2.RecordTypeId = IDRConstants.CFMS_MIGRATED_CASE_RT_ID;
    caseRecord2.Status = 'Open';
    Case caseRecord3 = new Case();
    caseRecord3.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecord3.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecord3.Status = 'Re-opened';
    Case caseRecord4 = new Case();
    caseRecord4.Id = caseRecord2.Id;
    caseRecord4.RecordTypeId = IDRConstants.CFMS_MIGRATED_CASE_RT_ID;
    caseRecord4.Status = 'Closed';
    updateCases.add(caseRecord4);
    Case caseRecord5 = new Case();
    caseRecord5.Id = caseRecord3.Id;
    caseRecord5.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecord5.Status = 'Closed';
    updateCases.add(caseRecord5);
    Case caseRecord6 = new Case();
    caseRecord6.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    caseRecord6.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecord6.Status = 'Provisionally Closed';
    Case caseRecord7 = new Case();
    caseRecord7.Id = caseRecord6.Id;
    caseRecord7.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecord7.Status = 'Closed';
    updateCases.add(caseRecord7);
    Map<ID, Case> oldMap = new Map<ID, Case>();
    oldMap.put(caseRecord2.Id, caseRecord2);
    oldMap.put(caseRecord3.Id, caseRecord3);
    oldMap.put(caseRecord6.Id, caseRecord6);
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
    Map<ID, Case_Reporting_Field__c> caseIdToFieldMap = getReportingFieldForCases(
      recordsToProcess
    );
    Test.startTest();
    IDR_CaseReportingCalculations.updateCaseReportingField(
      recordsToProcess,
      oldMap,
      caseIdToFieldMap
    );
    Test.StopTest();
  }
  @isTest
  static void testUpdateCaseReportingFieldUpdateTotalOpenTime() {
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
    Case caseRecord3 = new Case();
    caseRecord3.Id = caseRecord1.Id;
    caseRecord3.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecord3.Status = 'Open';
    oldMap.put(caseRecord3.Id, caseRecord3);
    Case caseRecord4 = new Case();
    caseRecord4.Id = caseRecord2.Id;
    caseRecord4.RecordTypeId = IDRConstants.NON_CUSTOMER_COMPLAINT_RT_ID;
    caseRecord4.Status = 'Re-opened';
    oldMap.put(caseRecord4.Id, caseRecord4);
    Map<ID, Case_Reporting_Field__c> caseIdToFieldMap = getReportingFieldForCases(
      recordsToProcess
    );
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

  private static Map<ID, Case_Reporting_Field__c> getReportingFieldForCases(
    List<Case> newRecords
  ) {
    Map<ID, Case_Reporting_Field__c> caseIdToFieldMap = new Map<ID, Case_Reporting_Field__c>();
    for (Case cse : newRecords) {
      if (!caseIdToFieldMap.containsKey(cse.Id)) {
        caseIdToFieldMap.put(cse.Id, initializeReportingField(cse));
      }
    }
    return caseIdToFieldMap;
  }

  private static Case_Reporting_Field__c initializeReportingField(Case cse) {
    Case_Reporting_Field__c crf = new Case_Reporting_Field__c();
    crf.Case__c = cse.Id;
    crf.IDR_Response_Time_RG271_MS__c = 0;
    crf.Total_Open_Time_MS__c = 0;
    crf.Case_Last_Opened_RG271__c = DateTime.now();
    crf.Case_Last_Opened__c = DateTime.now();
    return crf;
  }
}
