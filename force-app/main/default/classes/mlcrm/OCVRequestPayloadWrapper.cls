/**
 * @author Ashish Kumar
 * @since  07/August/2023
 * @description Wrapper class for OCV Request creationwrapper to call maintain party api
 */
public class OCVRequestPayloadWrapper {
  @AuraEnabled
  public Id strOwnerId;
  @AuraEnabled
  public Boolean isValidStreet;
  @AuraEnabled
  public String strStreet;
  @AuraEnabled
  public String strCity;
  @AuraEnabled
  public String strState;
  @AuraEnabled
  public String strCountry;
  @AuraEnabled
  public String strPostalCode;
  @AuraEnabled
  public String strMobilePhone;
  @AuraEnabled
  public String strHomePhone;
  @AuraEnabled
  public String strWorkPhone;
  @AuraEnabled
  public String strEmail;
  @AuraEnabled
  public String strSalutation;
  @AuraEnabled
  public String strFirstName;
  @AuraEnabled
  public String strMiddleName;
  @AuraEnabled
  public String strLastName;
  @AuraEnabled
  public String strGender;
  @AuraEnabled
  public String strRecordId;
}
