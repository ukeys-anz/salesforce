import { LightningElement, api } from "lwc";
import PROPERTY_IMG from "@salesforce/resourceUrl/Property";
import loanPreferenceEditDetails from "c/loanPreferenceEditDetails";
//import getCalculateLoanRepayment from "@salesforce/apex/LoanPreferenceController.getCalculateLoanRepayment";

export default class LoanPreferencesHeader extends LightningElement {
  @api preferenceData;
  showDetailedView = false;
  propertyImage = PROPERTY_IMG;
  connectedCallback() {
    this.getCalculateLoanRepayment();
  }

  toggleDetails() {
    this.showDetailedView = !this.showDetailedView;
  }

  //TO:DO Add edit screen modal popup and pass the preference data
  handleEditClick() {
    loanPreferenceEditDetails.open({
      size: "small"
    });
  }
  //TO:DO make callout to calculate Loan to get preference data
  getCalculateLoanRepayment() {
    try {
      // Callout to get the Loan Repayment Details
      // const calculateLoanRepayment = getCalculateLoanRepayment({
      //   loanId: this.recordId
      // });
      //TO:DO include calculate loan logic
    } catch (error) {
      //Capture error details and show Toast
    }
  }
}
