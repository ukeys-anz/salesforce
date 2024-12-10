/**
 * @author Karen Valeriano
 * @since 10/2024
 * @description Tests for ProfileStagingController
 */
@isTest
private class ProfileStagingControllerTest {
  static Lib_MockProvider repoMock;
  static Lib_MockProvider dmlRepoMock;
  static Lib_MockProvider handlerMock;

  static final String PENDING = 'Pending';

  static void registerMocks() {
    repoMock = Lib_MockProvider.forType(ProfileStagingRepository.class);
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
    handlerMock = Lib_MockProvider.forType(ProfileStagingHandler.class);
  }

  static Customer_Profile_Updates__c cpu = new Customer_Profile_Updates__c(
    Id = Lib_FakeIdGenerator.getMockId(Customer_Profile_Updates__c.SObjectType),
    Error_Description__c = 'Error description',
    Status__c = 'Error',
    Customer_Name__r = new Account(
      RecordType = new RecordType(DeveloperName = 'Customer')
    )
  );

  static List<Customer_Profile_Updates__c> cpuList = new List<Customer_Profile_Updates__c>{
    cpu
  };

  @isTest
  static void testProfileStagingRetrySuccessful() {
    registerMocks();
    repoMock.mock('queryCustomerProfileUpdates', cpuList);

    Test.startTest();
    ProfileStagingController.profileStagingRetry(cpu.Id);
    Test.stopTest();

    Customer_Profile_Updates__c updatedRecord = (Customer_Profile_Updates__c) dmlRepoMock
      .getHistory('doUpdate')
      .getParam('record');

    Set<Id> publishedRecordIds = (Set<Id>) handlerMock
      .getHistory('publishEvents')
      .getParam('recordIds');

    Assert.areEqual(
      PENDING,
      updatedRecord.Status__c,
      'Status__c should be ' + PENDING
    );
    Assert.isTrue(
      String.isBlank(updatedRecord.Error_Description__c),
      'Error_Description__c should be blank'
    );
    Assert.isTrue(
      publishedRecordIds.contains(cpu.Id),
      'Event should contain the updated Customer_Profile_Updates__c record Id'
    );
  }

  @isTest
  static void testProfileStagingRetryFailed() {
    registerMocks();
    dmlRepoMock.mockException(
      'doUpdate',
      new DmlException('Error updating the record.')
    );

    try {
      Test.startTest();
      ProfileStagingController.profileStagingRetry(cpu.Id);
      Test.stopTest();
    } catch (Exception ex) {
      Assert.isTrue(
        ex instanceof AuraHandledException,
        'AuraHandledException should have been thrown'
      );
    }
  }
}
