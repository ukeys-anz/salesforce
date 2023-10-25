import { LightningElement, wire, api } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import role from "@salesforce/schema/OpportunityContactRole.Role";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { CloseActionScreenEvent } from "lightning/actions";
import createProspectFromOpportunity from "@salesforce/apex/MLCRMOpportunityActions.createProspectFromOpportunity";
import createProspectForCustomer from "@salesforce/apex/MLCRMOpportunityActions.createOppContactRoleForCustomer";

//labels
import MLCRM_CreateProspect_Header from "@salesforce/label/c.MLCRM_CreateProspect_Header";
import MLCRM_Create_Prospect_Existing_Customer from "@salesforce/label/c.MLCRM_Create_Prospect_Existing_Customer";
import MLCRM_CreateProspectWarningMessage from "@salesforce/label/c.MLCRM_CreateProspectWarningMessage";
import ML_CreateProspectSuccessMessage from "@salesforce/label/c.ML_CreateProspectSuccessMessage";
import ML_CreateProspectErrorMessage from "@salesforce/label/c.ML_CreateProspectErrorMessage";
import ML_CreateRoleErrorMessage from "@salesforce/label/c.ML_CreateRoleErrorMessage";
import MLCRM_MobileOrEmailRequiredMessage from "@salesforce/label/c.MLCRM_MobileOrEmailRequiredMessage";
import MLCRM_PhoneFormatErrorMessage from "@salesforce/label/c.MLCRM_PhoneFormatErrorMessage";
import MLCRM_MobileHelpText from "@salesforce/label/c.MLCRM_MobileHelpText";
import MLCRM_ContactInformationHeader from "@salesforce/label/c.MLCRM_ContactInformationHeader";

export default class CreateProspectAndContactRole extends LightningElement {
  createProspectPayload = {};
  headerText;
  showWarningBanner = true;
  showCreateProspect;
  showProgressScreen;
  progress = 0;
  showMobileOrPhoneError = false;
  individualRecordTypeId;
  searchResults = [];
  isExistingCustomer = false;
  existingCustomerId;
  isCreatingProspect = false;
  @api recordId;

