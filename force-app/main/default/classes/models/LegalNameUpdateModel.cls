/**
 * @author Mani
 * @since Jan 2025
 * @description Request Payload Model for Legal Name Update in OCV
 */
public with sharing class LegalNameUpdateModel {
  /**
   * @description Default Values
   */
  @TestVisible
  private static final String CHANNEL_VALUE = 'AX3';
  @TestVisible
  private static final String CUSTOMER_IDENTIFIER_USAGE_TYPE = 'One Customer ID';
  @TestVisible
  private static final String DRIVER_LICENCE_CARD_NUMBER = 'DL Card Number';
  @TestVisible
  private static final String ENTITY_RELATIONSHIP_TYPE = 'Name Change Evidence Document';
  @TestVisible
  private static final String NAME_USAGE_TYPE = 'Legal Name';
  @TestVisible
  private static final String PARTY_TYPE = 'P';
  @TestVisible
  private static final String SOURCE_VALUE = 'AX3';
  @TestVisible
  private static final DateTime START_DATE = Datetime.now();
  @TestVisible
  private static final String VERIFICATION_ATTRIBUTE = 'Name Change Verification';
  @TestVisible
  private static final String VERIFICATION_METHOD = 'Name Document Verification';
  @TestVisible
  private static final String VERIFIED_BY = 'Self Service';
  @TestVisible
  private static final String DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE = 'DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE';
  private static final String DOCUMENT_TYPE_AUSTRALIAN_CHANGE_OF_NAME_CERTIFICATE = 'DOCUMENT_TYPE_AUSTRALIAN_CHANGE_OF_NAME_CERTIFICATE';
  @TestVisible
  private static final String DOCUMENT_TYPE_AUSTRALIAN_DRIVERS_LICENCE = 'DOCUMENT_TYPE_AUSTRALIAN_DRIVERS_LICENCE';
  private static final String DOCUMENT_TYPE_AUSTRALIAN_MARRIAGE_CERTIFICATE = 'DOCUMENT_TYPE_AUSTRALIAN_MARRIAGE_CERTIFICATE';
  @TestVisible
  private static final String DOCUMENT_TYPE_AUSTRALIAN_PASSPORT = 'DOCUMENT_TYPE_AUSTRALIAN_PASSPORT';

  @TestVisible
  private static final Map<String, String> DOC_TYPE_MAP = new Map<String, String>{
    DOCUMENT_TYPE_AUSTRALIAN_BIRTH_CERTIFICATE => 'Birth Document',
    DOCUMENT_TYPE_AUSTRALIAN_CHANGE_OF_NAME_CERTIFICATE => 'Change of Name',
    DOCUMENT_TYPE_AUSTRALIAN_DRIVERS_LICENCE => 'Drivers Licence',
    DOCUMENT_TYPE_AUSTRALIAN_MARRIAGE_CERTIFICATE => 'Marriage Certificate',
    DOCUMENT_TYPE_AUSTRALIAN_PASSPORT => 'Passport'
  };

  /**
   * @description Individual Customer
   */
  public String partyType;
  /**
   * @description Source System Name
   */
  public String source;
  /**
   * @description List of Customer Identifiers
   */
  public List<CustomerIdentifier> identifiers;
  /**
   * @description List of Legal Name Details with Changes
   */
  public List<Name> names;
  /**
   * @description List of Source System Details
   */
  public List<SourceSystem> sourceSystems;

  /**
   * @description Create new instance of LegalNameUpdateModel
   * @param theCase Case record
   * @param acc Account record
   */
  public LegalNameUpdateModel(Case theCase, Account acc) {
    this.partyType = PARTY_TYPE;
    this.source = SOURCE_VALUE;
    this.identifiers = new List<LegalNameUpdateModel.CustomerIdentifier>{
      new LegalNameUpdateModel.CustomerIdentifier(acc.OCV_ID__c)
    };
    this.names = new List<LegalNameUpdateModel.Name>{
      new LegalNameUpdateModel.Name(theCase)
    };
    this.sourceSystems = new List<LegalNameUpdateModel.SourceSystem>{
      new LegalNameUpdateModel.SourceSystem(
        acc.Source_System_ID__c,
        acc.Source_System_Name__c
      )
    };
  }

  /**
   * @description Customer Identifier (e.g OCV Id of the Customer)
   */
  public class CustomerIdentifier {
    public String identifierUsageType;
    public String identifier;

    /**
     * @description Create new instance of LegalNameUpdateModel.CustomerIdentifier
     * @param ocvId the Customer's OCV_ID__c
     */
    public CustomerIdentifier(String ocvId) {
      this.identifierUsageType = CUSTOMER_IDENTIFIER_USAGE_TYPE;
      this.identifier = ocvId;
    }
  }

  /**
   * @description Source System Details from Account Record
   */
  public class SourceSystem {
    public String sourceSystemId;
    public String sourceSystemName;

    /**
     * @description Create new instance of LegalNameUpdateModel.SourceSystem
     * @param sourceSystemId the Customer's Source_System_ID__c
     * @param sourceSystemName the Customer's Source_System_Name__c
     */
    public SourceSystem(String sourceSystemId, String sourceSystemName) {
      this.sourceSystemId = sourceSystemId;
      this.sourceSystemName = sourceSystemName;
    }
  }

  /**
   * @description Legal Name Details (e.g. new FirstName, MiddleName, LastName)
   */
  public class Name {
    public DateTime endDate;
    public String firstName;
    public String lastName;
    public String middleName;
    public String nameUsageType;
    public String source;
    public DateTime startDate;
    public List<LegalNameUpdateModel.RelatedEntity> relatedEntities;
    public List<LegalNameUpdateModel.VerificationDetail> verificationDetails;

    /**
     * @description Create new instance of LegalNameUpdateModel.Name
     * @param theCase the Case record
     */
    public Name(Case theCase) {
      this.firstName = theCase.NewFirstName__c;
      this.lastName = theCase.NewLastName__c;
      this.middleName = theCase.NewMiddleName__c;
      this.nameUsageType = NAME_USAGE_TYPE;
      this.source = SOURCE_VALUE;
      this.startDate = START_DATE;
      this.relatedEntities = new List<LegalNameUpdateModel.RelatedEntity>{
        new LegalNameUpdateModel.RelatedEntity(theCase)
      };
      this.verificationDetails = new List<LegalNameUpdateModel.VerificationDetail>{
        new LegalNameUpdateModel.VerificationDetail()
      };
    }
  }

  /**
   * @description Verification Detail
   */
  public class VerificationDetail {
    public String channel;
    public String documentReference;
    public DateTime endDate;
    public DateTime reVerificationDate;
    public String reVerificationTimeDesignator;
    public String reVerificationTimeInterval;
    public DateTime startDate;
    public String verificationAttribute;
    public String verificationMethod;
    public String verifiedBy;
    public DateTime verifiedDate;

    /**
     * @description Create new instance of LegalNameUpdateModel.VerificationDetail
     */
    public VerificationDetail() {
      this.channel = CHANNEL_VALUE;
      this.startDate = START_DATE;
      this.verificationAttribute = VERIFICATION_ATTRIBUTE;
      this.verificationMethod = VERIFICATION_METHOD;
      this.verifiedBy = VERIFIED_BY;
      this.verifiedDate = Datetime.now();
    }
  }

  /**
   * @description Supporting Evidences Used for Legal Name Change
   */
  public class RelatedEntity {
    public String entityRelationshipType;
    public String source;
    public List<LegalNameUpdateModel.DocumentIdentifier> identifiers;

    /**
     * @description Create new instance of LegalNameUpdateModel.RelatedEntity
     * @param theCase the Case record
     */
    public RelatedEntity(Case theCase) {
      this.entityRelationshipType = ENTITY_RELATIONSHIP_TYPE;
      this.source = SOURCE_VALUE;
      this.identifiers = new List<LegalNameUpdateModel.DocumentIdentifier>{
        new LegalNameUpdateModel.DocumentIdentifier(theCase)
      };
    }
  }

  /**
   * @description Document Details Submitted for Legal Name change evidence
   */
  public class DocumentIdentifier {
    public DateTime endDate;
    public DateTime expiryDate;
    public String identificationIssueLocation;
    public String identificationCountry;
    public String identificationState;
    public String identifier;
    public String identifierUsageType;
    public String source;
    public DateTime startDate;
    public List<LegalNameUpdateModel.DocumentRelatedIdentifier> relatedIdentifiers;

    /**
     * @description Create new instance of LegalNameUpdateModel.DocumentIdentifier
     * @param theCase the Case record
     */
    public DocumentIdentifier(Case theCase) {
      String encryptedIdentifier;

      if (theCase.DocumentType__c == DOCUMENT_TYPE_AUSTRALIAN_PASSPORT) {
        encryptedIdentifier = theCase.PassportNumber__c;
      } else if (
        theCase.DocumentType__c == DOCUMENT_TYPE_AUSTRALIAN_DRIVERS_LICENCE
      ) {
        encryptedIdentifier = theCase.LicenceNumber__c;
        this.relatedIdentifiers = new List<LegalNameUpdateModel.DocumentRelatedIdentifier>{
          new LegalNameUpdateModel.DocumentRelatedIdentifier(theCase)
        };
      } else {
        encryptedIdentifier = theCase.CertificateIdentifier__c;
      }

      this.expiryDate = theCase.ExpiryDate__c;
      this.identificationIssueLocation = theCase.CountryCode__c;
      this.identificationCountry = theCase.CountryCode__c;
      this.identificationState = theCase.StateCode__c;
      this.identifierUsageType = DOC_TYPE_MAP.get(theCase.DocumentType__c);
      this.identifier = 'enc(' + encryptedIdentifier + ')';
      this.source = SOURCE_VALUE;
      this.startDate = START_DATE;
    }
  }

  /**
   * @description Related Document Details (e.g. Licence Card Number for Driver's Licence)
   */
  public class DocumentRelatedIdentifier {
    public String identificationCountry;
    public String identificationState;
    public String identifierUsageType;
    public String identifier;
    public String source;

    /**
     * @description Create new instance of LegalNameUpdateModel.DocumentIdentifier
     * @param theCase the Case record
     */
    public DocumentRelatedIdentifier(Case theCase) {
      this.identificationCountry = theCase.CountryCode__c;
      this.identificationState = theCase.StateCode__c;
      this.identifierUsageType = DRIVER_LICENCE_CARD_NUMBER;
      this.identifier = 'enc(' + theCase.LicenceCardNumber__c + ')';
      this.source = SOURCE_VALUE;
    }
  }
}
