/**
 * @author Naman Garg
 * @since  12/2023
 * @group CCRM (Commercial CRM)
 * @description CCRMPopulateCPIDUserBatchTest is Test class to test CCRMPopulateCPIDUserBatch.
 */

@isTest
public class CCRMPopulateCPIDUserBatchTest {
  static Lib_MockProvider cpRepoMock;
  static Lib_MockProvider dmlRepoMock;
  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DMLRepository.class);
    cpRepoMock = Lib_MockProvider.forType(CCRMControllingPostRepository.class);
  }

  @isTest
  static void testExecuteException() {
    registerMocks();

    //GIVEN Controlling Post List and User List
    List<Controlling_Post__c> cpList = new List<Controlling_Post__c>{
      new Controlling_Post__c(
        Id = Lib_FakeIdGenerator.getMockId(
          Controlling_Post__c.getSobjectType()
        ),
        Name = 'Sample Controlling Post',
        Is_Active__c = true,
        CPID_CancelFag__c = false,
        CPID_LanID__c = 'Batch'
      )
    };

    List<User> userList = new List<User>{
      new User(
        FirstName = 'Test',
        LastName = 'User',
        isActive = true,
        Lan_Id__c = 'batch',
        Id = Lib_FakeIdGenerator.getMockId(User.getSobjectType())
      )
    };

    cpRepoMock.mockException('getActiveLanIdUser');

    //WHEN calling a method
    try {
      Test.startTest();
      CCRMPopulateCPIDUserBatch.execute(null, cpList);
      Test.stopTest();
    } catch (Exception ex) {
      //THEN error should thrown
      Assert.isTrue(ex instanceof QueryException, 'Exception should be thrown');
    }
  }

  @isTest
  static void testExecute() {
    registerMocks();
    //GIVEN List of Controlling Post records and user List
    List<Controlling_Post__c> cpList = new List<Controlling_Post__c>{
      new Controlling_Post__c(
        Id = Lib_FakeIdGenerator.getMockId(
          Controlling_Post__c.getSobjectType()
        ),
        Name = 'Sample Controlling Post',
        Is_Active__c = true,
        CPID_CancelFag__c = false,
        CPID_LanID__c = 'Batch'
      )
    };
    List<User> userList = new List<User>{
      new User(
        FirstName = 'Test',
        LastName = 'User',
        isActive = true,
        Lan_Id__c = 'Batch',
        Id = Lib_FakeIdGenerator.getMockId(user.getSobjectType())
      )
    };
    cpRepoMock.mock('getActiveLanIdUser', userList);
    //WHEN calling a method
    Test.startTest();
    CCRMPopulateCPIDUserBatch.execute(null, cpList);
    Test.stopTest();

    List<Controlling_Post__c> cpUpdatedList = (List<Controlling_Post__c>) dmlRepoMock.getHistory(
        'updateRecords'
      )
      .getParam('records');

    //THEN it should update 1 Controlling post record.
    Assert.areEqual(1, cpUpdatedList.size(), 'No Controlling record updated.');
  }
}
