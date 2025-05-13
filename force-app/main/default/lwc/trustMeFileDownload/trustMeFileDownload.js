import { LightningElement, track, api } from "lwc";
import getDocuments from "@salesforce/apex/TrustMeDocumentDetailsController.getTrustMeDocuments";
import MAX_RETRY_COUNT from "@salesforce/label/c.DAONImageReloadMaxRetryCount";

import IMG_DOC from "@salesforce/resourceUrl/onboardingDocumentImage";
import IMG_SELFIE from "@salesforce/resourceUrl/onboardingSelfieImage";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

//Default group configuration
const GROUP_DEFAULTS = {
  horizontalAlign: "center",
  verticalAlign: "stretch",
  //default file column size, can overriden in individual file
  size: 6
};

//Default file configuration
const FILE_DEFAULTS = {
  error: "File not found",
  size: 12
};

//Default file configuration per DAON file type
const FILETYPE_DEFAULTS = {
  FILE_TYPE_FRONT_PROCESSED: {
    title: "Processed Document",
    placeholder: IMG_DOC,
    size: 12
  },
  FILE_TYPE_FRONT_UNPROCESSED: {
    title: "Unprocessed Document",
    placeholder: IMG_DOC,
    size: 12
  },
  FILE_TYPE_BACK_PROCESSED: {
    title: "Processed Document Back",
    placeholder: IMG_DOC,
    size: 12
  },
  FILE_TYPE_BACK_UNPROCESSED: {
    title: "Unprocessed Document Back",
    placeholder: IMG_DOC,
    size: 12
  },
  FILE_TYPE_SELFIE: {
    title: "Enrolled Selfie",
    placeholder: IMG_SELFIE,
    size: 12
  }
};
export default class TrustMeFileDownload extends LightningElement {
  @track viewModel;
  _metadata;
  _layout;
  retryCount = 0;
  isLoading = false;
  isCallingOut = false;

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
      files: group?.files?.map((file) => ({
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

  service = {
    invokeGetDocuments: async () => {
      if (!this.metadata || !this.viewModel || this.isCallingOut) {
        return;
      }
      this.isCallingOut = true;
      try {
        const urlByType = await getDocuments({
          requestModel: this.metadata
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
