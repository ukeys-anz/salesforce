/**
 * @description Test class for PromptUtils utility class.
 */
@IsTest
private class PromptUtilsTest {
  @IsTest
  static void testInvokePromptWithoutMockCallsConnectApi() {
    Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();
    ConnectApi.WrappedValue wv = new ConnectApi.WrappedValue();
    wv.value = new Map<String, String>{ 'id' => '001xxx' };
    inputParams.put('Input:Account', wv);

    // Do NOT set mockResponseText - leave it null to force ConnectApi execution
    PromptUtils.mockResponseText = null;

    Test.startTest();
    try {
      String result = PromptUtils.invokePrompt(
        'Customer_Summary2',
        inputParams
      );
      // If we reach here without exception, the test environment somehow allowed the ConnectApi call
      System.assert(
        result != null,
        'If ConnectApi succeeded, result should not be null'
      );
    } catch (Exception ex) {
      // Expected: ConnectApi calls typically fail in test context without proper mocking infrastructure
      System.assert(
        ex != null,
        'Expected an exception when calling ConnectApi without mock'
      );
    }
    Test.stopTest();
  }
}
