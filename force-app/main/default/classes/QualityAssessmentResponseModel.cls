/** @author CMOS
 * @since April 2026
 * @description Request model for Quality Assessments
 * @group Models
 */
public class QualityAssessmentResponseModel extends CalloutModel {
  @AuraEnabled
  public String status;
  @AuraEnabled
  public Integer httpsStatusCode;
  @AuraEnabled
  public String qualityAssessmentId;
  @AuraEnabled
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
