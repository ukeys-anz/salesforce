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
}
