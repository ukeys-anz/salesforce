/**
 * @description Test class for Process Builder
 */
@isTest
private class ProcessBuilderNoActionTest {
  @isTest
  static void executeCode() {
    ProcessBuilderNoAction.DoNothing();
    System.assert(true, 'Nothing was done.');
  }
}
