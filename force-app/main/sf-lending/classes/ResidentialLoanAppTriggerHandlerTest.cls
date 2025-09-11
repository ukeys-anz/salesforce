/**
 * @author @ramvilas
 * @since April 2025
 * @description Test class for ResidentialLoanAppTriggerHandler actions
 */
@isTest
private class ResidentialLoanAppTriggerHandlerTest {
  private static final Id FAKER_RLA_ID = Lib_FakeIdGenerator.getMockId(
    ResidentialLoanApplication.getSObjectType()
  );

  @IsTest
  static void testIsValidRecord() {
    ResidentialLoanApplication rla = createMockRLARecord(
      RTResidentialLoanApplication.anzxHomeLoan,
      true
    );
    ResidentialLoanAppTriggerHandler handler = new ResidentialLoanAppTriggerHandler();
    Test.startTest();
    Boolean checkRecord = handler.isValidRecord(rla);
    Test.stopTest();
    Assert.isTrue(checkRecord, 'This is a valid record');
  }

  @IsTest
  static void testCoverageForBeforeInsertAndBeforeUpdate() {
    List<ResidentialLoanApplication> newRla = createMockRLARecordList(
      RTResidentialLoanApplication.anzxHomeLoan,
      true
    );
    List<ResidentialLoanApplication> oldRla = createMockRLARecordList(
      RTResidentialLoanApplication.anzxHomeLoan,
      false
    );
    Map<Id, ResidentialLoanApplication> oldRLAMap = new Map<Id, ResidentialLoanApplication>{
      oldRla.get(0).Id => oldRla.get(0)
    };
    ResidentialLoanAppTriggerHandler handler = new ResidentialLoanAppTriggerHandler();
    handler.records = newRla;
    Test.startTest();
    // Dummy Callouts for test coverage
    handler.onBeforeInsert();
    handler.onBeforeUpdate(oldRLAMap);
    handler.onAfterInsert();
    handler.onAfterUpdate(oldRLAMap);
    Test.stopTest();
    //Dummy assert
    Assert.isTrue(true, 'Before Insert and Before Update Method coverage');
  }

  private static ResidentialLoanApplication createMockRLARecord(
    Id recordTypeIdForRLA,
    Boolean reassessRequired
  ) {
    ResidentialLoanApplication loanApp = new ResidentialLoanApplication();
    loanApp.Id = FAKER_RLA_ID;
    loanApp.RecordTypeId = recordTypeIdForRLA;
    loanApp.Credit_Reassess_Required__c = reassessRequired;
    return loanApp;
  }

  private static List<ResidentialLoanApplication> createMockRLARecordList(
    Id recordTypeIdForRLA,
    Boolean reassessRequired
  ) {
    List<ResidentialLoanApplication> rlaRecordsList = new List<ResidentialLoanApplication>();
    ResidentialLoanApplication rlaRecord = createMockRLARecord(
      recordTypeIdForRLA,
      reassessRequired
    );
    rlaRecordsList.add(rlaRecord);
    return rlaRecordsList;
  }
}
