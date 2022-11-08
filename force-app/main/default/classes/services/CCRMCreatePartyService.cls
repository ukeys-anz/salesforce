/**
 * @author Boobalakrishnan Duraisamy
 * @since Aug 2022
 * @description extended service class for CAP create party api
 * @group Service
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class CCRMCreatePartyService extends Service {
  /**
   * @param record lead record from the lwc component
   * @return HttpCalloutResponse
   * @description gathers all the parameters required for callout
   */
  public override HttpCalloutResponse createParty(Lead record) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    List<Lead> leadList = new List<Lead>{ record };
    Map<Id, User> mapOfLanId = CCRMUserActions.getMapOfLanIds(leadList, false);
    String operatorId = mapOfLanId.containsKey(record.OwnerId)
      ? mapOfLanId.get(record.OwnerId).Lan_Id__c
      : '';

    headers.put('Content-Type', 'application/json');
    headers.put('client_id', '{!$Credential.Username}');
    headers.put('client_secret', '{!$Credential.Password}');
    headers.put('X-Operator-Id', operatorId);
    headers.put('X-Workstation', System.Label.CCRM_CreatePartyWorkStation);
    headers.put('X-Operator-Branch', System.Label.CCRM_CreatePartyBranch);
    headers.put(
      'X-Originating-App',
      System.Label.CCRM_CreatePartyOriginatingApp
    );
    String body = getBody(record);
    String endPoint = 'callout:SF_MS_Party' + Label.MS_Create_Party;
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
    CreatePartyRequest createPartyReq = new CreatePartyRequest();
    createPartyReq.name = String.isNotBlank(record.Company)
      ? '*' + record.Company
      : null;
    createPartyReq.email = String.isNotBlank(record.Email)
      ? record.Email
      : null;
    createPartyReq.customerStatus = 'Prospect';
    createPartyReq.customerType = record.Entity_Type__c;
    createPartyReq.openedDate = String.valueOf(system.today());

    //add address
    if (record.Is_Valid_Address__c) {
      Address address = new Address();
      address.addressLine1 = record.Street;
      address.city = record.City;
      address.postCode = record.PostalCode;
      address.state = record.State;
      address.countryCode = record.Country;
      createPartyReq.addresses.residential = address;
      createPartyReq.addresses.mailing = address;
    }

    //add additional details
    AdditionalDetails addDetails = new AdditionalDetails();
    addDetails.sicCode = record.Industry__r.Code__c;
    if (String.isNotBlank(record.ABN__c) && String.isNotBlank(record.ACN__c)) {
      addDetails.govtRefType = 'Australian Business Number';
      addDetails.govtRefNumberABN = record.ABN__c.deleteWhitespace();
    } else if (String.isNotBlank(record.ABN__c)) {
      addDetails.govtRefType = 'Australian Business Number';
      addDetails.govtRefNumberABN = record.ABN__c.deleteWhitespace();
    } else if (String.isNotBlank(record.ACN__c)) {
      addDetails.govtRefType = 'Australian Company Number';
      addDetails.govtRefNumber = record.ACN__c.deleteWhitespace();
      addDetails.govtRefNumberABN = record.ACN__c.deleteWhitespace();
    }
    addDetails.orgContactPhone = record.Work_Phone__c != null
      ? record.Work_Phone__c
      : null;
    addDetails.orgContactName = record.Name;
    addDetails.orgContactTitle = String.isNotBlank(record.Title__c)
      ? record.Title__c
      : null;
    addDetails.orgContactMobile = record.MobilePhone != null
      ? record.MobilePhone
      : null;
    addDetails.controllingPostId = String.isNotBlank(record.CPID__c)
      ? record.CPID__c
      : '';
    createPartyReq.additionalDetails = addDetails;
    return Json.serialize(createPartyReq, true);
  }

  /**
   * @description  Wrapper class to build the body
   */
  public class CreatePartyRequest {
    public String name;
    public String email;
    public String customerType;
    public String customerStatus;
    public String openedDate;
    public Employment employment = new Employment();
    public Addresses addresses = new Addresses();
    public AdditionalDetails additionalDetails = new AdditionalDetails();
  }

  /**
   * @description  Wrapper class to build the body
   */
  public class Addresses {
    public Address residential;
    public Address mailing;
  }

  /**
   * @description  Wrapper class to build the body
   */
  public class Address {
    public String addressLine1;
    public String city;
    public String postCode;
    public String state;
    public String countryCode;
  }

  /**
   * @description  empty Employment wrapper to avoid issue with CAP
   */
  public class Employment {
  }
  /**
   * @description  Wrapper class to build the body
   */
  public class AdditionalDetails {
    public String sicCode;
    public String govtRefType;
    public String govtRefNumber;
    public String govtRefNumberABN;
    public String orgContactPhone;
    public String orgContactName;
    public String orgContactTitle;
    public String orgContactMobile;
    public String controllingPostId;
  }
}
