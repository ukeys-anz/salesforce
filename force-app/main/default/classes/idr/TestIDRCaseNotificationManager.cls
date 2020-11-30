@isTest
private class TestIDRCaseNotificationManager {
  @testSetup
  static void setup() {
    String complaintRecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;
    List<Case> newCases = new List<Case>();

    Profile p = [SELECT Id FROM Profile WHERE Name = 'ANZ Standard User'];

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          RecordTypeId = complaintRecordTypeId,
          Status = IDRConstants.OPEN_STATUS,
          IDR_Account_Card_Policy_Number__c = '000001234',
          Description = 'Test decription'
        )
      );
    }

    insert newCases;
    List<User> userList = new List<USer>();
    User usr = (User) FakerFactory.make(new FakerUserFactory());
    usr.ProfileId = p.Id;
    usr.Business_Function__c = 'Test Business Function ';
    usr.Business_Role__c = 'Business Role';
    userList.add(usr);

    User usr2 = (User) FakerFactory.make(new FakerUserFactory());
    usr2.ProfileId = p.Id;
    usr2.Business_Function__c = 'Test Business Function ';
    usr2.Business_Role__c = 'Business Role';
    userList.add(usr2);

    insert userList;
  }

  @isTest
  static void testManualNotification() {
    List<User> usrlist = [SELECT id FROM User];
    List<IDR_Notification_Preference__c> npList = new List<IDR_Notification_Preference__c>();
    IDR_Notification_Preference__c npRecord = new IDR_Notification_Preference__c();
    npRecord.Case_Flag__c = true;
    npRecord.Email__c = false;
    npRecord.In_App__c = true;
    npRecord.OwnerId = usrlist[0].Id;
    npList.add(npRecord);

    IDR_Notification_Preference__c npRecord1 = new IDR_Notification_Preference__c();
    npRecord1.Case_Flag__c = true;
    npRecord1.Email__c = false;
    npRecord1.In_App__c = true;
    npRecord1.OwnerId = usrlist[1].Id;
    npList.add(npRecord1);

    insert npList;

    System.runAs(usrlist[0]) {
      List<Case> caseToUpdate = [SELECT Id FROM Case];
      for (Case c : caseToUpdate) {
        c.OwnerId = usrlist[1].id;
      }
      update caseToUpdate;

      for (Case c : [SELECT Id, IDR_Update_Notification_Flag__c FROM Case]) {
        System.assertEquals(true, c.IDR_Update_Notification_Flag__c);
      }
    }
  }
}
