/**
 * @author Batya Aisman Sufrin
 * @since 10/2024
 * @description  To test AutoKYCQACustomerUpdateTriggerHandler
 */
@IsTest
private class CustomerProfileUpdatesTriggerTest {
  @IsTest
  static void testCustomerProfileUpdatesOnAfterUpdate() {
    Customer_Profile_Updates__c cpuPending = new Customer_Profile_Updates__c(
      Name = 'test'
    );
    insert cpuPending;

    cpuPending.Status__c = 'Completed';

    try {
      Test.startTest();
      update cpuPending;
      Test.stopTest();
    } catch (Exception e) {
      Assert.fail('Should be no Exception');
    }
  }
}
