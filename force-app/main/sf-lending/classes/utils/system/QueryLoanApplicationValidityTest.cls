/**
 * @author Team Marvel
 * @since Sep 2025
 * @description Test class for QueryLoanApplicationValidity
 */

@isTest
public class QueryLoanApplicationValidityTest {
  @testSetup
  static void setupTestData() {
    // Create Loan_Application_Validity__mdt records for testing

    Loan_Application_Validity__mdt record1 = new Loan_Application_Validity__mdt(
      MasterLabel = 'RLS STATE APPROVED',
      DeveloperName = 'RLS_STATE_APPROVED',
      Days__c = 10,
      Months__c = 1,
      Years__c = 0
    );
    Loan_Application_Validity__mdt record2 = new Loan_Application_Validity__mdt(
      MasterLabel = 'RLS STATE CANCELLED',
      DeveloperName = 'RLS_STATE_CANCELLED',
      Days__c = 20,
      Months__c = 2,
      Years__c = 1
    );
    QueryLoanApplicationValidity.recordsByMasterLabel.put(
      record1.MasterLabel,
      record1
    );
    QueryLoanApplicationValidity.recordsByMasterLabel.put(
      record2.MasterLabel,
      record2
    );
    QueryLoanApplicationValidity.recordsByDeveloperName.put(
      record1.DeveloperName,
      record1
    );
    QueryLoanApplicationValidity.recordsByDeveloperName.put(
      record2.DeveloperName,
      record2
    );
    QueryLoanApplicationValidity.recordsById.put(record1.Id, record1);
    QueryLoanApplicationValidity.recordsById.put(record2.Id, record2);
  }

  @isTest
  static void testGetByMasterLabel() {
    Test.startTest();
    Loan_Application_Validity__mdt result = QueryLoanApplicationValidity.getByMasterLabel(
      'RLS STATE APPROVED'
    );
    Test.stopTest();
    Assert.isNotNull(result, 'Should return a record for valid MasterLabel');
    Assert.areEqual(
      'RLS_STATE_APPROVED',
      result.DeveloperName,
      'Record Developer Name is Invalid'
    );
  }

  @isTest
  static void testGetByDeveloperName() {
    Test.startTest();
    Loan_Application_Validity__mdt result = QueryLoanApplicationValidity.getByDeveloperName(
      'RLS_STATE_CANCELLED'
    );
    Test.stopTest();

    Assert.isNotNull(result, 'Should return a record for valid DeveloperName');
    Assert.areEqual(
      'RLS STATE CANCELLED',
      result.MasterLabel,
      'Record Master Lablel is Invalid'
    );
  }

  @isTest
  static void testGetById() {
    Loan_Application_Validity__mdt loanAppValidityRecord = [
      SELECT Id
      FROM Loan_Application_Validity__mdt
      LIMIT 1
    ];
    Test.startTest();
    Loan_Application_Validity__mdt result = QueryLoanApplicationValidity.getById(
      loanAppValidityRecord.Id
    );
    Test.stopTest();

    Assert.isNotNull(result, 'Should return a record for valid Id');
  }
}
