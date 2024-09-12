import { LightningElement, api, track, wire } from "lwc";
import performOnboardingOperations from "@salesforce/apex/PinAndSelfieWorkflowController.performOnboardingOperations";
import fetchOnboardingDocuments from "@salesforce/apex/PinAndSelfieWorkflowController.fetchOnboardingDocumentsLWC";
import apiCallToFetchImages from "@salesforce/apex/PinAndSelfieWorkflowController.apiCallToFetchImagesLWC";
import onboardingDocumentImage from "@salesforce/resourceUrl/onboardingDocumentImage";
import onboardingSelfieImage from "@salesforce/resourceUrl/onboardingSelfieImage";
import daonMaxPollingCount from "@salesforce/label/c.DAONMaxPollingCount";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ApprovalModal from "c/manageOpsWorkflowApproval";
import RejectModal from "c/manageOpsWorkflowReject";
import { getRecord, notifyRecordUpdateAvailable } from "lightning/uiRecordApi";

export default class PinAndSelfieWorkflow extends LightningElement {
  @wire(getRecord, { recordId: "$recordId", fields: ["Case.Status"] })
  record;

  @api recordId;
  noAccess = false;
  @track workflowDetails = {};
  imageNotFound = false;

  componentSpinner = false;
  errorOccurred = false;
  noRedBorder = false;

  callCount = 0;
  maxCalls = daonMaxPollingCount;
  apiCallMade = false;
  fileCreatedCounter = 0;
  _interval;

  onboardingDocumentErrorImage = onboardingDocumentImage;
  onboardingSelfieErrorImage = onboardingSelfieImage;
  filesToRender = [];

  connectedCallback() {
    //get fields status for showCheckboxButton & get case Id
    this.performOperations();
  }

  performOperations() {
    this.componentSpinner = true;
    performOnboardingOperations({ recordId: this.recordId })
      .then(async (result) => {
        this.workflowDetails = JSON.parse(JSON.stringify(result));
        if (this.workflowDetails.responseMsg === "NoAccessAegisFeatures") {
          this.noAccess = true;
          return;
        }
        if (this.workflowDetails.responseMsg === "ErrorOccurred") {
          this.errorOccurred = true;
          this.showNotification(
            "Error",
            "Error occurred while fetching onboarding details.",
            "error"
          );
          return;
        }

        if (
          this.workflowDetails.draftCVIDs &&
          this.workflowDetails.draftCVIDs.length !== 0
        ) {
          this.componentSpinner = false;
          await this.pollingMethod();
        }

        this.formFilesToRender();

        if (this.workflowDetails.fileCreatedCounter !== 4) {
          this.stopSpinnerMethod();
        }
      })
      .catch(() => {
        this.errorOccurred = true;
        this.showNotification(
          "Error",
          "Error occurred while fetching onboarding details.",
          "error"
        );
      });
  }

  formFilesToRender() {
    this.componentSpinner = false;
    this.filesToRender = [
      {
        fileTitle: "Unprocessed Document Image",
        currentFileType: this.workflowDetails.unProcessedImageData,
        errorImage: this.onboardingDocumentErrorImage,
        errorMessage: "User document not found",
        changeStyle: !this.workflowDetails.unProcessedImageData ? true : false
      },
      {
        fileTitle: "Processed Document Image",
        currentFileType: this.workflowDetails.processedImageData,
        errorImage: this.onboardingDocumentErrorImage,
        errorMessage: "User document not found",
        changeStyle: !this.workflowDetails.processedImageData ? true : false
      },
      {
        fileTitle: "Enrolled Selfie",
        currentFileType: this.workflowDetails.selfieData,
        errorImage: this.onboardingSelfieErrorImage,
        errorMessage: "Enrolled selfie not found",
        changeStyle: this.workflowDetails.selfieData ? true : false
      },
      {
        fileTitle: "Selfie to be Verified",
        currentFileType: this.workflowDetails.extractedFaceData,
        errorImage: this.onboardingSelfieErrorImage,
        errorMessage: "Selfie to be verified not found",
        changeStyle: this.workflowDetails.extractedFaceData ? true : false
      }
    ];
  }

