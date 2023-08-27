/**
 * @author Ankit Garg
 * @since June 2023
 * @description extended service class for OCV maintain party api
 * @group Service
 */
public with sharing class DCRMMaintainPartyService extends Service {
  private static final String CRM = 'CRM';
  private static final String STATUS_PROSPECT = 'Prospect';
  private static final String PARTY_TYPE = 'P';
  private static final String MOBILE_TELEPHONE = 'Mobile Telephone';
  private static final String PRIMARY_HOME_TELEPHONE = 'Primary Home Telephone';
  private static final String PRIMARY_BUSINESS_TELEPHONE = 'Primary Business Telephone';
  private static final String LEGAL_NAME = 'Legal Name';
  private static final String EMAIL_VALUE = 'Email';
  /**
   * @param record lead record from the lwc component
   * @return HttpCalloutResponse
   * @description gathers all the parameters required for callout
   */
  public override HttpCalloutResponse maintainParty(Lead record) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    List<Lead> leadList = new List<Lead>{ record };
    Map<Id, User> mapOfLanId = CCRMUserActions.getMapOfLanIds(leadList, false);
    String operatorId = mapOfLanId.containsKey(record.OwnerId)
      ? mapOfLanId.get(record.OwnerId).Lan_Id__c
      : '';
    String requestTime = String.valueOf(System.now()) + '.00'; // appended with ms as required by API mesh

    headers.put('Content-Type', 'application/json');
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('x-correlation-id', UniqueIdUtil.getTraceId());
    headers.put('Channel', 'CRM');
    headers.put('request-time', requestTime);
    if (!String.isBlank(operatorId)) {
      headers.put('user-id', operatorId);
    } else {
      // Throw custom exception
      throw new CustomException(Label.MLCRM_User_LAN_Id_Error);
    }
    String body = getBody(record);
    String endPoint = 'callout:SF_MS_Party' + Label.MS_Maintain_Party;
    return calloutService.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      body
    );
  }

  /**
   * @description Define custom exceptions
   */
  public class CustomException extends Exception {
  }

  /**
   * @param record lead record from the lwc component
   * @return String
   * @description creates the request body for callout
   */
  public static String getBody(Lead record) {
    PartyMaintain maintainPartyReq = new PartyMaintain();
    maintainPartyReq.partyType = PARTY_TYPE;
    maintainPartyReq.source = CRM;
    maintainPartyReq.status = STATUS_PROSPECT;

    //Add Phones
    if (record.MobilePhone != null) {
      Phones mobilePhone = new Phones();
      mobilePhone.source = CRM;
      mobilePhone.preferred = 'Y';
      mobilePhone.phoneUsageType = MOBILE_TELEPHONE;
      mobilePhone.phone = record.MobilePhone;

      maintainPartyReq.phones.add(mobilePhone);
    }
    if (record.Home_Phone__c != null) {
      Phones homePhone = new Phones();
      homePhone.source = CRM;
      homePhone.preferred = 'Y';
      homePhone.phoneUsageType = PRIMARY_HOME_TELEPHONE;
      homePhone.phone = record.Home_Phone__c;
      maintainPartyReq.phones.add(homePhone);
    }
    if (record.Work_Phone__c != null) {
      Phones workPhone = new Phones();
      workPhone.source = CRM;
      workPhone.preferred = 'Y';
      workPhone.phoneUsageType = PRIMARY_BUSINESS_TELEPHONE;
      workPhone.phone = record.Work_Phone__c;
      maintainPartyReq.phones.add(workPhone);
    }

    //Add Names
    Names name = new Names();
    name.source = CRM;
    name.nameUsageType = LEGAL_NAME;
    name.title = String.isNotBlank(record.Salutation)
      ? record.Salutation
      : null;
    name.firstName = String.isNotBlank(record.FirstName)
      ? record.FirstName
      : null;
    name.middleName = String.isNotBlank(record.MiddleName)
      ? record.MiddleName
      : null;
    name.lastName = String.isNotBlank(record.lastName) ? record.lastName : null;
    //Add Gender only for Individual
    maintainPartyReq.gender = String.isNotBlank(record.Gender__c)
      ? record.Gender__c
      : null;
    maintainPartyReq.names.add(name);

    //Add Email Address
    if (record.Email != null) {
      Emails email = new Emails();
      email.source = CRM;
      email.preferred = 'Y';
      email.emailUsageType = EMAIL_VALUE;
      email.email = record.Email;
      maintainPartyReq.emails.add(email);
    }

    //add address
    if (record.Is_Valid_Address__c) {
      Addresses address = new Addresses();
      address.source = CRM;
      address.addressUsageType = 'Primary Residential';
      address.addressLineOne = record.Street;
      address.city = record.City;
      address.state = record.State;
      address.country = record.Country;
      address.postalCode = record.PostalCode;
      maintainPartyReq.addresses.add(address);
    }
    return Json.serialize(maintainPartyReq, true);
  }

  /**
   * @description  Wrapper class to build the body
   */
  private class PartyMaintain {
    private String partyType; //P
    private String source; //CRM
    private String status; //Prospect
    private String gender; //F
    private List<Names> names = new List<Names>();
    private List<Phones> phones = new List<Phones>();
    private List<Emails> emails = new List<Emails>();
    private List<Addresses> addresses = new List<Addresses>();
  }

  /**
   * @description  Wrapper class to build the body
   */
  private class Addresses {
    private String source; //CRM
    private String addressUsageType; //Primary Residential
    private String addressLineOne; //56-M
    private String city; //Melbourne
    private String state; //VIC
    private String postalCode; //3168
    private String country; //AUS
  }

  /**
   * @description  Wrapper class to build the body
   */
  private class Phones {
    private String source; //CRM
    private String phoneUsageType; //Primary Home Telephone, Primary Business Telephone, Mobile Telephone
    private String phone; //0412345678
    private String preferred; //Y
  }

  /**
   * @description  Wrapper class to build the body
   */
  private class Emails {
    private String source; //CRM
    private String emailUsageType; //Email
    private String email; //abc@anz.com
    private String preferred; //Y
  }

  /**
   * @description  Wrapper class to build the body
   */
  private class Names {
    private String source; //CRM
    private String title; //Mr
    private String nameUsageType; //Legal Name
    private String firstName; //MARY
    private String middleName; //JOHN
    private String lastName; //NAPOLI
  }
}
