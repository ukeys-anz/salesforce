/**
 *
 * @author Pavan Kumar Ananta
 * @since 02/2020
 * @description Common Case Action methods
 */

public with sharing class CaseCommonActions {
  // General Inquiry Record Type Id
  public static final Id GENERAL_INQUIRY_RT_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
    .get('General_Inquiry')
    .getRecordTypeId();

  
}
