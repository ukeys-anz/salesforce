/**
 * @author Boobalakrishnan Duraisamy
 * @since Apr 2022
 * @description model for CCRM validate address API
 * @group Models
 */
public with sharing class CCRMValidateAddressModel extends CalloutModel {
  @AuraEnabled
  public Integer count;
  @AuraEnabled
  public List<Result> result;

  /**
   * @description address search result wrapper
   */
  public class Result {
    @AuraEnabled
    public String addressId;
    @AuraEnabled
    public String encodedAddressId;
    @AuraEnabled
    public String address;
    @AuraEnabled
    public Integer score;
  }

  /**
   * @param json input string to deserialize
   * @return CCRMValidateAddressModel
   * @description deserializes the input string into the model
   */
  public static CCRMValidateAddressModel parse(String json) {
    return (CCRMValidateAddressModel) System.JSON.deserialize(
      json,
      CCRMValidateAddressModel.class
    );
  }
}
