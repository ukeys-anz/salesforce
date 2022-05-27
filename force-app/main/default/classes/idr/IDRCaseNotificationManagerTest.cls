@isTest
private class IDRCaseNotificationManagerTest {
  @testSetup
  static void setup() {
    String complaintRecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;
    List<Case> newCases = new List<Case>();

    Profile p = [SELECT Id FROM Profile WHERE Name = 'ANZ Standard User'];

    for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      newCases.add(
        new Case(
          IDR_Account_Card_Policy_Number__c = '000001234',
          Description = 'Test Description',
          IDR_Complainant_Desired_Outcome__c = 'Test Outcome',
          IDR_Description_of_Outcome__c = 'Test Outcome',
          IDR_Systemic_Issue_Description__c = 'None',
          RecordTypeId = complaintRecordTypeId,
          IDR_Customer_Number__c = '1234567890',
          Status = 'Open',
          IDR_Date_Received__c = System.now()
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

    System.runAs(usrlist[0]) {
      List<Case> caseToUpdate = [SELECT Id FROM Case];
      for (Case c : caseToUpdate) {
        c.OwnerId = usrlist[1].id;
      }
      update caseToUpdate;

      List<Application_Log__c> appLogs = [
        SELECT ID
        FROM Application_Log__c
        WHERE Process_Name__c = 'IDRBankerNotificationBuilder'
      ];
      System.assertEquals(0, appLogs.size());
    }
  }

  @isTest
  static void testBankerNotifcationForCaseEscalation() {
    List<Case> complaintCaselist = [
      SELECT Id, IDR_Date_Received__c, IDR_Milestone_Sla__c
      FROM Case
    ];
    /*for (Integer i = 0; i < Integer.valueOf(Label.Test_Bulk_Size); i++) {
      complaintCaselist.add(
        new Case(
          IDR_Account_Card_Policy_Number__c = '000001234',
          Description = 'Test check entitlement',
          IDR_Complainant_Desired_Outcome__c = 'entitlement id populated',
          IDR_Description_of_Outcome__c = 'entitlement id populated',
          IDR_Systemic_Issue_Description__c = 'None',
          RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID,
          IDR_Customer_Number__c = '1234567890',
          Status = 'Open',
          IDR_Date_Received__c = System.now()
        )
      );
    }*/

    //insert complaintCaselist;
    Test.startTest();

    for (Case c : complaintCaselist) {
      c.IDR_Date_Received__c = DateTime.now().addDays(-2);
      c.IDR_Milestone_Sla__c = IDRConstants.MILESTONE_SLA_RED;
    }
    CheckRecursive.firstCall = false;

    update complaintCaselist;
    Test.stopTest();
    List<Application_Log__c> appLogs = [
      SELECT ID
      FROM Application_Log__c
      WHERE Function_Name__c = 'notifyBankersForEscalation'
    ];
    System.assertEquals(0, appLogs.size());
  }
}
