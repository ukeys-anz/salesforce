/**
 * @since July 2025
 * @description Test class for ResidentialLoanAppTriggerHandler actions
 */
@IsTest
public class RLSResidentialLoanAppTriggerHandlerTest {
  @IsTest
  static void testIsValidRecord() {
    ResidentialLoanApplication rla = new ResidentialLoanApplication();
    rla.RecordTypeId = RTResidentialLoanApplication.rlsResidentialLoanApplication;
    RLSResidentialLoanAppTriggerHandler handler = new RLSResidentialLoanAppTriggerHandler();
    Test.startTest();
    Boolean isRecordValid = handler.isValidRecord(rla);
    Test.stopTest();
    Assert.isTrue(isRecordValid, 'This is a valid record');
  }
}
