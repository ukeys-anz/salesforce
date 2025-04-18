/**
 * @author Shivam Swaraj
 * @since Oct 2024
 * @description  Wrapper class to create Customer Nudge Task and Notification Data
 */
public with sharing class PushToAppWrapper {

    /**
    * @description Wrapper Class for Notification Data Creation for Customer Nudge Task Record.
    * @name NotificationDataWrapper
    */
    public class NotificationDataWrapper {
        /**
        * @description AEM_Content_Data__c from the AEM Fragement after removing merge fields
        */
        @AuraEnabled
        public String aemContentData { get; set; }

    }

    /**
    * @description Wrapper Class for Customer Nudge Task Record.
    * @name PushToAppTaskWrapper
    */
    public class PushToAppTaskWrapper {
        /**
        * @description Subject of the Task from Title of the AEM Fragement
        */
        @AuraEnabled
        public String subject { get; set; }
        /**
         * @description ActivityDate from PushTaskToApp LWC
         */
        @AuraEnabled
        public String activityDate { get; set; }
        /**
         * @description Description of the Task shown in Notification Preview
         */
        @AuraEnabled
        public String description { get; set; }
        /**
         * @description Customer_Task_Configuration__c selected by the coach
         */
        @AuraEnabled
        public String notificationConfigId { get; set; }
        /**
         * @description SObject record Id from where the action called out
         */
        @AuraEnabled
        public String whatId { get; set; }
        /**
         * @description Available actions from AEM fragment
         */
        @AuraEnabled
        public String callToAction { get; set; }
    }
}