import { LightningElement, api, track } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from "lightning/navigation";

import getLeadRecordForConversion from "@salesforce/apex/CCRMLeadConversion.getLeadRecordForConversion";
import convertLead from "@salesforce/apex/CCRMLeadConversion.convertLead";
// Util methods
import { handleErrorShowToast, showToast, handleErrors } from "c/utils";
export default class LeadConversion extends NavigationMixin(LightningElement) {
  // Initial Declaration
  @api recordId;
  @track leadConvertData;
  @track leadTitle = null;
  @track isConverted = false;
  @track isModalOpen = false;
  @track validLead = false;
  @track validationMessage = [];
  @track progress = 0;
  @track processStatus = "";

  connectedCallback() {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this._interval = setInterval(() => {
      if (this.progress < 10) {
        this.processStatus = "Initiating Lead Conversion...";
        this.progress = this.progress + 3;
      } else if (this.progress >= 10 && this.progress < 50) {
        this.processStatus = "Validating Lead...";
        this.progress = this.progress + 3;
      } else if (this.progress >= 50 && this.progress <= 99) {
        this.processStatus = "Converting Lead...";
        this.progress =
          this.progress >= 90 && this.progress !== 99
            ? this.progress + 1
            : this.progress === 99
            ? (this.progress = 99)
            : this.progress + 3;
      } else if (this.progress >= 100 && this.isConverted) {
        clearInterval(this._interval);
        this.processStatus = "Completed";
      }
    }, 400);
  }

  disconnectedCallback() {
    clearInterval(this._interval);
  }

