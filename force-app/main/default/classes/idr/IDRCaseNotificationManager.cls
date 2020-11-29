public with sharing class IDRCaseNotificationManager {
    
    public static void manageNotification(List<Case> records, Map<Id, Case> oldMap){
        
        List<IDRBankerNotificationWrapper> wrapperList = new List<IDRBankerNotificationWrapper>();
        List<Schema.FieldSetMember> fieldsList =  getFields();
        
        for(Integer i = 0 ; i < records.size(); i++){
            for(Schema.FieldSetMember f : fieldsList){
                String fieldName = f.getFieldPath();
                String fieldLabel = f.getLabel();
               if(oldMap.containsKey(records[i].Id)&& records[i].get(fieldName) !=  oldMap.get(records[i].Id).get(fieldName) && Userinfo.getUserId() != records[i].ownerId){
                     wrapperList.add(createNotification( fieldLabel, records[i] )) ;  
               }
            }
        }
        
        if(!wrapperList.isEmpty()){
           IDRBankerNotificationBuilder.sendNotification(wrapperList); 
        }
    }
    
    public static IDRBankerNotificationWrapper createNotification(String fieldLabel, Case c ){
        IDRBankerNotificationWrapper wrapper = new IDRBankerNotificationWrapper();
        wrapper.sfObject = c;
        wrapper.msgTitle = c.CaseNumber;
        wrapper.msgBody = 'Field '+ fieldLabel + ' has been changed';
        
        if(fieldLabel.equalsIgnoreCase('Owner ID')){
            wrapper.msgBody = 'Case '+ c.CaseNumber + ' has been assigned to you';
        }
        
        wrapper.relatedCaseRecord = c;
        wrapper.recipientList = new List<Id>{c.OwnerId};
        return wrapper;
    }
    
   public static List<Schema.FieldSetMember> getFields() 
    {
        return SObjectType.Case.FieldSets.IDR_Notification_Fields.getFields();
    }
	
}