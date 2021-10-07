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

  /**
   * @description mapping from product to queue for workbasket allocation
   * @return Map of Product to Workbasket
   */
  public static final Map<String, String> caseAssignmentProductMap {
    get {
      if (caseAssignmentProductMap == null) {
        caseAssignmentProductMap = new Map<String, String>{
          'ANZ Business Black Credit Card' => 'IDR_Business_Owners',
          'ANZ Business 55 Days Interest Free Credit Card' => 'IDR_Business_Owners',
          'ANZ Business Rewards Options Credit Card' => 'IDR_Business_Owners',
          'ANZ Business Low Rate Credit Card' => 'IDR_Business_Owners',
          'ANZ Visa Purchasing Card' => 'IDR_Business_Owners',
          'ANZ Virtual Card' => 'IDR_Business_Owners',
          'ANZ Travel Account' => 'IDR_Business_Owners',
          'ANZ Corporate Card' => 'IDR_Business_Owners',
          'AGRI Finance Loan' => 'IDR_Business_Owners',
          'ANZ Business Loan (ABL) for Personal Investment' => 'IDR_Business_Owners',
          'ANZ Business Loan (ABL)' => 'IDR_Business_Owners',
          'ANZ Business Mortgage Loan (BML)' => 'IDR_Business_Owners',
          'ANZ Business Saver Loan' => 'IDR_Business_Owners',
          'Investment Property Loan (GF)' => 'IDR_Business_Owners',
          'Tailored Commercial Facility (TCF) - VARIABLE INT' => 'IDR_Business_Owners',
          'Tailored Commercial Facility (TCF) - RANGE INT' => 'IDR_Business_Owners',
          'Tailored Commercial Facility (TCF) - FIXED INT' => 'IDR_Business_Owners',
          'Tailored Commercial Facility (TCF) - FIX INT IN ADV' => 'IDR_Business_Owners',
          'Tailored Commercial Facility (TCF) - CAPPED INT' => 'IDR_Business_Owners',
          'Tailored Commercial Facility (TCF)' => 'IDR_Business_Owners',
          'ANZ Tailored Business Facility' => 'IDR_Business_Owners',
          'Chattel Mortgage' => 'IDR_Business_Owners',
          'Finance Lease' => 'IDR_Business_Owners',
          'Novated Lease' => 'IDR_Business_Owners',
          'Luxury Asset Lease' => 'IDR_Business_Owners',
          'Offer to Hire' => 'IDR_Business_Owners',
          'Asset Finance' => 'IDR_Business_Owners',
          'ANZ Revolving AGRI Line overdraft' => 'IDR_Business_Owners',
          'Business Credit Facility' => 'IDR_Business_Owners',
          'Business Advantage Overdraft' => 'IDR_Business_Owners',
          'Cash Covered Facility Account' => 'IDR_Business_Owners',
          'Cash Cover Indemnity Guarantee' => 'IDR_Business_Owners',
          'Indemnity Guarantee Facility' => 'IDR_Business_Owners',
          'Business Classic Account' => 'IDR_Business_Owners',
          'GST Payment Account' => 'IDR_Business_Owners',
          'Business Extra 50 Account' => 'IDR_Business_Owners',
          'Business Extra Account' => 'IDR_Business_Owners',
          'Negotiator Account' => 'IDR_Business_Owners',
          'ANZ Business Essentials (Previously ANZ Business Premium Saver)' => 'IDR_Business_Owners',
          'Negotiator Investor Account' => 'IDR_Business_Owners',
          'Statutory Trust Account' => 'IDR_Business_Owners',
          'Business Advantage Account' => 'IDR_Business_Owners',
          'Security Deposit Account' => 'IDR_Business_Owners',
          'Farm Management Deposit Account' => 'IDR_Business_Owners',
          'Agri Finance Offset Account' => 'IDR_Business_Owners',
          'ANZ Business Offset' => 'IDR_Business_Owners',
          'BML Offset Account - with Cheque Book' => 'IDR_Business_Owners',
          'Missing Funds' => 'IDR_Business_Owners',
          'ANZ Business Visa Debit card (ABVD)' => 'IDR_Business_Owners',
          'Business Online Saver Account' => 'IDR_Business_Owners',
          'ANZ Farm Management Deposit' => 'IDR_Business_Owners',
          'ANZ Business Notice Term Deposit' => 'IDR_Business_Owners',
          'Merchant services' => 'IDR_Business_Owners',
          'ANZ IB4B - Internet Banking for Business' => 'IDR_Business_Owners',
          'ANZ Transactive' => 'IDR_Business_Owners',
          'ANZ First Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Platinum Credit Card' => 'IDR_Everyday_Banking',
          'ANZ First (for Students) Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Low Rate Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Low Rate Platinum Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Rewards Black Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Rewards Platinum Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Rewards Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Rewards Travel Adventures Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Frequent Flyer Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Frequent Flyer Platinum Credit Card' => 'IDR_Everyday_Banking',
          'ANZ Frequent Flyer Black Credit Card' => 'IDR_Everyday_Banking',
          'Foreign Currency Accountx' => 'IDR_Everyday_Banking',
          'ANZ Passbook Pensioner Advantage' => 'IDR_Everyday_Banking',
          'ANZ Passbook Savings' => 'IDR_Everyday_Banking',
          'ANZ Access Select' => 'IDR_Everyday_Banking',
          'ANZ Everyday Visa Debit' => 'IDR_Everyday_Banking',
          'ANZ V2Plus (Retail)' => 'IDR_Everyday_Banking',
          'ANZ First Home Saver' => 'IDR_Everyday_Banking',
          'ANZ Cash Management Account' => 'IDR_Everyday_Banking',
          'ANZ Access Advantage' => 'IDR_Everyday_Banking',
          'ANZ Pensioner Advantage' => 'IDR_Everyday_Banking',
          'ANZ Access Basic' => 'IDR_Everyday_Banking',
          'Staff Cheque Account' => 'IDR_Everyday_Banking',
          'Retired Officers Cheque Account' => 'IDR_Everyday_Banking',
          'Security Deposit' => 'IDR_Everyday_Banking',
          'ANZ Access Limited' => 'IDR_Everyday_Banking',
          'V2 Plus' => 'IDR_Everyday_Banking',
          'V2 Plus Broking' => 'IDR_Everyday_Banking',
          'V2 Plus including Margin Lending' => 'IDR_Everyday_Banking',
          'V2 Plus Intermediary' => 'IDR_Everyday_Banking',
          'ANZ Access Visa Debit card (AAVD)' => 'IDR_Everyday_Banking',
          'Custodial Services' => 'IDR_Everyday_Banking',
          'Safe Deposit Box' => 'IDR_Everyday_Banking',
          'ANZ Premium Cash Management Account' => 'IDR_Everyday_Banking',
          'ANZ Cash Investment Account' => 'IDR_Everyday_Banking',
          'Investor Cash Hub' => 'IDR_Everyday_Banking',
          'ANZ Cash Advantage' => 'IDR_Everyday_Banking',
          'Prime Cash Management Account' => 'IDR_Everyday_Banking',
          'Prime Cash Management Account - Pension' => 'IDR_Everyday_Banking',
          'ANZ Online Saver' => 'IDR_Everyday_Banking',
          'ANZ Progress Saver' => 'IDR_Everyday_Banking',
          'ANZ Term Deposit' => 'IDR_Everyday_Banking',
          'ANZ Advance Notice Term Deposit' => 'IDR_Everyday_Banking',
          'Seniors Term Deposit' => 'IDR_Everyday_Banking',
          'Travel Money' => 'IDR_Everyday_Banking',
          'ANZ ATM' => 'IDR_Everyday_Banking',
          'Bank Drafts' => 'IDR_Everyday_Banking',
          'Cheque' => 'IDR_Everyday_Banking',
          'Branch Transaction' => 'IDR_Everyday_Banking',
          'Direct Debit' => 'IDR_Everyday_Banking',
          'EFTPOS Transaction' => 'IDR_Everyday_Banking',
          'Foreign Currency Transaction' => 'IDR_Everyday_Banking',
          'FOREX' => 'IDR_Everyday_Banking',
          'International payments' => 'IDR_Everyday_Banking',
          'Cash Pack' => 'IDR_Everyday_Banking',
          'Telegraphic Transfer' => 'IDR_Everyday_Banking',
          'ANZ Reward Points' => 'IDR_Everyday_Banking',
          'Qantas Frequent Flyer Points' => 'IDR_Everyday_Banking',
          'ANZ Internet Banking' => 'IDR_Everyday_Banking',
          'ANZ App' => 'IDR_Everyday_Banking',
          'ANZ FX Online' => 'IDR_Everyday_Banking',
          'ANZ Private FX Online' => 'IDR_Everyday_Banking',
          'ANZ Cashactive Virtual' => 'IDR_Everyday_Banking',
          'Currency by ANZ (app)' => 'IDR_Everyday_Banking',
          'ANZ Shield' => 'IDR_Everyday_Banking',
          'Phone Banking' => 'IDR_Everyday_Banking',
          'ANZ Travel Card (Multi Currency)' => 'IDR_Everyday_Banking',
          'Power of Attorney' => 'IDR_Everyday_Banking',
          'Wills' => 'IDR_Everyday_Banking',
          'Deceased Estates' => 'IDR_Everyday_Banking',
          'Open Banking/Data Sharing' => 'IDR_Everyday_Banking',
          'IVR' => 'IDR_Everyday_Banking',
          'N/A' => 'IDR_Everyday_Banking',
          'ANZ Breakfree Package' => 'IDR_Home_Owners',
          'ANZ Standard Variable Home Loan' => 'IDR_Home_Owners',
          'ANZ Fixed Home Loan' => 'IDR_Home_Owners',
          'ANZ Simplicity Plus Home Loan' => 'IDR_Home_Owners',
          'ANZ Standard Variable Investment Property Loan' => 'IDR_Home_Owners',
          'ANZ Fixed Investment Property Loan' => 'IDR_Home_Owners',
          'ANZ Simplicity Plus Investment Property Loan' => 'IDR_Home_Owners',
          'ANZ Assured' => 'IDR_Home_Owners',
          'ANZ Personal Overdraft' => 'IDR_Home_Owners',
          'ANZ Equity Manager' => 'IDR_Home_Owners',
          'ANZ Variable Rate Personal Loan' => 'IDR_Home_Owners',
          'ANZ Fixed Rate Personal Loan' => 'IDR_Home_Owners',
          'ANZ One Offset Account' => 'IDR_Home_Owners',
          'Margin Lending' => 'IDR_Wealth',
          'ANZ SMSF Cash Hub' => 'IDR_Wealth',
          'OnePath Life Term Deposit' => 'IDR_Wealth',
          'ANZ Term Deposit via External Platforms & Oasis Wrap' => 'IDR_Wealth',
          'ANZ Credit Card Insurance' => 'IDR_Wealth',
          'ANZ Loan Protection Insurance' => 'IDR_Wealth',
          'ANZ Mortgage Protection Insurance' => 'IDR_Wealth',
          'ANZ Lenders Mortgage Insurance' => 'IDR_Wealth',
          'ANZ Home and Contents Insurance' => 'IDR_Wealth',
          'ANZ Landlord Insurance' => 'IDR_Wealth',
          'ANZ Contents Insurance' => 'IDR_Wealth',
          'ANZ Car Insurance (Comprehensive)' => 'IDR_Wealth',
          'ANZ Car Insurance (Third Party Property Damage, Fire and Theft)' => 'IDR_Wealth',
          'ANZ Car Insurance (Third Party Property Damage)' => 'IDR_Wealth',
          'ANZ Travel Insurance' => 'IDR_Wealth',
          'ANZ Share Investment Loan' => 'IDR_Wealth',
          'White-Label ANZ Share Investing Service' => 'IDR_Wealth',
          'ANZ Accident Cover Plus' => 'IDR_Wealth',
          'ANZ Critical Illness Cover' => 'IDR_Wealth',
          'ANZ Income Cover' => 'IDR_Wealth',
          'ANZ Income Protection' => 'IDR_Wealth',
          'ANZ 50+ Life Cover' => 'IDR_Wealth',
          'ANZ Life Insurance' => 'IDR_Wealth',
          'ANZ Recover Well' => 'IDR_Wealth',
          'ANZ Credit Cover Plus' => 'IDR_Wealth',
          'ANZ Credit Cover' => 'IDR_Wealth',
          'ANZ Smart Choice Super for Employers and their Employees' => 'IDR_Wealth',
          'ANZ Smart Choice Pension' => 'IDR_Wealth',
          'ANZ Smart Choice Super' => 'IDR_Wealth',
          'IPO & Capital Raising Campaigns' => 'IDR_Wealth',
          'Direct Investments' => 'IDR_Wealth',
          'ANZ OneAnswer' => 'IDR_Wealth',
          'OneAnswer Frontier' => 'IDR_Wealth',
          'BT Wrap' => 'IDR_Wealth',
          'Netwealth' => 'IDR_Wealth',
          'Self Managed Super Fund (SMSF)' => 'IDR_Wealth',
          'Business One' => 'IDR_Business_Owners',
          'Salary Packaging Card' => 'IDR_Business_Owners',
          'Business Overdraft' => 'IDR_Business_Owners',
          'Business Select Package' => 'IDR_Business_Owners',
          'Residential Property Investment Loan' => 'IDR_Business_Owners',
          'Documentary Credit Facility' => 'IDR_Business_Owners',
          'Import Credit & Trade Facility' => 'IDR_Business_Owners',
          'Trade Finance Loan' => 'IDR_Business_Owners',
          'Export Trade Facility ' => 'IDR_Business_Owners',
          'Encashment Facility' => 'IDR_Business_Owners',
          'Commercial Bills' => 'IDR_Business_Owners',
          'Asset Finance - Car Loans' => 'IDR_Business_Owners',
          'Asset Finance - Esanda Business Equipment finance' => 'IDR_Business_Owners',
          'Asset Finance - Hire purchase' => 'IDR_Business_Owners',
          'Letter of Credit' => 'IDR_Business_Owners',
          'Standby Letter of Credit' => 'IDR_Business_Owners',
          'ANZ Frequent Flyer Visa Gold' => 'IDR_Everyday_Banking',
          'ANZ Prepaid Card' => 'IDR_Everyday_Banking',
          'ANZ Rewards Visa Gold' => 'IDR_Everyday_Banking',
          'Aussie Mastercard' => 'IDR_Everyday_Banking',
          'Balance Visa' => 'IDR_Everyday_Banking',
          'Verified by Visa' => 'IDR_Everyday_Banking',
          'Easy Start Residential Investment Loan' => 'IDR_Home_Owners',
          'Easy Start Home Loan' => 'IDR_Home_Owners',
          'Equity Release Fixed Rate Loan' => 'IDR_Home_Owners',
          'Equity Release Variable Rate Loan' => 'IDR_Home_Owners',
          'Fixed Rate' => 'IDR_Home_Owners',
          'Home Loan Interest Saver' => 'IDR_Home_Owners',
          'Money saver Home Loan' => 'IDR_Home_Owners',
          'Money Saver Residential Investment Loan' => 'IDR_Home_Owners',
          'Business Cash Management' => 'IDR_Business_Owners',
          'Negotiable Certificate of Deposit' => 'IDR_Business_Owners',
          'Premium Business Cash Account' => 'IDR_Business_Owners',
          'Premium Business Cash Management' => 'IDR_Business_Owners',
          'Short Term or Call Deposit' => 'IDR_Business_Owners',
          'Structured Bill Investment' => 'IDR_Business_Owners',
          'Corporate Transaction Account' => 'IDR_Business_Owners',
          'Client Money Account (Cache)' => 'IDR_Business_Owners',
          'Corporate Statutory Trust (Cache)' => 'IDR_Business_Owners',
          'ANZ Design My Card' => 'IDR_Everyday_Banking',
          'ANZ Online Investment Account' => 'IDR_Everyday_Banking',
          'Esanda Term Deposit' => 'IDR_Everyday_Banking',
          'Safe Deposit/ Locked Box/ Sealed Packet' => 'IDR_Everyday_Banking',
          'Seniors Privilege' => 'IDR_Everyday_Banking',
          'Esanda Term Deposit' => 'IDR_Everyday_Banking',
          'Access Deeming' => 'IDR_Everyday_Banking',
          'Access Simplicity' => 'IDR_Everyday_Banking',
          'Premier Cheque Account' => 'IDR_Everyday_Banking',
          'Premier Cheque Account - with Overdraft' => 'IDR_Everyday_Banking',
          'ANZ Plus Account – Transaction Account (ANZ Plus only)' => 'IDR_Everyday_Banking',
          'ANZ Save - Savings Account (ANZ Plus only)' => 'IDR_Everyday_Banking',
          'Corporate Term Deposit (Cache)' => 'IDR_Business_Owners',
          'Corporate Notice Term Deposit' => 'IDR_Business_Owners',
          'Money Market Deposits' => 'IDR_Business_Owners',
          'FX - Spot, Value Today and Value Tomorrow' => 'IDR_Business_Owners',
          'FX - Flexible Forwards' => 'IDR_Business_Owners',
          'FX - Forward Exchange Contracts' => 'IDR_Business_Owners',
          'FX - Foreign Currency Options' => 'IDR_Business_Owners',
          'Commodity Swap Facilities' => 'IDR_Business_Owners',
          'Agri Commodity Swap' => 'IDR_Business_Owners',
          'International Money Transfers' => 'IDR_Business_Owners',
          'Digital Wallets' => 'IDR_Everyday_Banking',
          'ANZ Plus App (ANZ Plus only)' => 'IDR_Everyday_Banking',
          'ANZ Cash Escrow Facility' => 'IDR_Business_Owners',
          'Home Loan Protection Insurance' => 'IDR_Home_Owners'
        };
      }
      return caseAssignmentProductMap;
    }
    set;
  }
}
