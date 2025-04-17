import { LightningElement, api, track } from "lwc";
import documentDetails from "@salesforce/apex/TrustMeDocumentDetailsController.getEvaluationDetails";
import currentUserId from "@salesforce/user/Id";
import { handleErrors } from "c/utils";

const APEX_ERRORS = {
  InsufficientAccessException:
    "You don't have required permission to perform this action",
  ServerErrorException:
    "The server encountered an unexpected error. Please retry after some time.",
  DmlException: "Error occurred while fetching documents details.",
  Exception: "Error occured while fetching evaluation details."
};

const NODE_TO_LABEL = {
  primaryDocumentDetails: "Primary Documents Details",
  secondaryDocumentDetails: "Secondary Documents Details",
  FILE_TYPE_FRONT_PROCESSED: "Processed Document",
  FILE_TYPE_FRONT_UNPROCESSED: "Unprocessed Document",
  FILE_TYPE_BACK_UNPROCESSED: "Unprocessed Document Back",
  FILE_TYPE_BACK_PROCESSED: "Processed Document Back",
  FILE_TYPE_SELFIE: "Selfie",
  LABEL_FRONT: "Front",
  LABEL_BACK: "Back",
  LABEL_SELFIE: "Selfie",
  TYPE_DRIVERS_LICENCE: "Drivers Licence",
  TYPE_MEDICARE: "Medicare",
  TYPE_PASSPORT: "Type Passport",
  TYPE_PROOF_OF_AGE: "Type Proof Of Age"
};

const FILES_BY_DOCUMENTTYPE = {
  TYPE_DRIVERS_LICENCE: [
    {
      fileType: "FILE_TYPE_FRONT_PROCESSED",
      title: "Processed Document Front"
    },
    {
      fileType: "FILE_TYPE_BACK_PROCESSED",
      title: "Processed Document Back"
    },
    {
      fileType: "FILE_TYPE_FRONT_UNPROCESSED",
      title: "Unprocessed Document Front"
    },
    {
      fileType: "FILE_TYPE_BACK_UNPROCESSED",
      title: "Unprocessed Document Back"
    },
    {
      fileType: "FILE_TYPE_SELFIE",
      title: "Selfie"
    }
  ],
  TYPE_PASSPORT: [
    {
      fileType: "FILE_TYPE_FRONT_PROCESSED",
      title: "Processed Document Front"
    },
    {
      fileType: "FILE_TYPE_FRONT_UNPROCESSED",
      title: "Unprocessed Document Front"
    },
    {
      fileType: "FILE_TYPE_SELFIE",
      title: "New Selfie"
    }
  ],
  TYPE_PROOF_OF_AGE: [
    {
      fileType: "FILE_TYPE_FRONT_PROCESSED",
      title: "Processed Proof Of Age Front"
    },
    {
      fileType: "FILE_TYPE_BACK_PROCESSED",
      title: "Processed Proof Of Age Back"
    },
    {
      fileType: "FILE_TYPE_FRONT_UNPROCESSED",
      title: "Unprocessed Proof Of Age Front"
    },
    {
      fileType: "FILE_TYPE_BACK_UNPROCESSED",
      title: "Unrocessed Proof Of Age Back"
    },
    {
      fileType: "FILE_TYPE_SELFIE",
      title: "Selfie"
    }
  ],
  TYPE_MEDICARE: [
    {
      fileType: "FILE_TYPE_FRONT_PROCESSED",
      title: "Processed Front"
    },
    {
      fileType: "FILE_TYPE_FRONT_UNPROCESSED",
      title: "Unprocessed Front"
    }
  ]
};

export default class TrustMeDocumentDetails extends LightningElement {
  @api recordId;
  userId = currentUserId;
  showSpinner = false;
  showError = false;

  data;
  evaluationOutcomes;
  evProviderOutcomes;
  selfieEvaluationOutcome;
  qualityReportSelfieAndPrimaryDocument;
  primaryDocAndSelfie;
  secondaryDocuments;
  qualityReportSecDocuments;
  @track addressDetails;
  imageMetadata;
  responseNodeToLabel;
  mdtReqBodyForPrimaryDoc;
  mdtReqBodyForSecDoc;
  errorMessage;

  connectedCallback() {
    this.showSpinner = true;
    this.getDocumentsDetails();
  }
  getDocumentsDetails() {
    documentDetails({
      caseId: this.recordId
    })
      .then((result) => {
        this.data = JSON.parse(JSON.stringify(result));
        this.evaluationOutcomes = this.transformResponse(
          this.data.evaluationOutcome,
          this.data.documentFieldMappingValues.Evaluation_Outcome
        );
        this.qualityReportSelfieAndPrimaryDocument =
          this.transformResponseForQualityReports(
            this.data.qualityReportSelfieAndPrimaryDocument,
            this.data.documentFieldMappingValues
              .Quality_Report_Selfie_Primary_Doc
          );
        this.qualityReportSecDocuments =
          this.transformResponseForQualityReports(
            this.data.qualityReportSecondaryDoc,
            this.data.documentFieldMappingValues
              .Quality_Report_Secondary_Document
          );
        this.primaryDocAndSelfie = this.transformResponse(
          this.data.primaryDocumentSelfieDetails,
          this.data.documentFieldMappingValues.Primary_Document_Selfie_Details
        );
        this.secondaryDocuments = this.transformResponse(
          this.data.secondaryDocumentDetails,
          this.data.documentFieldMappingValues.Secondary_Document_Details
        );
        this.evProviderOutcomes = this.transformResponseForEVProviderOutcome(
          this.data.evProviderOutcomes,
          this.data.documentFieldMappingValues.EV_Provider_Outcomes,
          this.data.documentFieldMappingValues.EV_Provider_Table_Columns
        );
        this.selfieEvaluationOutcome = this.transformResponse(
          this.data.selfieEvaluationOutcome,
          this.data.documentFieldMappingValues.Selfie_Evaluation_Outcome
        );
        this.addressDetails = this.transformResponseForAddress(
          this.data.addressDetails
        );
        this.imageMetadata = this.transformResponseForDocDetails(
          this.data.imageMetadataDetails,
          this.data.documentFieldMappingValues.Image_Metadata_Details
        );
        this.mdtReqBodyForPrimaryDoc = this.formRequestBodyToFetchDocuments(
          this.data.imageMetadataDetails?.primaryDocumentDetails,
          this.data.evaluationOutcome.id
        );
        if (this.data.imageMetadataDetails?.secondaryDocumentDetails != null) {
          this.mdtReqBodyForSecDoc = this.formRequestBodyToFetchDocuments(
            this.data.imageMetadataDetails?.secondaryDocumentDetails,
            this.data.evaluationOutcome.id
          );
        }
      })
      .catch((error) => {
        this.errorMessage =
          APEX_ERRORS[error.body.message] ?? handleErrors(error);
        this.showError = true;
      })
      .finally(() => {
        this.showSpinner = false;
      });
  }

