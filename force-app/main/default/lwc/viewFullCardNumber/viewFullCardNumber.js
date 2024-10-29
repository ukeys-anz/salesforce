import { api } from "lwc";
import LightningModal from "lightning/modal";
import getFullCardNumberDetails from "@salesforce/apex/CardDetailsController.getFullCardNumberDetails";
import HideCardDetailsAfterMiliseconds from "@salesforce/label/c.HideCardDetailsAfterMiliseconds";

export default class ViewFullCardNumber extends LightningModal {
  @api cardNumber;
  @api cardHolder;
  @api accountType;
  @api ocvId;

  loading = true;
  showFullCardDetails = true;
  showCopyMessage = false;
  cardHasError = false;
  fullCardNumber;
  errorMsg;
  timer;

  connectedCallback() {
    this.getFullCardNumber(); // Fetch full card number when component is initiated
  }

  async getFullCardNumber() {
    this.loading = true;
    try {
      const detokenizedCardNumber = await getFullCardNumberDetails({
        ocvId: this.ocvId,
        cardNumberToBeDetokenized: this.cardNumber
      });
      if (detokenizedCardNumber) {
        this.fullCardNumber = detokenizedCardNumber;
        this.startTimeout(); // Start timer to hide card details
      }
    } catch (error) {
      this.cardHasError = true;
      this.errorMsg =
        "An error has occurred. Please refresh and try again. Raise a fault through TechAssist if the problem persists";
    } finally {
      this.loading = false;
    }
  }

  startTimeout() {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.timer = setTimeout(() => {
      this.showFullCardDetails = false; // Hide card details after the specified time
    }, HideCardDetailsAfterMiliseconds);
  }

  handleClose() {
    this.close(); // Close the modal
  }

  handleCopyModal() {
    navigator.clipboard.writeText(this.fullCardNumber);
    this.showCopyMessage = true;
  }

  disconnectedCallback() {
    if (this.timer) {
      clearTimeout(this.timer); // Clear the timer if the modal is closed
    }
  }
}
