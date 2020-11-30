
/**
 *
 * @author Afreen
 * @since 11/2020
 * @description Builds and send the  Banker Notification as per their preference.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity')
public with sharing class IDRBankerNotificationBuilder {
    public static Map<Id ,UserPreference> userPreferenceMap;
    public static List<Case> updateCaseFlagList;
    
    /**
   * @description prepare the notification based on preference and sends to appropriate chnnel
   * @param wrapperList List of wrapper class which holds the notification details
   */
    @SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
    public static void sendNotification(List<IDRBankerNotificationWrapper> wrapperList){
        CustomNotificationType type = new CustomNotificationType();

        if(Schema.sObjectType.CustomNotificationType.isQueryable()){
            type = [SELECT Id FROM CustomNotificationType WHERE DeveloperName = 'IDR_Banker_Notification'];
        }
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
                sendInAppNotification(wrapperRecord, type.Id, inAppRecipientIds);
            }
            
            if(!caseFlagrecipients.isEmpty()){
                caseUpdateFlag(wrapperRecord.relatedCaseRecord);
                
            }

        }
        
        if(!updateCaseFlagList.isEmpty() && Schema.sObjectType.Case.isUpdateable()){
            update updateCaseFlagList;
        }
        
    }
    

     /**
   * @description Send the in app notification
   * @param wrapperRecord wrapper reccord 
   * @param notificationTypeId Id of the IDR Banker Notification Type
   * @param recipientIds Users ids to recieve this notification
   */
    public static void sendInAppNotification(IDRBankerNotificationWrapper wrapperRecord, String notificationTypeId, Set<String> recipientIds  ){
		Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setBody(wrapperRecord.msgBody);
        notification.setTitle(wrapperRecord.msgTitle);
        notification.setNotificationTypeId(notificationTypeId);
        notification.setTargetId(wrapperRecord.sfObject.Id); // target object id
        notification.send(recipientIds);  
    } 
    
    /**
   * @description Update the case flag
   * @param c case to be updated
   */
    public static void caseUpdateFlag(Case c){
        Case cas = new Case(Id = c.Id);
        cas.IDR_Update_Notification_Flag__c  = true;
        updateCaseFlagList.add(cas);
    }
    
     /**
   * @description builds a map of user and their notification preference
   * @param wrapperList List of wrapper class which holds the notification details
   */
    Public static void  populateUserPreference(List<IDRBankerNotificationWrapper> wrapperList){
        Set<Id> userIds = new Set<Id>();
        userPreferenceMap = new Map<Id, UserPreference>();
        List<IDR_Notification_Preference__c> nPreference = new  List<IDR_Notification_Preference__c>();
        
        for(IDRBankerNotificationWrapper wrapperRecord : wrapperList){
            userIds.addAll(wrapperRecord.recipientList);
        }
        if(Schema.sObjectType.IDR_Notification_Preference__c.isQueryable()){
            nPreference= [Select Id, Email__c, In_App__c, Case_Flag__c, User_Id__c From IDR_Notification_Preference__c where User_Id__c in : userIds ];
        }
        

        for(IDR_Notification_Preference__c userPref : nPreference){
            UserPreference up = new UserPreference();
            up.userId 	= userPref.User_Id__c;
            up.email	= userPref.Email__c;
            up.caseFlag	= userPref.In_App__c;
            up.inApp 	= userPref.Case_Flag__c;
            
            userPreferenceMap.put(userPref.User_Id__c, up);
        }
    }
    
    /**
   * @description Wrapper class to hold the user preference
   */
    public class UserPreference{
        public String userId;
        public Boolean email;
        public Boolean caseFlag;
        public Boolean inApp;
    }
}