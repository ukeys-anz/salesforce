import { LightningElement, api } from "lwc";
import reloadMaxRetryCount from "@salesforce/label/c.DAONImageReloadMaxRetryCount";

export default class OnboardingFalloutImageRenderer extends LightningElement {
  @api currentFileType;
  @api errorImage;
  @api errorMsg;
  @api showRedBorder;
  @api changeStyle;
  loading;
  reLoadCount = 0;
  imageReloadMaxRetryCount = reloadMaxRetryCount;

  disableRightClick(event) {
    event.preventDefault();
  }

  connectedCallback() {
    this.loading = true;
  }

  get showSpinner() {
    return this.loading || !this.currentFileType.stopSpinner;
  }

  get imgSrc() {
    if (!this.currentFileType.isImageFinalVersion) {
      return this.errorImage;
    }

    if (this.reLoadCount) {
      return `${this.currentFileType.imageURL}&RETRYCOUNT=${this.reLoadCount}`;
    }
    return this.currentFileType.imageURL;
  }

  get imgClass() {
    return this.showRedBorder ? "borderRed imgCSS" : "imgCSS";
  }

  get showError() {
    return !this.currentFileType.isImageFinalVersion;
  }

  handleImageLoad() {
    this.loading = false;
  }

  handleErrorLoad() {
    if (this.reLoadCount < this.imageReloadMaxRetryCount) {
      this.loading = true;
      this.reLoadCount += 1;
    } else {
      this.loading = false;
    }
  }
}
