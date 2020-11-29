public with sharing class IDRBankerNotificationBuilder {
    public static Map<Id ,UserPreference> userPreferenceMap;
    public static List<Case> updateCaseFlagList;
    
    
    public static void sendNotification(List<IDRBankerNotificationWrapper> wrapperList){
        CustomNotificationType type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'IDR_Banker_Notification'];
		updateCaseFlagList = new List<Case>();
        
        populateUserPreference(wrapperList);
        
        for(IDRBankerNotificationWrapper wrapperRecord : wrapperList){
            Set<String> inAppRecipientIds = new Set<String>();
            Set<String> emailrecipients = new Set<String>();
            Set<String> caseFlagrecipients = new Set<String>();

            for(Id recipient : wrapperRecord.recipientList){
                if(userPreferenceMap.containsKey(recipient)){
                    if(userPreferenceMap.get(recipient).inApp){
                    	inAppRecipientIds.add(recipient);
                    }
                    if(userPreferenceMap.get(recipient).email){
                        emailrecipients.add(recipient);
                    } 
                    if(userPreferenceMap.get(recipient).caseFlag){
                        caseFlagrecipients.add(recipient);
                    } 
                }else{
                    inAppRecipientIds.add(recipient);
                }
                
            }
            
            if(!inAppRecipientIds.isEmpty()){
                sendInAppNotification(wrapperRecord.sfObject, wrapperRecord.msgBody, wrapperRecord.msgTitle, type.Id, inAppRecipientIds);
            }
            
            if(!caseFlagrecipients.isEmpty()){
                caseUpdateFlag(wrapperRecord.relatedCaseRecord);
                
            }

        }
        
        if(!updateCaseFlagList.isEmpty()){
            update updateCaseFlagList;
        }
        
    }
    
    public static void sendInAppNotification(SObject objectAbstract , String msgBody, String msgTitle, String notificationTypeId, Set<String> recipientIds  ){
		Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setBody(msgBody);
        notification.setTitle(msgTitle);
        notification.setNotificationTypeId(notificationTypeId);
        notification.setTargetId(objectAbstract.Id); // target object id
        notification.send(recipientIds);  
    } 
    
    public static void caseUpdateFlag(Case c){
        System.debug('true;');
        Case cas = new Case(Id = c.Id);
        cas.IDR_Update_Notification_Flag__c  = true;
        updateCaseFlagList.add(cas);
    }
    
    Public static void  populateUserPreference(List<IDRBankerNotificationWrapper> wrapperList){
        Set<Id> userIds = new Set<Id>();
        userPreferenceMap = new Map<Id, UserPreference>();
        
        for(IDRBankerNotificationWrapper wrapperRecord : wrapperList){
            /*for(User recipient : wrapperRecord.recipientList){
                userIds.add(recipient.Id);
            }*/
            userIds.addAll(wrapperRecord.recipientList);
        }
        
       List<IDR_Notification_Preference__c> nPreference= [Select Id, Email__c, In_App__c, Case_Flag__c, User_Id__c From IDR_Notification_Preference__c where User_Id__c in : userIds ];

        for(IDR_Notification_Preference__c userPref : nPreference){
            UserPreference up = new UserPreference();
            up.userId 	= userPref.User_Id__c;
            up.email	= userPref.Email__c;
            up.caseFlag	= userPref.In_App__c;
            up.inApp 	= userPref.Case_Flag__c;
            
            userPreferenceMap.put(userPref.User_Id__c, up);
        }
    }
    
    
    public class UserPreference{
        public String userId;
        public Boolean email;
        public Boolean caseFlag;
        public Boolean inApp;
    }
}