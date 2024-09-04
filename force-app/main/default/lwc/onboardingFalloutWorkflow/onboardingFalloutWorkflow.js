import { LightningElement, api, track } from "lwc";
import performOnboardingOperations from "@salesforce/apex/OnboardingFalloutWorkflowController.performOnboardingOperations";
import fetchOnboardingDocuments from "@salesforce/apex/OnboardingFalloutWorkflowController.fetchOnboardingDocumentsLWC";
import apiCallToFetchImages from "@salesforce/apex/OnboardingFalloutWorkflowController.apiCallToFetchImagesLWC";
import onboardingDocumentImage from "@salesforce/resourceUrl/onboardingDocumentImage";
import onboardingSelfieImage from "@salesforce/resourceUrl/onboardingSelfieImage";
import daonMaxPollingCount from "@salesforce/label/c.DAONMaxPollingCount";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ApprovalModal from "c/manageOpsWorkflowApproval";
import RejectModal from "c/manageOpsWorkflowReject";
import { NavigationMixin } from "lightning/navigation";

export default class OnboardingFalloutWorkflow extends NavigationMixin(
  LightningElement
) {
  @api recordId;
  noAccess = false;
  @track workflowDetails = {};
  filesToRender = [];

  componentSpinner = false;
  errorOccurred = false;
  noRedBorder = false;

  callCount = 0;
  maxCalls = daonMaxPollingCount;
  apiCallMade = false;
  fileCreatedCounter = 0;
  _interval;

  isValidDocument = false;
  isSelfieMatched = false;
  onboardingDocumentErrorImage = onboardingDocumentImage;
  onboardingSelfieErrorImage = onboardingSelfieImage;

  connectedCallback() {
    this.performOperations();
  }

  performOperations() {
    this.componentSpinner = true;
    performOnboardingOperations({ recordId: this.recordId })
      .then((result) => {
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

        if (this.workflowDetails.draftCVIDs.length !== 0) {
          this.pollingMethod();
        }
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
      })
      .finally(() => {
        this.componentSpinner = false;
        this.filesToRender = [
          {
            fileTitle: "Processed Document Image",
            currentFileType: this.workflowDetails.processedImageData,
            errorImage: this.onboardingDocumentErrorImage,
            errorMessage: "User document not found",
            showRedBorder: this.workflowDetails.showRedBorder,
            changeStyle: false,
            size: 6,
            isImage: true
          },
          {
            fileTitle: "Unprocessed Document Image",
            currentFileType: this.workflowDetails.unProcessedImageData,
            errorImage: this.onboardingDocumentErrorImage,
            errorMessage: "User document not found",
            showRedBorder: this.workflowDetails.showRedBorder,
            changeStyle: false,
            size: 6,
            isImage: true
          },
          {
            size: 4,
            isEmptySpace: true
          },
          {
            label: "Is this a valid document?",
            name: "validDocument",
            size: 5,
            isCheckBox: true,
            showCheckbox: this.workflowDetails?.showCheckboxes,
            cssStyle: "slds-m-top--medium"
          },
          {
            size: 3,
            isEmptySpace: true
          },
          {
            fileTitle: "Document Extracted Face",
            currentFileType: this.workflowDetails.extractedFaceData,
            errorImage: this.onboardingSelfieErrorImage,
            errorMessage: "Enrolled selfie not found",
            changeStyle: this.workflowDetails.extractedFaceData ? true : false,
            size: 5,
            isImage: true
          },
          {
            label: "Matches",
            name: "selfieMatch",
            size: 2,
            isCheckBox: true,
            cssStyle: "slds-align_absolute-center",
            showCheckbox: this.workflowDetails?.showCheckboxes
          },
          {
            fileTitle: "Selfie to be enrolled",
            currentFileType: this.workflowDetails.selfieData,
            errorImage: this.onboardingSelfieErrorImage,
            errorMessage: "Selfie to be verified not found",
            changeStyle: this.workflowDetails.selfieData ? true : false,
            size: 5,
            isImage: true
          }
        ];
      });
  }

  callFetchOnboardingDocuments() {
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
    //eslint-disable-next-line @lwc/lwc/no-async-operation
    this._interval = setInterval(() => {
      if (
        this.callCount < this.maxCalls &&
        this.workflowDetails.filesCreatedCounter !== 4
      ) {
        this.callFetchOnboardingDocuments();
        this.callCount += 1;
      } else {
        clearInterval(this._interval);
        if (this.apiCallMade) {
          this.stopSpinnerMethod();
          return;
        }
        //check for all flags, form the body and then make a API call
        this.makeAPICallToFetchImages();
      }
    }, 5000);
  }

  makeAPICallToFetchImages() {
    apiCallToFetchImages({
      workflowDetailsJSON: JSON.stringify(this.workflowDetails)
    })
      .then((result) => {
        this.workflowDetails = JSON.parse(JSON.stringify(result));
        if (this.workflowDetails.responseMsg === "Success") {
          this.workflowDetails.draftCVIDs = [];
          this.callCount = 0;
          this.apiCallMade = true;
          //call polling
          this.pollingMethod();
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

  get checkBoxVisible() {
    return this.workflowDetails?.showCheckboxes;
  }

  changeHandler(event) {
    let name = event.target.name;
    if (name === "validDocument") {
      this.isValidDocument = event.target.checked;
    }
    if (name === "selfieMatch") {
      this.isSelfieMatched = event.target.checked;
    }
  }

  stopSpinnerMethod() {
    this.workflowDetails.unProcessedImageData.stopSpinner = true;
    this.workflowDetails.processedImageData.stopSpinner = true;
    this.workflowDetails.extractedFaceData.stopSpinner = true;
    this.workflowDetails.selfieData.stopSpinner = true;
  }

  openApprovalModal() {
    let caseId = this.workflowDetails?.caseId;
    let parentComponent = "Onboarding";
    let workflowId = this.workflowDetails?.workflowId;
    let IdValue = this.workflowDetails?.IDValue;
    let cobId = this.workflowDetails?.cobPIDRecordId;
    ApprovalModal.open({
      label: "Approval Modal",
      size: "small",
      options: { caseId, parentComponent, workflowId, IdValue, cobId },
      onrefresh: (e) => {
        e.stopPropagation();
        this.handleModalClose();
      }
    });
  }

  openRejectModal() {
    let caseId = this.workflowDetails?.caseId;
    let parentComponent = "Onboarding";
    let workflowId = this.workflowDetails?.workflowId;
    let IdValue = this.workflowDetails?.IDValue;
    let cobId = this.workflowDetails?.cobPIDRecordId;
    RejectModal.open({
      label: "Reject Modal",
      size: "small",
      options: { caseId, parentComponent, workflowId, IdValue, cobId },
      onrefresh: (e) => {
        e.stopPropagation();
        this.handleModalClose();
      }
    });
  }

  get isApprovButtonDisable() {
    return !this.isSelfieMatched || !this.isValidDocument;
  }

  get isRejectButtonDisable() {
    return !this.workflowDetails?.showCheckboxes;
  }

  handleModalClose() {
    this.dispatchEvent(
      new CustomEvent("closeparentmodel", {
        detail: {
          message: "closeModel"
        }
      })
    );
  }
}
