/**
 * @author Naman Garg
 * @since 06/2024
 * @description This is controller class for logInteractionOnCustomer Lightning Web Component.
 */

public with sharing class CCRMLogInteractionController {
  /**
   * @description This method is used to fetch the comment type and its default text
   * @name getCommentTypeMapping
   * @return String serialized Map<String, String>
   */
  @AuraEnabled
  public static CCRMInteractionCommentsWrapper getCommentTypeMapping() {
    try {
      CCRMInteractionCommentsWrapper commentWrap = new CCRMInteractionCommentsWrapper();
      commentWrap.commentType = CCRMLogInteractionHelper.retrieveCommentTypeMapping();
      return commentWrap;
    } catch (Exception e) {
      Logger.error('Error occured while fetching comment type', e);
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description This method is used to fetch the lookup values
   * @name getSearchResult
   * @param recordId Id of the customer
   * @param searchKey search key that user input on the UI
   * @return List<LookupSearchWrapper> containing the records
   */
  @AuraEnabled
  public static List<LookupSearchWrapper> getSearchResult(
    String recordId,
    String searchKey
  ) {
    try {
      List<LookupSearchWrapper> resultList = CCRMLogInteractionHelper.retrieveSearchResult(
        recordId,
        searchKey
      );
      return resultList;
    } catch (Exception e) {
      Logger.error('Error occured while fetching Financial Account', e);
      Logger.saveLog();
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @author Naman Garg
   * @since 06/2024
   * @description This is Wrapper class for Log Interction UI
   */
  public class CCRMInteractionCommentsWrapper {
    /**
     * @description comment Type value
     */
    @AuraEnabled
    public String commentType;
  }

  /**
   * @author Naman Garg
   * @since 06/2024
   * @description This is Wrapper class for Lookup Search.
   */
  public class LookupSearchWrapper {
    /**
     * @description uniqueId Id of the Customer Record
     */
    @AuraEnabled
    public String uniqueId { get; set; }
    /**
     * @description iconName icon that will display on the lookup
     */
    @AuraEnabled
    public String iconName { get; set; }
    /**
     * @description label heading of the lookup value
     */
    @AuraEnabled
    public String label { get; set; }
    /**
     * @description subLabel sub heading of the lookup value
     */
    @AuraEnabled
    public String subLabel { get; set; }
    /**
     * @description id Id of the related record
     */
    @AuraEnabled
    public String id { get; set; }

    /**
     * @description constructor of the LookupSearchWrapper
     * @param uniqueId Id of the Customer Record
     * @param iconName icon that will display on the lookup
     * @param label heading of the lookup value
     * @param subLabel sub heading of the lookup value
     * @param id Id of the related record
     */
    public LookupSearchWrapper(
      String uniqueId,
      String iconName,
      String label,
      String subLabel,
      String id
    ) {
      this.uniqueId = uniqueId;
      this.iconName = iconName;
      this.label = label;
      this.subLabel = subLabel;
      this.id = id;
    }
  }
}
