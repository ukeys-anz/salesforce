/**
 * @author Tan Phan
 * @since Nov 2022
 * @description model for CCRM get selected address API v2
 * 	Suppress "PMD.VariableNamingConventions, PMD.FieldNamingConventions": field names are mapped from web service response
 * @group Models
 * @runTests CCRMValidateAddressModelTest
 */
@SuppressWarnings('PMD.VariableNamingConventions, PMD.FieldNamingConventions')
public with sharing class CCRMGetSelectedAddressModelV2 extends CalloutModel {
  @AuraEnabled
  public Result result;
  @AuraEnabled
  public Metadata metadata;

  /**
   * @description address format result wrapper
   */
  public class Result {
    @AuraEnabled
    public String global_address_key;
    @AuraEnabled
    public Address address;
    @AuraEnabled
    public Components components;
  }

  /**
   * @description address format result wrapper
   */
  public class Components {
    @AuraEnabled
    public String country_iso_2;
  }

  /**
   * @description address format result wrapper
   */
  public class Address {
    @AuraEnabled
    public String address_line_1;
    @AuraEnabled
    public String address_line_2;
    @AuraEnabled
    public String address_line_3;
    @AuraEnabled
    public String locality;
    @AuraEnabled
    public String region;
    @AuraEnabled
    public String postal_code;
    @AuraEnabled
    public String country;
  }

  /**
   * @description address format result wrapper
   */
  public class Metadata {
    @AuraEnabled
    public AddressInfo address_info;
  }

  /**
   * @description address format result wrapper
   */
  public class AddressInfo {
    @AuraEnabled
    public Identifier identifier;
  }

  /**
   * @description address format result wrapper
   */
  public class Identifier {
    @AuraEnabled
    public String dpid;
    @AuraEnabled
    public String hin;
  }

  /**
   * @param json input string to deserialize
   * @return CCRMGetSelectedAddressModelV2
   * @description deserializes the input string into the model
   */
  public static CCRMGetSelectedAddressModelV2 parse(String json) {
    return (CCRMGetSelectedAddressModelV2) System.JSON.deserialize(
      json,
      CCRMGetSelectedAddressModelV2.class
    );
  }
}
