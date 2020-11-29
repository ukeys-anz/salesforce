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
        
         User usr = (User) FakerFactory.make(new FakerUserFactory());
	  usr.ProfileId = p.Id;
      usr.Business_Function__c = 'Test Business Function ';
      usr.Business_Role__c = 'Business Role';
      insert usr;
    }
    
    @isTest
    static void testManualNotification() {
        
        User usr = [Select id from User Limit 1];
        
        IDR_Notification_Preference__c npRecord = new IDR_Notification_Preference__c();
      npRecord.Case_Flag__c = true;
      npRecord.Email__c = false;
      npRecord.In_App__c = true;
          npRecord.OwnerId = usr.Id;
      
      insert nprecord; 
        
        System.runAs(usr){
         List<Case> caseToUpdate = [Select Id From Case]  ;
            for(Case c : caseToUpdate){
                c.OwnerId = usr.id;
            }    
            update caseToUpdate;
            
            for(Case c : [Select Id, IDR_Update_Notification_Flag__c From Case] ){
                System.assertEquals(true, c.IDR_Update_Notification_Flag__c);
            } 
        }  
    }
}