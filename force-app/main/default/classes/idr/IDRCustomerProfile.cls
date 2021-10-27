/**
 * @author Adnan
 * @since Oct 2021
 * @description Customer Profile Wrapper class
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDRCustomerProfile {
  @AuraEnabled
  public String customerId;
  @AuraEnabled
  public String ocvId;
  @AuraEnabled
  public Object cpId;
  @AuraEnabled
  public String complainantType;
  @AuraEnabled
  public Object businessName;
  @AuraEnabled
  public Object companyName;
  @AuraEnabled
  public String firstName;
  @AuraEnabled
  public String mobile;
  @AuraEnabled
  public String phone;
  @AuraEnabled
  public String gender;
  @AuraEnabled
  public String email;
  @AuraEnabled
  public String dob;
  @AuraEnabled
  public String age;
  @AuraEnabled
  public String suburb;
  @AuraEnabled
  public String street;
  @AuraEnabled
  public String state;
  @AuraEnabled
  public String postCode;
  @AuraEnabled
  public String country;
}
