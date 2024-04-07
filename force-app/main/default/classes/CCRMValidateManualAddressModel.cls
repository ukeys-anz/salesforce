/**
 * @author Ashish Kumar
 * @since Jan 2024
 * @description manual address validate result wrapper class
 * @group CCRM
 */
public class CCRMValidateManualAddressModel {
  @AuraEnabled
  public List<Result> result;
  @AuraEnabled
  public Boolean hasValidAddress;

  /**
   * @description manual address validate result wrapper
   */
  public class Result {
    @AuraEnabled
    public Integer postCode;
    @AuraEnabled
    public String state;
    @AuraEnabled
    public String suburb;
    @AuraEnabled
    public String deliveryOffice;
    @AuraEnabled
    public String category;
    @AuraEnabled
    public String pointOfOrigin;
  }

  /**
   * @param json input string to deserialize
   * @return CCRMValidateManualAddressModel
   * @description deserializes the input string into the model
   */
  public static CCRMValidateManualAddressModel parse(String json) {
    return (CCRMValidateManualAddressModel) System.JSON.deserialize(
      json,
      CCRMValidateManualAddressModel.class
    );
  }
}
