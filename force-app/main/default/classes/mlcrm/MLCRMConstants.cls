/**
 * @author Ashish Kumar
 * @since 04/2023
 * @description  MLCRMConstants consists of all the MLCRM constants
 */
public with sharing class MLCRMConstants {
  //Constant Values
  public static final String STATUS_OPPORTUNITY_INDENTIFIED = 'Opportunity Identified';
  public static final String STATUS_IN_PROGRESS = 'In progress';
  public static final String STATUS_NEW = 'New';
  public static final String STATUS_OPEN = 'Open';
  public static final String LEAD_NEW_TO_INPROGRESS = 'LeadNewToInProgress';
  public static final String MLCRM_LEAD_RECORDTYPE_NAME = 'MLCRM_Lead';
  public static final String CCRM_LEAD_RECORDTYPE_NAME = 'CCRM_Lead';
  public static final String ANZ_DOT_COM = 'ANZ.com';
  public static final String ANZ_CAMPAIGNS = 'ANZ Campaigns';
  public static final String ORIGINATOR_MLCRM = 'MLCRM';
  public static final String COPY_LEAD_ID = 'copyLeadId';
  public static final String SOBJECT_OPPORTUNITY = 'Opportunity';
  public static final String SOBJECT_ACCOUNT = 'Account';
  public static final String MAPPING_TYPE_FIELD = 'Field';
  public static final String MAPPING_TYPE_RT = 'Record Type';
  public static final String STATUS_ACTIVE = 'Active';
  public static final String ML_PROFILE_NAME = 'ANZ ML Standard User';
  public static final String ADMIN_PROFILE_NAME = 'System Administrator';
  public static final String STRING_UNRESTRICTED = 'Unrestricted';
  public static final String STRING_RESTRICTED = 'Restricted';
  public static final String LOAN_WRITER = 'Loan Writer';
  public static final String UNDERSCORE_C = '__c';
  public static final String UNDERSCORE_SHARE = '__Share';
  public static final String INTERNAL_REFERRAL = 'Internal Referral';
  public static final String EXTERNAL_REFERRAL = 'External Referral';
  public static final String PRIORITY_NORMAL = 'Normal';
  public static final String SPACE = ' ';
  public static final String STAGE_CLOSED = 'Closed';
  public static final String STAGE_LOST = 'Lost';
  public static final String PHONETYPE_MOBILE = 'Mobile Telephone';
  public static final String PERSONACCOUNT_RT = 'PersonAccount';
  public static final String CONTACT = 'Contact';
  public static final String CONTACTPOINTADDRESS = 'ContactPointAddress';
  public static final String CONTACTPOINTEMAIL = 'ContactPointEmail';
  public static final String CONTACTPOINTPHONE = 'ContactPointPhone';
  public static final String INDIVIDUAL_RT = 'Individual';
  public static final String ML_BUSINESS_ADMIN_ROLE_NAME = 'Business_Admin';
  public static final String ML_ROLE_DEV_NAME = 'Mobile_Lending_Franchise_Users';
  public static final String INACTIVE_STATUS = 'Inactive';
  public static final String SOBJECT_RELATIONSHIP_NOTES = 'Customer_Relationship__c';
  public static final String SOBJECT_LEAD = 'Lead';
  public static final String PRIMARY = 'Primary';
  public static final String STR_TERRITORY = 'Territory';
  public static final String STR_FRANCHISE = 'Franchise';
  public static final String STR_PARENT_OBJECT = 'Parent Object';
  public static final String YES = 'Y';
  public static final String SECONDARY = 'Secondary';
  public static final String ML_SUPER_USER_PSG_NAME = 'MLCRM_Super_User';
  public static final String BUSINESS_ADMIN_USER_PSG_NAME = 'Business_Admin';
  public static final String ENGINEER_PSG_NAME = 'Engineer';
  public static final String LOAN_WRITER_PSG_NAME = 'MLCRM_Loan_Writer';
  public static final String ARC_USER_ROLE = 'AR_C';
  public static final String FRANCHISE_ADMIN = 'Admin';

  //MLCRM Lead record type Ids
  public static final Id MLCRM_LEAD_RT_ID = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName()
    .get('MLCRM_Lead')
    .getRecordTypeId();

  //MLCRM Opportunity record type Ids
  public static final Id MLCRM_OPPORTUNITY_RT_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
    .get('MLCRM_Opportunity')
    .getRecordTypeId();

  //MLCRM Task record type Ids
  public static final Id MLCRM_TASK_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('MLCRM_Task')
    .getRecordTypeId();

  //MLCRM Product2 record type Ids
  public static final Id CRM_ANZ_PRODUCT_RT_ID = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
    .get('CRM_ANZ_Product')
    .getRecordTypeId();

  //MLCRM Interaction record type Ids
  public static final Id ML_INTERACTION_RT_ID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
    .get('ML_Interaction')
    .getRecordTypeId();

  //CCRM Interaction record type Ids
  public static final Id CCRM_INTERACTION_RT_ID = Schema.SObjectType.Interaction.getRecordTypeInfosByDeveloperName()
    .get('CCRM_Interaction')
    .getRecordTypeId();

  //ML Event record type Ids
  public static final Id ML_EVENT_RT_ID = Schema.SObjectType.Event.getRecordTypeInfosByDeveloperName()
    .get('ML_Event')
    .getRecordTypeId();
}
