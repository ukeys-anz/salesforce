/**
 * @author Boobalakrishnan Duraisamy
 * @since Apr 2022
 * @description model for CCRM get selected address API
 * @group Models
 */
public with sharing class CCRMGetSelectedAddressModel extends CalloutModel {
  @AuraEnabled
  public String addressType;
  @AuraEnabled
  public String levelNumber;
  @AuraEnabled
  public String streetNumber;
  @AuraEnabled
  public String streetName;
  @AuraEnabled
  public String street;
  @AuraEnabled
  public String streetType;
  @AuraEnabled
  public String city;
  @AuraEnabled
  public String state;
  @AuraEnabled
  public Integer postalCode;
  @AuraEnabled
  public String deliveryIdentifier;
  @AuraEnabled
  public String countryCode;
  @AuraEnabled
  public String countryCodeThree;
  @AuraEnabled
  public Decimal latitude;
  @AuraEnabled
  public Decimal longitude;

  /**
   * @param json input string to deserialize
   * @return CCRMGetSelectedAddressModel
   * @description deserializes the input string into the model
   */
  public static CCRMGetSelectedAddressModel parse(String json) {
    return (CCRMGetSelectedAddressModel) System.JSON.deserialize(
      json,
      CCRMGetSelectedAddressModel.class
    );
  }
}
