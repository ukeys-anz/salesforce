/**
 * @author Sahil Sachar
 * @since 08/2021
 * @description  CCRMConstants consists of all the CCRM constants
 */
public with sharing class CCRMConstants {
  //Constant Values
  public static final String STATUS_NEW = 'New';
  public static final String STATUS_IN_PROGRESS = 'In progress';
  public static final String STATUS_REFERRED = 'Referred';
  public static final String STATUS_EXPIRED = 'Expired';
  public static final String STATUS_CONVERTED = 'Converted';
  public static final String ORIGINATOR_ADOBE = 'Adobe';
  public static final String ORIGINATOR_CCRM = 'CCRM';
  public static final String ORIGINATOR_UNICA = 'UNICA';
  public static final String STATUS_COMPLETED = 'Completed';
  public static final String ACCOUNT_TYPE_BUSINESS = 'Business';
  public static final String ACCOUNT_TYPE_CUSTOMER = 'Customer';
  public static final String ACCOUNT_TYPE_CLG = 'CLG';
  public static final String ABN_ACN_STATUS_INPROGRESS = 'Validation Inprogress';
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

  //Lead Response Record Type Ids
  public static final Id LEAD_RESPONSE_RT_ID = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName()
    .get('Lead_Response')
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
}
