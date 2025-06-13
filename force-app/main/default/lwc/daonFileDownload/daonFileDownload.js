import { LightningElement, api, track } from "lwc";
import getDocuments from "@salesforce/apex/DAONFileController.getDocuments";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import MAX_RETRY_COUNT from "@salesforce/label/c.DAONImageReloadMaxRetryCount";
import IMG_DOC from "@salesforce/resourceUrl/onboardingDocumentImage";
import IMG_SELFIE from "@salesforce/resourceUrl/onboardingSelfieImage";
import DaonImageModal from "c/daonImageModal";

//Default group configuration
const GROUP_DEFAULTS = {
  horizontalAlign: "center",
  verticalAlign: "stretch",
  //default file column size, can overriden in individual file
  size: 6
};
//Default file configuration
const FILE_DEFAULTS = {
  error: "File not found"
};
//Default file configuration per DAON file type
const FILETYPE_DEFAULTS = {
  DAON_FILE_TYPE_FRONT_PROCESSED: {
    title: "Processed Document",
    placeholder: IMG_DOC
  },
  DAON_FILE_TYPE_FRONT_UNPROCESSED: {
    title: "Unprocessed Document",
    placeholder: IMG_DOC
  },
  DAON_FILE_TYPE_BACK_PROCESSED: {
    title: "Processed Document Back",
    placeholder: IMG_DOC
  },
  DAON_FILE_TYPE_BACK_UNPROCESSED: {
    title: "Unprocessed Document Back",
    placeholder: IMG_DOC
  },
  DAON_FILE_TYPE_EXTRACTED_FACE: {
    title: "Document Extracted Face",
    placeholder: IMG_SELFIE,
    size: 4
  },
  DAON_FILE_TYPE_SELFIE_ENROLLED: {
    title: "Enrolled Selfie",
    placeholder: IMG_SELFIE,
    size: 4
  },
  DAON_FILE_TYPE_SELFIE_ANZX_REKYC_FACE: {
    title: "TrustMe Selfie",
    placeholder: IMG_SELFIE,
    size: 4
  },
  DAON_FILE_TYPE_SELFIE_TO_BE_ENROLLED: {
    title: "Selfie to be enrolled",
    placeholder: IMG_SELFIE,
    size: 4
  },
  DAON_FILE_TYPE_SELFIE_TO_BE_VERIFIED: {
    title: "Selfie to be verified",
    placeholder: IMG_SELFIE,
    size: 4
  }
};

export default class DaonFileDownload extends LightningElement {
  @api
  get metadata() {
    return this._metadata;
  }
  set metadata(value) {
    if (this.helper.objEquals(this._metadata, value)) {
      return;
    }
    this._metadata = value;
    this.service.invokeGetDocuments();
  }
  @api
  get layout() {
    return this.viewModel;
  }
  set layout(value) {
    if (this.helper.objEquals(this._layout, value)) {
      return;
    }
    this._layout = value;
    this.viewModel = value.map((group) => ({
      ...GROUP_DEFAULTS,
      ...group,
      files: group.files.map((file) => ({
        ...FILE_DEFAULTS,
        ...FILETYPE_DEFAULTS[file.fileType],
        ...file,
        size:
          file.size ||
          group.size ||
          FILETYPE_DEFAULTS[file.fileType].size ||
          GROUP_DEFAULTS.size
      }))
    }));
    this.service.invokeGetDocuments();
  }
  @track viewModel;
  _metadata;
  _layout;
  retryCount = 0;
  isLoading = true;
  isCallingOut = false;

  handler = {
    onButtonClick: (e) => {
      this.dispatchEvent(
        new CustomEvent("action", {
          detail: {
            fileType: e.target.dataset.filetype,
            action: e.target.label
          }
        })
      );
    },
    openImage(e) {
      DaonImageModal.open({
        size: "full",
        ...e.target.dataset
      });
    }
  };

  service = {
    invokeGetDocuments: async () => {
      if (!this.metadata || !this.viewModel || this.isCallingOut) {
        return;
      }
      this.isCallingOut = true;
      try {
        const urlByType = await getDocuments({
          builder: this.metadata,
          fileTypes: this.viewModel.flatMap((group) =>
            group.files.map((file) => file.fileType)
          )
        });
        this.helper.updateLoadingStatus(urlByType);
        this.helper.updateFileStatus(urlByType);
        this.helper.scheduleRetry();
      } catch (e) {
        this.helper.handleError(e);
      } finally {
        this.isCallingOut = false;
      }
    }
  };

  helper = {
    handleError: (error) => {
      console.error(error);
      this.dispatchEvent(
        new ShowToastEvent({
          variant: "error",
          title: "Error!",
          message: "An error occurred while fetching documents"
        })
      );
    },
    updateFileStatus: (urlByType) => {
      this.viewModel.forEach((group) => {
        group.files.forEach((file) => {
          file.url = urlByType[file.fileType];
        });
      });
    },
    updateLoadingStatus: (urlByType) => {
      if (this.retryCount >= MAX_RETRY_COUNT) {
        this.isLoading = false;
        return;
      }
      const files = Object.entries(urlByType);
      this.isLoading = files.length === 0 || files.some((entry) => !entry[1]);
    },
    scheduleRetry: () => {
      if (this.isLoading) {
        this.retryCount++;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => this.service.invokeGetDocuments(), 5000);
      }
    },
    objEquals: (obj1, obj2) => {
      return JSON.stringify(obj1 ?? {}) === JSON.stringify(obj2 ?? {});
    }
  };
}
