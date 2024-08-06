/**
 * @author Victor Wang
 * @since Jan 2023
 * @description Response Model for Stravinsky Updating Primary ID Document
 */
public with sharing class COBPrimaryIDDocumentModel extends CalloutModel {
  public static final String TOKEN_TRANSFORM_VALUE = 'fpe.personal-identifier';
  static final String PASSPORT_TYPE = 'Passport';
  static final String AUSTRALIAN_DRIVER_LICENCE = 'Australian Driver\'s Licence';
  //use in api response
  public String name;
  public AustralianDriverLicence australianDriverLicence;
  public Passport passport;

  /**
   * @description constructor to build COBPrimaryIDDocumentModel.Passport response
   * @param passport the Passport record object
   */
  public COBPrimaryIDDocumentModel(Passport passport) {
    this.name = PASSPORT_TYPE;
    this.passport = passport;
  }

  /**
   * @description constructor to build COBPrimaryIDDocumentModel.Passport response
   * @param licence the Passport record object
   */
  public COBPrimaryIDDocumentModel(AustralianDriverLicence licence) {
    this.name = AUSTRALIAN_DRIVER_LICENCE;
    this.australianDriverLicence = licence;
  }

  /**
   * @description Common Details use for Passport and Licence
   */
  public virtual class Details {
    public String firstName;
    public String middleNames;
    public String lastName;
    public DateWrapper dateOfBirth;
    public DateWrapper expiryDate;

    /**
     * @description Constructor for inner DocumentDetails class
     * @param idDocument the COBPrimaryIDDocument__c record
     */
    public Details(COBPrimaryIDDocument__c idDocument) {
      this.firstName = idDocument.FirstName__c;
      this.middleNames = idDocument.MiddleNames__c;
      this.lastName = idDocument.LastName__c;
      this.dateOfBirth = new DateWrapper(idDocument.DateOfBirth__c);
      this.expiryDate = new DateWrapper(idDocument.ExpiryDate__c);
    }
  }

  /**
   * @description Passport Data wrapper
   */
  public class Passport extends Details {
    public String countryOfIssue;
    public String passportNumber;
    public TokenizedValue passportNumberToken;
    public String passportNumberOCRServer;
    public TokenizedValue passportNumberOCRServerToken;

    /**
     * @description Constructor for inner Passport class
     * @param idDocument the COBPrimaryIDDocument__c record
     */
    public Passport(COBPrimaryIDDocument__c idDocument) {
      super(idDocument);
      this.passportNumber = idDocument.PassportNumber__c;
      this.countryOfIssue = idDocument.CountryOfIssue__c;
    }
  }

  /**
   * @description AustralianDriverLicence Data wrapper
   */
  public class AustralianDriverLicence extends Details {
    public String stateOfIssue;
    public String licenceNumber;
    public TokenizedValue licenceNumberToken;
    public String licenceNumberOCRServer;
    public TokenizedValue licenceNumberOCRServerToken;
    public String licenceCardNumber;
    public TokenizedValue licenceCardNumberToken;
    public String licenceCardNumberOCRServer;
    public TokenizedValue licenceCardNumberOCRServerToken;

    /**
     * @description Constructor for inner AustralianDriverLicence class
     * @param idDocument the COBPrimaryIDDocument__c record
     */
    public AustralianDriverLicence(COBPrimaryIDDocument__c idDocument) {
      super(idDocument);
      this.licenceNumber = idDocument.LicenceNumber__c;
      this.licenceCardNumber = idDocument.LicenceCardNumber__c;
      this.stateOfIssue = idDocument.StateOfIssue__c;
    }
  }

  /**
   * @description COB Primary ID Document Dates' data wrapper
   */
  public class DateWrapper {
    public Integer year;
    public Integer month;
    public Integer day;

    /**
     * @description Constructor for inner DateWrapper class
     * @param d COBPID date, either dateOfBirth or expiryDate
     */
    public DateWrapper(Date d) {
      this.year = d.year();
      this.month = d.month();
      this.day = d.day();
    }
  }

  /**
   * @param json input string to deserialize
   * @return `COBPrimaryIDDocumentModel`
   * @description deserializes the input string into the model
   */
  public static COBPrimaryIDDocumentModel parse(String json) {
    try {
      return (COBPrimaryIDDocumentModel) deserialize(
        json,
        COBPrimaryIDDocumentModel.class
      );
    } catch (Exception ex) {
      throw CommonUtil.logException(ex);
    }
  }
}
