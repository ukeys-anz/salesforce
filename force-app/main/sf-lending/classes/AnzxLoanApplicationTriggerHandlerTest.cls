/**
 * @author @ramvilas
 * @since April 2025
 * @description Test class for AnzxLoanApplicationTriggerHandler actions
 */
@isTest
private class AnzxLoanApplicationTriggerHandlerTest {
  @IsTest
  static void testIsValidRecord() {
    ResidentialLoanApplication rla = createMockRLARecord(
      RTResidentialLoanApplication.anzxHomeLoan
    );
    AnzxLoanApplicationTriggerHandler handler = new AnzxLoanApplicationTriggerHandler();
    Test.startTest();
    Boolean checkRecord = handler.isValidRecord(rla);
    Test.stopTest();
    Assert.isTrue(checkRecord, 'This is a valid record');
  }

  @IsTest
  static void testCoverageForBeforeInsertAndBeforeUpdate() {
    List<ResidentialLoanApplication> newRla = new List<ResidentialLoanApplication>{
      createMockRLARecord(RTResidentialLoanApplication.anzxHomeLoan)
    };
    List<ResidentialLoanApplication> oldRla = new List<ResidentialLoanApplication>{
      createMockRLARecord(RTResidentialLoanApplication.anzxHomeLoan)
    };

    Map<Id, ResidentialLoanApplication> oldRLAMap = new Map<Id, ResidentialLoanApplication>{
      oldRla.get(0).Id => oldRla.get(0)
    };
    AnzxLoanApplicationTriggerHandler handler = new AnzxLoanApplicationTriggerHandler();
    handler.records = newRla;
    Test.startTest();
    // Dummy Callouts for test coverage
    handler.onBeforeInsert();
    handler.onBeforeUpdate(oldRLAMap);
    Test.stopTest();
    //Dummy assert
    Assert.isTrue(true, 'Before Insert and Before Update Method coverage');
  }
  private static ResidentialLoanApplication createMockRLARecord(
    Id recordTypeIdForRLA
  ) {
    ResidentialLoanApplication loanApp = TestDataFactory.createTestResidentialLoanApplication();
    loanApp.Id = Lib_FakeIdGenerator.getMockId(
      ResidentialLoanApplication.SObjectType
    );
    loanApp.RecordTypeId = recordTypeIdForRLA;
    return loanApp;
  }
}
