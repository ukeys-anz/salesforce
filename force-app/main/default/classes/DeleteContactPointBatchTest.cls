/**
 * @author Ashwin Mohan
 * @since 11/2024
 * @description DeleteContactPointBatchTest is the test class for DeleteContactPointBatch Class.
 */
@isTest
public class DeleteContactPointBatchTest {
  static Lib_MockProvider dmlRepoMock;

  static void registerMocks() {
    dmlRepoMock = Lib_MockProvider.forType(DmlRepository.class);
  }

  @isTest
  static void testBatch() {
    registerMocks();
    List<ContactPointEmail> emailRecords = new List<ContactPointEmail>{
      new ContactPointEmail(
        Id = Lib_FakeIdGenerator.getMockId(ContactPointEmail.SObjectType)
      )
    };
    Test.startTest();
    DeleteContactPointBatch batchObj = new DeleteContactPointBatch(
      'ContactPointEmail'
    );
    Database.executeBatch(batchObj); // to cover start method
    batchObj.execute(null, emailRecords);
    Test.stopTest();
    List<ContactPointEmail> deletedRecords = (List<ContactPointEmail>) dmlRepoMock.getHistory(
        'doDelete'
      )
      .getParam('records');
    Assert.areEqual(
      1,
      deletedRecords.size(),
      'The inactive address record is not deleted by batch'
    );
  }
}
