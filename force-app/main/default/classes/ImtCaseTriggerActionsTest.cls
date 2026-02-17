/**
 * @author Mohit Garg
 * @since  11/2025
 * @description  Test Class of ImtCaseTriggerActionsTest
 */
@isTest
public class ImtCaseTriggerActionsTest {
  /**
   * @description test to verify if the Case description is populated correctly
   */
  @isTest
  public static void testUpdateDescription() {
    Case theCase = new Case();
    theCase.RecordTypeId = RTCase.imtDispute;
    theCase.Description = 'IMT Dispute Case Description Test_Text_32k';
    theCase.Intended_Account_BSB__c = '012345';
    theCase.Dispute_Reason__c = 'Suspected fraud';
    theCase.Intended_Account_Name__c = 'Intended Account Name Test_Text_255';
    theCase.Intended_Account_Number__c = '0123456789';
    theCase.Intended_Amount__c = 1000.00;
    theCase.Intended_Pay_Id_Type__c = 'ABN';
    theCase.Intended_Pay_Id_Value__c = 'Intended Pay Id Value Test_Text_255';
    theCase.Status = 'Open';
    theCase.Submitted__c = false;
    theCase.Transaction_Id__c = 'Transaction Id Test_IMT_Text_255';
    theCase.Transaction_UUID__c = 'Transaction UUID Test_IMT_Text_255';
    theCase.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    String expectedDescription = 'Payment Recall IMT Dispute Case Description Test_Text_32k';
    Test.startTest();
    ImtCaseTriggerActions.updateDescription(new List<Case>{ theCase });
    Test.stopTest();
    Assert.areEqual(
      expectedDescription,
      theCase.Description,
      'Case Description prefixed successfully'
    );
  }

  /**
   * @description test to verify if the remove prefix method is working as expected
   */
  @isTest
  public static void testRemovePrefix() {
    String inputDescription = 'Payment Recall IMT Dispute Case Description Test_Text_32k';
    String expectedDescription = 'IMT Dispute Case Description Test_Text_32k';
    Test.startTest();
    String result = ImtCaseTriggerActions.removePrefix(inputDescription);
    Test.stopTest();
    Assert.areEqual(expectedDescription, result, 'Prefix removed successfully');
  }

  /**
   * @description To test caseDescriptionBlank
   */
  @isTest
  public static void testBlankDescriptionNotValid() {
    Case theCase = new Case();
    theCase.RecordTypeId = RTCase.imtDispute;
    theCase.Status = 'Open';
    theCase.Submitted__c = false;
    theCase.Dispute_Reason__c = 'Suspected fraud';
    theCase.Transaction_Id__c = 'CT5M00000024404234';
    theCase.CaseNumber__c = '04683911';
    theCase.Description = '';
    Test.startTest();
    ImtCaseTriggerActions.updateDescription(new List<Case>{ theCase });
    Assert.areEqual(
      '',
      theCase.Description,
      'No prefix added as description is blank'
    );
    Test.stopTest();
  }
}
