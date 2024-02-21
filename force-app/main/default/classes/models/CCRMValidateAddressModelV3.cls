/**
 * @author ANKIT GARG
 * @since Jan 2024
 * @description model for CCRM validate address API v3
 * 	Suppress "PMD.VariableNamingConventions, PMD.FieldNamingConventions": field names are mapped from web service response
 * @group Models
 */
@SuppressWarnings('PMD.VariableNamingConventions, PMD.FieldNamingConventions')
public with sharing class CCRMValidateAddressModelV3 extends CalloutModel {
  @AuraEnabled
  public Integer count;
  @AuraEnabled
  public List<Result> result;

  /**
   * @description address search result wrapper
   */
  public class Result {
    @AuraEnabled
    public String global_address_key;
    @AuraEnabled
    public String address;
    @AuraEnabled
    public Integer score;
  }

  /**
   * @param json input string to deserialize
   * @return CCRMValidateAddressModelV3
   * @description deserializes the input string into the model
   */
  public static CCRMValidateAddressModelV3 parse(String json) {
    return (CCRMValidateAddressModelV3) System.JSON.deserialize(
      json,
      CCRMValidateAddressModelV3.class
    );
  }
}
