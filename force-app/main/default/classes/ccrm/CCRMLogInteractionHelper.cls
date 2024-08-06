/**
 * @author Naman Garg
 * @since 06/2024
 * @description This is Helper class for CCRMLogInteractionController class.
 */
public with sharing class CCRMLogInteractionHelper {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final CCRMLogInteractionRepository LI_REPOSITORY = (CCRMLogInteractionRepository) Lib_InstanceProvider.forType(
    CCRMLogInteractionRepository.class
  );

  /**
   * @description This method is used to fetch the comment type and its default text
   * @name getCommentTypeMapping
   * @return String serialized Map<String, String>
   */
  public static String retrieveCommentTypeMapping() {
    List<CCRM_Log_Interaction_Comment__mdt> commentTypeList = LI_REPOSITORY.queryCommentType();
    Map<String, String> commentTypeMapping = formCommentTypeMap(
      commentTypeList
    );
    return JSON.serialize(commentTypeMapping);
  }

  /**
   * @description This method is used to form the map of the comment type and its default text
   * @param commentTypeList List of CCRM_Log_Interaction_Comment__mdt records
   * @return Map<String, String> Map of Comment type and its Default Text
   */
  @testVisible
  private static Map<String, String> formCommentTypeMap(
    List<CCRM_Log_Interaction_Comment__mdt> commentTypeList
  ) {
    Map<String, String> commentTypeMappingMap = new Map<String, String>();
    for (
      CCRM_Log_Interaction_Comment__mdt logInteractionItr : commentTypeList
    ) {
      if (
        logInteractionItr.Active_Flag__c == false ||
        commentTypeMappingMap.containsKey(logInteractionItr.Comment_Type__c)
      ) {
        continue;
      }
      commentTypeMappingMap.put(
        logInteractionItr.Comment_Type__c,
        logInteractionItr.Default_Text__c
      );
    }
    return commentTypeMappingMap;
  }

  /**
   * @description This method is used to fetch the lookup values
   * @name retrieveSearchResult
   * @param recordId Id of the customer
   * @param searchKey search key that user input on the UI
   * @return List<LookupSearchWrapper> containing the records
   */
  public static List<CCRMLogInteractionController.LookupSearchWrapper> retrieveSearchResult(
    String recordId,
    String searchKey
  ) {
    List<CCRMLogInteractionController.LookupSearchWrapper> resultList = new List<CCRMLogInteractionController.LookupSearchWrapper>();
    List<FinServ__FinancialAccountRole__c> financialAccountRoleList = LI_REPOSITORY.getFinancialAccountRole(
      recordId,
      searchKey
    );

    String iconName = CommonUtil.getObjectIconName(
      FinServ__FinancialAccount__c.SObjectType
    );
    resultList = populateLookupSearchWrapper(
      financialAccountRoleList,
      iconName
    );
    return resultList;
  }

  /**
   * @description This method is used to form the lookup Wrapper
   * @param financialAccountRoleList List of FinServ__FinancialAccountRole__c records
   * @param iconName Name of the object Tab icon
   * @return List<LookupSearchWrapper> List of LookupSearchWrapper
   */
  @testVisible
  private static List<CCRMLogInteractionController.LookupSearchWrapper> populateLookupSearchWrapper(
    List<FinServ__FinancialAccountRole__c> financialAccountRoleList,
    String iconName
  ) {
    List<CCRMLogInteractionController.LookupSearchWrapper> lookupSearchWrapList = new List<CCRMLogInteractionController.LookupSearchWrapper>();
    for (
      FinServ__FinancialAccountRole__c finAccRoleItr : financialAccountRoleList
    ) {
      CCRMLogInteractionController.LookupSearchWrapper result = new CCRMLogInteractionController.LookupSearchWrapper(
        finAccRoleItr.Id,
        iconName,
        finAccRoleItr.FinServ__FinancialAccount__r.Name,
        finAccRoleItr.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
        finAccRoleItr.FinServ__FinancialAccount__c
      );
      lookupSearchWrapList.add(result);
    }
    return lookupSearchWrapList;
  }
}
