@isTest
private class TestCustomerFeedbackTriggerHandler {
  //Tests if the Account Id is populated correctly based on OCV ID during Customer Feedback insert
  @isTest
  static void testCustomerFeedbackInsert() {
    Faker faker = new Faker('AU');
    Customer_Feedback__c[] newCFs = new List<Customer_Feedback__c>();

    //create test account
    Account testAcc = new Account(
      RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('PersonAccount')
        .getRecordTypeId(),
      FirstName = Faker.randomString(5),
      LastName = Faker.randomString(5),
      OCV_ID__c = 'test123'
    );
    insert testAcc;

    //Fetch Feedback_Type__c from the backend to avoid Restricted picklist error in future.
    Schema.DescribeFieldResult feedbackTypeList = Customer_Feedback__c.Feedback_Type__c.getDescribe();
    List<Schema.PicklistEntry> pleFeedbackType = feedbackTypeList.getPicklistValues();

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCFs.add(
        new Customer_Feedback__c(
          Feedback_Type__c = pleFeedbackType[0].getValue(),
          Advocacy_Rating__c = Faker.randomInteger(1),
          Verbatim__c = Faker.randomString(20),
          Store_Location__c = Faker.randomString(8),
          Coach_Type__c = Faker.randomString(8),
          Feedback_Received_Date_Time__c = DateTime.now()
        )
      );
    }

    //Pass valid OCV Id
    newCFs[0].OCV_ID__c = 'test123';

    //Pass invalid OCV Id
    newCFs[1].OCV_ID__c = 'test456';

    List<Database.SaveResult> results = Database.Insert(newCFs, false);

    Customer_Feedback__c[] insertedCFs = [
      SELECT Account_Name__c
      FROM Customer_Feedback__c
      WHERE id = :newCFs[0].id
    ];

    system.assertEquals(testAcc.Id, insertedCFs[0].Account_Name__c);
  }
}
