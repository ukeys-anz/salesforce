/**
 * @author Mani
 * @since 12/2024
 * @description This acts as a model class legal name update case types to publish cloud events
 * refer https://github.com/anzx/apis/blob/main/anz/salesforceapis/salesforce/service/profileupdate/v1alpha1/profileupdate_event.proto
 */
public virtual with sharing class LegalNameCaseCloudEventModel extends CaseCloudEventModel {
  private static final string EVENT_TYPE = System.Label.ANZX_ProfileUpdate_Event_Type_v1alpha1;
  private static final string DATA_SCHEMA = System.Label.ANZX_LegalName_Event_DataSchema_v1alpha1;
  private static Map<string, string> dataSchemaMap = new Map<string, string>{
    ProfileUpdateCaseActions.PASS => 'LegalNameUpdatePassEvent',
    ProfileUpdateCaseActions.FAILED_DOCUMENT_INVALID => 'LegalNameUpdateFailedDocumentInvalidEvent',
    ProfileUpdateCaseActions.FAILED_DOCUMENT_QUALITY => 'LegalNameUpdateFailedDocumentQualityEvent'
  };
  private static Map<string, string> eventTypeMap = new Map<string, string>{
    ProfileUpdateCaseActions.PASS => 'legalnameupdate.pass',
    ProfileUpdateCaseActions.FAILED_DOCUMENT_INVALID => 'legalnameupdate.failed_document_provided_invalid',
    ProfileUpdateCaseActions.FAILED_DOCUMENT_QUALITY => 'legalnameupdate.failed_document_quality_issue'
  };

  private static final string DOC_TYPE_PASSPORT = 'DOCUMENT_TYPE_AUSTRALIAN_PASSPORT';
  private static final string DOC_TYPE_LICENCE = 'DOCUMENT_TYPE_AUSTRALIAN_DRIVERS_LICENCE';
  private static final string DOC_TYPE_MARRIAGE_CERT = 'DOCUMENT_TYPE_AUSTRALIAN_MARRIAGE_CERTIFICATE';

  /**
   * @description Get an instance of LegalNameCaseCloudEventModel
   * @param theCase Case record
   */
  public LegalNameCaseCloudEventModel(Case theCase) {
    super(theCase, theCase.Account);
    ce_type = EVENT_TYPE + eventTypeMap.get(theCase.Fraud_Review_Outcome__c);
    ce_dataschema =
      DATA_SCHEMA + dataSchemaMap.get(theCase.Fraud_Review_Outcome__c);
    UserModel theOwner;
    if (theCase.Owner instanceof User) {
      theOwner = new UserModel((User) theCase.Owner);
    } else {
      theOwner = new UserModel((Group) theCase.Owner);
    }
    this.ce_data = new LegalNameCaseCloudEventDataModel(
      theCase,
      theCase.Account,
      theOwner
    );
  }

  /**
   * @description the model for LegalName Case cloud event data part
   */
  public virtual class LegalNameCaseCloudEventDataModel extends CloudEventModel.CloudEventDataModel {
    /**
     * @description LegalNameCase data
     */
    public LegalNameCase data { get; set; }

    /**
     * @description Get an instance of LegalNameCaseCloudEventDataModel
     * @param theCase Case record
     * @param theAccount Account record
     * @param theOwner Owner record
     */
    public LegalNameCaseCloudEventDataModel(
      Case theCase,
      Account theAccount,
      UserModel theOwner
    ) {
      this.data = new LegalNameCase(theCase, theAccount, theOwner);
    }
  }

  /**
   * @description LegalNameCase
   */
  public virtual class LegalNameCase {
    /**
     * @description ProfileUpdate Case details
     */
    public CaseDetail caseDetail { get; set; }
    /**
     * @description Legal Name
     */
    public LegalName legalName { get; set; }
    /**
     * @description DAON Document
     */
    public DaonDocument daonDocument { get; set; }
    /**
     * @description Manual Document Check
     */
    public ManualDocumentCheck manualDocumentCheck { get; set; }
    /**
     * @description ID Document Check
     */
    public IDDocumentCheck idDocumentCheck { get; set; }
    /**
     * @description DVS Verification Outcome
     */
    public DVSVerificationOutcome dvsVerificationOutcome { get; set; }
    /**
     * @description Review Outcome
     */
    public ReviewOutcome reviewOutcome { get; set; }

    /**
     * @description Get an instance of LegalNameCase
     * @param theCase Case record
     * @param theAccount Account record
     * @param theOwner Owner record
     */
    public LegalNameCase(Case theCase, Account theAccount, UserModel theOwner) {
      this.caseDetail = new CaseDetail(theCase, theAccount, theOwner);
      this.legalName = new LegalName(theCase);
      this.daonDocument = new DaonDocument(theCase);
      this.manualDocumentCheck = new ManualDocumentCheck(theCase);
      this.idDocumentCheck = new IDDocumentCheck(theCase);
      this.dvsVerificationOutcome = new DVSVerificationOutcome(theCase);
      this.reviewOutcome = new ReviewOutcome(theCase);
    }
  }

  /**
   * @description the model for CaseDetail - extends the Case CaseCloudEventDataModel and adds additional fields
   */
  public virtual class CaseDetail extends CaseCloudEventDataModel {
    /**
     * @description Case SystemData
     */
    public CloudEventSystemModel systemData { get; set; }

    /**
     * @description Get an instance of CaseDetail
     * @param theCase Case record
     * @param theAccount Account record
     * @param theOwner Owner record
     */
    public CaseDetail(Case theCase, Account theAccount, UserModel theOwner) {
      super(theCase, theAccount, theOwner);
      this.origin = ProfileUpdateEnum.channelReceived.getProtoKey(
        theCase.Origin
      );
      this.priority = ProfileUpdateEnum.priority.getProtoKey(theCase.Priority);
      this.status = ProfileUpdateEnum.status.getProtoKey(theCase.Status);
      this.systemData = new CloudEventSystemModel(
        theCase.LastModifiedDate,
        theCase.lastModifiedBy
      );
    }
  }

  /**
   * @description Customer Legal Name
   */
  public class LegalName {
    /**
     * @description Customer First Name
     */
    public string firstName { get; set; }
    /**
     * @description Customer Middle Name
     */
    public string middleName { get; set; }
    /**
     * @description Customer Last Name
     */
    public string lastName { get; set; }

    /**
     * @description Get an instance of LegalName
     * @param theCase Case record
     */
    public LegalName(Case theCase) {
      this.firstName = theCase.NewFirstName__c;
      this.middleName = theCase.NewMiddleName__c;
      this.lastName = theCase.NewLastName__c;
    }
  }

  /**
   * @description
   */
  public class DaonDocument {
    /**
     * @description Daon Document Id
     */
    public string documentId { get; set; }
    /**
     * @description Daon Check Id
     */
    public string idxIdCheckId { get; set; }
    /**
     * @description Daon User Id
     */
    public string idxUserId { get; set; }
    /**
     * @description Person Id
     */
    public string personId { get; set; }
    /**
     * @description Aegis workflow vId
     */
    public string workflowId { get; set; }

    /**
     * @description Get an instance of DaonDocument
     * @param theCase Case record
     */
    public DaonDocument(Case theCase) {
      this.documentId = theCase.Daon_Document_Id__c;
      this.idxIdCheckId = theCase.Daon_Check_Id__c;
      this.idxUserId = theCase.Daon_User_Id__c;
      this.personId = '';
      this.workflowId = theCase.Aegis_Workflow_Id__c;
    }
  }

  /**
   * @description
   */
  public class ManualDocumentCheck {
    /**
     * @description if the request for a name correction
     */
    public string nameCorrection { get; set; }
    /**
     * @description if the supporting document is valid
     */
    public string acceptableDocumentType { get; set; }
    /**
     * @description if the supporting document quality is valid
     */
    public string acceptableDocumentQuality { get; set; }
    /**
     * @description if there is link between old identity and new name
     */
    public string linkBetweenOldIdentityAndNewName { get; set; }

    /**
     * @description when the doc type is passport/ licence/ Name change cert/ Birth cert
     */
    public string nameOnIdMatchesTheNameRequested { get; set; }
    /**
     * @description when the doc type in Marriage cert
     */
    public string namesCertificateSupportNameRequested { get; set; }

    /**
     * @description when the doc type is passport/ licence
     */
    public string photoOnIdMatchesSelfieOnFile { get; set; }
    /**
     * @description when the doc type in Name change cert/ Birth cert/ Marriage cert
     */
    public string certificateShowsCurrentContactName { get; set; }

    /**
     * @description applicable for all the doc type
     */
    public string dateOfBirthOnIdMatchesProfile { get; set; }

    /**
     * @description Get an instance of ManualDocumentCheck
     * @param theCase Case record
     */
    public ManualDocumentCheck(Case theCase) {
      this.nameCorrection = ProfileUpdateEnum.yesNoList.getProtoKey(
        theCase.NameCorrection__c
      );
      this.acceptableDocumentType = ProfileUpdateEnum.yesNoList.getProtoKey(
        theCase.AcceptableDocumentType__c
      );
      this.acceptableDocumentQuality = ProfileUpdateEnum.yesNoList.getProtoKey(
        theCase.AcceptableDocumentQuality__c
      );
      this.linkBetweenOldIdentityAndNewName = ProfileUpdateEnum.yesNoList.getProtoKey(
        theCase.LinkBetweenOldIdentityAndNewName__c
      );

      if (
        theCase.DocumentType__c == DOC_TYPE_PASSPORT ||
        theCase.DocumentType__c == DOC_TYPE_LICENCE
      ) {
        this.photoOnIdMatchesSelfieOnFile = ProfileUpdateEnum.yesNoList.getProtoKey(
          theCase.PhotoOnIDMatchesSelfieOnFile__c
        );
      } else {
        this.certificateShowsCurrentContactName = ProfileUpdateEnum.yesNoList.getProtoKey(
          theCase.CertificateShowsCurrentContactName__c
        );
      }
      if (theCase.DocumentType__c == DOC_TYPE_MARRIAGE_CERT) {
        this.namesCertificateSupportNameRequested = ProfileUpdateEnum.yesNoList.getProtoKey(
          theCase.NamesCertificateSupportNameRequested__c
        );
      } else {
        this.nameOnIdMatchesTheNameRequested = ProfileUpdateEnum.yesNoList.getProtoKey(
          theCase.NameOnIDMatchesTheNameRequested__c
        );
      }

      this.dateOfBirthOnIdMatchesProfile = ProfileUpdateEnum.yesNoList.getProtoKey(
        theCase.DateOfBirthOnIDMatchesProfile__c
      );
    }
  }

  /**
   * @description IDDocumentCheck
   */
  public class IDDocumentCheck {
    /**
     * @description supporting document type
     */
    public string documentType { get; set; }
    /**
     * @description when passport is attached
     */
    public Passport passport { get; set; }
    /**
     * @description when licence is attached
     */
    public Licence licence { get; set; }
    /**
     * @description when Name change cert/ Birth cert/ Marriage cert is attached
     */
    public Certificate certificate { get; set; }

    /**
     * @description Get an instance of IDDocumentCheck
     * @param theCase Case record
     */
    public IDDocumentCheck(Case theCase) {
      this.documentType = theCase.DocumentType__c;
      if (theCase.DocumentType__c == DOC_TYPE_PASSPORT) {
        this.passport = new Passport(theCase);
      } else if (theCase.DocumentType__c == DOC_TYPE_LICENCE) {
        this.licence = new Licence(theCase);
      } else {
        this.certificate = new Certificate(theCase);
      }
    }
  }

  /**
   * @description Passport
   * */
  public class Passport {
    /**
     * @description tokenised passport number
     */
    public string passportNumber { get; set; }
    /**
     * @description passport expiry date
     */
    public FabricType.FabricDate expiryDate { get; set; }
    /**
     * @description passport issued country code, 3 digit code
     */
    public string coutryCode { get; set; }

    /**
     * @description Get an instance of Passport
     * @param theCase Case record
     */
    public Passport(Case theCase) {
      this.passportNumber = theCase.PassportNumber__c;
      this.expiryDate = new FabricType.FabricDate(theCase.ExpiryDate__c);
      this.coutryCode = theCase.CountryCode__c;
    }
  }

  /**
   * @description Licence
   */
  public class Licence {
    /**
     * @description tokenised licence number
     */
    public string licenceNumber { get; set; }
    /**
     * @description tokenised licence card number
     */
    public string licenceCardNumber { get; set; }
    /**
     * @description licence expiry date
     */
    public FabricType.FabricDate expiryDate { get; set; }
    /**
     * @description licence issued state code, 3 digit code
     */
    public string stateCode { get; set; }

    /**
     * @description Get an instance of Licence
     * @param theCase Case record
     */
    public Licence(Case theCase) {
      this.licenceNumber = theCase.LicenceNumber__c;
      this.licenceCardNumber = theCase.LicenceCardNumber__c;
      this.expiryDate = new FabricType.FabricDate(theCase.ExpiryDate__c);
      this.stateCode = theCase.StateCode__c;
    }
  }

  /**
   * @description Certificate
   */
  public class Certificate {
    /**
     * @description type of certificate id
     * eg certificate numnber/ registration number/ registration date
     */
    public string certificateUniqueIdType { get; set; }
    /**
     * @description tokenised cetificate number
     */
    public string certificateUniqueId { get; set; }
    /**
     * @description cetificate registration date
     */
    public FabricType.FabricDate registrationDate { get; set; }
    /**
     * @description certificate expiry date
     */
    public FabricType.FabricDate expiryDate { get; set; }
    /**
     * @description certificate issued state code, 3 digit code
     */
    public string stateCode { get; set; }

    /**
     * @description Get an instance of Certificate
     * @param theCase Case record
     */
    public Certificate(Case theCase) {
      this.certificateUniqueIdType = theCase.CertificateIdentifierType__c;
      this.certificateUniqueId = theCase.CertificateIdentifier__c;
      this.registrationDate = new FabricType.FabricDate(
        theCase.RegistrationDate__c
      );
      this.expiryDate = new FabricType.FabricDate(theCase.ExpiryDate__c);
      this.stateCode = theCase.StateCode__c;
    }
  }

  /**
   * @description DVS Verification Outcome
   */
  public class DVSVerificationOutcome {
    /**
     * @description DVS verfication request number
     */
    public string verificationRequest { get; set; }
    /**
     * @description DVS verfication outcome
     */
    public string verificationOutcome { get; set; }

    /**
     * @description Get an instance of DVSVerificationOutcome
     * @param theCase Case record
     */
    public DVSVerificationOutcome(Case theCase) {
      this.verificationRequest = theCase.VerificationRequest__c;
      this.verificationOutcome = theCase.VerificationOutcome__c;
    }
  }

  /**
   * @description Review Outcome
   */
  public class ReviewOutcome {
    /**
     * @description review outcome Pass/ Failed - Document Provided Invalid/ Failed - Document Quality Issue
     */
    public string reviewOutcome { get; set; }
    /**
     * @description reason for review failure
     */
    public string documentFailureReason { get; set; }

    /**
     * @description Get an instance of ReviewOutcome
     * @param theCase Case record
     */
    public ReviewOutcome(Case theCase) {
      this.reviewOutcome = theCase.Fraud_Review_Outcome__c;
      this.documentFailureReason = theCase.DocumentFailureReason__c;
    }
  }
}
