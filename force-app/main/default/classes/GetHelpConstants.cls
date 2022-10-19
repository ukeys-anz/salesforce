/**
 * @author Victor Wang
 * @since 08/2021
 * @description  GetHelpConstants consists of all the GetHelp constants
 */
public with sharing class GetHelpConstants {
  //Case - RTs
  public static final String GENERAL_INQUIRY_RT = 'General_Inquiry';
  public static final String ATM_DISPUTE_RT = 'ATM_Dispute';
  public static final String CARD_DISPUTE_RT = 'Card_Dispute';
  public static final String DIRECT_DEBIT_DISPUTE_RT = 'Direct_Debit_Dispute';
  public static final String DIRECT_ENTRY_DISPUTE_RT = 'Direct_Entry_Dispute';
  public static final String NPP_DISPUTE_RT = 'NPP_Dispute';
  public static final String COMPLAINT_RT = 'ANZx_Complaint';
  public static final String FRAUD_RT = 'Fraud';
  public static final String IDENTITY_RT = 'Identity';
  public static final String RECIPIENT_MULE_RT = 'Recipient_Mule';
  public static final String SCAM_RT = 'Scam';
  public static final String KYCQA_RT = 'KYC_QA';
  public static final String BUG_RT = 'Bug_Enquiry';
  public static final String CUSTOMER_FEEDBACK_RT = 'Customer_Feedback';
  public static final String QUALITY_ASSESSMENT_GENERAL_RT = 'General';
  public static final String TASK_COMPLIANCE_RT = 'Compliance_Task';
  public static final String LEAD_ANZX_RT = 'ANZX_Leads';
  public static final String ACCOUNT_PERSON_ACCOUNT_RT = 'PersonAccount';
  public static final String NON_CUSTOMER_COMPLAINT_RT = 'Non_Customer_Complaint';
  public static final String UNAUTHENTICATED_ENQUIRY_RT = 'General_Inquiry_CMOS';
  public static final String CUSTOMER_COMPLAINT_RT = 'Customer_Complaint';

  //Case - ANZx Dispute Case RT Ids
  public static final Id GENERAL_INQUIRY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(GENERAL_INQUIRY_RT)
    .getRecordTypeId();

  public static final Id ATM_DISPUTE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(ATM_DISPUTE_RT)
    .getRecordTypeId();

  public static final Id CARD_DISPUTE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(CARD_DISPUTE_RT)
    .getRecordTypeId();

  public static final Id DIRECT_DEBIT_DISPUTE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(DIRECT_DEBIT_DISPUTE_RT)
    .getRecordTypeId();

  public static final Id DIRECT_ENTRY_DISPUTE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(DIRECT_ENTRY_DISPUTE_RT)
    .getRecordTypeId();

  public static final Id NPP_DISPUTE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(NPP_DISPUTE_RT)
    .getRecordTypeId();

  public static final Id BPAY_DISPUTE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('BPAY_Dispute')
    .getRecordTypeId();

  public static final Id COMPLAINT_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(COMPLAINT_RT)
    .getRecordTypeId();

  //Case - ANZx Fraud Case RT Ids
  public static final Id FRAUD_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(FRAUD_RT)
    .getRecordTypeId();

  public static final Id IDENTITY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(IDENTITY_RT)
    .getRecordTypeId();

  public static final Id RECIPIENT_MULE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(RECIPIENT_MULE_RT)
    .getRecordTypeId();

  public static final Id SCAM_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(SCAM_RT)
    .getRecordTypeId();

  public static final Id KYCQA_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(KYCQA_RT)
    .getRecordTypeId();

  public static final Id BUG_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(BUG_RT)
    .getRecordTypeId();

  public static final Id CUSTOMER_FEEDBACK_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(CUSTOMER_FEEDBACK_RT)
    .getRecordTypeId();

  //Quality Assessment - General RT Id
  public static final Id QUALITY_ASSESSMENT_GENERAL_RT_ID = Schema.SObjectType.Quality_Assessment__c.getRecordTypeInfosByDeveloperName()
    .get(QUALITY_ASSESSMENT_GENERAL_RT)
    .getRecordTypeId();

  //Quality Assessment - Join RT Id
  public static final Id QUALITY_ASSESSMENT_JOIN_RT_ID = Schema.SObjectType.Quality_Assessment__c.getRecordTypeInfosByDeveloperName()
    .get('Join')
    .getRecordTypeId();

  //Quality Assessment - Get_Help RT Id
  public static final Id QUALITY_ASSESSMENT_GETHELP_RT_ID = Schema.SObjectType.Quality_Assessment__c.getRecordTypeInfosByDeveloperName()
    .get('Get_Help')
    .getRecordTypeId();

  //Task - Compliance Task RT Id
  public static final Id TASK_COMPLIANCE_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get(TASK_COMPLIANCE_RT)
    .getRecordTypeId();

  //Lead - ANZx RT Id
  public static final Id LEAD_ANZX_RT_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
    .get(LEAD_ANZX_RT)
    .getRecordTypeId();

  //Lead - ANZx RT Id
  public static final Id LEAD_GENERAL_RT_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
    .get('General')
    .getRecordTypeId();

  // Account - Person Account RT Id
  public static final Id ACCOUNT_PERSON_ACCOUNT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get(ACCOUNT_PERSON_ACCOUNT_RT)
    .getRecordTypeId();

  // Case - Non Customer Complaint
  public static final Id NON_CUSTOMER_COMPLAINT_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(NON_CUSTOMER_COMPLAINT_RT)
    .getRecordTypeId();

  // Case - Unauthenticated Enquiry RT Id
  public static final Id UNAUTHENTICATED_ENQUIRY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get(UNAUTHENTICATED_ENQUIRY_RT)
    .getRecordTypeId();

  // Interaction - Appointment Interaction RT Id
  public static final Id INTERACTION_APPT_RT_ID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
    .get('Appointment')
    .getRecordTypeId();

  // Interaction - General Interaction RT Id
  public static final Id INTERACTION_GENERAL_RT_ID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
    .get('General')
    .getRecordTypeId();

  // Case - Account Closure
  public static final Id ACCOUNT_CLOSURE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Account_Closure')
    .getRecordTypeId();

  public static final String CARD_DISPUTE_FRAUD_QUEUE = 'Card_Dispute_Fraud_Queue';
  public static final String CARD_DISPUTE_GENERAL_QUEUE = 'Card_Dispute_General_Queue';
  public static final String DIGITAL_FRAUD_QUEUE = 'Digital_Fraud_Queue';
  public static final String SUPPORT_COACH_QUEUE = 'Support_Coach_Queue';
  public static final String COACH_QUEUE = 'Coach_Queue';
  public static final String PENDING_CARD_DISPUTE_FRAUD_QUEUE = 'Pending_Card_Dispute_Fraud_Queue';
  public static final String PENDING_CARD_DISPUTE_GENERAL_QUEUE = 'Pending_Card_Dispute_General_Queue';
  public static final String TRANSACTION_STATUS_PENDING = 'TRANSACTION_STATUS_PENDING';
  public static final String TRANSACTION_STATUS_POSTED = 'TRANSACTION_STATUS_POSTED';

  /**
   * @description Static variable to list ANZX workbaskets' API names
   * @return List ANZX workbaskets' API names
   */
  public static final List<String> workBasketNames {
    get {
      if (workBasketNames == null) {
        workBasketNames = new List<String>{
          CARD_DISPUTE_FRAUD_QUEUE,
          CARD_DISPUTE_GENERAL_QUEUE,
          SUPPORT_COACH_QUEUE,
          DIGITAL_FRAUD_QUEUE,
          PENDING_CARD_DISPUTE_FRAUD_QUEUE,
          PENDING_CARD_DISPUTE_GENERAL_QUEUE
        };
      }
      return workBasketNames;
    }
    set;
  }

  //ANZx Case Status
  public static final String OPEN_STATUS = 'Open';
  public static final String CLOSED_STATUS = 'Closed';
  public static final String RESOLVED_STATUS = 'Resolved';
  public static final String WITHDRAWN_STATUS = 'Withdrawn';
  public static final String ESCALATED_STATUS = 'Escalated';
  public static final String UNDER_INVESTIGATION_STATUS = 'Under Investigation';
  public static final String CLOSED_STATUS_EDUCATED = 'Closed - Customer Educated';
  public static final String CLOSED_STATUS_FUTURE_RELEASE = 'Closed - Future Release';
  public static final String CLOSED_STATUS_RESOLVED = 'Closed - Resolved';
  public static final String CLOSED_STATUS_NO_FIX = 'Closed - Won\'t Be Fixed';

  //ANZx Case Sub Status
  public static final String CLOSED_SUB_STATUS_NO_DEFECT = 'No Defect';
  // Case Origins
  public static final String ANZ_PLUS_WEB_ORIGIN = 'ANZ Plus Web';
}
