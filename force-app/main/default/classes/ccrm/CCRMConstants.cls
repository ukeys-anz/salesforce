/**
 * @author Sahil Sachar
 * @since 08/2021
 * @description  CCRMConstants consists of all the CCRM constants
 */
public with sharing class CCRMConstants {
  //Constant Values
  public static final String STATUS_NEW = 'New';
  public static final String STATUS_ASSIGNED = 'Assigned';
  public static final String STATUS_OUTCOME = 'Outcome';
  public static final String OPP_IDENTIFIED = 'Opportunity Identified';
  public static final String STATUS_IN_PROGRESS = 'In progress';
  public static final String STATUS_REFERRED = 'Referred';
  public static final String STATUS_EXPIRED = 'Expired';
  public static final String STATUS_CONVERTED = 'Converted';
  public static final String ORIGINATOR_ADOBE = 'Adobe';
  public static final String ORIGINATOR_CCRM = 'CCRM';
  public static final String ORIGINATOR_UNICA = 'UNICA';
  public static final String ORIGINATOR_UNICA_OR_ADOBE_OR_CCRM = 'CCRM OR UNICA OR ADOBE';
  public static final String INTEGRATION_USER_UNICA = 'unica.integration@anzx.com';
  public static final String INTEGRATION_USER_ADOBE = 'adobe.integration@anzx.com';
  public static final String LEAD_SUBSTATUS_NEW = 'New';
  public static final String STATUS_COMPLETED = 'Completed';
  public static final String STATUS_NOT_REQUIRED = 'Not required';
  public static final String ACCOUNT_TYPE_BUSINESS = 'Business';
  public static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
  public static final String ACCOUNT_TYPE_CLG = 'CLG';
  public static final String ABN_ACN_STATUS_INPROGRESS = 'Validation in progress';
  public static final String ABN_ACN_STATUS_FAILED = 'Validation Error';
  public static final String ABN_ACN_STATUS_ACTIVE = 'Active';
  public static final String ABN_ACN_STATUS_CANCELLED = 'Cancelled';
  public static final String CONVERT_LEAD = 'ConvertLead';
  public static final String MANUAL_LEADS_TO_UNICA_ACTION_NEW = 'New';
  public static final String MANUAL_LEADS_TO_UNICA_ACTION_UPDATE = 'Update';
  public static final String NO_CONTACT_FOUND = 'No Contact Found';
  public static final String IS_BUSINESS = 'isBusiness';
  public static final String IS_INDIVIDUAL = 'isIndividual';
  public static final String IS_INVALID = 'isInvalid';
  public static final String ACTIVE_STATUS = 'Active';
  public static final String INACTIVE_STATUS = 'Inactive';
  public static final String ACC_RT = 'Business_Account';
  public static final String ACC_PERSON_RT = 'PersonAccount';
  public static final String CON_RT = 'Organisation';
  public static final String CPE_RT = 'Organisation';
  public static final String CPE_IND_RT = 'Individual';
  public static final String CPA_RT = 'Organisation';
  public static final String CPA_IND_RT = 'Individual';
  public static final String CPP_IND_RT = 'Individual';
  public static final String SOBJECT_ACCOUNT = 'Account';
  public static final String SOBJECT_CONTACT = 'Contact';
  public static final String SOBJECT_CPE = 'ContactPointEmail';
  public static final String SOBJECT_CPA = 'ContactPointAddress';
  public static final String SOBJECT_CPP = 'ContactPointPhone';
  public static final String ACC_CPID = 'Controlling_Post__c';
  public static final String ACC_CPID_LABEL = 'Controlling Post';
  public static final String ACC_CP_TRANSFORM = 'CPID__c';
  public static final String ACC_IND = 'Industry__c';
  public static final String ACC_IND_LABEL = 'Industry';
  public static final string INVALID_OCV_ROLE_ERROR_MESSAGE = 'OCV Role Id is not found in the Reciprocal Role table';
  public static final String PROSPECT = 'Prospect';
  public static final String SOURCE_SYSTEM_NAME = 'CAP-CIS';
  public static final String NEED_ANALYSIS = 'Needs Analysis';
  public static final String SOL_DEV = 'Solution Development';
  public static final String APPROVED_OFFERED = 'Approved & Offered';
  public static final String CUST_ACCEPT = 'Customer Acceptance';
  public static final String OPP_WON = 'Opportunity Won';
  public static final String OPP_LOST = 'Opportunity Lost';
  public static final String STAGE_CAN_BE_OPP_IDENTIFIED = 'Stage can only be set to Opportunity Identified.';
  public static final String OTHER_SOURCE_DETAIL_MANDATORY = 'Other Source Detail is mandatory if Lead Source is Other.';
  public static final String SKIP_STAGE = 'Unfortunately, you are not allowed to skip stages or re-open a closed Opportunity.';
  public static final String LOST_REASON_DETAIL_MISSING = 'Please provide valid Lost Reason/Lost Reason Detail.';
  public static final String WON_LOST_MANDATORY = 'Won From/Lost To is mandatory to Proceed to Opportunity Won/Lost.';
  public static final String NEEDS_ANALYSIS_ACTION_PLAN_TEMP = 'Needs Analysis Action Plan Template';
  public static final String NOT_STARTED = 'Not Started';
  public static final String PLAN_TYPE = 'Industries';
  public static final String PUBLISHED_TEMPLATE_STATUS = 'Final';
  public static final String ERROR = 'Error';
  public static final String OPPORTUNITY_OBJ_PREFIX = '006';
  public static final String STATUS_OPEN = 'Open';
  public static final String DORMANT_STATUS = 'Dormant';
  public static final String OTHER = 'Other';
  public static final String NEW_LINE_CHAR = '\n';
  public static final String CUSTOMER_NEEDS_ERROR = 'Secondary Customer Needs should not be the same as Customer Needs.';
  public static final String REOPEN_CLOSED_OPP = 'You cannot reopen a closed opportunity';

  public static final String NO_AVAILABLE_BALANCE = 'No available balance';
  public static final String ACC_ORG = 'FinServ__CustomerType__c';
  public static final String ACC_ORG_LABEL = 'Organisation Type';
  public static final String ERROR_RESPONSE = 'Unexpected error';
  public static final String SUCCESS_RESPONSE = 'Success';
  public static final String FINANCIAL_ACCOUNT_OBJECT_NAME = 'FinServ__FinancialAccount__c';
  public static final String INTER_CAT_CAPDIARYCOMMENTS = 'CAP Diary Comments';
  public static final String INTER_CAT_GENERAL = 'General';
  public static final String ACTION_CODE_CREATE = 'create';
  public static final String ACTION_CODE_UPDATE = 'update';
  public static final String CCRM_PROFILE_NAME = 'ANZ CCRM Standard User';
  public static final String DELETE_ERROR = 'You cannot delete leads';
  public static final List<String> BUSINESS_PARTY_RECORDTYPES = new List<String>{
    'Business_Account'
  };
  public static final List<String> INDIVIDUAL_PARTY_RECORDTYPES = new List<String>{
    'PersonAccount',
    'CLG'
  };
  public static final String ABN_ACN_VALIDATION_MESSAGE = 'Capture valid ABN / ACN details';

  //CCRM Lead record type Ids
  public static final Id CCRM_LEAD_RT_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
    .get('CCRM_Lead')
    .getRecordTypeId();

  //MLCRM Lead Record Type Id
  public static final Id MLCRM_LEAD_RT_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
    .get('MLCRM_Lead')
    .getRecordTypeId();

  //CCRM Opportunity record type Ids
  public static final Id CCRM_OPP_RT_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
    .get('Commercial_Opportunity')
    .getRecordTypeId();

  //Lead Response Record Type Ids
  public static final Id LEAD_RESPONSE_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Lead_Response')
    .getRecordTypeId();

  //CCRM Task Record Type Id
  public static final Id CCRM_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('CCRM_Task')
    .getRecordTypeId();

  //Account Record Type Ids
  public static final Id ACCOUNT_ORGANISATION_BUSINESS_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('Business_Account')
    .getRecordTypeId();

  //Account - Person Account Record Type Id
  public static final Id ACCOUNT_PERSON_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('PersonAccount')
    .getRecordTypeId();

  //Account - CLG Record Type Id
  public static final Id ACCOUNT_CLG_RT_ID = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get('CLG')
    .getRecordTypeId();

  //Contact - Business Record Type Id
  public static final Id CONTACT_BUSINESS_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Organisation')
    .getRecordTypeId();

  //Contact - Hidden Record Type Id
  public static final Id CONTACT_HIDDEN_RT_ID = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName()
    .get('Hidden')
    .getRecordTypeId();

  //FinServ__ReciprocalRole__c Contact Role Record Type Id
  public static final Id RECIPROCAL_CONTACT_ROLE_RT_ID = Schema.SObjectType.FinServ__ReciprocalRole__c.getRecordTypeInfosByDeveloperName()
    .get('ContactRole')
    .getRecordTypeId();

  //FinServ__ReciprocalRole__c Contact Role Record Type Id
  public static final Id RECIPROCAL_ACCOUNT_ROLE_RT_ID = Schema.SObjectType.FinServ__ReciprocalRole__c.getRecordTypeInfosByDeveloperName()
    .get('AccountRole')
    .getRecordTypeId();

  //Financial Account Role - System Role Record Type Id
  public static final Id FAR_SYSTEM_RT_ID = Schema.SObjectType.FinServ__FinancialAccountRole__c.getRecordTypeInfosByDeveloperName()
    .get('System_Role')
    .getRecordTypeId();

  //Financial Account Role - Contact Role Record Type Id
  public static final Id FAR_CONTACT_RT_ID = Schema.SObjectType.FinServ__FinancialAccountRole__c.getRecordTypeInfosByDeveloperName()
    .get('ContactRole')
    .getRecordTypeId();

  //Financial Account Role - Contact Role Record Type Id
  public static final Id FAR_ACCOUNT_RT_ID = Schema.SObjectType.FinServ__FinancialAccountRole__c.getRecordTypeInfosByDeveloperName()
    .get('AccountRole')
    .getRecordTypeId();

  //Contact Point Email - Organisation Record Type Id
  public static final Id CPE_ORG_RT_ID = Schema.SObjectType.ContactPointEmail.getRecordTypeInfosByDeveloperName()
    .get('Organisation')
    .getRecordTypeId();

  //Contact Point Address - Organisation Record Type Id
  public static final Id CPA_ORG_RT_ID = Schema.SObjectType.ContactPointAddress.getRecordTypeInfosByDeveloperName()
    .get('Organisation')
    .getRecordTypeId();

  //Contact Point Email - Individual Record Type Id
  public static final Id CPE_IND_RT_ID = Schema.SObjectType.ContactPointEmail.getRecordTypeInfosByDeveloperName()
    .get('Individual')
    .getRecordTypeId();

  //Contact Point Address - Individual Record Type Id
  public static final Id CPA_IND_RT_ID = Schema.SObjectType.ContactPointAddress.getRecordTypeInfosByDeveloperName()
    .get('Individual')
    .getRecordTypeId();

  //Financial Account record type Ids
  public static final Id FA_RT_ID = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName()
    .get('BankingAccount')
    .getRecordTypeId();

  //Financial Account Role record type Ids
  public static final Id FAR_RT_ID = Schema.SObjectType.FinServ__FinancialAccountRole__c.getRecordTypeInfosByDeveloperName()
    .get('AccountRole')
    .getRecordTypeId();

  //A-Z Review - Commerical A-Z Review Record TypeId
  public static final Id AZ_REVIEW_RT_ID = Schema.SObjectType.A_Z_Review__c.getRecordTypeInfosByDeveloperName()
    .get('Commercial_A_Z_Review')
    .getRecordTypeId();

  // Interaction - CCRM Interaction RT Id
  public static final Id INTERACTION_CCRM_RT_ID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
    .get('CCRM_Interaction')
    .getRecordTypeId();

  /**
   * To be used for apex validations that are meant to replace Custom Validation rules
   * (eg. to run validation at specific points in code whereas Custom Validations are usually run after before triggers).
   * Those apex validations should be treated the same as Custom Validations
   * (can be disabled via "Disable_VRs__c" instead of having to disable all triggers, and can be skipped by user with "CCRM_Skip_Validation" custom permission)
   */
  public static final Boolean SKIP_CUSTOM_VALIDATION_RULES =
    FeatureManagement.checkPermission('CCRM_Skip_Validation') ||
    Salesforce_Library_Settings__c.getInstance(UserInfo.getUserId())
      .Disable_VRs__c;
}
