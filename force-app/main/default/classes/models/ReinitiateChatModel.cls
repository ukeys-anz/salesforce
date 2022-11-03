/**
 * @author Peter Charalambous
 * @since September 2022
 * @description model for reinititating chat
 * @group Models
 */
public with sharing class ReinitiateChatModel extends CalloutModel {
  @AuraEnabled
  public String executionSid;

  /**
   * @param json input string to deserialize
   * @return `InitiateReinitiateChatModelChatModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static ReinitiateChatModel parse(String json) {
    return (ReinitiateChatModel) deserialize(json, ReinitiateChatModel.class);
  }
}
