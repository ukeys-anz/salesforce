/**
 * @author Tan Phan
 * @since Nov 2022
 * @description model for CCRM validate address API v2
 * 	Suppress "PMD.VariableNamingConventions, PMD.FieldNamingConventions": field names are mapped from web service response
 * @group Models
 */
@SuppressWarnings('PMD.VariableNamingConventions, PMD.FieldNamingConventions')
public with sharing class CCRMValidateAddressModelV2 extends CalloutModel {
  @AuraEnabled
  public Result result;

  /**
   * @description address search result wrapper
   */
  public class Result {
    @AuraEnabled
    public Suggestion[] suggestions;
  }

  /**
   * @description address search result wrapper
   */
  public class Suggestion {
    @AuraEnabled
    public String global_address_key;
    @AuraEnabled
    public String text;
  }

  /**
   * @param json input string to deserialize
   * @return CCRMValidateAddressModelV2
   * @description deserializes the input string into the model
   */
  public static CCRMValidateAddressModelV2 parse(String json) {
    return (CCRMValidateAddressModelV2) System.JSON.deserialize(
      json,
      CCRMValidateAddressModelV2.class
    );
  }
}
