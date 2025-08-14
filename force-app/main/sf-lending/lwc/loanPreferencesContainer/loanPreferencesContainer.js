import { LightningElement, api } from "lwc";

export default class LoanPreferencesContainer extends LightningElement {
  @api preferenceData;
  @api showDetailedView;
  //Conditional CSS for border
  get className() {
    return this.showDetailedView ? "expandedStyle" : "colapsedStyle";
  }
  //Display Interest Related field only when Loan Repayment Type is Interest Only
  get showInterestFields() {
    return this.preferenceData.loanRepaymentType === "Interest Only";
  }
}
