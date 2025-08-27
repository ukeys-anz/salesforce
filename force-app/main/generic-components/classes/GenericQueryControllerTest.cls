/**
 * @description Test class for GenericQueryController.
 * @author Peter Charalambous
 * @since 07/2025
 */
@IsTest
public class GenericQueryControllerTest {
  static Lib_MockProvider accountRepoMock;

  //Using AccountQueryController as test
  static final String CONTROLLER_TYPE = 'AccountQueryController';
  static final String NOTCALLABLE_TYPE = 'GenericQueryControllerTest$NotCallable';

  static Account testAccount = new Account(
    Name = 'Test Account',
    OCV_ID__c = 'OCV12345',
    Id = Lib_FakeIdGenerator.getMockId(Account.getSObjectType()),
    ANZx_Customer__c = true
  );

  /**
   * @description Mock class to simulate a non-callable controller
   */
  public class NotCallable {
  }

  static void registerMocks() {
    accountRepoMock = Lib_MockProvider.forType(AccountRepository.class);
    accountRepoMock.mock('getAccountByOcvId', testAccount);

    Lib_InstanceProvider.register(
      Type.forName(CONTROLLER_TYPE),
      new AccountQueryController()
    );
  }

  @testSetup
  static void setup() {
    // Mock AccountRepository
    Lib_MockProvider.forType(AccountRepository.class)
      .mock('getAccountByOcvId', testAccount);

    // Register AccountQueryController
    Lib_InstanceProvider.register(
      Type.forName(CONTROLLER_TYPE),
      new AccountQueryController()
    );
  }

  @isTest
  static void testSuccess() {
    registerMocks();
    Map<String, Object> args = new Map<String, Object>{ 'ocvId' => 'OCV12345' };
    String param = JSON.serialize(
      new Map<String, Object>{
        'controller' => CONTROLLER_TYPE,
        'method' => 'getAccountByOcvId',
        'args' => args
      }
    );

    GenericQueryController controller = new GenericQueryController();

    Test.startTest();
    Account result = (Account) controller.getData(param);
    Test.stopTest();

    Assert.areNotEqual(null, result, 'Result should not be null');
    Assert.areEqual('Test Account', result.Name, 'Account name should match');
    Assert.areEqual('OCV12345', result.OCV_ID__c, 'OCV ID should match');
  }

  @isTest
  static void testMissingController() {
    registerMocks();
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
    registerMocks();
    String param = JSON.serialize(
      new Map<String, Object>{
        'controller' => CONTROLLER_TYPE,
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
