/**
 * @author Lance Shi
 * @since March 2021
 * @description MockProvider is an implementation of StubProvider to generate mocks results for unit tests
 * @group Library
 */
@SuppressWarnings('PMD.ExcessiveParameterList')
@isTest
public class Lib_MockProvider implements System.StubProvider {
  private static final DefaultException DEFAULT_EXCEPTION = new DefaultException(
    'Default Exception'
  );
  private static Map<Type, Lib_MockProvider> mockProviders = new Map<Type, Lib_MockProvider>();

  private Map<String, List<MockHistory>> histories;
  private Map<String, Object> stubbedMethodMap;

  /**
   * @description Private constructor for the Lib_MockProvider class, preventing the instantiation of this class from outside the class itself.
   */
  private Lib_MockProvider() {
    this.stubbedMethodMap = new Map<String, Object>();
    this.histories = new Map<String, List<MockHistory>>();
  }

  /**
   * @description Creates and returns a new instance of the Lib_MockProvider class for the specified Apex class.
   * @param apexType The Apex class for which the mock provider is being created.
   * @return The newly created Lib_MockProvider instance.
   */
  public static Lib_MockProvider forType(Type apexType) {
    if (mockProviders.containsKey(apexType)) {
      return mockProviders.get(apexType);
    }
    Lib_MockProvider mock = new Lib_MockProvider();
    mockProviders.put(apexType, mock);

    Object apexInstance = Test.createStub(apexType, mock);
    Lib_InstanceProvider.register(apexType, apexInstance);

    return mock;
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
    MockHistory history = new MockHistory();
    history.listOfParamNames = listOfParamNames;
    history.listOfArgs = listOfArgs;
    if (!histories.containsKey(stubbedMethodName)) {
      histories.put(stubbedMethodName, new List<MockHistory>());
    }
    histories.get(stubbedMethodName).add(history);

    Object result;
    if (stubbedMethodMap.containsKey(stubbedMethodName)) {
      result = stubbedMethodMap.get(stubbedMethodName);
    }
    if (result instanceof ExceptionStub) {
      ExceptionStub mockConfig = (ExceptionStub) result;
      throw mockConfig.apexException;
    }
    return result;
  }

  /**
   * @description Returns the 1st mock history for the specified stubbed method name.
   * @param stubbedMethodName The name of the stubbed method.
   * @return The mock history for the specified stubbed method name, or null if no history is found.
   */
  public MockHistory getHistory(String stubbedMethodName) {
    List<MockHistory> methodHistories = this.histories.get(stubbedMethodName);
    return methodHistories == null ? null : methodHistories[0];
  }

  /**
   * @description Returns the mock histories for the specified stubbed method name.
   * @param stubbedMethodName The name of the stubbed method.
   * @return The mock histories for the specified stubbed method name.
   */
  public List<MockHistory> getHistories(String stubbedMethodName) {
    List<MockHistory> methodHistories = histories.get(stubbedMethodName);
    return methodHistories == null ? new List<MockHistory>() : methodHistories;
  }

  /**
   * @description Adds a mock method to the mock provider. Overrides any existing mock method with the same name.
   * @param stubbedMethodName The name of the stubbed method.
   * @param result The result to be returned when the stubbed method is called.
   * @return The updated mock provider instance.
   */
  public Lib_MockProvider mock(String stubbedMethodName, Object result) {
    this.stubbedMethodMap.put(stubbedMethodName, result);
    this.histories.remove(stubbedMethodName);
    return this;
  }

  /**
   * @description Mocks the specified methods with the provided stubbed values.
   * @param stubbedMethodMap A map containing the method names as keys and the corresponding stubbed values as values.
   * @return The updated mock provider instance.
   */
  public Lib_MockProvider mock(Map<String, Object> stubbedMethodMap) {
    for (String stubbedMethodName : stubbedMethodMap.keySet()) {
      this.mock(stubbedMethodName, stubbedMethodMap.get(stubbedMethodName));
    }
    return this;
  }

  /**
   * @description Mocks an exception for a specified method in the class.
   * @param stubbedMethodName The name of the stubbed method.
   * @param result The exception to be thrown when the method is called.
   * @return The updated mock provider instance.
   */
  public Lib_MockProvider mockException(
    String stubbedMethodName,
    Exception result
  ) {
    ExceptionStub mockConfig = new ExceptionStub();
    mockConfig.apexException = result;
    this.mock(stubbedMethodName, mockConfig);
    return this;
  }

  /**
   * @description Mocks a default exception for a specified method in the class.
   * @param stubbedMethodName The name of the stubbed method.
   * @return The updated mock provider instance.
   */
  public Lib_MockProvider mockException(String stubbedMethodName) {
    return this.mockException(stubbedMethodName, DEFAULT_EXCEPTION);
  }

  /**
   * @description Represents a mock history object used for testing purposes.
   */
  public class MockHistory {
    public List<String> listOfParamNames;
    public List<Object> listOfArgs;

    /**
     * @description Returns the value of the specified parameter.
     * @param paramName The name of the parameter.
     * @return The value of the parameter.
     */
    public Object getParam(String paramName) {
      Integer index = this.listOfParamNames?.indexOf(paramName);
      return index >= 0 ? listOfArgs[index] : null;
    }
  }

  private class ExceptionStub {
    private Exception apexException;
  }

  /**
   * @description DefaultException is thrown when a mocked method is set to throw an exception, but no specific exception type is defined.
   * It acts as a generic, fallback exception in testing scenarios.
   */
  public class DefaultException extends Exception {
  }
}
