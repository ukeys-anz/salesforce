/**
 * @author Lance Shi
 * @since March 2021
 * @description Lib_MockService is to generate mock for unit test
 */
@IsTest
public class Lib_MockService {
  /**
   * @description createMock is to generate a test mock for a certain class
   * @param typeToMock the type to get mocked
   * @param stubbedMethodMap the map to get mock results
   * @return Object the mocked class instance
   */
  public static Object createMock(
    Type typeToMock,
    Map<String, Object> stubbedMethodMap
  ) {
    return Test.createStub(
      typeToMock,
      Lib_MockProvider.forType(typeToMock).mock(stubbedMethodMap)
    );
  }
}
