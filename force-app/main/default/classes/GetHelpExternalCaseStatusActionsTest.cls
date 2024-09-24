/**
 * @author Hrushikesh Pathak
 * @since 08/03/2024
 * @description test class for the GetHelpExternalCaseStatusActions
 */
@isTest
public with sharing class GetHelpExternalCaseStatusActionsTest {
  @isTest
  public static void testUpdateIntDescForNonNPPDispute() {
    Case caseRecord = TestDataFactory.createCase('ATM_Dispute');
    RecordType rt = [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE Id = :(caseRecord.RecordTypeId)
      LIMIT 1
    ];
    caseRecord = (Case) TestDataFactory.populateRecordType(caseRecord, rt);
    caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = caseRecord.Id,
      External_Status__c = 'Resolved-Completed',
      Status_Event_ID__c = 'Status_Event_ID__c_0',
      Result_Message__c = 'Accept',
      Internal_Description__c = ''
    );
    Test.startTest();
    GetHelpExternalCaseStatusActions.updateExternalCaseStatusFields(
      new List<External_Case_Status__c>{ externalCaseStatus }
    );
    Test.stopTest();
    Assert.isTrue(externalCaseStatus.Internal_Description__c == '', '');
  }

  // test method to check if internal description when result message is unkonwn
  @isTest
  public static void testGetStatusToMetadataMap() {
    Case caseRecord = TestDataFactory.createCase('NPP_Dispute');
    RecordType rt = [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE Id = :(caseRecord.RecordTypeId)
      LIMIT 1
    ];
    caseRecord = (Case) TestDataFactory.populateRecordType(caseRecord, rt);
    ExternalCaseStatusMappingQueryHelper caseStatusQueryHelper = ExternalCaseStatusMappingQueryHelper.getInstance();
    Map<String, External_Case_Status_Mapping__mdt> statusToMetadataMap = caseStatusQueryHelper.getStatusToMetadataMap();

    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = caseRecord.Id,
      External_Status__c = 'Resolved-Completed',
      Status_Event_ID__c = 'Status_Event_ID__c_0',
      Result_Message__c = 'Accept',
      Internal_Description__c = ''
    );
    Test.startTest();
    GetHelpExternalCaseStatusActions.populateExternalCaseStatusFields(
      new List<External_Case_Status__c>{ externalCaseStatus },
      statusToMetadataMap,
      new Map<Id, Case>{ caseRecord.Id => caseRecord }
    );
    Test.stopTest();
    Assert.isTrue(
      externalCaseStatus.Internal_Description__c == 'Dispute Successful',
      'Internal Description is not correct'
    );
    Assert.isTrue(
      externalCaseStatus.Customer_Message__c != '',
      'Customer Message is not correct'
    );
  }

  // test method to check if internal description when statuc & result message is unkonwn
  @isTest
  public static void testUpdateIntDesForUnknownValues() {
    Case caseRecord = TestDataFactory.createCase('NPP_Dispute');
    RecordType rt = [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE Id = :(caseRecord.RecordTypeId)
      LIMIT 1
    ];
    caseRecord = (Case) TestDataFactory.populateRecordType(caseRecord, rt);
    ExternalCaseStatusMappingQueryHelper caseStatusQueryHelper = ExternalCaseStatusMappingQueryHelper.getInstance();
    Map<String, External_Case_Status_Mapping__mdt> statusToMetadataMap = caseStatusQueryHelper.getStatusToMetadataMap();

    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = caseRecord.Id,
      External_Status__c = 'unknown-test',
      Status_Event_ID__c = 'Status_Event_ID__c_0',
      Result_Message__c = 'unknown test',
      Internal_Description__c = ''
    );
    Test.startTest();
    GetHelpExternalCaseStatusActions.populateExternalCaseStatusFields(
      new List<External_Case_Status__c>{ externalCaseStatus },
      statusToMetadataMap,
      new Map<Id, Case>{ caseRecord.Id => caseRecord }
    );
    Test.stopTest();
    Assert.isTrue(
      externalCaseStatus.Internal_Description__c ==
      GetHelpExternalCaseStatusActions.DEFAULT_NPP_INTERNAL_DESCRIPTION,
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
    Map<Id, String> caseIdToExtStatus = GetHelpExternalCaseStatusActions.getCaseIdToExternalStatusMap(
      new List<External_Case_Status__c>{ externalCaseStatus }
    );
    Test.stopTest();
    Assert.isTrue(!caseIdToExtStatus.isEmpty(), 'Map should not be empty');
  }

  // test method to check if case is getting closed or not
  @isTest
  public static void testUpdateNPPCaseRecordsToClosed() {
    Case caseRecord = TestDataFactory.createCase('NPP_Dispute');
    RecordType rt = [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE Id = :(caseRecord.RecordTypeId)
      LIMIT 1
    ];
    caseRecord = (Case) TestDataFactory.populateRecordType(caseRecord, rt);
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
    GetHelpExternalCaseStatusActions.updateRelatedCases(
      new List<External_Case_Status__c>{ externalCaseStatus }
    );

    Map<String, External_Case_Status_Mapping__mdt> statusToMetadataMap = ExternalCaseStatusMappingQueryHelper.getInstance()
      .getRecordTypeStatusToMetadataMap();

    List<Case> updatedCases = GetHelpExternalCaseStatusActions.updateCaseRecords(
      new List<Case>{ caseRecord },
      new Map<Id, String>{
        externalCaseStatus.Case__c => externalCaseStatus.External_Status__c
      },
      statusToMetadataMap
    );
    Test.stopTest();
    Assert.isTrue(
      updatedCases[0].Status == 'Closed',
      'Case Status should be closed'
    );
  }

  // test method to check if case status is updated according to mapping
  @isTest
  public static void testUpdateNPPCaseRecords() {
    Case caseRecord = TestDataFactory.createCase('NPP_Dispute');
    RecordType rt = [
      SELECT Id, DeveloperName
      FROM RecordType
      WHERE Id = :(caseRecord.RecordTypeId)
      LIMIT 1
    ];
    caseRecord = (Case) TestDataFactory.populateRecordType(caseRecord, rt);
    caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);

    External_Case_Status__c externalCaseStatus = new External_Case_Status__c(
      Case__c = caseRecord.Id,
      External_Status__c = 'unknown-test',
      Status_Event_ID__c = 'Status_Event_ID__c_0',
      Result_Message__c = 'unknown test',
      Internal_Description__c = ''
    );
    Test.startTest();
    Map<String, External_Case_Status_Mapping__mdt> statusToMetadataMap = ExternalCaseStatusMappingQueryHelper.getInstance()
      .getRecordTypeStatusToMetadataMap();

    List<Case> updatedCases = GetHelpExternalCaseStatusActions.updateCaseRecords(
      new List<Case>{ caseRecord },
      new Map<Id, String>{
        externalCaseStatus.Case__c => externalCaseStatus.External_Status__c
      },
      statusToMetadataMap
    );
    Test.stopTest();
    Assert.isTrue(
      updatedCases[0].Status == 'On Hold',
      'Case Status should be On Hold'
    );
  }
}
