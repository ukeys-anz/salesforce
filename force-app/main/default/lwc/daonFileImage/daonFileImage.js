import { LightningElement, api } from "lwc";
import MAX_RETRY_COUNT from "@salesforce/label/c.DAONImageReloadMaxRetryCount";

export default class DaonFileImage extends LightningElement {
  @api placeholder;
  @api url;
  //Is DAON file download in progress.
  @api isLoading;
  @api error;
  //Custom css in array format. The CSS classes must be added to daonFileImage.css
  //Example: ["customClass1", "customClass2"]
  @api customClass = [];
  @api customStyle = "";

  //Is image "src" fetching in progress.
  isFetchingSrc = true;
  //Retry count for fetching image "src".
  fetchingCount = 0;

  disableClick(event) {
    event.preventDefault();
  }

  get isLoadingImage() {
    return this.isLoading || (this.url && this.isFetchingSrc);
  }

  get imgSrc() {
    if (this.fetchingCount) {
      return `${this.url}&retrycount=${this.fetchingCount}`;
    }
    return this.url;
  }

  get imgClass() {
    return ["imgCSS", ...(this.customClass ?? [])];
  }

  get showError() {
    return !this.url && !this.isLoading;
  }

  handler = {
    onLoad: () => {
      this.isFetchingSrc = false;
    },
    onError: () => {
      this.isFetchingSrc = this.fetchingCount++ < MAX_RETRY_COUNT;
    }
  };
}
