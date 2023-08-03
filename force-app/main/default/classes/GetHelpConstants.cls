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

  public static final Id KYCQA_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('KYC_QA')
    .getRecordTypeId();

  public static final Id CUSTOMER_FEEDBACK_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Customer_Feedback')
    .getRecordTypeId();

  public static final Id ID_OPS_ASSISTANCE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('ID_Ops_Assistance')
    .getRecordTypeId();

  public static final Id FRAUD_CHECK_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('Fraud_Check')
    .getRecordTypeId();

  public static final Id FALSE_CUSTOMER_PROFILE_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('False_Customer_Profile')
    .getRecordTypeId();

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

  //Financial Account marketing code values
  public static final List<String> ANZX_MARKETING_CODES = new List<String>{
    'TRANSACT01',
    'SAVING01',
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
  public static final String COB_DAON_FAILED_STATUS = 'Daon Fallout';
  public static final String COB_ID_OPS_DAON_APPROVED_STATUS = 'ID Ops: Daon OK';
  public static final String COB_FRAUD_CHECK_DAON_APPROVED_STATUS = 'Fraud Check: Daon OK';
  public static final String COB_EQUIFAX_FAILED_STATUS = 'Equifax Fallout';
  public static final String COB_EQUIFAX_PASSED_STATUS = 'ID Check OK';
  public static final String COB_FAILED_OK_STATUS = 'Failed';
  public static final String COB_POTENTIAL_FRAUD_STATUS = 'Potential Fraud';
  public static final String COB_CONFIRMED_FRAUD_STATUS = 'Confirmed Fraud';

  //ANZx Case Sub Status
  public static final String CLOSED_SUB_STATUS_NO_DEFECT = 'No Defect';
  // Case Origins
  public static final String ANZ_PLUS_WEB_ORIGIN = 'ANZ Plus Web';

  // Dispute Business Hour Name
  public static final String ANZ_DISPUTE_BUSINESS_HOUR_NAME = 'ANZx Case Business Hours';

  // Task Record Type for Email Case
  public static final String TASK_EMAIL_RT = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Email_Task')
    .getRecordTypeId();

  // Email Task Description
  public static final String TASK_EMAIL_DESCRIPTION = 'Please send the customer the relevant closure email(s)';

  //Customer Onboarding 'ID Ops'->'Fraud Check' corresponding Case statuses
  public static final Map<String, String> COB_ID_OPS_TO_FRAUD_CHECK_STATUS_MAP = new Map<String, String>{
    GetHelpConstants.COB_DAON_FAILED_STATUS => GetHelpConstants.COB_DAON_FAILED_STATUS,
    GetHelpConstants.COB_EQUIFAX_FAILED_STATUS => GetHelpConstants.COB_EQUIFAX_FAILED_STATUS
  };

  //Customer Onboarding 'Fraud Check'->'ID Ops' corresponding Case statuses
  public static final Map<String, String> COB_FRAUD_CHECK_TO_ID_OPS_STATUS_MAP = new Map<String, String>{
    GetHelpConstants.COB_FRAUD_CHECK_DAON_APPROVED_STATUS => GetHelpConstants.COB_ID_OPS_DAON_APPROVED_STATUS,
    GetHelpConstants.COB_EQUIFAX_PASSED_STATUS => GetHelpConstants.COB_EQUIFAX_PASSED_STATUS,
    GetHelpConstants.COB_FAILED_OK_STATUS => GetHelpConstants.COB_FAILED_OK_STATUS,
    GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS => GetHelpConstants.COB_CONFIRMED_FRAUD_STATUS
  };

  // Basic Subscription Entitlment Process Name
  public static final String BASIC_SUBSCRIPTION_ENTITLEMENT_NAME = 'Basic Subscription';
  public static final String ANZ_PLUS_BASIC_SUBSCRIPTION_SLA_PROCESS_NAME = 'anz plus - basic subscription';
  public static final String COMPLAINTS_SLA_PROCESS_NAME = 'complaints';
}
