/**
 * @description       :
 * @author            : Anuj Jain
 * @group             :
 * @last modified on  : 08-05-2025
 **/
@SuppressWarnings('PMD.TooManyFields,PMD.ExcessivePublicCount')
public with sharing class TrustMeDocumentDetailsModel extends CalloutModel {
  @AuraEnabled
  public EvaluationOutcome evaluationOutcome;
  @AuraEnabled
  public EvProviderOutcomes evProviderOutcomes;
  @AuraEnabled
  public SelfieEvaluationOutcome selfieEvaluationOutcome;
  @AuraEnabled
  public PrimaryDocumentSelfieDetails primaryDocumentSelfieDetails;
  @AuraEnabled
  public SecondaryDocumentDetails secondaryDocumentDetails;
  @AuraEnabled
  public List<AddressDetails> addressDetails;
  @AuraEnabled
  public ImageMetadataDetails imageMetadataDetails;
  @AuraEnabled
  public Map<String, List<TrustMe_Docs_Tab_Section_Detail__mdt>> documentFieldMappingValues;
  @AuraEnabled
  public List<QualityReportSecondaryDoc> qualityReportSecondaryDoc;
  @AuraEnabled
  public List<QualityReportSelfieAndPrimaryDocument> qualityReportSelfieAndPrimaryDocument;
  @AuraEnabled
  public DocumentQualityEvalOutcome documentQualityEvalOutcome;

  /**
   * @description EvaluationOutcome
   * @name EvaluationOutcome
   * @author Anuj Jain
   */
  public class EvaluationOutcome {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String evaluationOutcomeState;
    @AuraEnabled
    public String createTime;
    @AuraEnabled
    public String lastUpdateTime;
    @AuraEnabled
    public String clientId;
    @AuraEnabled
    public String processDefinitionName;
    @AuraEnabled
    public Integer processDefinitionVersion;
    @AuraEnabled
    public String clientName;
  }

  /**
   * @description EvProviderOutcomes
   * @name EvProviderOutcomes
   * @author Anuj Jain
   */
  public class EvProviderOutcomes {
    @AuraEnabled
    public String evOutcome;
    @AuraEnabled
    public String evEvaluationDateTime;
    @AuraEnabled
    public List<Providers> providers;
  }

  /**
   * @description Providers
   * @name Providers
   * @author Anuj Jain
   */
  public class Providers {
    @AuraEnabled
    public String displayName;
    @AuraEnabled
    public String matchResult;
  }

  /**
   * @description SelfieEvaluationOutcome
   * @name SelfieEvaluationOutcome
   * @author Anuj Jain
   */
  public class SelfieEvaluationOutcome {
    @AuraEnabled
    public String selfieOutcome;
    @AuraEnabled
    public String selfieMatchDateTime;
  }

  /**
   * @description QualityReportSelfieAndPrimaryDocument
   * @name QualityReportSelfieAndPrimaryDocument
   * @author Anuj Jain
   */
  public class QualityReportSelfieAndPrimaryDocument {
    @AuraEnabled
    public String reportId;
    @AuraEnabled
    public String outcome;
  }

  /**
   * @description PrimaryDocumentSelfieDetails
   * @name PrimaryDocumentSelfieDetails
   * @author Anuj Jain
   */
  public class PrimaryDocumentSelfieDetails {
    @AuraEnabled
    public String documentType;
    @AuraEnabled
    public String documentOutcome;
    @AuraEnabled
    public String documentIssueCountry;
    @AuraEnabled
    public String confirmedGivenName;
    @AuraEnabled
    public String confirmedMiddleName;
    @AuraEnabled
    public String confirmedSurname;
    @AuraEnabled
    public String confirmedDateofBirth;
    @AuraEnabled
    public String confirmedPrimaryIdentifier;
    @AuraEnabled
    public String confirmedSecondaryIdentifier;
    @AuraEnabled
    public String confirmedExpireDate;
    @AuraEnabled
    public String ocrGivenName;
    @AuraEnabled
    public String ocrMiddleName;
    @AuraEnabled
    public String ocrSurname;
    @AuraEnabled
    public String ocrDateofBirth;
    @AuraEnabled
    public String ocrPrimaryIdentifier;
    @AuraEnabled
    public String ocrSecondaryIdentifier;
    @AuraEnabled
    public String ocrExpireDate;
    @AuraEnabled
    public String documentIssueState;
  }

  /**
   * @description SecondaryDocumentDetails
   * @name SecondaryDocumentDetails
   * @author Anuj Jain
   */
  public class SecondaryDocumentDetails {
    @AuraEnabled
    public String documentType;
    @AuraEnabled
    public String documentIssueCountry;
    @AuraEnabled
    public String confirmedExpireDate;
    @AuraEnabled
    public String confirmedPrimaryIdentifier;
    @AuraEnabled
    public String ocrExpireDate;
    @AuraEnabled
    public String sequenceNumber;
    @AuraEnabled
    public String colour;
    @AuraEnabled
    public String documentOutcome;
    @AuraEnabled
    public String certificateNumber;
    @AuraEnabled
    public String registrationNumber;
    @AuraEnabled
    public String registrationState;
  }

  /**
   * @description QualityReportSecondaryDoc
   * @name QualityReportSecondaryDoc
   * @author Anuj Jain
   */
  public class QualityReportSecondaryDoc {
    @AuraEnabled
    public String reportId;
    @AuraEnabled
    public String outcome;
  }

  /**
   * @description AddressDetails
   * @name AddressDetails
   * @author Anuj Jain
   */
  public class AddressDetails {
    @AuraEnabled
    public String addressType;
    @AuraEnabled
    public String addressTypeDescription;
    @AuraEnabled
    public String buildingName;
    @AuraEnabled
    public String lobbyName;
    @AuraEnabled
    public String residence;
    @AuraEnabled
    public String residenceTypeCode;
    @AuraEnabled
    public String residenceNumber;
    @AuraEnabled
    public String levelNumber;
    @AuraEnabled
    public String streetNumber;
    @AuraEnabled
    public String streetName;
    @AuraEnabled
    public String street;
    @AuraEnabled
    public String streetType;
    @AuraEnabled
    public String streetSuffix;
    @AuraEnabled
    public String stationInfo;
    @AuraEnabled
    public String boxId;
    @AuraEnabled
    public String city;
    @AuraEnabled
    public String suburb;
    @AuraEnabled
    public String state;
    @AuraEnabled
    public String postalCode;
    @AuraEnabled
    public String countryCode;
    @AuraEnabled
    public String countryCode3Chars;
    @AuraEnabled
    public String deliveryIdentifier;
    @AuraEnabled
    public String latitude;
    @AuraEnabled
    public String longitude;
    @AuraEnabled
    public String allotment;
    @AuraEnabled
    public String allotmentType;
    @AuraEnabled
    public String allotmentNumber;
    @AuraEnabled
    public string addressSource;
    @AuraEnabled
    public string addressLine1;
    @AuraEnabled
    public string addressLine2;
    @AuraEnabled
    public string addressLine3;
  }

  /**
   * @description ImageMetadataDetails
   * @name ImageMetadataDetails
   * @author Anuj Jain
   */
  public class ImageMetadataDetails {
    @AuraEnabled
    public List<DocumentDetails> primaryDocumentDetails;
    @AuraEnabled
    public List<DocumentDetails> secondaryDocumentDetails;
  }

  /**
   * @description DocumentDetails
   * @name DocumentDetails
   * @author Anuj Jain
   */
  public class DocumentDetails {
    @AuraEnabled
    public String fileType;
    @AuraEnabled
    public String documentId;
    @AuraEnabled
    public String type;
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String uri;
  }

  /**
   * @description DocumentQualityEvalOutcome
   * @name DocumentQualityEvalOutcome
   * @author Anuj Jain
   */
  public class DocumentQualityEvalOutcome {
    @AuraEnabled
    public String primaryDocumentOutcome;
    @AuraEnabled
    public String secondaryDocumentOutcome;
  }

  /**
   * @description performing deserilize operation
   * @param json json
   * @return  TrustMeDocumentDetailsModel (An instance of TrustMeDocumentDetailsModel class)
   */
  public static TrustMeDocumentDetailsModel parse(String json) {
    return (TrustMeDocumentDetailsModel) deserialize(
      json,
      TrustMeDocumentDetailsModel.class
    );
  }
}
