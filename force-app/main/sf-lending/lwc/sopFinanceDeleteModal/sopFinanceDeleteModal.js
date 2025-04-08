import { api, wire } from "lwc";
import SopModalUtils from "c/sopModalUtils";
import { handleErrorShowToast, showToast } from "c/utils";
import RefreshSOP from "@salesforce/messageChannel/RefreshSOP__c";
import deleteIncome from "@salesforce/apex/SOPController.deleteIncome";
import deleteDebt from "@salesforce/apex/SOPController.deleteDebt";
import { publish, MessageContext } from "lightning/messageService";

export default class SopFinanceDeleteModal extends SopModalUtils {
  @api recordDetails;
  @api isDeletionAllowed;
  @api sopType;
  @api recordId;

  @wire(MessageContext)
  messageContext;

  componentSpinner;

  handleClose() {
    this.close("okay");
  }

  async handleDelete() {
    try {
      this.componentSpinner = true;
      let result = true;
      if (this.sopType === "Income") {
        result = await deleteIncome({
          loanId: this.recordId,
          incomeName: this.recordDetails.name,
          etag: this.recordDetails.etag
        });
      } else {
        result = await deleteDebt({
          loanId: this.recordId,
          debtName: this.recordDetails.name,
          etag: this.recordDetails.etag
        });
      }

      if (result) {
        showToast(
          this,
          "",
          `This ${this.sopType} record was successfully deleted.`,
          "",
          "Success",
          ""
        );
        publish(this.messageContext, RefreshSOP, {
          refresh: true
        });
      }
      this.close();
    } catch (error) {
      handleErrorShowToast(
        this,
        "",
        error.body.message,
        `The ${this.sopType} record couldn't be deleted. Please review and try again. Raise a fault through TechAssist if the problem persists.`
      );
    } finally {
      this.componentSpinner = false;
    }
  }

  //Based on sopType and isDeletionAllowed will return msg,msgDetails and label
  get messageAndLabel() {
    let msg = "";
    let msgDetails = "";
    if (this.sopType === "Income") {
      if (this.isDeletionAllowed) {
        msg = this.incomeDelConfirmation;
      } else {
        msg = this.incomeDelErrorMsg;
        msgDetails = this.incomeDelErrorMsgDetails;
      }
      return { msg, msgDetails, label: this.deleteIncomeLabel };
    }
    if (this.isDeletionAllowed) {
      msg = `Are you sure you want to delete this ${this.recordDetails.readableType} debt from the application?`;
    } else {
      msg = this.debtDelErrorMsg;
      msgDetails = this.debtDelErrorMsgDetails;
    }
    return {
      msg: msg,
      msgDetails,
      label: this.deleteDebtLabel
    };
  }

  // Get modal header label and delete button label
  get sopLabel() {
    return this.messageAndLabel.label;
  }

  get msg() {
    return this.messageAndLabel.msg;
  }

  get msgDetails() {
    return this.messageAndLabel.msgDetails;
  }
}
