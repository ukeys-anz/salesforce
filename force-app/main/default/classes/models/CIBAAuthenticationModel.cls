/**
 * @author shawg2
 * @since January 2024
 * @description Simple mode for CIA Authentication response
 *
 */

@SuppressWarnings('PMD.FieldNamingConventions')
public with sharing virtual class CIBAAuthenticationModel {
  @AuraEnabled
  public String auth_req_id;
  @AuraEnabled
  public Integer expires_in;
  @AuraEnabled
  public Integer interval;
  //this is only for lwc to get the salesforce record context
  @AuraEnabled
  public String authHistoryId;

  /**
   * @param json input string to deserialize
   * @return CIBAAuthenticationModel
   * @description deserializes the input string into the model
   */
  public static CIBAAuthenticationModel parse(String json) {
    return (CIBAAuthenticationModel) System.JSON.deserialize(
      json,
      CIBAAuthenticationModel.class
    );
  }
}
