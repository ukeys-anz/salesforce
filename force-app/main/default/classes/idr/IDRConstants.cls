/**
 * @author Afreen Khan
 * @since 10/2020
 * @description  IDRConstants consists of all the IDR constants
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDRConstants {
  //Complaint Status
  public static final String OPEN_STATUS = 'Open';
  public static final String UNDER_INVESTIGATION_STATUS = 'Under Investigation';
  public static final String ESCALATED_STATUS = 'Escalated';
  public static final String REOPENED_STATUS = 'Re-opened';
  public static final String PROVISIONALLY_CLOSED_STATUS = 'Provisionally Closed';
  public static final String CLOSED_STATUS = 'Closed';
  public static final String WITHDRAWN_STATUS = 'Withdrawn';

  //Case Priority
  public static final String CASE_PRIORITY_STANDARD = 'Standard';

  //Customer Notification Template
  public static final String CUSTOMER_NOTIFICATION_TEMPLATE_ID = 'AgCaseRegister';

  //Banker Notification Template
  public static final String BANKER_EMAIL_NOTIFICATION_TEMPLATE = 'AgCaseAutoEsclate';

  public static final String QUEUE_TYPE = 'Queue';

  //CMOS Case record type Ids
  public static final Id CUSTOMER_COMPLAINT_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Customer_Complaint')
    .getRecordTypeId();
  public static final Id NON_CUSTOMER_COMPLAINT_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Non_Customer_Complaint')
    .getRecordTypeId();
  public static final Id GENERAL_INQUIRY_CMOS_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('General_Inquiry_CMOS')
    .getRecordTypeId();
  public static final Id SI_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Systemic_Issue')
    .getRecordTypeId();
  public static final Id CFMS_MIGRATED_CASE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('CFMS_Migrated_Case')
    .getRecordTypeId();

  //CMOS ContentVersion record type Ids
  public static final Id EMAIL_ATTACHMENT_RT_ID = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
    .get('IDR_Attachment')
    .getRecordTypeId();
  public static final Id COMPLAINT_FILE_RT_ID = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
    .get('IDR_File')
    .getRecordTypeId();

  //AR&C products record type Id
  public static final Id ANZ_PRODUCT_RT_ID = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
    .get('ANZ_Product_or_Service')
    .getRecordTypeId();

  //CMOS Task record type Ids
  public static final Id IDR_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('IDR_Task')
    .getRecordTypeId();
  public static final Id IDR_SYSTEM_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('IDR_System_Task')
    .getRecordTypeId();
  public static final Id SI_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Systemic_Issue_Task')
    .getRecordTypeId();

  //Complaint Type and Subsequent Issue Type Set for collections
  public static final Set<String> ISSUE_TYPE_COLLECTIONS = new Set<String>{
    '4',
    '5',
    '17',
    '19'
  };

  public static final Set<String> SUB_ISSUE_TYPE_COLLECTIONS = new Set<String>{
    '20',
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '38',
    '42'
  };

  //NotificationHandler Status
  public static final String NOTIFICATION_PUBLISH_STATUS = 'Published';
  public static final String NOTIFICATION_PENDING_PUBLISH_STATUS = 'Pending Publish';
  public static final String NOTIFICATION_ERROR_PUBLISH_STATUS = 'Error while Publish';

  //Message Text
  public static final String RESTRICTED_ACTION_MESSAGE = 'You are not authorised to perform this action.';

  //Milestone Sla
  public static final String MILESTONE_SLA_NORMAL = 'Normal';
  public static final String MILESTONE_SLA_RED = '1 business day';
  public static final String MILESTONE_SLA_AMBER = '2 business days';
  public static final string MILESTONE_SLA_VIOLATED = 'Violated';
  public static final string COMPLAINTS_ENTITLMENT_ACCT = 'Complaint Entitlement Account';
  public static final string COMPLAINTS_ENTITLMENT_PROCESS = 'complaints';
  public static final string COMPLAINTS_ENTITLEMENT_NAME = 'Complaints Entitlement';

  //Field labels
  public static final String MILESTONE_SLA_FIELD_LABEL = 'Milestone Sla';
  public static final String CASE_OWNER_ID = 'Owner ID';

  //IDR Maximum time constants
  public static final string TASK_SUBJECT_DAY5 = 'IDR Response due in 5-days';
  public static final string TASK_SUBJECT_DAY1 = 'IDR Response Due in 1-day';
  public static final string TASK_STANDARD_PRIORITY = 'Standard';
  public static final string TASK_STATUS_EXPIRED = 'Expired';
  public static final string TASK_STATUS_COMPLETED = 'Completed';
  public static final string MILESTONE_STANDARD = '30-day IDR Response Due';
  public static final string MILESTONE_PRIORITY = '21-day IDR Response Due';

  //Channel Recieved
  public static final string CHANNEL_RECEIVED_AFCA_REFERRED = '11';

  //IDREmailServiceConstants
  public static final String CASE_NO_REGEX = '\\d{4,8}';
  public static final String CASE_EMAIL_REGEX = '(?<=\\<)(.*?)(?=\\>)';

  //IDR Account number pattern
  public static final String MULTIPLE_ACCOUNT_NO_REGEX = '^[0-9]{6,42}(;[0-9]{6,42})*$';
  public static final String INVALID_ACC_NO_MESSAGE = 'Account numbers can not include any symbols or special characters. Only use a Semicolon to separate account numbers if more than 1 account';

  //Task fields Constants
  public static final String TASK_TYPE_PEND_CASE = 'Pend Case';
  public static final String SUBJECT_PEND_CASE_TASK = 'Case Pended - provide update in case comment';
  public static final String TASK_TYPE_SYSTEMIC_ISSUE = 'Systemic Issue';

  //Migrated Document
  public static final String DELETION_NOT_ALLOWED = 'You may not delete CFMS migrated documents.';

  //Anz.com constants
  /**
   * @description Static variable to map anz.com field with case fields
   * @return anzComFieldMapping map of anz.com field with case fields
   */
  public static final Map<String, String> anzComFieldMapping {
    get {
      if (anzComFieldMapping == null) {
        anzComFieldMapping = new Map<String, String>{
          'Product Category' => 'IDR_Product_Category__c',
          'Issue Type' => 'Type',
          'Description of Issue' => 'Description',
          'Customer Desired Outcome' => 'IDR_Complainant_Desired_Outcome__c',
          'Existing ANZ Customer' => 'IDR_Existing_ANZ_Customer__c',
          'First Name' => 'IDR_NC_First_Name__c',
          'Last Name' => 'IDR_NC_Last_Name__c',
          'Street Address' => 'IDR_NC_Street__c',
          'Suburb' => 'IDR_NC_Suburb__c',
          'Postcode' => 'IDR_NC_Postcode__c',
          'Country' => 'IDR_NC_Country__c',
          'Phone' => 'IDR_NC_Phone__c',
          'Email' => 'IDR_NC_Email__c'
        };
      }
      return anzComFieldMapping;
    }
    set;
  }

  /**

* @description Static variable to map anz.com Issue type field with case type field

* @return anzComIssueTypeMapping map of anz.com Issue type field with case type field

*/

  public static final Map<String, String> anzComIssueTypeMapping {
    get {
      if (anzComIssueTypeMapping == null) {
        anzComIssueTypeMapping = new Map<String, String>{
          'Service quality' => '9',
          'Channel accessibility' => '13',
          'Account set-up & maintenance' => '18',
          'Fees, interest, rewards' => '2',
          'Financial difficulty & hardship' => '4',
          'Collections' => '17',
          'Lending fulfilment' => '6',
          'Product features, offers, sales' => '15',
          'Closure process' => '16',
          'Credit assessment' => '5',
          'Credit reporting' => '16',
          'Transactions & payments' => '10',
          'Fraud & Scams' => '14',
          'Transaction Disputes' => '20',
          'Privacy and Confidentiality' => '8',
          'Advice' => '1',
          'Insurance Claims' => '7',
          'Disclosure' => '3',
          'Organisational Structure & Marketing ' => '12',
          'Remediation' => '21',
          'Other' => '11'
        };
      }

      return anzComIssueTypeMapping;
    }
    set;
  }

  /**
   * @description Static variable to list CMOS workbaskets' API names
   * @return List CMOS workbaskets' API names
   */
  @TestVisible
  public static final List<String> workBasketNames {
    get {
      if (workBasketNames == null) {
        workBasketNames = new List<String>{
          'Specialised_Early_Resolution_Hardship',
          'Specialised_EarlyRes_Responsible_Lending',
          'EDR_Early_Resolution',
          'IDR_Hardship',
          'IDR_Responsible_Lending',
          'IDR_CEO',
          'IDR_Business_Owners',
          'IDR_Everyday_Banking',
          'IDR_Home_Owners',
          'IDR_Wealth',
          'IDR_Early_Resolution'
        };
      }
      return workBasketNames;
    }
    set;
  }

  //Anz.com constants
  /**
   * @description Static variable to map xpression Template name
   * @return xpressiontemplateName map of xpression template name
   */
  public static final Map<String, String> xpressiontemplateName {
    get {
      if (xpressiontemplateName == null) {
        xpressiontemplateName = new Map<String, String>{
          'Declined Application Letter' => 'Declined_Application_Letter',
          '21 Day Letter' => '21_DAY_LETTER'
        };
      }
      return xpressiontemplateName;
    }
    set;
  }
}
