/**
 * @author @ramvilas
 * @since April 2025
 * @description Test class for Common Residential Loan Application actions
 */
@isTest
private class CommonResidentialLoanAppActionsTest {
  private static final Id FAKER_RLA_ID = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.getSObjectType()
  );
  @isTest
  private static void testUpdateAppProgressToBlankSuccess() {
    List<ResidentialLoanApplication> rlaRecord = new List<ResidentialLoanApplication>();
    List<ResidentialLoanApplication> newRlaRecords = createMockRlaRecordWithSubStatus(
      'STATE_CANCELLED',
      'With Coach'
    );
    List<ResidentialLoanApplication> oldRlaRecordsList = createMockRlaRecordWithSubStatus(
      'STATE_REFERRED',
      'With Coach'
    );
    Map<Id, ResidentialLoanApplication> oldRlaRecords = new Map<Id, ResidentialLoanApplication>{
      oldRlaRecordsList.get(0).Id => oldRlaRecordsList.get(0)
    };

    Test.startTest();
    rlaRecord = CommonResidentialLoanApplicationActions.updateApplicationProgressToBlank(
      newRlaRecords,
      oldRlaRecords
    );

    Test.stopTest();

    Assert.isFalse(
      rlaRecord.isEmpty(),
      'Residential Loan Application should return to update substatus'
    );
    Assert.isNull(
      rlaRecord[0].Application_Progress__c,
      'Residential Loan Application Progress should be blank'
    );
  }

  @isTest
  private static void testUpdateAppProgressToBlankFailure() {
    List<ResidentialLoanApplication> rlaRecord = new List<ResidentialLoanApplication>();
    List<ResidentialLoanApplication> newRlaRecords = createMockRlaRecordWithSubStatus(
      'STATE_REFERRED',
      'With Coach'
    );
    List<ResidentialLoanApplication> oldRlaRecordsList = createMockRlaRecordWithSubStatus(
      'STATE_EXPIRED',
      'With Coach'
    );
    Map<Id, ResidentialLoanApplication> oldRlaRecords = new Map<Id, ResidentialLoanApplication>{
      oldRlaRecordsList.get(0).Id => oldRlaRecordsList.get(0)
    };

    Test.startTest();
    rlaRecord = CommonResidentialLoanApplicationActions.updateApplicationProgressToBlank(
      newRlaRecords,
      oldRlaRecords
    );

    Test.stopTest();
    Assert.isTrue(
      rlaRecord.isEmpty(),
      'Residential Loan Application Progress should not changed so return should be null'
    );
    Assert.areEqual(
      'With Coach',
      newRlaRecords[0].Application_Progress__c,
      'RLA Application Progress should remains same'
    );
  }

  private static List<ResidentialLoanApplication> createMockRlaRecordWithSubStatus(
    String status,
    String appProgress
  ) {
    List<ResidentialLoanApplication> rlaRecordsList = new List<ResidentialLoanApplication>();
    ResidentialLoanApplication rlaRecord = new ResidentialLoanApplication();
    rlaRecord.Id = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.getSObjectType()
    );
    rlaRecord.Status = status;
    rlaRecord.Application_Progress__c = appProgress;

    rlaRecordsList.add(rlaRecord);
    return rlaRecordsList;
  }
}
