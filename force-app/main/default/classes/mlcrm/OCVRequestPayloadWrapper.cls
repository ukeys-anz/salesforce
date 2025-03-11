/**
 * @author Ashish Kumar
 * @since  07/August/2023
 * @description Wrapper class for OCV Request creationwrapper to call maintain party api
 */
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.TooManyFields')
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
  public String strAdvertisingIndicator; //added as part of CC-6745
  @AuraEnabled
  public String strRecordId;
  @AuraEnabled
  public String strDateOfBirth;

  // added as a part of OCV Org Repointing CC-11990
  @AuraEnabled
  public Boolean isIndividual;

  @AuraEnabled
  public String strOrganisationType;
  @AuraEnabled
  public String strIndustryCode;
  @AuraEnabled
  public String strName;
  @AuraEnabled
  public String strStartDate;
  @AuraEnabled
  public String strCommercialContactsPhone;
  @AuraEnabled
  public String strCommercialContactsMobile;
  @AuraEnabled
  public String strCommercialContactsName;
  @AuraEnabled
  public String strCommercialContactsTitle;
  @AuraEnabled
  public String strABNIdentifier;
  @AuraEnabled
  public String strACNIdentifier;
  @AuraEnabled
  public String strIdentifiersStartDate;
  @AuraEnabled
  public String strIdentifiersExpiryDate;
}
