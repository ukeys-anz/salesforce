/**
 * @author Victor Wang
 * @since 08/2021
 * @description  GetHelpConstants consists of all the GetHelp constants
 */
public with sharing class GetHelpConstants {
  //Case - ANZx Dispute Case RT Ids
  public static final Id GENERAL_INQUIRY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('General_Inquiry')
    .getRecordTypeId();

  public static final Id ATM_DISPUTE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('ATM_Dispute')
    .getRecordTypeId();

  public static final Id CARD_DISPUTE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Card_Dispute')
    .getRecordTypeId();

  public static final Id DIRECT_DEBIT_DISPUTE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Direct_Debit_Dispute')
    .getRecordTypeId();

  public static final Id DIRECT_ENTRY_DISPUTE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Direct_Entry_Dispute')
    .getRecordTypeId();

  public static final Id NPP_DISPUTE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('NPP_Dispute')
    .getRecordTypeId();

  public static final Id COMPLAINT_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('ANZx_Complaint')
    .getRecordTypeId();

  //Case - ANZx Fraud Case RT Ids
  public static final Id FRAUD_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Fraud')
    .getRecordTypeId();

  public static final Id IDENTITY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Identity')
    .getRecordTypeId();

  public static final Id RECIPIENT_MULE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Recipient_Mule')
    .getRecordTypeId();

  public static final Id SCAM_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Scam')
    .getRecordTypeId();

  public static final Id KYCQA_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('KYC_QA')
    .getRecordTypeId();

  public static final Id BUG_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Bug_Enquiry')
    .getRecordTypeId();

  //Quality Assessment - General RT Id
  public static final Id QUALITY_ASSESSMENT_GENERAL_RT_ID = Schema.SObjectType.Quality_Assessment__c.getRecordTypeInfosByDeveloperName()
    .get('General')
    .getRecordTypeId();

  //Task - Compliance Task RT Id
  public static final Id TASK_COMPLIANCE_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Compliance_Task')
    .getRecordTypeId();

  //Lead - ANZx RT Id
  public static final Id LEAD_ANZX_RT_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
    .get('ANZX_Leads')
    .getRecordTypeId();

  // Account - Person Account RT Id
  public static final Id ACCOUNT_PERSON_ACCOUNT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('PersonAccount')
    .getRecordTypeId();

  public static final String CARD_DISPUTE_FRAUD_QUEUE = 'Card_Dispute_Fraud_Queue';
  public static final String CARD_DISPUTE_GENERAL_QUEUE = 'Card_Dispute_General_Queue';
  public static final String DIGITAL_FRAUD_QUEUE = 'Digital_Fraud_Queue';
  public static final String SUPPORT_COACH_QUEUE = 'Support_Coach_Queue';
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
}
