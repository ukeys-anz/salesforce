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
}
