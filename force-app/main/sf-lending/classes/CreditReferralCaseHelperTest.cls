/**
 *
 * @author Pooja Kirtishahi
 * @since Aug 2025
 * @description Test class for {@link CreditReferralCaseHelper)
 */
@isTest
public with sharing class CreditReferralCaseHelperTest {
  static Lib_MockProvider dmlMockProvider;
  static void registerMocks() {
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
  }

  static Case getCase {
    get {
      case caseRecord = new Case();
      caseRecord.Id = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
      caseRecord.Address__c = 'Test';
      caseRecord.Status = 'New';
      caseRecord.Loan_Application__c = getRLA.Id;
      return caseRecord;
    }
  }

  static ResidentialLoanApplication getRLA {
    get {
      return new ResidentialLoanApplication(
        Id = Lib_FakeIdGenerator.getMockId(
          ResidentialLoanApplication.SObjectType
        ),
        Name = 'Test Loan Application',
        Property_Use__c = 'LOAN_PRODUCT_TYPE_INVESTOR',
        ApplicationExtIdentifier = '1234',
        Application_Progress__c = 'Confirmed'
      );
    }
  }

  @isTest
  static void testUpdateCaseStatusSuccess() {
    Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    registerMocks();
    Test.startTest();
    CreditReferralCaseHelper.updateCaseStatus(caseId, 'FRAUD');
    Test.stopTest();
    Case updatedCase = (Case) dmlMockProvider.getHistory('doUpdate')
      .getParam('record');
    Assert.isNotNull(updatedCase, 'Case is updated');
  }

  @isTest
  static void testUpdateCaseStatusException() {
    Id caseId = Lib_FakeIdGenerator.getMockId(Case.SObjectType);
    registerMocks();
    dmlMockProvider.mockException(
      'doUpdate',
      new AuraHandledException('Update failed!')
    );
    Test.startTest();
    try {
      CreditReferralCaseHelper.updateCaseStatus(caseId, 'FRAUD');
      Assert.isFalse(false, 'Success');
    } catch (AuraHandledException ex) {
      Assert.areEqual('Update failed!', ex.getMessage(), 'Case update Failed');
    }
    Test.stopTest();
  }

  @isTest
  static void testUpdateRLAStatusSuccess() {
    Id rlaId = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    registerMocks();
    Test.startTest();
    CreditReferralCaseHelper.updateRLAStatus(rlaId, getCase);
    Test.stopTest();
    ResidentialLoanApplication updatedRLA = (ResidentialLoanApplication) dmlMockProvider.getHistory(
        'doUpdate'
      )
      .getParam('record');
    Assert.isNotNull(updatedRLA, 'RLA is updated');
  }

  @isTest
  static void testUpdateRLAStatusException() {
    Id rlaId = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    registerMocks();
    dmlMockProvider.mockException(
      'doUpdate',
      new AuraHandledException('Update failed!')
    );
    Test.startTest();
    try {
      CreditReferralCaseHelper.updateRLAStatus(rlaId, getCase);
      Assert.isFalse(false, 'Success');
    } catch (AuraHandledException ex) {
      Assert.areEqual('Update failed!', ex.getMessage(), 'RLA update Failed');
    }
    Test.stopTest();
  }
}
