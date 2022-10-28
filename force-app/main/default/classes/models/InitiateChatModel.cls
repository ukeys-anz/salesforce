/**
 * @author Peter Charalambous
 * @since August 2022
 * @description model for inititating chat
 * @group Models
 */
public with sharing class InitiateChatModel extends CalloutModel {
  @AuraEnabled
  public String conversationSid;
  @AuraEnabled
  public String caseId;

  /**
   * @param json input string to deserialize
   * @return `InitiateChatModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static InitiateChatModel parse(String json) {
    return (InitiateChatModel) deserialize(json, InitiateChatModel.class);
  }
}
