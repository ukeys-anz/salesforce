/**
 * @author Naman Garg
 * @since  07/2024
 * @group CCRM (Commercial CRM)
 * @description CCRMControllingPostHelperTest is Test class to test CCRMControllingPostHelper.
 */
@isTest
public class CCRMControllingPostHelperTest {
  @isTest
  static void testGetLanIds() {
    //GIVEN List of Controlling Post records
    List<Controlling_Post__c> cpList = new List<Controlling_Post__c>{
      new Controlling_Post__c(
        Id = Lib_FakeIdGenerator.getMockId(Controlling_Post__c.SObjectType),
        Name = 'Sample Controlling Post',
        Is_Active__c = true,
        CPID_CancelFag__c = false,
        CPID_LanID__c = 'Batch'
      )
    };

    //WHEN calling a method
    Test.startTest();
    Set<String> lanIdsSet = CCRMControllingPostHelper.getLanIds(cpList);
    Test.stopTest();

    //THEN it should fetch one lan Id
    Assert.areEqual(1, lanIdsSet.size(), 'Not able to retrieve lan Id');
  }

  @isTest
  static void testFormLanIdToUserMap() {
    //GIVEN User List
    List<User> userList = new List<User>{
      new User(
        FirstName = 'Test',
        LastName = 'User',
        isActive = true,
        Lan_Id__c = 'user1',
        Id = Lib_FakeIdGenerator.getMockId(User.SObjectType)
      )
    };

    //WHEN method get called
    test.startTest();
    Map<String, User> lanIdUserMap = CCRMControllingPostHelper.formLanIdToUserMap(
      userList
    );
    test.stopTest();

    //THEN the user is able to get the filtered Controlling_Post__c records
    System.assertEquals(
      1,
      lanIdUserMap.size(),
      'Not able to form the map of User and lan Id'
    );
  }

  @isTest
  static void testSetUserLookup() {
    //GIVEN List of Controlling Post records and Map of LanId to User
    List<Controlling_Post__c> cpList = new List<Controlling_Post__c>{
      new Controlling_Post__c(
        Id = Lib_FakeIdGenerator.getMockId(Controlling_Post__c.SObjectType),
        Name = 'Sample Controlling Post',
        Is_Active__c = true,
        CPID_CancelFag__c = false,
        CPID_LanID__c = 'Batch'
      )
    };

    Map<String, User> mapOfLanIdToUser = new Map<String, User>{
      'batch' => new User(
        Id = Lib_FakeIdGenerator.getMockId(User.SObjectType),
        FirstName = 'Test',
        LastName = 'User',
        isActive = true,
        Lan_Id__c = 'batch'
      )
    };

    //WHEN calling a method
    Test.startTest();
    List<Controlling_Post__c> cpRecToUpdateList = CCRMControllingPostHelper.setUserLookup(
      cpList,
      mapOfLanIdToUser
    );
    Test.stopTest();

    //THEN it should fetch one lan Id
    Assert.areEqual(
      1,
      cpRecToUpdateList.size(),
      'No controlling post record is available for udpate'
    );
  }
}
