/** @author CMOS
 * @since April 2026
 * @description Request model for Quality Assessments
 * @group Models
 */
public class QualityAssessmentResponseModel extends CalloutModel {
  public String status;
  public Integer httpsStatusCode;
  public String qualityAssessmentId;
  public String message;

  /**
   * @param json input string to deserialize
   * @return `QualityAssessmentResponseModel`
   * @description Method to deserialize Response body.
   */

  public static QualityAssessmentResponseModel parse(String json) {
    return (QualityAssessmentResponseModel) deserialize(
      json,
      QualityAssessmentResponseModel.class
    );
  }
}
