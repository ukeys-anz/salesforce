/**
 * @author Hrushikesh
 * @since April 2025
 * @description Holds cached Quality Assessment Record Types.
 */
public with sharing class RTQualityAssessment {
  static QueryRT base = QueryRT.of(Quality_Assessment__c.SObjectType);

  public static Id getHelp = base.getId('Get_Help');
  public static Id getHelpAppointment = base.getId('Get_Help_Appointment');
  public static Id lendingEvaluation = base.getId(
    'ANZ_Plus_Governance_Lending_Evaluation'
  );
  public static Id joinRTId = base.getId('Join');
  public static Id idrCQQualityId = base.getId('C_Q_Assessment');
  public static Id idrReviewAssessmentId = base.getId(
    'Call_Letter_Review_Assessment'
  );

  /**
   * @description Get the record type info for a given record type id
   * @param recordTypeId The record type id
   * @return The record type info
   */
  public static RecordTypeInfo get(Id recordTypeId) {
    return base.get(recordTypeId);
  }
}
