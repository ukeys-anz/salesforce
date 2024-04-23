/**
 * @author Akshat Khandelwal
 * @since January 2024
 * @description test class for TFMConsentListController apex class
 */
@isTest
private class TFMConsentListControllerTest {
  @isTest
  static void getConsentsListTest() {
    Test.startTest();
    TFMConsentListController controller = new TFMConsentListController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put('recordId', 'fake0357-fake-fake-fake-66671f11fake');

    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('getConsentsList', args);
    Test.stopTest();
    Map<String, Object> payload = (Map<String, Object>) output.get('output');
    Assert.areEqual(true, isInvoked, 'Method not invoked.');
    Assert.areNotEqual(null, payload, 'Empty JSON');
  }
}