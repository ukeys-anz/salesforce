/**
 * @author Pooja Kirtishahi
 * @since Mar 2025
 * @description Test class for {@link LoanAccountChangesViewModel}
 */

@isTest
public class LoanAccountChangesViewModelTest {
  @isTest
  static void testLoanAccountChangesViewModel() {
    Map<String, Case> caseMap = new Map<String, Case>();
    Test.startTest();
    caseMap.put(
      'accounts_391450876_changes_aa15100e-ce05-4c2e-bbc4-b9d1031da111',
      getCase
    );

    LoanAccountChangesViewModel response = new LoanAccountChangesViewModel(
      getLoanAccountChanges,
      caseMap
    );
    Test.stopTest();
    Assert.areEqual(
      response.accountHistoryList[0].newValue,
      'LOAN_PRODUCT_TYPE_INVESTOR',
      'New Value updated'
    );
  }

  @isTest
  static void testLoanAccountChangesViewModelNull() {
    Test.startTest();
    LoanAccountChangesViewModel response = new LoanAccountChangesViewModel();
    Test.stopTest();
    Assert.isNull(response.accountHistoryList, 'Null response');
  }

  /**
   * @description Static method to return LoanAccountChangesModel data
   */
  static List<LoanAccountChangesModel.LoanAccountChange> getLoanAccountChanges {
    get {
      LoanAccountChangesModel.Approval approval = new LoanAccountChangesModel.Approval(
        'STATE_APPROVED',
        null
      );
      LoanAccountChangesModel.LoanAccount request = new LoanAccountChangesModel.LoanAccount(
        'LOAN_PRODUCT_TYPE_OWNER_OCCUPIED'
      );
      LoanAccountChangesModel.LoanAccount response = new LoanAccountChangesModel.LoanAccount(
        'LOAN_PRODUCT_TYPE_INVESTOR'
      );
      LoanAccountChangesModel.LoanAccountChange loanAccountChange = new LoanAccountChangesModel.LoanAccountChange(
        'accounts_391450876_changes_aa15100e-ce05-4c2e-bbc4-b9d1031da111',
        request,
        response,
        'Product Type',
        approval
      );
      List<LoanAccountChangesModel.LoanAccountChange> changeList = new List<LoanAccountChangesModel.LoanAccountChange>{
        loanAccountChange
      };
      return changeList;
    }
  }

  /**
   * @description Static method to return Case record
   */
  static Case getCase {
    get {
      Id lendingRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
        .get('Lending')
        .getRecordTypeId();
      Case caseRecord = new Case();
      caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
      caseRecord.Type = 'Manage Home Loans';
      caseRecord.Sub_Type__c = 'NCC - Update Property Use';
      caseRecord.RecordTypeId = lendingRecordTypeId;
      caseRecord.Status = 'Closed - Approved';
      caseRecord.Loan_Account_Change_Number__c = 'accounts_391450876_changes_aa15100e-ce05-4c2e-bbc4-b9d1031da111';
      return caseRecord;
    }
  }
}
