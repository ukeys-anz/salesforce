@isTest
public class AssessmentQRTriggerTest {
  @isTest
  static void testMasking() {
    AssessmentQuestionResponse aqr = new AssessmentQuestionResponse();
    aqr.ResponseText = '123456789111234 TAX 21874214';
    aqr.Name = 'Test Tax';
    AssessmentQuestionResponse aqr2 = new AssessmentQuestionResponse();
    aqr2.Name = 'Test Without Tax';
    aqr2.ResponseText = '123456789111234 test test 21874214';
    AssessmentQuestionResponseTriggerHandler aqrth = new AssessmentQuestionResponseTriggerHandler();
    aqrth.records = new List<SObject>{ aqr, aqr2 };
    aqrth.onApplyDefaults();
    for (
      AssessmentQuestionResponse record : (List<AssessmentQuestionResponse>) aqrth.records
    ) {
      if (record.Name == 'Test Tax') {
        Assert.areEqual(record.ResponseText, '***********1234 TAX ****4214');
      }
      if (record.Name == 'Test Without Tax') {
        Assert.areEqual(
          record.ResponseText,
          '***********1234 test test 21874214'
        );
      }
    }
  }
  @isTest
  static void triggerCoverage() {
    try {
      AssessmentQuestionResponse aqr = new AssessmentQuestionResponse();
      aqr.ResponseText = '123456789111234 TAX 21874214';
      aqr.Name = 'Test Tax';
      insert aqr;
    } catch (Exception e) {
    }
  }
}
