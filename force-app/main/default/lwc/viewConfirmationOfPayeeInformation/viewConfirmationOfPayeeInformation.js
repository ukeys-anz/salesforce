import { LightningElement, api } from "lwc";
import fetchCOPInformation from "@salesforce/apex/ConfirmationOfPayeeController.fetchCOPInformation";

export default class ViewConfirmationOfPayeeInformation extends LightningElement {
  @api recordId;
  status;
  requestedBy;
  modifiedBy;
  dateTimeValue;
  showData = false;
  isLoading = false;
  error;

  handleButtonClick() {
    this.isLoading = true;
    fetchCOPInformation({ financialAccountId: this.recordId })
      .then((dataList) => {
        if (dataList && dataList.length > 0) {
          const data = dataList[0];
          this.showData = true;
          this.status = data.accountStatusCOP;
          this.requestedBy = data.requestedByName;
          this.modifiedBy = data.modifiedByName;
          this.dateTimeValue = data.statusChangeDateTime;
          this.isLoading = false;
        }
      })
      .catch((error) => {
        this.error = error;
        this.showData = false;
        this.isLoading = false;
        console.error("Error fetching CoP information:", error);
      });
  }
}
