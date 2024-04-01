/**
 * @author TFM Squad
 * @date Mar 2024
 * @description This component is generic utility component where blob content can be passed to download the file. If moved to apex causes a overburden of delting the files as it has to be stored in Content Document
 */
import { LightningElement, api } from "lwc";

export default class DownloadFileUtility extends LightningElement {
  _uniqueIdentifier;
  eventName;
  @api
  get uniqueIdentifier() {
    return this._uniqueIdentifier;
  }
  set uniqueIdentifier(value) {
    this._uniqueIdentifier = value;
    this.eventName = this.uniqueIdentifier
      ? "fileNameAndContentData_" + this.uniqueIdentifier
      : "fileNameAndContentData_";
    window.addEventListener(this.eventName, this.receiveMessage);
  }

  disconnectedCallback() {
    window.removeEventListener(this.eventName, this.receiveMessage);
  }

  receiveMessage = (event) => {
    this.downloadCSV(event.detail.blobContent, event.detail.fileTitle);
  };

  downloadCSV(blobContent, fileName) {
    try {
      const byteCharacters = atob(blobContent);
      const byteNumbers = new Array(byteCharacters.length);
      for (let i = 0; i < byteCharacters.length; i++) {
        byteNumbers[i] = byteCharacters.charCodeAt(i);
      }
      const byteArray = new Uint8Array(byteNumbers);
      const blob = new Blob([byteArray], { type: "application/octet-stream" });

      // Create a URL for the Blob
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.style.display = "none";
      document.body.appendChild(a);
      a.href = url;
      a.download = fileName;
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    } catch (error) {
      console.error("Error generating file: ", error);
    }
  }
}
