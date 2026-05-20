/** @author CMOS
 * @since April 2026
 * @description Repo class for fetching Quality Assessments
 */
public with sharing class IDRFetchQualityAssessmentsController {
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  private static final ComplaintsRepository COMPLAINT_REPO = (ComplaintsRepository) Lib_InstanceProvider.forType(
    ComplaintsRepository.class
  );

  private static final IDRQualityAssessmentRepo QA_REPO = (IDRQualityAssessmentRepo) Lib_InstanceProvider.forType(
    IDRQualityAssessmentRepo.class
  );
  private static final String EXCEPTION_ERROR_MSG = 'Error occurred generating A.I. evaluation. Please try again.';

  /**
   * @description The method is used to create Quality Assessments.
   * @param complaintId Id of the Complaint
   * @return `QualityAssessmentResponseModel response model
   */
  @AuraEnabled(cacheable=true)
  public static QualityAssessmentResponseModel fetchQualityAssessments(
    String complaintId
  ) {
    try {
      QualityAssessmentRequestModel reqModel = new QualityAssessmentRequestModel(
        complaintId,
        USER_INFO.getUser().Id
      );
      return QA_REPO.getQualityAssessments(reqModel);
    } catch (Exception ex) {
      throw new AuraHandledException(EXCEPTION_ERROR_MSG);
    }
  }

  /**
   * @description Checks if a case exists with the given case number.
   * @param caseNumber The case number to check
   * @return Boolean indicating if the case exists
   */
  @AuraEnabled(cacheable=true)
  public static Boolean checkCaseExists(String caseNumber) {
    try {
      Case existingCase = COMPLAINT_REPO.getCaseByCaseNumber(caseNumber);
      return existingCase != null;
    } catch (Exception ex) {
      throw new AuraHandledException(
        'Case number is invalid and doesn\'t exist in Salesforce'
      );
    }
  }
}
