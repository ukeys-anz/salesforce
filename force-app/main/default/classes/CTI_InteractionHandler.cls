/**
 * @author Nilesh Kalal
 * @since May 2026
 * @description Controller class to handle CTI Interactions Actions (calls and chats)
 * following the repository pattern and dependency injection framework
 */
public with sharing class CTI_InteractionHandler {
  private static final CTI_InteractionRepository CTI_REPOSITORY = (CTI_InteractionRepository) Lib_InstanceProvider.forType(
    CTI_InteractionRepository.class
  );

  /**
   * @description Handles call accepted event by updating interaction owner
   * @param jsonData JSON string containing CTI details
   * @return Interaction Id if found and updated, null otherwise
   */
  @AuraEnabled
  public static String onCallAccepted(String jsonData) {
    CTIDetailsWrapper ctiDetails = CTIDetailsWrapper.parseCTIJson(jsonData);
    String queryId = getQueryId(ctiDetails);
    Interaction interactionRecord = CTI_REPOSITORY.queryInteractionBySID(
      queryId
    );
    return interactionRecord?.Id;
  }

  /**
   * @description Determines the query ID to use for searching interactions
   * Prioritizes originalContactId over contactId if available
   * @param ctiDetails CTI details wrapper
   * @return Query ID to use for interaction lookup
   */
  private static String getQueryId(CTIDetailsWrapper ctiDetails) {
    String originalContactId = ctiDetails.originalContactId;
    String contactId = ctiDetails.contactId;
    return originalContactId ?? contactId;
  }

  /**
   * @description Fetches the Amazon Connect URL from custom settings
   * @return String the Amazon Connect URL
   */
  @AuraEnabled
  public static String getAmazonConnectUrl() {
    return amazonconnect__Amazon_Connect__c.getInstance(UserInfo.getUserId())
      .URL_Text__c;
  }
}
