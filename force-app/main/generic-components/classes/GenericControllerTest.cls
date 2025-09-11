/**
 * @description Test class for GenericController.
 * @author Mohit Tripathi
 * @since 08/2025
 */
@isTest
public class GenericControllerTest {
  /**
   * @description Mock implementation of IGenericClass for testing
   */
  public class TestGenericClass implements IGenericClass {
    /**
     * @description Mock implementation of getData method for testing success scenarios
     * @param param Parameter string to process
     * @return Map containing test data and status
     */
    public Object getData(String param) {
      if (String.isBlank(param)) {
        throw new IllegalArgumentException('Parameter cannot be blank');
      }
      Map<String, Object> result = new Map<String, Object>{
        'status' => 'success',
        'data' => 'test data',
        'param' => param
      };
      return result;
    }
  }

  /**
   * @description Mock implementation that throws exception for testing
   */
  public class TestGenericClassThatThrows implements IGenericClass {
    /**
     * @description Mock implementation of getData method that throws exception for testing error scenarios
     * @param param Parameter string (not used in this mock)
     * @return Never returns as it always throws an exception
     * @throws QueryException Always throws this exception for testing purposes
     */
    public Object getData(String param) {
      throw new QueryException('Test exception');
    }
  }

  @isTest
  static void testGetConfigSuccess() {
    String configName = 'config_template';

    Test.startTest();
    String result = GenericController.getConfig(configName);
    Test.stopTest();

    Assert.isNotNull(result, 'Config should not be null');
    Assert.isTrue(result.length() > 0, 'Config should have content');
  }

  @isTest
  static void testGetConfigWithBlankName() {
    Test.startTest();

    Boolean thrown = false;
    try {
      GenericController.getConfig('');
    } catch (AuraHandledException e) {
      thrown = true;
      Assert.areEqual(
        'Script-thrown exception',
        e.getMessage(),
        'Should throw AuraHandledException for blank config name'
      );
    }

    Test.stopTest();
    Assert.isTrue(thrown, 'Exception should be thrown for blank config name');
  }

  @isTest
  static void testGetConfigWithNullName() {
    Test.startTest();

    Boolean thrown = false;
    try {
      GenericController.getConfig(null);
    } catch (AuraHandledException e) {
      thrown = true;
      Assert.areEqual(
        'Script-thrown exception',
        e.getMessage(),
        'Should throw AuraHandledException for null config name'
      );
    }

    Test.stopTest();
    Assert.isTrue(thrown, 'Exception should be thrown for null config name');
  }

  @isTest
  static void testGetDataSuccess() {
    String testParam = JSON.serialize(
      new Map<String, Object>{ 'testKey' => 'testValue' }
    );

    Test.startTest();
    Object result = GenericController.getData(
      'GenericControllerTest.TestGenericClass',
      testParam
    );
    Test.stopTest();

    Assert.isNotNull(result, 'Result should not be null');

    Map<String, Object> resultMap = (Map<String, Object>) result;
    Assert.areEqual(
      'success',
      resultMap.get('status'),
      'Status should be success'
    );
    Assert.areEqual(
      'test data',
      resultMap.get('data'),
      'Data should match expected value'
    );
    Assert.areEqual(
      testParam,
      resultMap.get('param'),
      'Param should match input'
    );
  }

  @isTest
  static void testGetDataWithBlankController() {
    String testParam = JSON.serialize(
      new Map<String, Object>{ 'testKey' => 'testValue' }
    );

    Test.startTest();

    Boolean thrown = false;
    try {
      GenericController.getData('', testParam);
    } catch (AuraHandledException e) {
      thrown = true;
      Assert.areEqual(
        'Script-thrown exception',
        e.getMessage(),
        'Should throw AuraHandledException for blank controller name'
      );
    }

    Test.stopTest();
    Assert.isTrue(
      thrown,
      'Exception should be thrown for blank controller name'
    );
  }

  @isTest
  static void testGetDataWithNullController() {
    String testParam = JSON.serialize(
      new Map<String, Object>{ 'testKey' => 'testValue' }
    );

    Test.startTest();

    Boolean thrown = false;
    try {
      GenericController.getData(null, testParam);
    } catch (AuraHandledException e) {
      thrown = true;
      Assert.areEqual(
        'Script-thrown exception',
        e.getMessage(),
        'Should throw AuraHandledException for null controller name'
      );
    }

    Test.stopTest();
    Assert.isTrue(
      thrown,
      'Exception should be thrown for null controller name'
    );
  }

  @isTest
  static void testGetDataWithInvalidController() {
    String testParam = JSON.serialize(
      new Map<String, Object>{ 'testKey' => 'testValue' }
    );

    Test.startTest();

    Boolean thrown = false;
    try {
      GenericController.getData('NonExistentController', testParam);
    } catch (AuraHandledException e) {
      thrown = true;
      // Exception message will vary based on the actual error from Type.forName()
    }

    Test.stopTest();
    Assert.isTrue(
      thrown,
      'Exception should be thrown for invalid controller name'
    );
  }

  @isTest
  static void testGetDataControllerThrowsException() {
    String testParam = JSON.serialize(
      new Map<String, Object>{ 'testKey' => 'testValue' }
    );

    Test.startTest();

    Boolean thrown = false;
    try {
      GenericController.getData(
        'GenericControllerTest.TestGenericClassThatThrows',
        testParam
      );
    } catch (AuraHandledException e) {
      thrown = true;
      Assert.areEqual(
        'Script-thrown exception',
        e.getMessage(),
        'Should throw AuraHandledException when controller getData throws exception'
      );
    }

    Test.stopTest();
    Assert.isTrue(
      thrown,
      'Exception should be thrown when controller getData throws exception'
    );
  }

  @isTest
  static void testGetDataWithBlankParam() {
    Test.startTest();

    Boolean thrown = false;
    try {
      GenericController.getData('GenericControllerTest.TestGenericClass', '');
    } catch (AuraHandledException e) {
      thrown = true;
      Assert.areEqual(
        'Script-thrown exception',
        e.getMessage(),
        'Should throw AuraHandledException for blank parameter'
      );
    }

    Test.stopTest();
    Assert.isTrue(thrown, 'Exception should be thrown for blank parameter');
  }
}
