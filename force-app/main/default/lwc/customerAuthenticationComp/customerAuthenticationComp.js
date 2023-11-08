import { LightningElement, api } from "lwc";
import getSecurityCode from "@salesforce/apex/CustomerAuthController.getSecurityCode";
import createDiaryComment from "@salesforce/apex/CustomerAuthController.createDiaryComment";
import updateSecurityCode from "@salesforce/apex/CustomerAuthController.updateSecurityCode";
import Customer_Failed_Auth_Comment from "@salesforce/label/c.Customer_Failed_Auth_Comment";
import Customer_Existing_BTL_Comment from "@salesforce/label/c.Customer_Existing_BTL_Comment";
import Customer_Id_Fraud_Comment from "@salesforce/label/c.Customer_Id_Fraud_Comment";
import MLCRM_AUTH_BTL_Code from "@salesforce/label/c.MLCRM_AUTH_BTL_Code";
import Customer_Reference_Guide_URL from "@salesforce/label/c.Customer_Reference_Guide_URL";
import ConfirmationModal from "c/confirmationModal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CustomerAuthenticationComp extends LightningElement {
  securityCode;
  loading = false;
  label = {
    customerFailedAuthComment: Customer_Failed_Auth_Comment,
    customerExistingBTLComment: Customer_Existing_BTL_Comment,
    customerIdFraudComment: Customer_Id_Fraud_Comment,
    authBTLCode: MLCRM_AUTH_BTL_Code,
    customerReferenceGuideURL: Customer_Reference_Guide_URL
  };
  @api recordId;
  showAuthenticateBtn = true;
  showSecurityCode = false;
  toastHeader = "Diary comment submitted";
  handleAuth() {
    this.loading = true;
    getSecurityCode({ customerId: this.recordId })
      .then((result) => {
        if (result || result === "") {
          this.loading = false;
          this.securityCode = result;
          this.showAuthenticateBtn = false;
          this.showSecurityCode = true;
        } else {
          this.loading = false;
          this.showToast("Error!", "Something went wrong!", "error");
        }
      })
      .catch((error) => {
        this.loading = false;
        this.showToast("Error!", error.body.message, "error");
      });
  }
  handleCode(event) {
    let content = "A Diary Comment will be added to the customer profile.";
    this.openModal(
      content,
      event.target.dataset.name,
      this.label.customerExistingBTLComment
    );
  }
  openModal(content, eventName, comment) {
    ConfirmationModal.open({
      size: "small",
      description: "Diary Comment Addition Confirmation",
      content: content,
      onselect: (e) => {
        // stop further propagation of the event
        e.stopPropagation();
        if (e.detail === "confirm") {
          let toastBody = "A diary comment will be added for this customer.";
          this.showToast(this.toastHeader, toastBody, "success");
          this.createDiaryComment(this.recordId, comment, eventName);
        }
      }
    });
  }
  handleFailedAuth(event) {
    let eventName = event.target.dataset.name;
    let content =
      "When logging a failed authentication: " +
      "<ul> " +
      '<li> The customers Security Code will be updated to "Branch To Load". </li>' +
      "<li> And a Diary Comment will be submitted. </li>" +
      "</ul>" +
      "<br/>" +
      "The customers will need to visit their nearest branch with photo ID to reset their Security Code.";
    ConfirmationModal.open({
      size: "small",
      description: "Auth Failed",
      content: content,
      onselect: (e) => {
        // stop further propagation of the event
        e.stopPropagation();
        if (e.detail === "confirm") {
          this.loading = true;
          //update security code here
          updateSecurityCode({
            customerId: this.recordId,
            securityCode: this.label.authBTLCode
          })
            .then((result) => {
              if (result) {
                let toastBody =
                  "A diary comment will be added and Customer's security code has been replaced";
                this.showToast(this.toastHeader, toastBody, "success");
                this.createDiaryComment(
                  this.recordId,
                  this.label.customerFailedAuthComment,
                  eventName
                );
              } else {
                this.loading = false;
                this.showToast(
                  "Error!",
                  "Error occured while updating security code",
                  "error"
                );
              }
            })
            .catch((error) => {
              this.loading = false;
              this.showToast("Error!", error.body.message, "error");
            });
        }
      }
    });
  }
  handleTheft(event) {
    let content = "A Diary Comment will be added to the customer profile.";
    this.openModal(
      content,
      event.target.dataset.name,
      this.label.customerIdFraudComment
    );
  }
  createDiaryComment(customerId, comment, event) {
    this.loading = true;
    createDiaryComment({
      customerId: customerId,
      comment: comment,
      event: event
    })
      .then((result) => {
        if (result) {
          this.handleClose();
        } else {
          this.showToast(
            "Error!",
            "Error occured while creating diary comment",
            "error"
          );
        }
        this.loading = false;
      })
      .catch((error) => {
        this.loading = false;
        this.showToast("Error!", error.body.message, "error");
      });
  }
  handleClose() {
    this.showSecurityCode = false;
    this.showAuthenticateBtn = true;
  }
  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
}
