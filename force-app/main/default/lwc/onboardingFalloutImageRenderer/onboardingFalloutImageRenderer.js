import { LightningElement, api } from "lwc";

export default class OnboardingFalloutImageRenderer extends LightningElement {
  @api currentFileType;
  @api errorImage;
  @api errorMsg;
  @api showRedBorder;
  @api changeStyle;
  loading;
  reLoad;

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
    if (this.reLoad) {
      return `${this.currentFileType.imageURL}&TIMESTAMP=${new Date()}`;
    }

    if (this.currentFileType.isImageFinalVersion) {
      return this.currentFileType.imageURL;
    }
    return this.errorImage;
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
    this.loading = true;
    this.reLoad = true;
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.loading = false;
    }, 200);
  }
}
