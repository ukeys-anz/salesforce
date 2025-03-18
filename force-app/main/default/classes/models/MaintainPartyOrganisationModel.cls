/**
 * @author Mildeep Pahw
 * @since Jan 2025
 * @description model for OCV Maintain Party API Organisation
 * @group Models
 */
public with sharing class MaintainPartyOrganisationModel extends CalloutModel {
  private static final String CRM = 'CRM';
  private static final String STATUS_PROSPECT = 'Prospect';
  private static final String PARTY_TYPE_ORG = 'O';
  private static final String LEGAL_NAME = 'Legal';
  private static final String EMAIL_VALUE = 'Email';
  private static final String EMAIL_PREFERRED = 'Y';
  private static final String PRIMARY_RESIDENTAIL = 'Principal Place of Business';
  private static final String IDENTIFIER_ABN = 'ABN';
  private static final String IDENTIFIER_ACN = 'ACN';
  /**
   * @description Constructor
   */
  public MaintainPartyOrganisationModel() {
  }
  /**
   * @param record requestwrapper payload from the lwc component
   * @return String
   * @description creates the request body/payload for callout
   */
  public static string getBody(OCVRequestPayloadWrapper record) {
    PartyMaintain maintainPartyReq = new PartyMaintain();
    maintainPartyReq.partyType = PARTY_TYPE_ORG;
    maintainPartyReq.source = CRM;
    maintainPartyReq.status = STATUS_PROSPECT;
    maintainPartyReq.organisationType = record.strOrganisationType;

    //Add Names
    Names names = new Names();
    names.source = CRM;
    names.nameUsageType = LEGAL_NAME;
    names.name = String.isNotBlank(record.strName) ? record.strName : null;
    names.startDate = String.isNotBlank(record.strStartDate)
      ? record.strStartDate
      : null;
    maintainPartyReq.names.add(names);
    //Add Email
    if (String.isNotBlank(record.strEmail)) {
      Emails email = new Emails();
      email.source = CRM;
      email.preferred = EMAIL_PREFERRED;
      email.emailUsageType = EMAIL_VALUE;
      email.email = record.strEmail;
      maintainPartyReq.emails.add(email);
    }
    //add address
    if (record.isValidStreet) {
      Addresses address = new Addresses();
      address.source = CRM;
      address.addressUsageType = PRIMARY_RESIDENTAIL;
      address.addressLineOne = record.strStreet;
      address.city = record.strCity;
      address.state = record.strState;
      address.postalCode = record.strPostalCode;
      address.country = record.strCountry;
      maintainPartyReq.addresses.add(address);
    }

    //add identifiers
    if (String.isNotBlank(record.strABNIdentifier)) {
      // Add ABN Identifier
      Identifiers abnIdentifier = new Identifiers();
      abnIdentifier.identifier = record.strABNIdentifier;
      abnIdentifier.source = CRM;
      abnIdentifier.identifierUsageType = IDENTIFIER_ABN;
      abnIdentifier.startDate = record.strIdentifiersStartDate;
      abnIdentifier.expiryDate = record.strIdentifiersExpiryDate;
      maintainPartyReq.identifiers.add(abnIdentifier);
    }

    if (String.isNotBlank(record.strACNIdentifier)) {
      // Add ACN Identifier
      Identifiers acnIdentifier = new Identifiers();
      acnIdentifier.identifier = record.strACNIdentifier;
      acnIdentifier.source = CRM;
      acnIdentifier.identifierUsageType = IDENTIFIER_ACN;
      acnIdentifier.startDate = record.strIdentifiersStartDate;
      acnIdentifier.expiryDate = record.strIdentifiersExpiryDate;
      maintainPartyReq.identifiers.add(acnIdentifier);
    }

    //add commercialContacts
    CommercialContacts commercialContacts = new CommercialContacts();
    commercialContacts.phone = record.strCommercialContactsPhone;
    commercialContacts.mobile = record.strCommercialContactsMobile;
    commercialContacts.name = record.strCommercialContactsName;
    commercialContacts.title = record.strCommercialContactsTitle;
    maintainPartyReq.commercialContacts.add(commercialContacts);
    //add industry
    Industry industry = new Industry();
    industry.code = record.strIndustryCode;
    maintainPartyReq.Industry = industry;
    return Json.serialize(maintainPartyReq, true);
  }
  /**
   * @description  Wrapper class to build the body
   */
  private class PartyMaintain {
    private String partyType; //O
    private String source; //CRM
    private String status; //Prospect
    private String organisationType; // 04
    private List<Names> names = new List<Names>();
    private List<Emails> emails = new List<Emails>();
    private List<Addresses> addresses = new List<Addresses>();
    private List<Identifiers> identifiers = new List<Identifiers>();
    private List<CommercialContacts> commercialContacts = new List<CommercialContacts>();
    Industry industry = new Industry();
  }
  /**
   * @description  Wrapper class to build the body
   */
  private class Names {
    private String source; //CRM
    private String nameUsageType; //Legal
    private String name; //JOHN
    private String startDate; //"2023-12-20"
  }
  /**
   * @description  Wrapper class to build the body
   */
  private class Emails {
    private String source; //CRM
    private String emailUsageType; //Email
    private String preferred; //Y
    private String email; //abc@anz.com
  }
  /**
   * @description  Wrapper class to build the body
   */
  private class Addresses {
    private String source; //CRM
    private String addressUsageType; //Principal Place of Business
    private String addressLineOne; //56-M
    private String city; //Melbourne
    private String state; //VIC
    private String postalCode; //3168
    private String country; //AUS
  }
  /**
   * @description  Wrapper class to build the body
   */
  private class Identifiers {
    private String source; //CRM
    private String identifierUsageType; //ABN / ACN - TBD ##
    private String identifier; // 32790228959 - TBD ##
    private String startDate; //2023-12-20
    private String expiryDate; //""
  }
  /**
   * @description  Wrapper class to build the body
   */
  private class CommercialContacts {
    private String phone; // +61412345378
    private String mobile; // +61412345378
    private String name; // John Smith
    private String title; // Mr
  }
  /**
   * @description  Wrapper class to build the body
   */
  private class Industry {
    private String code; // 0011
  }
}
