import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class FileUpload extends LightningElement {
  @api recordId;
  get acceptedFormats() {
    return [
      ".png",
      ".jpg",
      ".jpeg",
      ".docx",
      ".tiff",
      ".tif",
      ".gif",
      ".bmp",
      ".pdf",
      ".doc",
      ".xls",
      ".xlsx",
      ".xlsb",
      ".eml",
      ".rtf",
      ".txt",
      ".ppt",
      ".pptx",
      ".msg",
      ".csv",
      ".zip"
    ];
  }
  handleUploadFinished(event) {
    // Get the list of uploaded files
    const uploadedFiles = event.detail.files;
    let uploadedFileNames = "";
    for (let i = 0; i < uploadedFiles.length; i++) {
      uploadedFileNames += uploadedFiles[i].name + ", ";
    }

    this.dispatchEvent(new CustomEvent("newfileupload"));
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Success",
        message:
          uploadedFiles.length +
          " Files uploaded Successfully: " +
          uploadedFileNames,
        variant: "success"
      })
    );
  }
}
