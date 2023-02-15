/**
 * Suppressing PMD naming convention warnings as some fields return in snake case formatting from the API.
 */
@SuppressWarnings(
  'PMD.ExcessivePublicCount, PMD.FieldNamingConventions, PMD.VariableNamingConventions, PMD.TooManyFields, PMD.PropertyNamingConventions'
)
/**
 * @author Victor Wang
 * @since Jan 2023
 * @description Model for Stravinsky Customer Onboarding Primary ID Document related APIs
 */
public with sharing class COBPrimaryIDDocumentModel extends CalloutModel {
  public static final String PASSPORT_TYPE = 'Passport';
  public static final String PASSPORT_UPDATE_MASK =
    'primaryIdDocument.passport.firstName,' +
    'primaryIdDocument.passport.middleNames,' +
    'primaryIdDocument.passport.lastName,' +
    'primaryIdDocument.passport.dateOfBirth.day,' +
    'primaryIdDocument.passport.dateOfBirth.month,' +
    'primaryIdDocument.passport.dateOfBirth.year,' +
    'primaryIdDocument.passport.passportNumber';
  public static final String LICENCE_TYPE = 'Licence';
  public static final String AUSTRALIAN_DRIVER_LICENCE = 'Australian Driver\'s Licence';
  public static final String AUSTRALIAN_DRIVER_LICENCE_UPDATE_MASK =
    'primaryIdDocument.australianDriverLicence.firstName,' +
    'primaryIdDocument.australianDriverLicence.middleNames,' +
    'primaryIdDocument.australianDriverLicence.lastName,' +
    'primaryIdDocument.australianDriverLicence.dateOfBirth.day,' +
    'primaryIdDocument.australianDriverLicence.dateOfBirth.month,' +
    'primaryIdDocument.australianDriverLicence.dateOfBirth.year,' +
    'primaryIdDocument.australianDriverLicence.licenceNumber,' +
    'primaryIdDocument.australianDriverLicence.licenceCardNumber';

  // part of the detokenization api
  public List<DetokenizedValue> values;

  // part of the tokenization request
  public PrimaryIdDocument primaryIdDocument;
  public String updateMask;
  public String caseId;

  // part of the tokenization response
  public DocumentDetail passport;
  public DocumentDetail australianDriverLicence;

  /**
   * @description constructor to build COBPrimaryIDDocumentModel
   * @param idDocumentType either passport or licence
   * @param caseId ID Ops Assistance Case linked to the parent COB record
   */
  public COBPrimaryIDDocumentModel(String idDocumentType, String caseId) {
    if (idDocumentType == PASSPORT_TYPE) {
      this.updateMask = PASSPORT_UPDATE_MASK;
    } else if (idDocumentType == LICENCE_TYPE) {
      this.updateMask = AUSTRALIAN_DRIVER_LICENCE_UPDATE_MASK;
    }

    this.caseId = caseId;
    this.primaryIdDocument = new PrimaryIdDocument();
  }

  /**
   * @description COB Primary Document ID Update API PrimaryIdDocument Data wrapper
   */
  public class PrimaryIdDocument {
    public String name;
    public DocumentDetail australianDriverLicence;
    public DocumentDetail passport;
  }

  /**
   * @description COB Primary Document ID Update API document detail Data wrapper
   */
  public class DocumentDetail {
    public String firstName;
    public String middleNames;
    public String lastName;
    public String licenceNumber;
    public TokenizedValue licenceNumberToken;
    public String licenceCardNumber;
    public TokenizedValue licenceCardNumberToken;
    public String passportNumber;
    public TokenizedValue passportNumberToken;
    public DateOfBirth dateOfBirth;

    /**
     * @description Constructor for inner DocumentDetail class
     * @param firstName first name on COBPID
     * @param middleNames middle names on COBPID
     * @param lastName last name on COBPID
     */
    public DocumentDetail(
      String firstName,
      String middleNames,
      String lastName
    ) {
      this.firstName = firstName;
      this.middleNames = middleNames;
      this.lastName = lastName;
    }
  }

  /**
   * @description COB Primary Document ID Update API dateOfBirth Data wrapper
   */
  public class DateOfBirth {
    public Integer year;
    public Integer month;
    public Integer day;

    /**
     * @description Constructor for inner dateOfBirth class
     * @param dob COBPID date
     */
    public DateOfBirth(Date dob) {
      this.year = dob.year();
      this.month = dob.month();
      this.day = dob.day();
    }
  }

  /**
   * @description COB Primary Document ID Tokenized Data wrapper
   */
  public class TokenizedValue {
    public String Tokenized;
    public String Transform;
    public String value;

    /**
     * @description Constructor for inner TokenizedValue class
     * @param tokenizedValue COBPID record tokenized field value
     */
    public TokenizedValue(String tokenizedValue) {
      this.Tokenized = tokenizedValue;
      this.Transform = 'fpe.personal-identifier';
    }
  }

  /**
   * @description COB Primary Document ID Detokenized Data wrapper
   */
  public class DetokenizedValue {
    @AuraEnabled
    public String Tokenized;
    @AuraEnabled
    public String Detokenized;
  }

  /**
   * @param json input string to deserialize
   * @return `COBPrimaryIDDocumentModel`
   * @description deserializes the input string into the model
   */
  public static COBPrimaryIDDocumentModel parse(String json) {
    return (COBPrimaryIDDocumentModel) deserialize(
      json,
      COBPrimaryIDDocumentModel.class
    );
  }

  /**
   * @param pid COBPrimaryIDDocument__c record with field values
   * @param fields COBPrimaryIDDocument__c fields
   * @return `List<TokenizedValue>`
   * @description build a set of predefined fields into a list of apex-defined class Tokenized Value,
   * like for Passport__c = 'dF23Xf', we convert it to a {Tokenized: 'dF23Xf', Transform: 'fpe.personal-identifier'}
   */
  public static List<TokenizedValue> buildTokenizedValues(
    COBPrimaryIDDocument__c pid,
    List<String> fields
  ) {
    List<TokenizedValue> tokenizedValues = new List<TokenizedValue>();

    for (String fieldName : fields) {
      TokenizedValue tv = new TokenizedValue((String) pid.get(fieldName));
      tokenizedValues.add(tv);
    }

    return tokenizedValues;
  }

  /**
   * @description method to build request body for update COBPID api call
   * @param record cobpid record
   * @return `COBPrimaryIDDocumentModel`
   */
  public static COBPrimaryIDDocumentModel buildUpdateRequestBody(
    COBPrimaryIDDocument__c record
  ) {
    List<Case> idOpsCases = [
      SELECT Id
      FROM Case
      WHERE
        PersonaId__c = :record.PersonaId__c
        AND RecordTypeId = :GetHelpConstants.ID_OPS_ASSISTANCE_RT_ID
      ORDER BY LastModifiedDate DESC
      LIMIT 1
    ];

    String caseId = '';

    if (!idOpsCases.isEmpty()) {
      caseId = idOpsCases[0]?.Id;
    }

    COBPrimaryIDDocumentModel requestBody = new COBPrimaryIDDocumentModel(
      record.IdDocumentType__c,
      caseId
    );

    COBPrimaryIDDocumentModel.DocumentDetail detail = new COBPrimaryIDDocumentModel.DocumentDetail(
      record.FirstName__c,
      record.MiddleNames__c,
      record.LastName__c
    );

    COBPrimaryIDDocumentModel.DateOfBirth dob = new COBPrimaryIDDocumentModel.DateOfBirth(
      record.DateOfBirth__c
    );

    if (record.IdDocumentType__c == PASSPORT_TYPE) {
      requestBody.primaryIdDocument.name = PASSPORT_TYPE;
      requestBody.primaryIdDocument.passport = detail;
      requestBody.primaryIdDocument.passport.dateOfBirth = dob;
      requestBody.primaryIdDocument.passport.passportNumber = record.PassportNumber__c;
    } else if (record.IdDocumentType__c == LICENCE_TYPE) {
      requestBody.primaryIdDocument.name = AUSTRALIAN_DRIVER_LICENCE;
      requestBody.primaryIdDocument.australianDriverLicence = detail;
      requestBody.primaryIdDocument.australianDriverLicence.dateOfBirth = dob;
      requestBody.primaryIdDocument.australianDriverLicence.licenceNumber = record.LicenceNumber__c;
      requestBody.primaryIdDocument.australianDriverLicence.licenceCardNumber = record.LicenceCardNumber__c;
    }

    return requestBody;
  }
}
