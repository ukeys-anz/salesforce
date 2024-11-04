/**
 * @author Hrushikesh
 * @since 10/2024
 * @description DisputesCaseActionsTest class for DisputesCaseActions
 */
@isTest
public with sharing class DisputesCaseActionsTest {
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  // To test creation of External Case Status for NPP Non Fruad dispute
  @isTest
  private static void testNewExternalStatusCreationForNppNonFraud() {
    registerMocks();

    dmlRepoMock.mock(
      'doInsert',
      new List<Database.SaveResult>{
        TestUtil.getMockSaveResult('{"success":true}')
      }
    );

    Case theCase = TestDataFactory.createCase('NPP_Dispute');

    Test.startTest();
    DisputesCaseActions.createExternalCaseStatuses(
      new List<Case>{ theCase },
      'NPP_New'
    );
    Test.stopTest();
    List<External_Case_Status__c> extCaseStatuses = (List<External_Case_Status__c>) dmlRepoMock.getHistory(
        'doInsert'
      )
      .getParam('records');

    Assert.isTrue(
      extCaseStatuses.size() == 1,
      'Only one external case record should be created'
    );

    Assert.areEqual(
      extCaseStatuses[0].External_Status__c,
      'New',
      'External Case Status with External Status as New should be created'
    );
  }
}
