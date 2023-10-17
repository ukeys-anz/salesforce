/**
 * @author Ankit Garg
 * @since 31 July 2023
 * @description test classes for MLCRMCustomerSetCPIDLookupBatch, MLCRMCustomerSetCPIDLookupBatchAction and MLCRMCustomerSetCPIDLookupBatchSchedule.
 * @group Service
 */
@isTest
public class MLCRMCustomerSetCPIDLookupBatchTest {
  @TestSetup
  static void setup() {
    User mlUser = MLCRMTestDataFactory.createAdminUser();
    System.runAs(mlUser) {
      List<Territory__c> lstOfTerritory = MLCRMTestDataFactory.createTerritoryRecords(
        1,
        mlUser,
        true
      );
      MLCRMTestDataFactory.createUserTerritoryRecords(
        1,
        mlUser.Id,
        lstOfTerritory[0].Id
      );
    }
    System.runAs(mlUser) {
      Set<String> setOfEmployeeId = new Set<String>{ '30456789', '10456790' };
      CCRMTestDataFactory.createUsersWithEmployeeId(setOfEmployeeId);
    }
    System.runAs(mlUser) {
      Faker faker = new Faker('AU');
      Account testAccount = new Account(
        Name = 'Test Account CPID Batch',
        OCV_ID__c = faker.randomString(10),
        ANZx_Customer__c = false,
        OCV_Event_Version__c = 1,
        CPID__c = 'L7601'
      );
      insert testAccount;
    }
  }

  @IsTest
  static void testMLCRMCustomerSetCPIDLookupBatchAction() {
    User mlUser = MLCRMTestDataFactory.getAdminUser();
    System.runAs(mlUser) {
      Map<String, String> values = new Map<String, String>{
        'L7601' => '30456789',
        'L7602' => '30456790'
      };
      CCRMTestDataFactory.createControllingPosts(values);

      Test.startTest();
      MLCRMCustomerSetCPIDLookupBatch batch = new MLCRMCustomerSetCPIDLookupBatch();
      Database.executeBatch(batch);
      Test.stopTest();
      // THEN the existing lead is converted into this account
      Account acc = [
        SELECT Id, Controlling_Post__c
        FROM Account
        WHERE Name = 'Test Account CPID Batch'
        LIMIT 1
      ];
      System.assertNotEquals(
        null,
        acc.Controlling_Post__c,
        'Account is not updated'
      );
    }
  }

  @isTest
  public static void testMLCRMCustomerSetCPIDLookupBatchSchedule() {
    Test.startTest();
    String cronExp = '0 0 */8 ? * *';

    String jobId = MLCRMCustomerSetCPIDLookupBatchSchedule.schedule(
      'MLCRMCustomerSetCPIDLookupBatchSchedule Test Job',
      cronExp
    );

    // Get the information from the CronTrigger API object
    CronTrigger ct = [
      SELECT Id, CronExpression
      FROM CronTrigger
      WHERE id = :jobId
    ];

    // Verify the expressions are the same
    System.assertEquals(
      cronExp,
      ct.CronExpression,
      'MLCRMCustomerSetCPIDLookupBatchSchedule should be invoked every 8 hours.'
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      jobId,
      'Should have a MLCRMCustomerSetCPIDLookupBatchSchedule job scheduled.'
    );
  }
}
