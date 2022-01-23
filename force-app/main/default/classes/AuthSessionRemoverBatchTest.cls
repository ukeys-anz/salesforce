/**
 * @author Victor
 * @since 11/2021
 * @description test class for AuthSessionRemoverBatch
 */
@isTest
public with sharing class AuthSessionRemoverBatchTest {
  @isTest
  public static void testExecuteBatchJob() {
    Test.startTest();
    AuthSessionRemoverBatch batch = new AuthSessionRemoverBatch();
    Id batchId = Database.executeBatch(batch);
    Test.stopTest();

    System.assertNotEquals(
      null,
      batchId,
      'Should have a batch Id for AuthSessionRemoverBatch job.'
    );
  }
}
