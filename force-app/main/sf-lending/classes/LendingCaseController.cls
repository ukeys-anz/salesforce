/**
 * @description controller class for Lending Case
 * @author Jaya Srivastava
 * @since Jan 2025
 */
public with sharing class LendingCaseController {
  private static final LendingCaseRepository CASE_SOQL_REPOSITORY = (LendingCaseRepository) Lib_InstanceProvider.forType(
    LendingCaseRepository.class
  );

  private static final LendingCaseAPIRepository LENDING_CASE_API_REPOSITORY = (LendingCaseAPIRepository) Lib_InstanceProvider.forType(
    LendingCaseAPIRepository.class
  );

  /**
   * @description Below method will accept the updated values of from the LWC and turn it into the requestBody and make callout.
   * @param approvalState String
   * @param recordId Id
   * @return `Boolean`
   * @exception
   */
  @AuraEnabled
  public static LendingCaseResponseModel updateCaseStatusApproveReject(
    String approvalState,
    Id recordId
  ) {
    try {
      if (approvalState == '' || recordId == null) {
        throw new IllegalArgumentException(
          'Approval or Rejection status could not be found'
        );
      }
      Case caseRecord = CASE_SOQL_REPOSITORY.queryCaseByRecordId(recordId);
      LendingCaseRequestModel requestBody = new LendingCaseRequestModel(
        approvalState
      );

      LendingCaseResponseModel responseModel = LENDING_CASE_API_REPOSITORY.updateCaseStatusApproveReject(
        caseRecord,
        requestBody
      );
      Boolean caseUpdate = false;
      if (responseModel.approveRejectSuccess) {
        caseUpdate = LendingCaseHelper.updateCaseStatus(
          recordId,
          approvalState
        );
      }
      responseModel.caseUpdateSuccess = caseUpdate;
      return responseModel;
    } catch (Exception e) {
      Logger.info('Failure on upadate status as callout failed', e);
      Logger.saveLog();
      LendingCaseResponseModel responseModel = new LendingCaseResponseModel();
      responseModel.approveRejectSuccess = false;
      responseModel.caseUpdateSuccess = false;
      return responseModel;
    }
  }
}
