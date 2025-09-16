/**
 * @description Test class for GenericQueryController.
 * @author Peter Charalambous
 * @since 07/2025
 */
@IsTest
public class GenericQueryControllerTest {
  static final String NOTCALLABLE_TYPE = 'GenericQueryControllerTest$NotCallable';

  /**
   * @description Mock class to simulate a non-callable controller
   */
  public class NotCallable {
  }

  @isTest
  static void testMissingController() {
    String param = JSON.serialize(
      new Map<String, Object>{
        'method' => 'getDummyData',
        'args' => new Map<String, Object>{ 'ocvId' => 'OCV12345' }
      }
    );

    GenericQueryController controller = new GenericQueryController();

    Test.startTest();
    try {
      controller.getData(param);
      Assert.isTrue(false, 'Should have thrown AuraHandledException');
    } catch (AuraHandledException e) {
      Assert.isTrue(
        e.getMessage().contains('Something went wrong'),
        'Should throw generic error'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testMissingMethod() {
    String param = JSON.serialize(
      new Map<String, Object>{
        'controller' => 'testController',
        'args' => new Map<String, Object>{ 'ocvId' => 'OCV12345' }
      }
    );

    GenericQueryController controller = new GenericQueryController();

    Test.startTest();
    try {
      controller.getData(param);
      Assert.isTrue(false, 'Should have thrown AuraHandledException');
    } catch (AuraHandledException e) {
      Assert.isTrue(
        e.getMessage().contains('Something went wrong'),
        'Should throw generic error'
      );
    }
    Test.stopTest();
  }

  @isTest
  static void testControllerNotCallable() {
    // NotCallable mock registration
    Lib_InstanceProvider.register(
      Type.forName(NOTCALLABLE_TYPE),
      new NotCallable()
    );

    String param = JSON.serialize(
      new Map<String, Object>{
        'controller' => NOTCALLABLE_TYPE,
        'method' => 'testMethod',
        'args' => new Map<String, Object>{}
      }
    );

    GenericQueryController controller = new GenericQueryController();

    Test.startTest();
    try {
      controller.getData(param);
      Assert.isTrue(false, 'Should have thrown AuraHandledException');
    } catch (AuraHandledException e) {
      Assert.isTrue(
        e.getMessage().contains('Something went wrong'),
        'Should throw generic error'
      );
    }
    Test.stopTest();
  }
}