  get primaryLayout() {
    if (!this.data?.imageMetadataDetails?.primaryDocumentDetails) {
      return null;
    }
    let docType =
      this.data?.imageMetadataDetails.primaryDocumentDetails[0].type;
    return [
      {
        title: "",
        size: 4,
        files: FILES_BY_DOCUMENTTYPE[docType]
      }
    ];
  }

  get secondaryLayout() {
    if (!this.data?.imageMetadataDetails?.secondaryDocumentDetails) {
      return null;
    }
    let docType =
      this.data?.imageMetadataDetails.secondaryDocumentDetails[0].type;
    return [
      {
        title: "",
        size: 4,
        files: FILES_BY_DOCUMENTTYPE[docType]
      }
    ];
  }
  transformResponse(response, documentFieldMappingValues) {
    if (!response) {
      return null;
    }
    return documentFieldMappingValues.map((item) => ({
      label: item.Label,
      fieldName: response[item.API_Node__c]
    }));
  }
  transformResponseForQualityReports(response, documentFieldMappingValues) {
    if (!response) {
      return null;
    }
    let reportIdMap = new Map();
    for (let item of response) {
      reportIdMap.set(item.reportId, item);
    }
    return documentFieldMappingValues.map((item) => ({
      label: item.Label,
      fieldName: reportIdMap.get(item.API_Node__c).outcome
    }));
  }

  transformResponseForEVProviderOutcome(
    response,
    documentFieldMappingValues,
    documentFieldMappingDataTable
  ) {
    if (!response) {
      return null;
    }
    let evProviderObj = {};
    evProviderObj.evOutcomeNode = this.transformResponse(
      response,
      documentFieldMappingValues
    );
    evProviderObj.records = response.providers;
    evProviderObj.column = this.createColumnForDataTable(
      response.providers,
      documentFieldMappingDataTable
    );
    return evProviderObj;
  }

  transformResponseForDocDetails(response, documentFieldMappingValues) {
    if (!response) {
      return null;
    }
    return Object.entries(response).map(([field, value]) => ({
      type: NODE_TO_LABEL[field],
      records: this.tranformValueForDataTable(value),
      column: this.createColumnForDataTable(value, documentFieldMappingValues)
    }));
  }

  tranformValueForDataTable(response) {
    if (!response) {
      return null;
    }
    return response.map((item) => {
      let tempObj = {};
      Object.entries(item).forEach(([obj, val]) => {
        tempObj[obj] = NODE_TO_LABEL[val] || val;
      });
      return tempObj;
    });
  }

  createColumnForDataTable(response, documentFieldMappingValues) {
    if (!response) {
      return null;
    }
    let responseRecord = response[0];
    return documentFieldMappingValues
      .filter(
        (item) =>
          responseRecord[item.API_Node__c] && item.API_Node__c !== "documentId"
      )
      .map((item) => ({
        label: item.Label,
        fieldName: item.API_Node__c
      }));
  }

  transformResponseForAddress(response) {
    if (!response) {
      return null;
    }
    return response.map((item) => ({
      type: item.addressType,
      addressValue: this.concatAddress(item),
      latitude: item.latitude,
      longitude: item.longitude
    }));
  }

  concatAddress(response) {
    if (!response) {
      return null;
    }
    if (response.stationInfo) {
      return [
        response.stationInfo,
        response.boxId,
        response.postalCode,
        response.countryCode3Chars
      ]
        .filter((value) => value)
        .join(", ");
    }
    return [
      response.levelNumber,
      response.residenceNumber,
      response.buildingName,
      response.streetName,
      response.streetType,
      response.streetSuffix,
      response.city,
      response.state,
      response.postalCode,
      response.countryCode3Chars
    ]
      .filter((value) => value)
      .join(", ");
  }

  formRequestBodyToFetchDocuments(docMetadata, evaluationId) {
    let reqBody = {};
    reqBody.related_user = this.userId;
    reqBody.evaluation_id = evaluationId;
    reqBody.related_id = this.recordId;
    reqBody.attachments = this.createBodyForAttachments(docMetadata);
    return reqBody;
  }

  createBodyForAttachments(response) {
    if (!response) {
      return null;
    }
    return response.map((item) => ({
      documentId: item.documentId,
      fileType: item.fileType,
      uri: item.uri
    }));
  }
}
