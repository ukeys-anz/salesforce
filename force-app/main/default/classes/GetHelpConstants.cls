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

  public static final Id BPAY_DISPUTE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('BPAY_Dispute')
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

  public static final Id CUSTOMER_FEEDBACK_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Customer_Feedback')
    .getRecordTypeId();

  public static final Id FALSE_CUSTOMER_PROFILE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('False_Customer_Profile')
    .getRecordTypeId();

  //Hold the multi-party account's ownership value
  public static final String MULTI_PARTY = 'Multi-party';

  //Hold the joint account's ownership value
  public static final String JOINT = 'Joint';

  //Hold the single account's ownership value
  public static final String SINGLE = 'Single';

  //Hold the value of Transaction Initiator for joint account's secondary owner.
  public static final String CO_OWNER = 'Co-Owner';

  //Hold the value of Transaction Initiator for joint accounts not having persona id.
  public static final String THIS_CUSTOMER = 'This Customer';

  //API response of Transaction incoming
  public static final String TRANSFER_INCOMING = 'TRANSFER_INCOMING';

  //Financial Account Record types

  public static final String CHECKING_ACCOUNT_RT_APINAME = 'CheckingAccount';
  public static final Id CHECKING_ACCOUNT_RT_ID = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName()
    .get(GetHelpConstants.CHECKING_ACCOUNT_RT_APINAME)
    .getRecordTypeId();

  public static final String SAVINGS_ACCOUNT_RT_APINAME = 'SavingsAccount';
  public static final Id SAVINGS_ACCOUNT_RT_ID = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName()
    .get(GetHelpConstants.SAVINGS_ACCOUNT_RT_APINAME)
    .getRecordTypeId();

  public static final String BANK_ACCOUNT_RT_APINAME = 'BankingAccount';
  public static final Id BANK_ACCOUNT_RT_ID = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName()
    .get(GetHelpConstants.BANK_ACCOUNT_RT_APINAME)
    .getRecordTypeId();

  public static final String S2_ACCOUNT_MARKETING_CODE = 'SAVING02';

  //Financial Account marketing code values
  public static final List<String> ANZX_MARKETING_CODES = new List<String>{
    'TRANSACT01',
    'SAVING01',
    'SAVING02',
    'HLVAR01',
    'HLFXD01'
  };

  public static final List<String> HOME_LOAN_MARKETING_CODES = new List<String>{
    'HLVAR01',
    'HLFXD01'
  };

  //Quality Assessment - General RT Id
  public static final Id QUALITY_ASSESSMENT_GENERAL_RT_ID = Schema.SObjectType.Quality_Assessment__c.getRecordTypeInfosByDeveloperName()
    .get('General')
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
    .get('Compliance_Task')
    .getRecordTypeId();

  //Lead - ANZx RT Id
  public static final Id LEAD_ANZX_RT_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
    .get('ANZX_Leads')
    .getRecordTypeId();

  //Lead - ANZx RT Id
  public static final Id LEAD_GENERAL_RT_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
    .get('General')
    .getRecordTypeId();

  // Account - Person Account RT Id
  public static final Id ACCOUNT_PERSON_ACCOUNT_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('PersonAccount')
    .getRecordTypeId();

  // Case - Non Customer Complaint
  public static final Id NON_CUSTOMER_COMPLAINT_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Non_Customer_Complaint')
    .getRecordTypeId();

  // Case - Unauthenticated Enquiry RT Id
  public static final Id UNAUTHENTICATED_ENQUIRY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('General_Inquiry_CMOS')
    .getRecordTypeId();

  // Interaction - Appointment Interaction RT Id
  public static final Id INTERACTION_APPT_RT_ID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
    .get('Appointment')
    .getRecordTypeId();

  // Interaction - General Interaction RT Id
  public static final Id INTERACTION_GENERAL_RT_ID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
    .get('General')
    .getRecordTypeId();

  // Interaction - Store Interaction RT Id
  public static final Id INTERACTION_STORE_RT_ID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
    .get('Store')
    .getRecordTypeId();

  // Interaction - Message Interaction RT Id
  public static final Id INTERACTION_MESSAGE_RT_ID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
    .get('Message')
    .getRecordTypeId();

  // Interaction - CCRM Interaction RT Id
  public static final Id INTERACTION_CCRM_RT_ID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
    .get('CCRM_Interaction')
    .getRecordTypeId();

  // Interaction - Appointment Interaction RT Id
  public static final Id INTERACTION_ML_RT_ID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
    .get('ML_Interaction')
    .getRecordTypeId();

  // Case - Account Closure
  public static final Id ACCOUNT_CLOSURE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Account_Closure')
    .getRecordTypeId();

  // Case - Credit Referral
  public static final Id CREDIT_REFERRAL_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Credit_Referral')
    .getRecordTypeId();

  // Residential Loan App - Loan Application
  public static final Id LOAN_APPLICATION_RT_ID = Schema.SObjectType.ResidentialLoanApplication.getRecordTypeInfosByDeveloperName()
    .get('Loan_Application')
    .getRecordTypeId();

  //Residential Loan App Status : Cancelled
  public static final String RLA_STATUS_CANCELLED = 'STATE_CANCELLED';

  // Contact Relationship (FinServ__ContactContactRelation__c )
  public static final Id BROKER_STAFF_RT_ID = Schema.SObjectType.FinServ__ContactContactRelation__c.getRecordTypeInfosByDeveloperName()
    .get('Broker_Staff')
    .getRecordTypeId();
  // Customer Action - Pending Financial Account Updates
  public static final Id CUSTOMER_ACTION_FIN_ACCOUNT_UPDATE_RT_ID = Schema.SObjectType.Customer_Action__c.getRecordTypeInfosByDeveloperName()
    .get('Pending_Financial_Account_Updates')
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
  public static final String TRANSACTION_PENDING = 'PENDING';

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
  public static final String PROVISIONALLY_CLOSED_STATUS = 'Provisionally Closed';
  public static final String UNDER_INVESTIGATION_STATUS = 'Under Investigation';
  public static final String CLOSED_STATUS_EDUCATED = 'Closed - Customer Educated';
  public static final String CLOSED_STATUS_FUTURE_RELEASE = 'Closed - Future Release';
  public static final String CLOSED_STATUS_RESOLVED = 'Closed - Resolved';
  public static final String CLOSED_STATUS_NO_FIX = 'Closed - Won\'t Be Fixed';
  public static final String CUSTOMER_UPDATE_PENDING = 'Customer Update Pending';

  //ANZx Case Sub Status
  public static final String CLOSED_SUB_STATUS_NO_DEFECT = 'No Defect';
  public static final String CLOSED_SUB_STATUS_NO_LONGER_REQUIRED = 'No Longer Required';
  public static final String PROCESSING = 'Processing';
  public static final String FAILED = 'Failed';
  public static final String SUCCESS = 'Success';
  // Case Origins
  public static final String ANZ_PLUS_WEB_ORIGIN = 'ANZ Plus Web';
  // Case Origins for Self Service Dispute Cases
  public static final Set<String> SELF_SERVICE_ORIGIN = new Set<String>{
    'App',
    'ANZ Plus App'
  };
  // Permission Set Group Name
  public static final String BUSINESS_ADMIN_PSG = 'Business_Admin';

  // ANZX Case Type
  public static final String MANUAL_ADDRESS_UPDATE_TYPE = 'Manual Address Update';
  public static final String RESIDENTIAL_ADDRESS_QA = 'Residential Address QA';
  public static final String ACCOUNT_CLOSURE = 'Account Closure';

  // Dispute Business Hour Name
  public static final String ANZ_DISPUTE_BUSINESS_HOUR_NAME = 'ANZx Case Business Hours';

  // UUID Log Status
  public static final String IN_PROGRESS_STATUS = 'In Progress';

  // Task Record Type for Email Case
  public static final String TASK_EMAIL_RT = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Email_Task')
    .getRecordTypeId();

  // Task Record Type for Coach Nudge
  public static final String COACH_NUDGE_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Coach_Nudge')
    .getRecordTypeId();

  // Task Record Type for Callback Request
  public static final String CALLBACK_REQUEST_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Callback_Request')
    .getRecordTypeId();

  // Email Task Description
  public static final String TASK_EMAIL_DESCRIPTION = 'Please send the customer the relevant closure email(s)';

  // Basic Subscription Entitlment Process Name
  public static final String BASIC_SUBSCRIPTION_ENTITLEMENT_NAME = 'Basic Subscription';
  public static final String ANZ_PLUS_BASIC_SUBSCRIPTION_SLA_PROCESS_NAME = 'anz plus - basic subscription';
  public static final String COMPLAINTS_SLA_PROCESS_NAME = 'complaints';

  //Set of Interaction RecordTypeIds for Store, Call and Chat
  public static final Set<Id> STORE_CALL_MSG_INTERACTION_RECORTYPEIDS_SET = new Set<Id>{
    GetHelpConstants.INTERACTION_GENERAL_RT_ID,
    GetHelpConstants.INTERACTION_STORE_RT_ID,
    GetHelpConstants.INTERACTION_MESSAGE_RT_ID
  };

  /**
   * @return Boolean
   * @description Method to check if Transaction API has been updated to V1
   */
  public static Boolean isTransactionsV1() {
    return Label.TransactionAPIUpliftedToV1 == 'True';
  }

  /**
   * @return Boolean
   * @description Method to check if Account API has been updated to V1
   */
  public static Boolean isAccountV1() {
    return Label.AccountAPIUpliftedToV1 == 'True';
  }
  // String to formulate name of Store Interaction
  public static final String COACHING_LAB = 'Coaching Lab';
  // Set of transactions type where the default value of Transaction Made By should be blank (Transaction Made By this is a field and column on transaction record page)
  public static final Set<String> CARD_TRANSACTION_TYPES = new Set<String>{
    'CARD',
    'DEPOSIT_WITHDRAWAL'
  };

  public static final Map<String, String> COACH_NUDGE_TASK_STATUS = new Map<String, String>{
    'Actioned' => 'STATUS_ACTIONED',
    'Expired' => 'STATUS_EXPIRED'
  };

  /**
   * @description Fetch Coach Nudge and Callback Request record types
   * @return Set record type Ids
   */
  public static final Set<Id> taskRecordTypeIds {
    get {
      if (taskRecordTypeIds == null) {
        taskRecordTypeIds = new Set<Id>();
        taskRecordTypeIds.add(GetHelpConstants.COACH_NUDGE_RT_ID);
        taskRecordTypeIds.add(GetHelpConstants.CALLBACK_REQUEST_RT_ID);
      }
      return taskRecordTypeIds;
    }
    private set;
  }

  /**
   * @description fetch ANZx financial account record types
   * @return Set<String> financial account record types developer name
   */
  public static final Set<String> anzxFinancialAccountRecordTypes {
    get {
      if (anzxFinancialAccountRecordTypes == null) {
        anzxFinancialAccountRecordTypes = new Set<String>();
        anzxFinancialAccountRecordTypes.add(SAVINGS_ACCOUNT_RT_APINAME);
        anzxFinancialAccountRecordTypes.add(CHECKING_ACCOUNT_RT_APINAME);
      }
      return anzxFinancialAccountRecordTypes;
    }
    private set;
  }
}
