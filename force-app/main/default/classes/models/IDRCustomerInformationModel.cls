/**
 * @author Adnan
 * @since Sep 2021
 * @description model for CMOS get customer information API (IDRAPIRepository), extending the base
 * @group Models
 */
public with sharing class IDRCustomerInformationModel extends CalloutModel {
  /**
   * @description details wrapper
   */
  public class Details {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String phoneNumber;
    @AuraEnabled
    public List<Address> address;
  }

  @AuraEnabled
  public IDRCustomerProfile profile;
  @AuraEnabled
  public RelationshipManager relationshipManager;
  @AuraEnabled
  public List<Accounts> accounts;

  /**
   * @description address wrapper
   */
  public class Address {
    @AuraEnabled
    public String addressLine1;
    @AuraEnabled
    public String addressLine2;
  }

  /**
   * @description relationship manager wrapper wrapper
   */
  public class RelationshipManager {
    @AuraEnabled
    public Details details;
    @AuraEnabled
    public Error error;
  }

  /**
   * @description error wrapper containing error message
   */
  public class Error {
    @AuraEnabled
    public String message;
  }

  /**
   * @description accounts wrapper
   */
  public class Accounts {
    @AuraEnabled
    public String accountNumber;
    @AuraEnabled
    public String productCode;
    @AuraEnabled
    public String subProductCode;
  }

  /**
   * @param json input string to deserialize
   * @return IDRCustomerInformationModel
   * @description deserializes the input string into the model
   */
  public static IDRCustomerInformationModel parse(String json) {
    return (IDRCustomerInformationModel) System.JSON.deserialize(
      json,
      IDRCustomerInformationModel.class
    );
  }
}
