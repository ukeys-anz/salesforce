/**
 * @author Batya Aisnman Sufrin
 * @since  08/2023
 * @description Wrapper Class for AutoKYCQA metadata and data
 */
@SuppressWarnings(
  'PMD.ApexDoc, PMD.ExcessivePublicCount, PMD.PropertyNamingConventions, PMD.ExcessiveParameterList'
)
public with sharing class AutoKYCQACaseCloudEventModel extends CaseCloudEventModel {
  private static final Integer RECORD_TYPE_AUTOKYC_QA = 1;
  private static final String AUTO_KYC_QA_SCHEMA = '#AutoKYCQA';

  public AutoKYCQACaseCloudEventModel(
    Case theCase,
    Account theAccount,
    String action,
    User theUser,
    UserModel theOwner,
    CustomerOnboardingApplication__c theCOB
  ) {
    super(theCase, theAccount);
    ce_type = System.Label.ANZX_AutoKYCQA_Event_ce_type + action;
    ce_dataschema =
      System.Label.ANZX_CustomerValidation_Event_Proto_Data_Schema +
      AUTO_KYC_QA_SCHEMA;
    this.ce_data = new AutoKYCQACaseCloudEventDataModel(
      theCase,
      theAccount,
      theOwner,
      theCOB
    );
    this.systemData = new CloudEventSystemModel(
      theCase.LastModifiedDate,
      theUser
    );
  }

  /**
   * @description the model for AutoKYCQA Case cloud event data part
   */
  public class AutoKYCQACaseCloudEventDataModel extends CaseCloudEventModel.CaseCloudEventDataModel {
    public CustomerOnboardingApplicationModel customerOnboardingApplication {
      get;
      set;
    }
    public String parentCase { get; set; }
    public Datetime dateReceived { get; set; }
    public String chatTopicId { get; set; }
    public String subStatus { get; set; }
    public String contactId { get; set; }
    public String contactMobile { get; set; }
    public String fraudCustomerDetails { get; set; }
    public String fraudMiddleNameCheck { get; set; }
    public String fraudSelfieComparisonMatch { get; set; }
    public String fraudPOBox { get; set; }
    public String fraudAddressValid { get; set; }
    public String fraudRestraintStatus { get; set; }
    public String fraudIDLegible { get; set; }
    public String fraudIDNotPicture { get; set; }
    public String fraudCustomerPhotoModified { get; set; }
    public String fraudSecurityFeatures { get; set; }
    public String fraudDefectsRectified { get; set; }
    public String suppliedEmail { get; set; }
    public Integer recordType { get; set; }

    public AutoKYCQACaseCloudEventDataModel(
      Case theCase,
      Account theAccount,
      UserModel theOwner,
      CustomerOnboardingApplication__c theCOB
    ) {
      super(theCase, theAccount, theOwner);
      this.customerOnboardingApplication = new CustomerOnboardingApplicationModel(
        theCOB
      );
      this.parentCase = theCase.ParentId;
      this.dateReceived = theCase.IDR_Date_Received__c;
      this.chatTopicId = theCase.Twilio_Channel_SID__c;
      this.subStatus = theCase.Sub_Status__c;
      this.contactId = theCase.ContactId;
      this.contactMobile = theCase.ContactMobile;
      this.fraudCustomerDetails = theCase.Fraud_Customer_Details__c;
      this.fraudMiddleNameCheck = theCase.Fraud_MiddleNameCheck__c;
      this.fraudSelfieComparisonMatch = theCase.Fraud_Selfie_Comparison_Match__c;
      this.fraudPOBox = theCase.Fraud_PO_Box__c;
      this.fraudAddressValid = theCase.Fraud_Address_Valid__c;
      this.fraudRestraintStatus = theCase.Fraud_Restraint_Status__c;
      this.fraudIDLegible = theCase.Fraud_ID_Legible__c;
      this.fraudIDNotPicture = theCase.Fraud_ID_Not_Picture__c;
      this.fraudCustomerPhotoModified = theCase.Fraud_Customer_Photo_Modified__c;
      this.fraudSecurityFeatures = theCase.Fraud_Security_Features__c;
      this.fraudDefectsRectified = theCase.Fraud_Defects_Rectified__c;
      this.suppliedEmail = theCase.SuppliedEmail;
      this.recordType = RECORD_TYPE_AUTOKYC_QA;
    }
  }

  /**
   * @description Inner Wrapper Class for the CustomerOnboardingApplication of KYC QA Case
   */
  public class CustomerOnboardingApplicationModel {
    public String personaId { get; set; }

    /**
     * @description get an instance of CustomerOnboardingApplicationModel
     * @param theCOB the CustomerOnboardingApplication record
     */
    public CustomerOnboardingApplicationModel(
      CustomerOnboardingApplication__c theCOB
    ) {
      this.personaId = theCOB?.PersonaId__c;
    }
  }
}
