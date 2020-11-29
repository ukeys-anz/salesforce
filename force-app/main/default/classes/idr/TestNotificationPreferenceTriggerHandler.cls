@isTest
public class TestNotificationPreferenceTriggerHandler {
    @isTest
  static void testdefaultValues() {
          Profile p = [SELECT Id FROM Profile WHERE Name = 'ANZ Standard User'];
      
      User usr = (User) FakerFactory.make(new FakerUserFactory());
	  usr.ProfileId = p.Id;
      usr.Business_Function__c = 'Test Business Function ';
      usr.Business_Role__c = 'Business Role';
      insert usr;
                                          
      
      System.runAs(usr){
          IDR_Notification_Preference__c npRecord = new IDR_Notification_Preference__c();
      npRecord.Case_Flag__c = true;
      npRecord.Email__c = false;
      npRecord.In_App__c = true;
          npRecord.OwnerId = usr.Id;
      
      insert nprecord; 
	
      IDR_Notification_Preference__c record = [Select Id, User_Id__c From IDR_Notification_Preference__c Limit 1];
          
      System.assertEquals(usr.Id, record.User_Id__c );
      
      IDR_Notification_Preference__c npRecord2 = new IDR_Notification_Preference__c();
      npRecord2.Case_Flag__c = true;
      npRecord2.Email__c = false;
      npRecord2.In_App__c = true;
      npRecord2.OwnerId = usr.Id;
      try{
          insert nprecord2; 
      }catch(Exception e){
          System.assert(e.getMessage().contains('duplicate'));
      }
      
      }
  }

}