  @api async invoke() {
    try {
      const leadConvertDataResult = await getLeadRecordForConversion({
        recordId: this.recordId
      });
      this.leadConvertData = leadConvertDataResult;
      const validationResult = await this.validateLead();
      if (validationResult) {
        this.isModalOpen = true;
        this.progress = 0;
        convertLead({
          recordId: this.recordId,
          accountId: this.leadConvertData.leadRecord.FinServ__RelatedAccount__c
        })
          .then((result) => {
            this.isConverted = true;
            this.progress = 98;
            if (result === null) {
              this.closeAction();
              handleErrorShowToast(
                this,
                "ERROR!",
                "",
                "Empty result. Lead Conversion Failed!",
                "pester"
              );
            } else {
              this.closeAction();
              showToast(
                this,
                "SUCCESS!",
                "Lead Conversion Completed successfully.",
                "",
                "Success",
                ""
              );
              this[NavigationMixin.Navigate]({
                type: "standard__recordPage",
                attributes: {
                  recordId: result,
                  objectApiName: "Opportunity",
                  actionName: "view"
                }
              });
            }
          })
          .catch((error) => {
            this.handleError(error);
          });
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  validateLead() {
    this.isModalOpen = true;
    this.validationMessage = [];
    this.validLead = true;

    //# Setting Modal Title
    if (
      this.leadConvertData.leadRecord.Company === null ||
      this.leadConvertData.leadRecord.Company === undefined
    ) {
      this.leadTitle =
        "Converting Lead - " +
        this.leadConvertData.leadRecord.Name +
        " into an Opportunity.";
    } else {
      this.leadTitle =
        "Converting Lead - " +
        this.leadConvertData.leadRecord.Company +
        " into an Opportunity.";
    }

    //# Criteria #1
    if (
      this.leadConvertData.leadRecord.FinServ__RelatedAccount__c === null ||
      this.leadConvertData.leadRecord.FinServ__RelatedAccount__c === undefined
    ) {
      //# Criteria #2
      if (
        this.leadConvertData.leadRecord.FinServ__ExpressedInterest__c ===
          null ||
        this.leadConvertData.leadRecord.FinServ__ExpressedInterest__c ===
          undefined
      ) {
        this.validLead = false;
        this.validationMessage.push({
          id: this.validationMessage.length + 1,
          body:
            "Expressed Interest - Please select a product category from Expressed Interest field."
        });
      }
      //# Criteria #3
      if (
        this.leadConvertData.leadRecord.Address !== null &&
        this.leadConvertData.leadRecord.Address !== undefined &&
        !this.leadConvertData.leadRecord.Is_Valid_Address__c
      ) {
        this.validLead = false;
        this.validationMessage.push({
          id: this.validationMessage.length + 1,
          body: "Please enter a valid address."
        });
      }
      //# Criteria #4
      if (
        this.leadConvertData.leadRecord.Street !== undefined &&
        this.leadConvertData.leadRecord.Street !== null
      ) {
        let street = this.leadConvertData.leadRecord.Street;
        let result = /P\.?\s?O\.?\sB[Oo][Xx]./.exec(street);
        if (result) {
          this.validLead = false;
          this.validationMessage.push({
            id: this.validationMessage.length + 1,
            body:
              "Please enter a valid address. A PO Box addresses cannot be entered."
          });
        }
      }
      //# Criteria #5
      if (
        this.leadConvertData.leadRecord.CPID__c === undefined ||
        this.leadConvertData.leadRecord.CPID__c === null
      ) {
        this.validLead = false;
        this.validationMessage.push({
          id: this.validationMessage.length + 1,
          body: "Please select a valid Controlling Post ID."
        });
      }
      //# Criteria #6
      if (
        this.leadConvertData.leadRecord.Industry__c === undefined ||
        this.leadConvertData.leadRecord.Industry__c === null
      ) {
        this.validLead = false;
        this.validationMessage.push({
          id: this.validationMessage.length + 1,
          body: "Please select a valid Industry Code."
        });
      }
      //# Criteria #7
      if (
        this.leadConvertData.leadRecord.Entity_Type__c === undefined ||
        this.leadConvertData.leadRecord.Entity_Type__c === null
      ) {
        this.validLead = false;
        this.validationMessage.push({
          id: this.validationMessage.length + 1,
          body: "Please select a valid Entity Type."
        });
      }
      //# Criteria #8
      if (
        this.leadConvertData.leadRecord.New_to_Bank__c === undefined ||
        this.leadConvertData.leadRecord.New_to_Bank__c === null
      ) {
        this.validLead = false;
        this.validationMessage.push({
          id: this.validationMessage.length + 1,
          body: "New to Bank field cannot be blank."
        });
      }
      //# Criteria #9
      if (
        !this.leadConvertData.leadRecord.Not_Registered__c &&
        this.leadConvertData.leadRecord.Entity_Type__c !== "Individual"
      ) {
        this.validLead = false;
        this.validationMessage.push({
          id: this.validationMessage.length + 1,
          body: "Capture valid ABN and ACN details."
        });
      }
    } else {
      //# Criteria #10
      if (this.leadConvertData.relatedAccountType === "isBusiness") {
        if (
          this.leadConvertData.leadRecord.ABN_Validation_Status__c !==
            "Active" &&
          this.leadConvertData.leadRecord.ACN_Validation_Status__c !== "Active"
        ) {
          this.validLead = false;
          this.validationMessage.push({
            id: this.validationMessage.length + 1,
            body:
              "Capture valid ABN and ACN details for selected Related Party."
          });
        }
        //# Criteria #11
      } else if (this.leadConvertData.relatedAccountType === "isIndividual") {
        if (
          (this.leadConvertData.leadRecord.ABN__c !== null &&
            this.leadConvertData.leadRecord.ABN__c !== undefined &&
            this.leadConvertData.leadRecord.ABN_Validation_Status__c !==
              "Active") ||
          (this.leadConvertData.leadRecord.ACN__c !== null &&
            this.leadConvertData.leadRecord.ACN__c !== undefined &&
            this.leadConvertData.leadRecord.ACN_Validation_Status__c !==
              "Active")
        ) {
          this.validLead = false;
          this.validationMessage.push({
            id: this.validationMessage.length + 1,
            body: "Capture valid ABN / ACN details."
          });
        }
      } else if (this.leadConvertData.relatedAccountType === "isInvalid") {
        this.validLead = false;
        this.validationMessage.push({
          id: this.validationMessage.length + 1,
          body:
            "Related Party - Please select a valid Party for Conversion. This includes Organisation, Individual, CLG, Prospect Customers."
        });
      }

      //# Criteria #12
      if (
        (this.leadConvertData.leadRecord.ABN_Validation_Status__c ===
          "Active" ||
          this.leadConvertData.leadRecord.ACN_Validation_Status__c ===
            "Active") &&
        this.leadConvertData.leadRecord.Not_Registered__c
      ) {
        this.validLead = false;
        this.validationMessage.push({
          id: this.validationMessage.length + 1,
          body:
            "Not Registered - Valid ABN or ACN exist, please uncheck Not Registered box."
        });
      }
    }
    return this.validLead;
  }

  closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
    this.initialise();
  }

  initialise() {
    this.validLead = false;
    this.leadTitle = "";
    this.isModalOpen = false;
    this.validationMessage = [];
    this.progress = 0;
    this.processStatus = "";
  }

  handleError(error) {
    handleErrors(error);
    handleErrorShowToast(this, "ERROR!", "", this.errorMessage, "pester");
    this.closeAction();
  }
}
