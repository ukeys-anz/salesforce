/**
 * @author Hrushikesh Pathak
 * @since 08/03/2024
 * @description test class for the GetHelpExternalCaseStatusActions
 */
@isTest
public with sharing class GetHelpExternalCaseStatusActionsTest {
  // test method to check that non NPP disputes should not be returned
  @isTest
  public static void testGetRelatedNPPCaseIds() {
    Case caseRecord = TestDataFactory.createCase('ATM_Dispute');
    caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = caseRecord.Id,
      External_Status__c = 'Resolved-Completed',
      Status_Event_ID__c = 'Status_Event_ID__c_0',
      Result_Message__c = 'Accept',
      Internal_Description__c = ''
    );
    Test.startTest();
    // Dummy call for test coverage
    GetHelpExternalCaseStatusActions.updateInternalDescription(
      new List<External_Case_Status__c>{ externalCaseStatus }
    );
    Set<Id> relatedNPPCasesId = GetHelpExternalCaseStatusActionHelper.getRelatedNppCasesIds(
      new List<Id>{ caseRecord.Id }
    );
    Test.stopTest();
    Assert.isTrue(relatedNPPCasesId.size() == 0, 'List size is incorrect');
  }

  @isTest
  public static void testUpdateIntDescForNonNPPDispute() {
    Case caseRecord = TestDataFactory.createCase('ATM_Dispute');
    caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = caseRecord.Id,
      External_Status__c = 'Resolved-Completed',
      Status_Event_ID__c = 'Status_Event_ID__c_0',
      Result_Message__c = 'Accept',
      Internal_Description__c = ''
    );
    Test.startTest();
    GetHelpExternalCaseStatusActions.updateInternalDescription(
      new List<External_Case_Status__c>{ externalCaseStatus }
    );
    Test.stopTest();
    Assert.isTrue(externalCaseStatus.Internal_Description__c == '', '');
  }

  // test method to check if internal description when result message is unkonwn
  @isTest
  public static void testGetInternalDescriptionForNPPDispute() {
    Case caseRecord = TestDataFactory.createCase('NPP_Dispute');
    caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    ExternalCaseStatusMappingQueryHelper caseStatusQueryHelper = ExternalCaseStatusMappingQueryHelper.getInstance();
    Map<String, String> statusToInternalDescMap = caseStatusQueryHelper.getStatusToInternalDescriptionMap();

    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = caseRecord.Id,
      External_Status__c = 'Resolved-Completed',
      Status_Event_ID__c = 'Status_Event_ID__c_0',
      Result_Message__c = 'Accept',
      Internal_Description__c = ''
    );
    Test.startTest();
    GetHelpExternalCaseStatusActionHelper.getInternalDescription(
      new List<External_Case_Status__c>{ externalCaseStatus },
      statusToInternalDescMap
    );
    Test.stopTest();
    Assert.isTrue(
      externalCaseStatus.Internal_Description__c == 'Dispute Successful',
      'Internal Description is not correct'
    );
  }

  // test method to check if internal description when statuc & result message is unkonwn
  @isTest
  public static void testUpdateIntDesForUnknownValues() {
    Case caseRecord = TestDataFactory.createCase('NPP_Dispute');
    caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    ExternalCaseStatusMappingQueryHelper caseStatusQueryHelper = ExternalCaseStatusMappingQueryHelper.getInstance();
    Map<String, String> statusToInternalDescMap = caseStatusQueryHelper.getStatusToInternalDescriptionMap();

    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = caseRecord.Id,
      External_Status__c = 'unknown-test',
      Status_Event_ID__c = 'Status_Event_ID__c_0',
      Result_Message__c = 'unknown test',
      Internal_Description__c = ''
    );
    Test.startTest();
    GetHelpExternalCaseStatusActionHelper.getInternalDescription(
      new List<External_Case_Status__c>{ externalCaseStatus },
      statusToInternalDescMap
    );
    Test.stopTest();
    Assert.isTrue(
      externalCaseStatus.Internal_Description__c ==
      GetHelpExternalCaseStatusActionHelper.DEFAULT_NPP_INTERNAL_DESCRIPTION,
      'Internal Description is not correct'
    );
  }

  @isTest
  public static void testGetCaseIdToExternalStatusMap() {
    Case caseRecord = TestDataFactory.createCase('NPP_Dispute');
    caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = caseRecord.Id,
      External_Status__c = 'unknown-test',
      Status_Event_ID__c = 'Status_Event_ID__c_0',
      Result_Message__c = 'unknown test',
      Internal_Description__c = ''
    );
    Test.startTest();
    Map<Id, String> caseIdToExtStatus = GetHelpExternalCaseStatusActionHelper.getCaseIdToExternalStatusMap(
      new List<External_Case_Status__c>{ externalCaseStatus }
    );
    Test.stopTest();
    Assert.isTrue(!caseIdToExtStatus.isEmpty(), 'Map should not be empty');
  }

  // test method to check if case is getting closed or not
  @isTest
  public static void testUpdateNPPCaseRecordsToClosed() {
    Case caseRecord = TestDataFactory.createCase('NPP_Dispute');
    caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = caseRecord.Id,
      External_Status__c = 'Resolved-Completed',
      Status_Event_ID__c = 'Status_Event_ID__c_0',
      Result_Message__c = 'Accept',
      Internal_Description__c = ''
    );
    Test.startTest();
    // Dummy callout for test coverage
    GetHelpExternalCaseStatusActions.updateRelatedNPPCases(
      new List<External_Case_Status__c>{ externalCaseStatus }
    );

    Map<String, String> statusToCaseStatusMap = ExternalCaseStatusMappingQueryHelper.getInstance()
      .getStatusToCaseStatusMap();

    List<Case> updatedCases = GetHelpExternalCaseStatusActionHelper.updateNPPCaseRecords(
      new List<Case>{ caseRecord },
      new Map<Id, String>{
        externalCaseStatus.Case__c => externalCaseStatus.External_Status__c
      },
      statusToCaseStatusMap
    );
    Test.stopTest();
    Assert.isTrue(
      updatedCases[0].Status == 'Closed',
      'Case Status should be closed'
    );
  }

  // test method to check if case status is uupdated according to mapping
  @isTest
  public static void testUpdateNPPCaseRecords() {
    Case caseRecord = TestDataFactory.createCase('NPP_Dispute');
    caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = caseRecord.Id,
      External_Status__c = 'unknown-test',
      Status_Event_ID__c = 'Status_Event_ID__c_0',
      Result_Message__c = 'unknown test',
      Internal_Description__c = ''
    );
    Test.startTest();
    Map<String, String> statusToCaseStatusMap = ExternalCaseStatusMappingQueryHelper.getInstance()
      .getStatusToCaseStatusMap();

    List<Case> updatedCases = GetHelpExternalCaseStatusActionHelper.updateNPPCaseRecords(
      new List<Case>{ caseRecord },
      new Map<Id, String>{
        externalCaseStatus.Case__c => externalCaseStatus.External_Status__c
      },
      statusToCaseStatusMap
    );
    Test.stopTest();
    Assert.isTrue(
      updatedCases[0].Status == 'On Hold',
      'Case Status should be On Hold'
    );
  }
}