  // getting opportunity contact default recordtype role picklist value
  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: role
  })
  rolePicklistValues;

  salutationPicklistValue = [
    {
      label: "Mr.",
      value: "Mr."
    },
    {
      label: "Ms.",
      value: "Ms."
    },
    {
      label: "Dr.",
      value: "Dr."
    },
    {
      label: "Mr.",
      value: "Mr."
    },
    {
      label: "Prof.",
      value: "Prof."
    }
  ];

  // Table header column for existing customer table
  columnsIndividual = [
    {
      label: "Customer Name",
      fieldName: "accountName",
      sortable: true,
      type: "url",
      typeAttributes: { label: { fieldName: "name" }, target: "_self" }
    },

    {
      label: "Mobile",
      fieldName: "strMobilePhone"
    },
    {
      label: "Email",
      fieldName: "strEmail"
    }
  ];

  label = {
    MLCRM_CreateProspect_Header,
    MLCRM_Create_Prospect_Existing_Customer,
    MLCRM_CreateProspectWarningMessage,
    ML_CreateProspectSuccessMessage,
    ML_CreateProspectErrorMessage,
    ML_CreateRoleErrorMessage,
    MLCRM_MobileOrEmailRequiredMessage,
    MLCRM_PhoneFormatErrorMessage,
    MLCRM_MobileHelpText,
    MLCRM_ContactInformationHeader
  };

  get rolePicklistValue() {
    return this.rolePicklistValues.data
      ? this.rolePicklistValues.data.values
      : [];
  }

  connectedCallback() {
    this.createProspectPayload.strRole = "Applicant";
    this.headerText = this.label.MLCRM_CreateProspect_Header;
    this.showCreateProspect = true;
    this.showProgressScreen = false;
    this.processMaintainPartyAPICall();
  }

  disconnectedCallback() {
    clearInterval(this._interval);
  }

  // method to hide warning banner
  hideBanner() {
    this.showWarningBanner = false;
  }

  // handling change event on input field and store values in wrapper
  handleChange(evt) {
    this.createProspectPayload[evt.target.name] = evt.target.value;
    if (
      evt.target.name === "strEmail" ||
      evt.target.name === "strMobilePhone"
    ) {
      this.validateEmailOrPhone();
    }
  }

  // saving and validation input which user selects on UI.
  saveRecord() {
    if (this.existingCustomerId) {
      this.createOcrForExistingCustomer();
    } else {
      let mobileOrEmailValid = this.validateEmailOrPhone();
      let allInputElement = [
        ...this.template.querySelectorAll("lightning-input")
      ];

      let allCombobox = [
        ...this.template.querySelectorAll("lightning-combobox")
      ];
      let allField = [...allInputElement, ...allCombobox];
      const allValid =
        allField.reduce((validSoFar, inputFields) => {
          inputFields.reportValidity();
          return validSoFar && inputFields.checkValidity();
        }, true) && mobileOrEmailValid;
      if (allValid) {
        this.headerText =
          "Creating New Prospect:" +
          this.createProspectPayload.strFirstName +
          " " +
          this.createProspectPayload.strLastName;
        this.showCreateProspect = false;
        this.showProgressScreen = true;
        this.progress = 0;
        this.callMaintainPartyAPI();
      }
    }
  }

  // callout to maintain party API to check if detail enter matches with any existing customer or if is a prospect
  callMaintainPartyAPI() {
    createProspectFromOpportunity({
      requestPayload: JSON.stringify(this.createProspectPayload),
      oppId: this.recordId,
      strRole: this.createProspectPayload.strRole
    })
      .then((result) => {
        this.isLoading = false;
        this.leadDetails = false;
        this.showProgressScreen = false;
        if (result.isNewCustomer === false) {
          this.isExistingCustomer = true;
          this.headerText = this.label.MLCRM_Create_Prospect_Existing_Customer;
          result.matchedResults.forEach((record) => {
            let tempRec = Object.assign({}, record);
            this.existingCustomerId = tempRec.id;
            tempRec.accountName = "/" + tempRec.id;
            tempRec.strMobilePhone = this.createProspectPayload.strMobilePhone;
            tempRec.strEmail = this.createProspectPayload.strEmail;
            this.searchResults.push(tempRec);
          });
        } else {
          this.showProgressScreen = false;
          this.closeAction();
          this.showToast(
            "Success",
            "Success",
            this.label.ML_CreateProspectSuccessMessage,
            "Dismissable"
          );
        }
      })
      .catch(() => {
        this.closeAction();
        this.showProgressScreen = false;
        this.showToast(
          "Error",
          "Error",
          this.label.ML_CreateProspectErrorMessage,
          "Dismissable"
        );
      });
  }

  // maintaing process bar during process call.
  processMaintainPartyAPICall() {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this._interval = setInterval(() => {
      if (this.progress < 10) {
        this.progress = this.progress + 3;
      } else if (this.progress >= 10 && this.progress < 50) {
        this.progress = this.progress + 3;
      } else if (this.progress >= 50 && this.progress <= 99) {
        this.progress =
          this.progress >= 90 && this.progress !== 99
            ? this.progress + 1
            : this.progress === 99
            ? (this.progress = 99)
            : this.progress + 3;
      }
    }, 200);
  }

  // method to validate user enter atleast mobile or email
  validateEmailOrPhone() {
    let email = this.template.querySelector(".email").value;
    let phone = this.template.querySelector(".phone").value;
    if (email || phone) {
      this.showMobileOrPhoneError = false;
      return true;
    }
    this.showMobileOrPhoneError = true;
    return false;
  }

  // method to show toast message
  showToast(title, varriant, message, mode) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: varriant,
      mode: mode
    });
    this.dispatchEvent(toastEvent);
  }

  // method to create contact role for existing customer
  createOcrForExistingCustomer() {
    this.isCreatingProspect = true;
    createProspectForCustomer({
      strRecordId: this.existingCustomerId,
      oppId: this.recordId,
      strRole: this.createProspectPayload.strRole
    })
      .then(() => {
        this.closeAction();
        this.showToast(
          "Success",
          "Success",
          this.label.ML_CreateProspectSuccessMessage,
          "Dismissable"
        );
        this.isCreatingProspect = false;
      })
      .catch(() => {
        this.isCreatingProspect = false;
        this.closeAction();
        this.showToast(
          "Error",
          "Error",
          this.label.ML_CreateRoleErrorMessage,
          "Dismissable"
        );
      });
  }

  // method to close the modao
  closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}
