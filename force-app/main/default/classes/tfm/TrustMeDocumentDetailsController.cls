/**
 * @description       :
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 04-16-2025
 **/
public with sharing class TrustMeDocumentDetailsController {
  private static final TrustMeDocumentQueryRepository QUERY = (TrustMeDocumentQueryRepository) Lib_InstanceProvider.forType(
    TrustMeDocumentQueryRepository.class
  );
  private static final TrustMeAPIRepository TRUSTMEREPO = (TrustMeAPIRepository) Lib_InstanceProvider.forType(
    TrustMeAPIRepository.class
  );

  /**
   * @description Retrieves Evaluation Details
   * @param caseId
   * @return  TrustMeDocumentDetailsModel Model class instance
   */
  @AuraEnabled
  public static TrustMeDocumentDetailsModel getEvaluationDetails(Id caseId) {
    try {
      Case caseRec = QUERY.getCaseRecordById(caseId);
      TrustMeDocumentDetailsModel trustMeEvaluationDetails = TRUSTMEREPO.getEvaluationDetails(
        caseRec.Evaluation_Id__c
      );
      Map<String, List<TrustMe_Docs_Tab_Section_Detail__mdt>> evaluationSecMetadataMappingRecords = TrustMeDocumentDetailsHelper.evaluationSections();
      trustMeEvaluationDetails.documentFieldMappingValues = evaluationSecMetadataMappingRecords;
      return trustMeEvaluationDetails;
    } catch (TrustMeAPIRepository.InsufficientAccessException e) {
      throw new AuraHandledException('InsufficientAccessException');
    } catch (TrustMeAPIRepository.ServerErrorException e) {
      throw new AuraHandledException('ServerErrorException');
    } catch (Exception e) {
      throw new AuraHandledException('Exception');
    }
  }

  /**
   * @description fetching Documents for document tab
   * @param requestModel requestModel
   * @return  Map<String,String> (An array of documentType and documentURL)
   */
  @AuraEnabled
  public static Map<String, String> getTrustMeDocuments(
    TrustMeDocumentRequestModel requestModel
  ) {
    Logger.debug(
      DateTimeUtils.timeString +
      ' | Apex execution for TrustMeDocumentDetailsController.getTrustMeDocuments started'
    );

    Case caseRec = QUERY.getCaseRecordById(requestModel.relatedId);
    Map<String, String> uuidByType = new Map<String, String>();
    Map<String, ContentVersion> cvByType = new Map<String, ContentVersion>();
    Map<String, String> urlByType = new Map<String, String>();

    try {
      uuidByType = TrustMeDocumentDetailsHelper.buildUUIDByType(requestModel);
      cvByType = TrustMeDocumentDetailsHelper.queryCvByType(uuidByType);
      Map<String, ContentVersion> incompleteTypes = TrustMeDocumentDetailsHelper.filterIncomplete(
        cvByType
      );
      if (incompleteTypes.isEmpty()) {
        urlByType = TrustMeDocumentDetailsHelper.buildUrlByType(cvByType);
        TrustMeDocumentDetailsHelper.logAudit(
          requestModel,
          urlByType,
          caseRec.CaseNumber
        );
        return urlByType;
      }
      TRUSTMEREPO.getTrustMeDocuments(requestModel);
      cvByType = TrustMeDocumentDetailsHelper.queryCvByType(uuidByType);
      urlByType = TrustMeDocumentDetailsHelper.buildUrlByType(cvByType);
      TrustMeDocumentDetailsHelper.logAudit(
        requestModel,
        urlByType,
        caseRec.CaseNumber
      );
      return urlByType;
    } catch (TrustMeAPIRepository.ServerErrorException e) {
      //check partial success
      cvByType = TrustMeDocumentDetailsHelper.queryCvByType(uuidByType);
      if (cvByType.isEmpty()) {
        throw new AuraHandledException(e.getMessage());
      }
      urlByType = TrustMeDocumentDetailsHelper.buildUrlByType(cvByType);
      TrustMeDocumentDetailsHelper.logAudit(
        requestModel,
        urlByType,
        caseRec.CaseNumber
      );
      Logger.error('partial file downloaded', e, Logger.Severity.LOW);
      return urlByType;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    } finally {
      Logger.debug(
          DateTimeUtils.timeString +
          ' | Apex execution for TrustMeDocumentDetailsController.getTrustMeDocuments ended'
        )
        .save();
    }
  }
}
