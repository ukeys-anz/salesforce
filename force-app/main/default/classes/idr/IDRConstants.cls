/**
 * @author Afreen Khan
 * @since 10/2020
 * @description  IDRConstants consists of all the IDR constants
 */
public with sharing class IDRConstants {
  //Complaint Status
  public static final String OPEN_STATUS = 'Open';
  public static final String UNDER_INVESTIGATION_STATUS = 'Under Investigation';
  public static final String ESCALATED_STATUS = 'Escalated';
  public static final String REOPENED_STATUS = 'Re-opened';
  public static final String CLOSED_STATUS = 'Closed';
  public static final String RESOLVED_STATUS = 'Resolved';
  public static final String WITHDRAWN_STATUS = 'Withdrawn';

  //Complaint, Non- Complaint, General Inquiry Case Record Type
  public static final Id CUSTOMER_COMPLAINT_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Customer_Complaint')
    .getRecordTypeId();
  public static final Id NON_CUSTOMER_COMPLAINT_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Non_Customer_Complaint')
    .getRecordTypeId();
  public static final Id GENERAL_INQUIRY_CMOS_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('General_Inquiry_CMOS')
    .getRecordTypeId();

  //IDR collections task record type
  public static final Id IDR_COLLECTIONS_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('IDR_Collections')
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
  public static final string CHANNEL_RECEIVED_AFCA_REFERRED = 'Referred from AFCA';

  //Anz.com constants
  /**
   * @description Static variable to map anz.com field with case fields
   * @return anzComFieldMapping map of anz.com field with case fields
   */
  public static final Map<String, String> anzComFieldMapping {
    get {
      if (anzComFieldMapping == null) {
        anzComFieldMapping = new Map<String, String>{
          'This feedback is a' => 'IDR_Feedback_Category__c',
          'Previously raised?' => 'IDR_Previously_raised_with_ANZ__c',
          'Which product' => 'IDR_Product_Category__c',
          'Feedback topic' => 'Type',
          'Feedback summary' => 'Description',
          'Details and outcome' => 'IDR_Complainant_Desired_Outcome__c',
          'ANZ Customer?' => 'IDR_Existing_ANZ_Customer__c',
          'First name' => 'IDR_NC_First_Name__c',
          'Last name' => 'IDR_NC_Last_Name__c',
          'Contact number' => 'IDR_NC_Phone__c',
          'Email address' => 'IDR_NC_Email__c',
          'Street address' => 'IDR_NC_Street__c',
          'Suburb' => 'IDR_NC_Suburb__c',
          'Postcode' => 'IDR_NC_Postcode__c',
          'Country' => 'IDR_NC_Country__c'
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
          'Account set up/Maitenence/Closure' => 'Account set-up & maintenance',
          'Branch/Merchant/System issue' => 'Channel accessibility',
          'Collections' => 'Collections',
          'Credit card/Loan assessment' => 'Credit assessment',
          'Fees/Interest/Rewards' => 'Fees, interest, rewards',
          'Fraud/Dispute' => 'Transaction Disputes',
          'Hardship' => 'Financial difficulty & hardship',
          'Loan settlement/Drawdown' => 'Lending fulfilment',
          'Payments' => 'Transactions & payments',
          'Product features/Marketing/Sales' => 'Product features, offers, sales',
          'Service Quality' => 'Service quality',
          'Other' => 'Other'
        };
      }
      return anzComIssueTypeMapping;
    }
    set;
  }

  /**
   * @description Static variable to map anz.com Issue type field with case type field
   * @return anzComIssueTypeMapping map of anz.com Issue type field with case type field
   */
  public static final List<String> workBasketNames {
    get {
      if (workBasketNames == null) {
        workBasketNames = new List<String>{
          'Specialised_Early_Resolution_Hardship',
          'Specialised_EarlyRes_Responsible_Lending',
          'EDR_Early_Resolution'
        };
      }
      return workBasketNames;
    }
    set;
  }
}
