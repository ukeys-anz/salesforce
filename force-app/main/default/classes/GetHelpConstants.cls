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
