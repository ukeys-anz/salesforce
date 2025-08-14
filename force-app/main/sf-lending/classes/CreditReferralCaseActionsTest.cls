/**
 * @author Jaya Srivastava
 * @since February 2025
 * @description Test class for CreditReferralCaseActions
 */
@IsTest
public class CreditReferralCaseActionsTest {
  private static final Id FAKER_CASE_ID = Lib_FakeIdGenerator.getMockId(
    Case.getSObjectType()
  );
  static Id loanId = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.SObjectType
  );
  private static Lib_MockProvider dmlMockProvider;
  static void registerMocks() {
    dmlMockProvider = Lib_MockProvider.forType(DmlRepository.class);
  }
  private static Id fraudRefQueueId = QueryQueue.get(
      'Fraud_Credit_Referral_Case_Queue'
    )
    .Id;
  private static Id noCadRefQueueId = QueryQueue.get(
      'No_CAD_Credit_Referral_Case_Queue'
    )
    .Id;

  @IsTest
  static void ownerAssignment() {
    List<Case> getCaseRecords = createMockCaseRecordList('Escalated', 2);
    getCaseRecords[0].Case_Authority_Level__c = 'FRAUD';
    Test.startTest();
    List<Case> updatedOwnerCaseList = CreditReferralCaseActions.ownerAssignment(
      getCaseRecords
    );
    Test.stopTest();
    Assert.areEqual(
      fraudRefQueueId,
      updatedOwnerCaseList[0].OwnerId,
      'Case Owner Updated to Fraud Queue'
    );
    Assert.areEqual(
      noCadRefQueueId,
      updatedOwnerCaseList[1].OwnerId,
      'Case Owner Updated to NO CAD Queue'
    );
  }

  @IsTest
  static void ownerUpdateToFruadCases() {
    List<Case> getNewCaseRecords = createMockCaseRecordList('Escalated', 1);
    getNewCaseRecords[0].Case_Authority_Level__c = 'FRAUD';
    List<Case> getOldCaseRecords = createMockCaseRecordList('Open', 1);
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    Test.startTest();
    List<Case> updatedOwnerCaseList = CreditReferralCaseActions.ownerUpdateToFruadCases(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    Assert.areEqual(
      fraudRefQueueId,
      updatedOwnerCaseList[0].OwnerId,
      'Case Owner Updated to Fraud Queue'
    );
  }

  @isTest
  static void escalateFraudCaseInsert() {
    List<Case> getCaseRecords = createMockCaseRecordList('Open', 1);
    getCaseRecords[0].Case_Authority_Level__c = 'FRAUD';
    Test.startTest();
    List<Case> updatedOwnerCaseList = CreditReferralCaseActions.escalateFraudCase(
      getCaseRecords,
      null
    );
    Test.stopTest();
    Assert.areEqual(
      'Escalated',
      updatedOwnerCaseList[0].Status,
      'Case Status Updated to Escalated'
    );
  }

  @isTest
  static void escalateFraudCaseUpdate() {
    List<Case> getNewCaseRecords = createMockCaseRecordList('Escalated', 1);
    getNewCaseRecords[0].Case_Authority_Level__c = 'FRAUD';
    List<Case> getOldCaseRecords = createMockCaseRecordList('Open', 1);
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    Test.startTest();
    List<Case> updatedOwnerCaseList = CreditReferralCaseActions.escalateFraudCase(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    Assert.areEqual(
      'Escalated',
      updatedOwnerCaseList[0].Status,
      'Case Status Updated to Escalated'
    );
  }

  @isTest
  static void escalateRLA() {
    List<Case> getNewCaseRecords = createMockCaseRecordList('Escalated', 1);
    getNewCaseRecords[0].Case_Authority_Level__c = 'FRAUD';
    List<Case> getOldCaseRecords = createMockCaseRecordList('Open', 1);
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    registerMocks();
    Test.startTest();
    CreditReferralCaseActions.escalateRLA(getNewCaseRecords, oldCaseMap);
    Test.stopTest();
    List<ResidentialLoanApplication> rlaUpdate = (List<ResidentialLoanApplication>) dmlMockProvider.getHistory(
        'doUpdate'
      )
      .getParam('records');
    Assert.isNotNull(rlaUpdate, 'RLA is updated');
  }

  @IsTest
  static void invalidUserForFraudCase() {
    List<Case> getNewCaseRecords = createMockCaseRecordList('Escalated', 1);
    getNewCaseRecords[0].Case_Authority_Level__c = 'FRAUD';
    getNewCaseRecords[0].OwnerId = Lib_FakeIdGenerator.getMockId(
      User.getSObjectType()
    );
    List<Case> getOldCaseRecords = createMockCaseRecordList('Open', 1);
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    Test.startTest();
    CreditReferralCaseActions.invalidUserForFraudCase(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    List<Database.Error> errors = getNewCaseRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'Error');
    Database.Error error = errors.get(0);
    Assert.areEqual(
      'You can\'t assign a credit referral case to someone who does not have the authority to resolve it.',
      error.getMessage(),
      'Case cannot be updated'
    );
  }
  @IsTest
  static void invalidOutcomeToUpdateOwner() {
    List<Case> getNewCaseRecords = createMockCaseRecordList('Escalated', 1);
    getNewCaseRecords[0].Case_Authority_Level__c = 'FRAUD';
    getNewCaseRecords[0].OwnerId = Lib_FakeIdGenerator.getMockId(
      User.getSObjectType()
    );
    getNewCaseRecords[0].Assessment_Outcome__c = 'Processing';
    List<Case> getOldCaseRecords = createMockCaseRecordList('Open', 1);
    Map<Id, Case> oldCaseMap = new Map<Id, Case>{
      getOldCaseRecords.get(0).Id => getOldCaseRecords.get(0)
    };
    Test.startTest();
    CreditReferralCaseActions.invalidOutcomeToUpdateOwner(
      getNewCaseRecords,
      oldCaseMap
    );
    Test.stopTest();
    List<Database.Error> errors = getNewCaseRecords[0].getErrors();
    Assert.areEqual(1, errors.size(), 'Error');
    Database.Error error = errors.get(0);
    Assert.areEqual(
      'You can\'t assign a credit referral case to someone who does not have the authority to resolve it.',
      error.getMessage(),
      'Case cannot be updated'
    );
  }
  static ResidentialLoanApplication getRLA {
    get {
      return new ResidentialLoanApplication(
        Id = loanId,
        Name = 'Test Loan Application',
        Property_Use__c = 'LOAN_PRODUCT_TYPE_INVESTOR',
        ApplicationExtIdentifier = '1234',
        Application_Progress__c = 'Escalated',
        Account = new Account(
          Id = Lib_FakeIdGenerator.getMockId(Account.SObjectType),
          FirstName = 'FakeNameB',
          OCV_ID__c = '11111231'
        )
      );
    }
  }
  private static List<Case> createMockCaseRecordList(
    String status,
    Integer noOfRecords
  ) {
    List<Case> caseRecordsList = new List<Case>();
    for (Integer i = 0; i < noOfRecords; i++) {
      Case caseRecord = new Case();
      caseRecord.Id = FAKER_CASE_ID;
      caseRecord.Status = status;
      caseRecord.Loan_Application__c = getRLA.Id;
      caseRecord.Case_Authority_Level__c = 'NO CAD';
      caseRecord.RecordTypeId = RTCase.creditReferral;
      caseRecord.System_Action__c = false;
      caseRecordsList.add(caseRecord);
    }
    return caseRecordsList;
  }
}