  async callFetchOnboardingDocuments() {
    fetchOnboardingDocuments({
      workflowDetailsJSON: JSON.stringify(this.workflowDetails)
    })
      .then((result) => {
        this.workflowDetails = JSON.parse(JSON.stringify(result));
        this.workflowDetails.draftCVIDs = [];
      })
      .catch(() => {
        this.showNotification(
          "Error",
          "Error occurred while fetching onboarding documents.",
          "error"
        );
      });
  }

  pollingMethod() {
    return new Promise((resolve, reject) => {
      //eslint-disable-next-line @lwc/lwc/no-async-operation
      this._interval = setInterval(async () => {
        try {
          if (
            this.callCount < this.maxCalls &&
            this.workflowDetails.filesCreatedCounter !== 4
          ) {
            await this.callFetchOnboardingDocuments();
            this.callCount += 1;
          } else {
            clearInterval(this._interval);
            if (this.apiCallMade) {
              this.stopSpinnerMethod();
              return;
            }
            //check for all flags, form the body and then make a API call
            await this.makeAPICallToFetchImages();
            resolve();
          }
        } catch (error) {
          clearInterval(this._interval);
          reject(error);
        }
      }, 5000);
    });
  }

  async makeAPICallToFetchImages() {
    apiCallToFetchImages({
      workflowDetailsJSON: JSON.stringify(this.workflowDetails)
    })
      .then((result) => {
        this.workflowDetails = JSON.parse(JSON.stringify(result));
        if (this.workflowDetails.responseMsg === "Success") {
          this.workflowDetails.draftCVIDs = [];
          this.callCount = 0;
          this.apiCallMade = true;
        } else {
          this.showNotification(
            "Error",
            this.workflowDetails.responseMsg,
            "error"
          );
          this.stopSpinnerMethod();
        }
      })
      .catch(() => {
        this.showNotification(
          "Error",
          "Error occurred while performing api call.",
          "error"
        );
      });
  }

  showNotification(titleText, messageText, variant) {
    const evt = new ShowToastEvent({
      title: titleText,
      message: messageText,
      variant: variant
    });
    this.dispatchEvent(evt);
  }

  disconnectedCallback() {
    clearInterval(this._interval);
  }

  stopSpinnerMethod() {
    this.workflowDetails.unProcessedImageData.stopSpinner = true;
    this.workflowDetails.processedImageData.stopSpinner = true;
    this.workflowDetails.extractedFaceData.stopSpinner = true;
    this.workflowDetails.selfieData.stopSpinner = true;
  }

  openApprovalModal() {
    let caseId = this.workflowDetails?.caseId;
    let parentComponent = "PinAndSelfie";
    let IdValue = this.workflowDetails?.IDValue;
    let workflowId = this.workflowDetails?.workflowId;
    let isPinWorkFlow = this.workflowDetails?.isPinWorkflow;
    let isPinHistoryCheck = this.workflowDetails?.isPinHistoryCheckFailed;

    ApprovalModal.open({
      label: "Approval Modal",
      size: "small",
      options: {
        caseId,
        parentComponent,
        IdValue,
        workflowId,
        isPinHistoryCheck,
        isPinWorkFlow
      },
      onrefresh: (e) => {
        e.stopPropagation();
        this.performOperations();
        notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
      }
    });
  }

  openRejectModal() {
    let caseId = this.workflowDetails?.caseId;
    let parentComponent = "PinAndSelfie";
    let IdValue = this.workflowDetails?.IDValue;
    let workflowId = this.workflowDetails?.workflowId;
    let isPinHistoryCheck = this.workflowDetails?.isPinHistoryCheckFailed;
    let isPinWorkFlow = this.workflowDetails?.isPinWorkflow;
    RejectModal.open({
      label: "Reject Modal",
      size: "small",
      options: {
        caseId,
        parentComponent,
        IdValue,
        workflowId,
        isPinHistoryCheck,
        isPinWorkFlow
      },
      onrefresh: (e) => {
        e.stopPropagation();
        this.performOperations();
        notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
      }
    });
  }

  get isApprovButtonDisable() {
    return (
      this.workflowDetails.isPinHistoryCheckFailed ||
      this.workflowDetails.isCaseClosed
    );
  }

  get isRejectButtonDisable() {
    return this.workflowDetails.isCaseClosed;
  }
}
