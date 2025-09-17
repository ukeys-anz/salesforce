/*
 * @author Pragya Awasthi
 * @since  26 Aug 2025
 * @description InteractionTriggerTest is the test class for trigger code coverage
 */
@isTest
public class InteractionTriggerTest {
  private static Integer otherPurposeDuration = 30;

  /**
   * @description helper method to create a person account
   * @param firstName String the first name of the person
   * @param lastName String the last name of the person
   * @param ocvId the OCVId
   * @return Account a Person Account with Name and OCV as provided
   */
  static Account createTestAccount(
    String firstName,
    String lastName,
    String ocvId
  ) {
    return new Account(
      FirstName = firstName,
      LastName = lastName,
      OCV_ID__c = ocvId,
      RecordTypeId = RTAccount.personAccount
    );
  }

  /**
   * @description test method for trigger code coverage
   */
  @isTest
  static void createInteraction() {
    Account testAccount = createTestAccount('Joe', 'Bloggs', 'afr123');
    DateTime startTime = DateTime.newInstance(DateTime.now().year() + 1, 1, 1);
    User mlUser = MLCRMTestDataFactory.createMLCRMBaseUser();

    System.runAs(MLCRMTestDataFactory.createMLBusinessAdminUser()) {
      Territory__c terrRecord = new Territory__c(Name = 'Melbourne CBD (VIC)');
      terrRecord.Primary_Franchise_Owner__c = UserInfo.getUserId();
      insert terrRecord;

      Interaction testInteraction = new Interaction(
        Status__c = 'Unassigned',
        Interaction_Purpose__c = 'Other',
        InteractionType = 'Call',
        RecordTypeId = RTInteraction.mlcrmInteraction,
        StartTime = startTime,
        AccountId = testAccount.Id,
        Name = 'MLCRM Interaction',
        EndTime = startTime.addMinutes(otherPurposeDuration),
        OwnerId = UserInfo.getUserId(),
        Territory__c = terrRecord.Id
      );

      try {
        Test.startTest();
        insert testInteraction;
        Test.stopTest();
      } catch (Exception e) {
        Assert.fail('Should be no Exception');
      }
    }
  }
}
