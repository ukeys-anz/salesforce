/**
 * @author Lance
 * @date Jan 2022
 */

import { LightningElement, track, api } from "lwc";
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import publishWithValidation from "@salesforce/apex/PublishArticleController.publishWithValidation";

export default class PublishArticle extends NavigationMixin(LightningElement) {
  @api recordId;
  @track isLoading = false;

  closeAction() {
    const closeQA = new CustomEvent("close");
    this.dispatchEvent(closeQA);
  }

  publish() {
    this.isLoading = true;

    publishWithValidation({
      recordId: this.recordId
    })
      .then(() => {
        // Refresh the View once escalated
        getRecordNotifyChange([{ recordId: this.recordId }]);

        let title = "Success";
        let message = "Knowledge article was successfully published.";
        let variant = "success";

        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);

        this.closeAction();
      })
      .catch((error) => {
        var message;
        if (typeof error.body != "undefined") {
          message = error.body.message;
        } else {
          message = error;
        }

        const title = "Can't publish";
        const variant = "error";

        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);
      })
      .finally(() => {
        this.isLoading = false;
      });
  }
}
