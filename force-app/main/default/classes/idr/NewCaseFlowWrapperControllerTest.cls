/**
 * @author saiero
 * @since 2020
 * @description Test class for {@link NewCaseFlowWrapperController}
 * @group IDR(Internal Dispute Resolution)
 */
@isTest
private with sharing class NewCaseFlowWrapperControllerTest {
  /**
   * @description setup is to prepare test data
   */
  @testSetup
  static void setup() {
    Faker faker = new Faker('AU');
    //create test account
    Id recTypeID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get('PersonAccount')
      .getRecordTypeId();
    Account testAcc = new Account(
      RecordTypeId = recTypeID,
      FirstName = faker.randomString(5),
      LastName = faker.randomString(5),
      OCV_ID__c = '1234567891'
    );
    insert testAcc;
  }

  @isTest
  static void testRecordTypeDevNameFromId() {
    RecordType rt = [
      SELECT DeveloperName
      FROM RecordType
      WHERE DeveloperName = 'Customer_Complaint'
    ];
    System.assertEquals(
      'Customer_Complaint',
      NewCaseFlowWrapperController.getCaseRecordTypeDevNameById(rt.Id),
      'Developer name should be Customer_Complaint'
    );
  }

  // Test getting available record type Ids for Case
  @isTest
  private static void testGetAvailableRecordTypeIdsForSObject() {
    List<Id> caseRecordTypeIdsByQuery = new List<Id>();
    Test.startTest();
    String resultString = NewCaseFlowWrapperController.getCaseRecordTypes();
    Test.stopTest();
    System.assertNotEquals(
      0,
      ((List<RecordType>) JSON.deserializeStrict(
          resultString,
          List<RecordType>.class
        ))
        .size(),
      'Record type Ids were returned'
    );
  }
}
