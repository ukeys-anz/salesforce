/**
 * @author Afreen Khan
 * @since 10/2020
 * @description  IDRConstants consists of all the IDR constants
 * @group IDR(Internal Dispute Resolution)
 * @runTests ContentDocumentLinkTriggerHandlerTest
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
  public static final String RESOLVED_STATUS = 'Resolved';

  //Case Priority
  public static final String CASE_PRIORITY_STANDARD = 'Standard';

  //Customer Notification Template
  public static final String CUSTOMER_NOTIFICATION_TEMPLATE_ID = 'AgCaseRegister';

  //Banker and Manager Notification Template
  public static final String BANKER_EMAIL_NOTIFICATION_TEMPLATE = 'AgCaseAutoEsclate';
  public static final String MANAGER_EMAIL_NOTIFICATION_TEMPLATE = 'AgCaseManagerAutoEsclate';

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

  public static final Id CFAAS_FILE_RT_ID = Schema.SObjectType.ContentVersion.getRecordTypeInfosByDeveloperName()
    .get('CFaaS_File')
    .getRecordTypeId();

  /**
   * @description get Quality_Assessment__c.C_Q_Assessment record on demand
   */
  public static final Id idrtCQQualityAssessment {
    get {
      if (idrtCQQualityAssessment == null) {
        idrtCQQualityAssessment = Schema.SObjectType.Quality_Assessment__c.getRecordTypeInfosByDeveloperName()
          .get('C_Q_Assessment')
          .getRecordTypeId();
      }
      return idrtCQQualityAssessment;
    }
    private set;
  }

  /**
   * @description get Quality_Assessment__c.Call_Letter_Review_Assessment record on demand
   */
  public static final Id idrtCallLetterReviewQualityAssessment {
    get {
      if (idrtCallLetterReviewQualityAssessment == null) {
        idrtCallLetterReviewQualityAssessment = Schema.SObjectType.Quality_Assessment__c.getRecordTypeInfosByDeveloperName()
          .get('Call_Letter_Review_Assessment')
          .getRecordTypeId();
      }
      return idrtCallLetterReviewQualityAssessment;
    }
    private set;
  }

  //Complaint Status' for STOP collection
  public static final Set<String> STATUS_STOP_COLLECTIONS = new Set<String>{
    OPEN_STATUS,
    UNDER_INVESTIGATION_STATUS,
    ESCALATED_STATUS,
    REOPENED_STATUS
  };

  //Complaint Type and Subsequent Issue Type Set for collections
  public static final Set<String> ISSUE_TYPE_COLLECTIONS = new Set<String>{
    '4',
    '5',
    '17',
    '19'
  };

  public static final Set<String> FRAUD_SCAM_ISSUE_TYPE_COLLECTIONS = new Set<String>{
    'Fraud',
    'Scam'
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
    '42',
    '96',
    '97',
    '98'
  };

  //To auto assign cases checking for Subsequent Issue Type Set
  public static final Set<String> SUB_ISSUE_TYPE_HARDSHIP = new Set<String>{
    '20',
    '21',
    '22',
    '23',
    '96'
  };

  public static final Set<String> IDR_EARLY_RESOLUTION = new Set<String>{
    '8',
    'Email'
  };

  //NotificationHandler Status
  public static final String NOTIFICATION_PUBLISH_STATUS = 'Published';
  public static final String NOTIFICATION_PENDING_PUBLISH_STATUS = 'Pending Publish';
  public static final String NOTIFICATION_ERROR_PUBLISH_STATUS = 'Error while Publish';

  //Message Text
  public static final String RESTRICTED_ACTION_MESSAGE = 'You are not authorised to perform this action.';
  public static final String CANNOT_CHANGE_ISSUE_MESSAGE = 'You cannot change a collections issue to a non collections issue.';
  public static final String CANNOT_CHANGE_PRODUCT_MESSAGE = 'You cannot change this Product/Service name as collections activity has been stopped on account(s) for this product/service.';

  //Milestone Sla
  public static final String MILESTONE_SLA_NORMAL = 'Normal';
  public static final String MILESTONE_SLA_RED = '1 business day';
  public static final String MILESTONE_SLA_AMBER = '2 business days';
  public static final String MILESTONE_SLA_VIOLATED = 'Violated';
  public static final String COMPLAINTS_ENTITLMENT_ACCT = 'Complaint Entitlement Account';
  public static final String COMPLAINTS_ENTITLMENT_PROCESS = 'complaints';
  public static final String COMPLAINTS_ENTITLEMENT_NAME = 'Complaints Entitlement';

  //Field labels
  public static final String MILESTONE_SLA_FIELD_LABEL = 'Milestone Sla';
  public static final String CASE_OWNER_ID = 'Owner ID';

  //IDR Maximum time constants
  public static final String TASK_SUBJECT_DAY1 = 'IDR Response Due in 1-day';
  public static final String TASK_STANDARD_PRIORITY = 'Standard';
  public static final String TASK_STATUS_EXPIRED = 'Expired';
  public static final String TASK_STATUS_COMPLETED = 'Completed';
  public static final String MILESTONE_STANDARD = '30-day IDR Response Due';
  public static final String MILESTONE_PRIORITY = '21-day IDR Response Due';

  public static final String TASK_AFCA_SUBJECT_DAY1 = 'AFCA Response is due in 1 day';

  //Channel Received
  public static final String CHANNEL_RECEIVED_AFCA_REFERRED = '11';
  public static final String CHANNEL_RECEIVED_ANZ_COM = '8';

  //IDREmailServiceConstants
  public static final String CASE_NO_REGEX = '\\d{4,8}';
  public static final String CASE_EMAIL_REGEX = '(?<=\\<)(.*?)(?=\\>)';
  public static final String EMAIL_USER_FNAME = 'IDREmailService';

  //IDR Account number pattern
  public static final String MULTIPLE_ACCOUNT_NO_REGEX = '^[0-9]{6,42}(;[0-9]{6,42})*$';
  public static final String INVALID_ACC_NO_MESSAGE = 'Account numbers can not include any symbols or special characters. Only use a Semicolon to separate account numbers if more than 1 account';

  //Task fields Constants
  public static final String TASK_TYPE_PEND_CASE = 'Pend Case';
  public static final String SUBJECT_PEND_CASE_TASK = 'Case Pended - provide update in case comment';
  public static final String TASK_TYPE_SYSTEMIC_ISSUE = 'Systemic Issue';
  public static final String TASK_TYPE_COLLECTION = 'Collections';
  public static final String TASK_TYPE_COMPLIANTS_FLAG = 'Complaints Flag';
  public static final String TASK_TYPE_NOTIFICATION = 'Notification';
  public static final String TASK_CORRESPONDENCE_SUBJECT = 'New Correspondence received on a Closed Complaint added by';
  public static final String TASK_CORRESPONDENCE_DESCRIPTION = 'You must add a task comment detailing the action taken in your review of the new correspondence received on the closed complaint before marking this task as completed';
  public static final String TASK_QA_COMPLIANCE_SUBJECT = 'Review Required: Quality Assessment Completed for ';
  public static final String TASK_TM_ATTESTATION_SUBJECT = 'Team Manager Corrective Actions- Attestation- ';
  public static final String TASK_QA_CLOSE_ERROR = 'Cannot close a Compliance Task if the associated Quality Assessment doesn\'t have a Team Manager Response';
  public static final Id TASK_COMPLIANCE_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Compliance_Task')
    .getRecordTypeId();

  //QA Dispute Tasks Constants
  public static final String TEAM_MANAGER_REJECTION_RESPONSE = 'Rejected by TM';
  public static final String TM_REJECTS_CQ_MANAGER_RESPONSE = 'TM Rejects C&Q Manager\'s review';
  public static final String TM_REJECTS_CQ_REVIEW_TASK_SUBJECT = 'Team Manager has rejected review of ';
  public static final String TM_REJECTS_CQ_REVIEW_TASK_DESC = 'Please review the Quality Assessment and complete the C&Q Manager Response and C&Q Manager Comments fields on the Assessment Outcome tab.';
  public static final String CQ_MANAGER_REV_COMPLETED_TASK_SUBJECT = 'C&Q Manager review completed on ';
  public static final String CQ_MANAGER_REV_COMPLETED_TASK_DESC = 'Please review the Quality Assessment and complete the TM response to Q&C Manager review and TM Comments on C&Q Manager review on the Assessment Outcome tab.';
  public static final String TM_REJECTS_CQ_MANAGER_REV_TASK_SUBJECT = 'C&Q Manager review rejected on ';
  public static final String TM_REJECTS_CQ_MANAGER_REV_TASK_DESC = 'Please review the Quality Assessment and complete the C&Q Lead Response and C&Q Lead Comments fields on the Assessment Outcome tab.';
  public static final String CQ_LEAD_RESPONSE_TASK_SUBJECT = 'C&Q Lead review completed on ';
  public static final String CQ_LEAD_RESPONSE_TASK_DESC = 'Please review the comments left on the Assessment Outcome tab of the Quality Assessment';

  //Quality Assessment Constants
  public static final String CORRECTIVE_ACTIONS_NA = 'N/A- no action required';

  //Quality Assessment Fieldset Name
  public static final String CQ_EDITABLE_RESPONSE_FIELDS = 'CQAssessment_Editable_Response_Fields';

  //Migrated Document
  public static final String DELETION_NOT_ALLOWED = 'You may not delete CFMS migrated documents.';

  //Anz.com constants
  /**
   * @description Static variable to map anz.com field with case fields
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
          'Credit reporting' => '19',
          'Transactions & payments' => '10',
          'Fraud & Scams' => 'Fraud',
          'Fraud' => 'Fraud',
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

  /*
   *@description static variable to list all the priority issues for cases ingested through anz com
   */
  public static final List<String> ANZ_COM_PRIORITY_ISSUES = new List<String>{
    'Financial difficulty & hardship',
    'Collections',
    'Credit reporting',
    'Credit assessment'
  };

  /**
   * @description Static variable to list CMOS workbaskets' API names
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
          'IDR_Early_Resolution',
          'IDR_Early_Resolution_Unassisted_Channel',
          'CCR_Complaints',
          'Hardship_IDR_Letter',
          'IDR_ANZ_Plus',
          'EDR_Hardship',
          'EDR_Wealth',
          'IDR_Satellite',
          'IDR_Spare', //IDR Disputes
          'EDR_CM_Everyday_Banking_Wealth', // EDR Scams
          'IDR_Scams', // IDR Scams
          'IDR_Deceased_Estates'
        };
      }
      return workBasketNames;
    }
    set;
  }

  //CAP ID value on the customer identifier (IDR_Customer_Identifier__c) case field
  public static final String CUSTOMER_IDENTIFIER_CAP_ID = 'Customer/Business CAP ID';

  /**
   * @description Static values for 3rd party relationship to complainant
   */

  public static final String DEBT_MANAGEMENT_FIRM = '20';
  public static final String WEALTH_REPRESENTATIVE = '23';

  public static final List<String> COMPLAINANT_USE_FIRST_NAME = new List<String>{
    DEBT_MANAGEMENT_FIRM,
    WEALTH_REPRESENTATIVE
  };

  public static final Boolean DISABLE_OMNI_FOR_CMOS = IDR_Omni_Settings__c.getInstance(
      UserInfo.getUserId()
    )
    .Disable_CMOS_Omni__c;
  public static final String CUSTOMER_COMPLAINT_RT_NAME = 'Customer_Complaint';
  public static final String NON_CUSTOMER_COMPLAINT_RT_NAME = 'Non_Customer_Complaint';

  public static final List<String> IDR_PRIORITY_VALUES = new List<String>{
    'Standard',
    'Vulnerable Customer'
  };

  public static final List<String> IDR_ORIGIN_VALUES = new List<String>{
    '1',
    'Phone',
    '3',
    '4',
    '5',
    'Email',
    '6',
    '8',
    '9',
    '10',
    '11',
    'Chat',
    'ANZ Plus App',
    'ANZ Plus Web'
  };

  public static final List<String> IDR_TYPE_VALUES = new List<String>{
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '12',
    '13',
    'Fraud',
    'Scam',
    '15',
    '16',
    '17',
    '18',
    '19',
    '20',
    '21',
    'Chat',
    'ANZ Plus App',
    'Know Your Customer'
  };

  public static final List<String> IDR_ESCALATION_VALUES = new List<String>{
    '21',
    '22',
    '23',
    '24',
    '25',
    '26',
    '27',
    '28',
    '18'
  };

  public static final List<String> IDR_UNASSISTED_ISSUE_TYPE = new List<String>{
    '18',
    '13',
    '12',
    '15',
    '9',
    '10'
  };

  public static final List<String> IDR_UNASSISTED_SUB_ISSUE_TYPE = new List<String>{
    // Account Set-up & Maintenance
    '11', // Account/Profile set up
    '12', // Account/Profile Maintenance
    '63', // Statement Issue
    // Channel Accessibility
    '2', // Branch queues / wait time
    '3', // Call queues / wait time
    '4', // Trading hours/ location/ closures
    '5', // Design/ layout/ content
    '6', // System fault/ outage
    '9', // Digital
    'Not working on device',
    'No direct phone line',
    'Not enough stores',
    'Digital only service',
    // Organisational Structure & Marketing
    '54', // About ANZ organisational structure
    '55', // Media releases
    '56', // Marketing campaigns
    '10', // Other
    // Product Features, Offers, Sales
    '73', // Marketing contact not requested/ required
    // Service Quality
    '57', // Tone or manner of response
    '59', // Call transferred, disconnected or not returned
    '60', // Appointment not made/ upheld
    '62', // Failure to respond to customer request for info
    'Request won\'t be actioned',
    // Transactions & Payments
    '50' // Payment system fault/outage
  };
}
