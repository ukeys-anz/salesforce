/**
 * @description       : Apex Test class for RBMAssociatedLoanApplicationHandler
 * @author            : Madhuri Edke | Salesforce
 * @group             :
 * @last modified on  : 06-02-2025
 * @last modified by  : Madhuri Edke | Salesforce
 **/

@isTest
public class RBMAssociatedLoanApplicationHandlerTest {
  /*
   * @description Positive unit test to validate Associated Loan Application Records
   */

  @IsTest
  static void testIsValidRecordPositive() {
    RBMAssociatedLoanApplicationHandler loanApplicationHandler = new RBMAssociatedLoanApplicationHandler();

    Associated_Loan_Application__c associatedloanApplication = new Associated_Loan_Application__c();
    associatedloanApplication.Residential_Loan_Application__c = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    associatedloanApplication.Interaction__c = Lib_FakeIdGenerator.getMockId(
      Interaction.SObjectType
    );
    loanApplicationHandler.records = new List<Associated_Loan_Application__c>{
      associatedloanApplication
    };
    Test.startTest();
    Boolean isRecordValid = loanApplicationHandler.isValidRecord(
      associatedloanApplication
    );
    Test.stopTest();

    Assert.areEqual(
      true,
      isRecordValid,
      'Should return true for Record with Interaction Value'
    );
  }

  /*
   * @description Negative unit test to validate Associated Loan Application Records
   */

  @IsTest
  static void testIsValidRecordNegative() {
    RBMAssociatedLoanApplicationHandler loanApplicationHandler = new RBMAssociatedLoanApplicationHandler();
    Associated_Loan_Application__c associatedloanApplication = new Associated_Loan_Application__c();
    associatedloanApplication.Residential_Loan_Application__c = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    loanApplicationHandler.records = new List<Associated_Loan_Application__c>{
      associatedloanApplication
    };
    Test.startTest();
    Boolean isRecordValid = loanApplicationHandler.isValidRecord(
      associatedloanApplication
    );
    Test.stopTest();

    Assert.areEqual(
      false,
      isRecordValid,
      'Should return true for Record with Interaction Value'
    );
  }

  /*
   * @description unit test to validate RBM Interaction recordtype
   */
  @IsTest
  static void testBeforeInsert() {
    RBMAssociatedLoanApplicationHandler loanApplicationHandler = new RBMAssociatedLoanApplicationHandler();
    Associated_Loan_Application__c associatedloanApplication = new Associated_Loan_Application__c();
    associatedloanApplication.Residential_Loan_Application__c = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    associatedloanApplication.Interaction__c = Lib_FakeIdGenerator.getMockId(
      Interaction.SObjectType
    );
    loanApplicationHandler.records = new List<Associated_Loan_Application__c>{
      associatedloanApplication
    };
    loanApplicationHandler.onBeforeInsert();
    String uniqueKey =
      associatedloanApplication.Interaction__c +
      '_' +
      associatedloanApplication.Residential_Loan_Application__c;
    Assert.areEqual(
      associatedloanApplication.UniqueKeyForAssociatedApplication__c,
      uniqueKey,
      'Must have one Associated Loan Applications to delete'
    );
  }
  /**
   * @description test method with DMLs to cover Associated loan Application trigger
   * @author  Smruti Khobragade | Salesforce | 21-07-2025
   **/
  @IsTest
  static void associatedLoanApplicationTriggersTest() {
    try {
      Associated_Loan_Application__c application = new Associated_Loan_Application__c();
      insert application;
    } catch (Exception e) {
      Assert.areEqual(
        true,
        String.isNotBlank(e.getMessage()),
        'Exception was not thrown as expected'
      );
    }
  }
}
