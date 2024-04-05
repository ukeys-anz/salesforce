/**
 * @author ducnamle
 * @since 12/2024
 * @description ConnectIDControllerTest Class is the test class for ConnectIDController Class.
 */
@isTest
private class ConnectIDControllerTest {
  @isTest
  static void testinvokeMethod() {
    String methodName = 'getConnectIDs';
    Map<String, Object> inputMap = new Map<String, Object>();
    Map<String, Object> outMap = new Map<String, Object>();
    Map<String, Object> optionMap = new Map<String, Object>();

    Map<String, Object> args = new Map<String, Object>{
      'input' => inputMap,
      'output' => outMap,
      'options' => optionMap
    };
    ConnectIDController ctrl = new ConnectIDController();
    Object isInvoked = ctrl.call('getConnectIDs', args);
    Assert.isTrue(
      (Boolean) isInvoked,
      'Method getConnectIDs should be invoked'
    );
  }
}
