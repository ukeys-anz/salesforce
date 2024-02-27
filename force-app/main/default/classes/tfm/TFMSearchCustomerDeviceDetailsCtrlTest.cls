/**
 * @author Akshat Khandelwal
 * @since November 2023
 * @description test class for TFMSearchCustomerDeviceDetailsController apex class
 */

@isTest
private class TFMSearchCustomerDeviceDetailsCtrlTest {
  @isTest
  static void getDeviceDetailsTest() {
    Test.startTest();
    TFMSearchCustomerDeviceDetailsController controller = new TFMSearchCustomerDeviceDetailsController();
    Map<String, Object> input = new Map<String, Object>();
    Map<String, Object> output = new Map<String, Object>();
    input.put('recordId', 'x00Bm000008L9jfake');

    Map<String, Object> args = new Map<String, Object>{
      'input' => input,
      'output' => output,
      'options' => new Map<String, Object>()
    };
    Object isInvoked = controller.call('getDeviceDetails', args);
    Test.stopTest();
    List<Map<String, Object>> payload = (List<Map<String, Object>>) output.get(
      'devices'
    );
    Assert.areEqual(isInvoked, true, 'Method not invoked.');
    Assert.areNotEqual(payload, null, 'Empty JSON');
  }
}
