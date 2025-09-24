/**
 * @author Shivsharan Giram
 * @since 07/2025
 * @description UserTerritorySetupHandlerTest is the test class for UserTerritorySetupHandler Class.
 */
@isTest
public with sharing class UserTerritorySetupHandlerTest {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  @isTest
  public static void testInsertUserTerritorySetupEvent() {
    Id usrId = Lib_FakeIdGenerator.getMockId(User.SObjectType);
    List<User_Territory_Setup_Event__e> objEvent = new List<User_Territory_Setup_Event__e>{
      new User_Territory_Setup_Event__e(User_Id__c = usrId)
    };
    test.startTest();
    DML_REPOSITORY.doPublish(objEvent);
    test.stopTest();
    Assert.isNotNull(
      objEvent[0].EventUuid,
      'User Territory Setup Event CreatedBy should not be null'
    );
  }
}
