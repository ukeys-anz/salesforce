import LightningModal from "lightning/modal";
import { api, wire } from "lwc";
import updateLoanPreference from "@salesforce/apex/LoanPreferenceController.updateLoanPreference";
import { handleErrorShowToast, showToast } from "c/utils";
import { publish, MessageContext } from "lightning/messageService";
import RefreshLoanPreference from "@salesforce/messageChannel/RefreshLoanPreference__c";

const TOAST_SUCCESS_MSG =
  "Changes to Loan Preferences were successfully saved.";
const TOAST_ERROR_MSG =
  "The changes to the Additional Funds and Purpose did not save. Please try again.";

export default class LoanPreferenceDeleteCashOutPurpose extends LightningModal {
  @api purposeName;
  @api fundRecords;
  @api loanPreferenceData;
  fundRecordsList = [];
  componentSpinner = false;
  calloutResponse = false;
  additionalFundsModel;

  @wire(MessageContext)
  messageContext;

  // To get message for modal header
  get deleteHeaderMessage() {
    return "Delete " + this.purposeName + " Additional Funds and Purpose?";
  }

  // To get confirmation message for modal body
  get deleteConfirmationMessage() {
    let showCategory =
      this.purposeName === "All"
        ? this.purposeName.toLowerCase()
        : "<b>" + this.purposeName + "</b>";
    return (
      "Are you sure you want to delete " +
      showCategory +
      " additional funds and purpose? This will delete the additional fund details from the application."
    );
  }

  //Remove selected purpose/fund entry from available fundRecords
  handleDelete() {
    this.fundRecordsList =
      this.fundRecords?.filter((fund) => fund.name !== this.purposeName) ?? [];
    this.transformToAddFundsModel();
    this.makeCalloutToDelete();
  }

  //Transform fundRecordsList to additional Funds View Model
  transformToAddFundsModel() {
    this.additionalFundsModel = {
      additionalFunds: []
    };
    if ((this.fundRecordsList?.length ?? 0) === 0) {
      return this.additionalFundsModel;
    }
    this.fundRecordsList.forEach((fundRecord) => {
      fundRecord.value.forEach((value) => {
        this.additionalFundsModel.additionalFunds.push({
          amount: value.amount,
          purpose: value.purpose,
          otherReason: value.otherReason ? value.otherReason : ""
        });
      });
    });
    return this.additionalFundsModel;
  }

  makeCalloutToDelete() {
    this.componentSpinner = true;
    updateLoanPreference({
      updateLoanPreferenceData: this.loanPreferenceData,
      additionalFundsData: this.additionalFundsModel
    })
      .then((response) => {
        this.calloutResponse = response;
        if (this.calloutResponse.successful) {
          showToast(this, "", TOAST_SUCCESS_MSG, "", "Success", "dismissable");
          publish(this.messageContext, RefreshLoanPreference, {
            refresh: true
          });
        } else {
          if (this.calloutResponse.message === "") {
            this.calloutResponse.message = TOAST_ERROR_MSG;
          }
          handleErrorShowToast(
            this,
            "",
            "",
            this.calloutResponse.message,
            "pester"
          );
        }
      })
      .catch((error) => {
        handleErrorShowToast(this, "", error, TOAST_ERROR_MSG, "pester");
      })
      .finally(() => {
        this.componentSpinner = false;
        this.handleClose();
      });
  }

  handleClose() {
    this.close("okay");
  }
}
