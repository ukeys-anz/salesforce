/**
 * @author Prahlad Bhadani
 * @since  31/July/2024
 * @group MLCRM (Mobile Lending CRM)
 * @description OCRRelatedListController is controller class for OCR Related list LWC.
 */
public with sharing class OCRRelatedListController {
  private static final OCRRelatedListRepository CTRL_REPOSITORY = (OCRRelatedListRepository) Lib_InstanceProvider.forType(
    OCRRelatedListRepository.class
  );
  /**
   * @description called from ocrRelatedList component
   * @name getOcrListForCustomer
   * @param inputWrapper wrapper for all required inputs
   * @return OCRRelatedListController.OcrResultWrapper
   */
  @AuraEnabled
  public static OcrResultWrapper getOcrListForCustomer(
    OCRParamsWrapper inputWrapper
  ) {
    try {
      if (String.isBlank(inputWrapper.recordId)) {
        return null;
      }
      Account customer = CTRL_REPOSITORY.getCustomer(inputWrapper.recordId);
      inputWrapper.personContactId = customer?.PersonContactId;
      if (String.isBlank(inputWrapper.personContactId)) {
        return null;
      }
      OcrResultWrapper resWrap = new OcrResultWrapper();
      resWrap.relatedRecordList = CTRL_REPOSITORY.getRecordsList(inputWrapper);
      resWrap.countOfRecords = inputWrapper.pageSize != null
        ? CTRL_REPOSITORY.countRecords(
            inputWrapper.personContactId,
            inputWrapper.recordId
          )
        : resWrap.relatedRecordList.size();
      return resWrap;
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description return wrapper for getOcrListForCustomer
   */
  public class OcrResultWrapper {
    /**
     * @description related OpportunityContactRole record list
     */
    @AuraEnabled
    public List<OpportunityContactRole> relatedRecordList { get; set; }
    /**
     * @description count of related OpportunityContactRole record
     */
    @AuraEnabled
    public Integer countOfRecords { get; set; }
  }

  /**
   * @description input wrapper for getOcrListForCustomer
   */
  public class OCRParamsWrapper {
    /**
     * @description Record Id  of related Opportunity record
     */
    @AuraEnabled
    public String recordId { get; set; }
    /**
     * @description no of records to be displayed
     */
    @AuraEnabled
    public Integer pageSize { get; set; }
    /**
     * @description field selected for sorting
     */
    @AuraEnabled
    public String sortByField { get; set; }
    /**
     * @description sort order - asc/desc
     */
    @AuraEnabled
    public String sortOrder { get; set; }
    /**
     * @description Id of PersonContact of account
     */
    @AuraEnabled
    public String personContactId { get; set; }
  }
}
