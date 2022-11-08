/**
 * @author Boobalakrishnan Duraisamy
 * @since May 2022
 * @description extended service class for OCV search party api
 * @group Service
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class CCRMSearchPartyService extends Service {
  /**
   * @param record lead record from the lwc component
   * @return HttpCalloutResponse
   * @description gathers all the parameters required for callout
   */
  public override HttpCalloutResponse searchPartyInfo(Lead record) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('Content-Type', 'application/json');
    headers.put('channel', 'CCRM');
    String body = getBody(record);
    String endPoint =
      'callout:SF_MS_Party' +
      Label.MS_Search_Party +
      Label.MS_Search_Party_Params;
    return calloutService.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_POST,
      headers,
      body
    );
  }

  /**
   * @param record lead record from the lwc component
   * @return String
   * @description creates the request body for callout
   */
  public static String getBody(Lead record) {
    SearchPartyRequest searchPartyReq = new SearchPartyRequest();
    searchPartyReq.partyType = record.Entity_Type__c == 'Individual'
      ? 'P'
      : 'O';
    //add address
    if (record.Is_Valid_Address__c) {
      Addresses address = new Addresses();
      address.addressLineOne = record.Street;
      address.city = record.City;
      address.state = record.State;
      address.country = record.Country;
      address.postalCode = record.PostalCode;
      searchPartyReq.addresses.add(address);
    }

    //Add Phones
    if (record.MobilePhone != null) {
      Phones mobilePhone = new Phones();
      mobilePhone.phone = record.MobilePhone;
      searchPartyReq.phones.add(mobilePhone);
    }
    if (record.Home_Phone__c != null) {
      Phones homePhone = new Phones();
      homePhone.phone = record.Home_Phone__c;
      searchPartyReq.phones.add(homePhone);
    }
    if (record.Work_Phone__c != null) {
      Phones workPhone = new Phones();
      workPhone.phone = record.Work_Phone__c;
      searchPartyReq.phones.add(workPhone);
    }

    //Add Email Address
    if (record.Email != null) {
      Emails email = new Emails();
      email.email = record.Email;
      searchPartyReq.emails.add(email);
    }

    //Add identifiers ABN & ACN
    if (String.isNotBlank(record.ABN__c)) {
      Identifiers abn = new Identifiers();
      abn.identifierUsageType = 'ABN';
      abn.identifier = record.ABN__c.deleteWhitespace();
      searchPartyReq.identifiers.add(abn);
    }
    if (String.isNotBlank(record.ACN__c)) {
      Identifiers acn = new Identifiers();
      acn.identifierUsageType = 'ACN';
      acn.identifier = record.ACN__c.deleteWhitespace();
      searchPartyReq.identifiers.add(acn);
    }

    //Add Names
    Names name = new Names();
    if (record.Entity_Type__c == 'Individual') {
      name.title = String.isNotBlank(record.Salutation)
        ? record.Salutation
        : null;
      name.firstName = String.isNotBlank(record.FirstName)
        ? record.FirstName
        : null;
      name.middleName = String.isNotBlank(record.MiddleName)
        ? record.MiddleName
        : null;
      name.lastName = String.isNotBlank(record.lastName)
        ? record.lastName
        : null;
      //Add Gender only for Individual
      searchPartyReq.gender = String.isNotBlank(record.Gender__c)
        ? record.Gender__c
        : null;
    } else {
      name.name = String.isNotBlank(record.Company) ? record.Company : null;
    }
    searchPartyReq.names.add(name);
    return Json.serialize(searchPartyReq, true);
  }

  /**
   * @description  Wrapper class to build the body
   */
  public class SearchPartyRequest {
    public String partyType; //P
    public String gender;
    public List<Addresses> addresses = new List<Addresses>();
    public List<Phones> phones = new List<Phones>();
    public List<Emails> emails = new List<Emails>();
    public List<Identifiers> identifiers = new List<Identifiers>();
    public List<Names> names = new List<Names>();
  }

  /**
   * @description  Wrapper class to build the body
   */
  public class Addresses {
    public String addressLineOne; //56-M
    public String city; //Melbourne
    public String postalCode; //3168
    public String state; //VIC
    public String country; //AUS
  }

  /**
   * @description  Wrapper class to build the body
   */
  public class Phones {
    public String phone; //0412345678
  }

  /**
   * @description  Wrapper class to build the body
   */
  public class Emails {
    public String email; //abc@anz.com
  }

  /**
   * @description  Wrapper class to build the body
   */
  public class Identifiers {
    public String identifierUsageType; //ABN
    public String identifier; //12345679801
  }

  /**
   * @description  Wrapper class to build the body
   */
  public class Names {
    public String name; //ABC Pvt Ltd
    public String title; //Mr
    public String firstName; //MARY
    public String middleName; //JOHN
    public String lastName; //NAPOLI
  }
}
