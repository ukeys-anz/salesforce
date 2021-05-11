/**
 * @author Lance Shi
 * @since March 2021
 * @description MockProvider is an implementation of StubProvider to generate mocks results for unit tests
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
@isTest
public class Lib_MockProvider implements System.StubProvider {
  private Map<String, Object> stubbedMethodMap;

  /**
   * @description constructor of the Lib_MockProvider which takes the expected outcome map as input
   * @param stubbedMethodMap the map to get mock results
   */
  public Lib_MockProvider(Map<String, Object> stubbedMethodMap) {
    this.stubbedMethodMap = stubbedMethodMap;
  }

  /**
   * @description handleMethodCall is to get the mocked outcome of each method implementing Salesforce interface
   * @param stubbedObject the object to be stubbed
   * @param stubbedMethodName the method name to be mocked
   * @param returnType the return type of the mocked method
   * @param listOfParamTypes parameter type list of the mocked method
   * @param listOfParamNames parameter name list of the mocked method
   * @param listOfArgs actual args passed to the mocked method
   * @return Object the mocked result to be returned
   */
  public Object handleMethodCall(
    Object stubbedObject,
    String stubbedMethodName,
    Type returnType,
    List<Type> listOfParamTypes,
    List<String> listOfParamNames,
    List<Object> listOfArgs
  ) {
    Object result;
    if (stubbedMethodMap.containsKey(stubbedMethodName)) {
      result = stubbedMethodMap.get(stubbedMethodName);
    }
    return result;
  }
}
