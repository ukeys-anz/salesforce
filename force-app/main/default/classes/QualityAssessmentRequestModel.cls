/** @author CMOS
 * @since April 2026
 * @description Request model for Quality Assessments
 * @group Models
 */
public class QualityAssessmentRequestModel extends CalloutModel {
  String caseNumber;
  String userId;

  /**
   * @description Constructor
   * @param caseNumber case number of the complaint
   * @param userId user id of the user
   */
  public QualityAssessmentRequestModel(String caseNumber, String userId) {
    this.caseNumber = caseNumber;
    this.userId = userId;
  }
}
