import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import searchPartyInfo from "@salesforce/apex/CCRMLeadConversionActions.searchPartyInfoLWC";
import createParty from "@salesforce/apex/CCRMLeadConversionActions.createPartyLWC";
import maintainParty from "@salesforce/apex/CCRMLeadConversionActions.maintainPartyLWC";
import isLeadMisMatchCustomer from "@salesforce/apex/CCRMLeadConversionActions.isLeadMisMatchCustomer"; //CC-857
import getLeadRecordForConversion from "@salesforce/apex/CCRMLeadConversion.getLeadRecordForConversion";
import convertCCRMLead from "@salesforce/apex/CCRMLeadConversionActions.convertCCRMLead";
import convertLeadWithMatchedParty from "@salesforce/apex/CCRMLeadConversionActions.convertLeadWithMatchedParty";
import { handleErrorShowToast, showToast, handleErrors } from "c/utils";
import WARNING_ICON from "@salesforce/resourceUrl/Warning_Icon"; //CC-857

// import labels
import CCRM_LeadConversionValidationSubText from "@salesforce/label/c.CCRM_LeadConversionValidationSubText";
import CCRM_LeadConversionValidationHeading from "@salesforce/label/c.CCRM_LeadConversionValidationHeading";
import CCRM_LeadConversionSearchPartySubText from "@salesforce/label/c.CCRM_LeadConversionSearchPartySubText";
import MLCRM_LeadConversionMaintainPartySubText from "@salesforce/label/c.MLCRM_LeadConversionMaintainPartySubText";
import CCRM_LeadDetailsSubText from "@salesforce/label/c.CCRM_LeadDetailsSubText";
import MLCRM_LeadDetailsSubText from "@salesforce/label/c.MLCRM_LeadDetailsSubText";
import MLCRM_AmountValidationError from "@salesforce/label/c.MLCRM_AmountValidationError";
import MLCRM_CustomerNeedsError from "@salesforce/label/c.MLCRM_CustomerNeedsError";
import MLCRM_LeadSourceError from "@salesforce/label/c.MLCRM_LeadSourceError";
import MLCRM_ConversionStatusValidationError from "@salesforce/label/c.MLCRM_ConversionStatusValidationError";
import CCRM_AddressError from "@salesforce/label/c.CCRM_AddressError";
import CCRM_RegisteredCompanyError from "@salesforce/label/c.CCRM_RegisteredCompanyError";
import CCRM_ExistingCustomerError from "@salesforce/label/c.CCRM_ExistingCustomerError";
import CCRM_CustomerNeedsError from "@salesforce/label/c.CCRM_CustomerNeedsError";
import MLCRM_Lead_MisMatch_Warning_Message from "@salesforce/label/c.MLCRM_Lead_MisMatch_Warning_Message"; //CC-857

const columns = [
  {
    label: "Name",
    fieldName: "accountName",
    sortable: true,
    type: "url",
    typeAttributes: { label: { fieldName: "name" }, target: "_self" }
  },
  {
    label: "Suburb",
    fieldName: "suburb"
  },
  {
    label: "Postcode",
    fieldName: "postCode"
  },
  {
    label: "CPID",
    fieldName: "cpid"
  },
  {
    label: "KYC status",
    fieldName: "kycStatus"
  },
  {
    label: "Match",
    fieldName: "match"
  }
];
const columnsIndividual = [
  {
    label: "Customer Name",
    fieldName: "accountName",
    sortable: true,
    type: "url",
    typeAttributes: { label: { fieldName: "name" }, target: "_self" }
  },
  {
    label: "Address",
    fieldName: "address"
  },
  {
    label: "CLG ID",
    fieldName: "clgId"
  },
  {
    label: "CPID",
    fieldName: "cpid"
  },
  {
    label: "KYC status",
    fieldName: "kycStatus"
  },
  {
    label: "Source System",
    fieldName: "sourceSystem"
  },
  {
    label: "OCV ID",
    fieldName: "ocvId"
  }
];

const leadCommonValidationMatrix = [
  {
    fieldName: "Company",
    length: 40,
    message: "Company Name cannot be greater than 40 chars."
  },
  {
    fieldName: "City",
    length: 25,
    message: "City Name cannot be greater than 25 chars."
  },
  {
    fieldName: "State",
    length: 15,
    message: "State cannot be greater than 15 chars."
  },
  {
    fieldName: "ABN__c",
    length: 11,
    replace: " ",
    message: "ABN cannot be greater than 11 chars."
  },
  {
    fieldName: "ACN__c",
    length: 11,
    replace: " ",
    message: "ACN cannot be greater than 11 chars."
  },
  {
    fieldName: "Name",
    length: 40,
    message: "Name cannot be greater than 40 chars."
  }
];

const warningMsgConstant = "Warning";

export default class LeadConversion extends NavigationMixin(LightningElement) {
  // Initial Declaration
  @api recordId;
  @track leadConvertData;
  @track leadTitle = null;
  @track modalBodySubText = null;
  @track isConverted = false;
  @track isModalOpen = false;
  @track enableCreatePartAndConvertButton = false;
  @track validLead = false;
  @track validationMessage = [];
  @track progress = 0;
  @track processStatus = "";
  @track errorMessage;
  @track noMatchSelected = "";
  @track misMatchWarning = false; //CC-857
  @track misMatchLeadDetailsMessage = null; //CC-857
  columns = columns;
  columnsIndividual = columnsIndividual;
  leadCommonValidationMatrix = leadCommonValidationMatrix;
  searchResults = [];
  leadSearchResultRows = [];
  isLoading = false;
  searchParty = false;
  createPartyRequired = false;
  maintainPartyExist = false;
  leadDetails = false;
  isCCRMlead = false;
  isMLCRMlead = false;
  isConvertLead = false;
  noDataFound = false;
  setSelectedRow = [];
  isConvertLeadButton = false;
  setTableHeight = "height: 100%";
  cpId = "";
  accountId = "";
  warningSignUrl = WARNING_ICON; //CC-857
  warningMsgConstant = warningMsgConstant; //CC-857

  get noMatchOption() {
    return [{ label: "No Match Available", value: "createParty" }];
  }

  label = {
    CCRM_LeadConversionValidationSubText,
    CCRM_LeadConversionValidationHeading,
    CCRM_LeadConversionSearchPartySubText,
    MLCRM_LeadDetailsSubText,
    MLCRM_AmountValidationError,
    MLCRM_CustomerNeedsError,
    MLCRM_LeadSourceError,
    CCRM_CustomerNeedsError,
    MLCRM_LeadConversionMaintainPartySubText,
    MLCRM_ConversionStatusValidationError,
    CCRM_AddressError,
    CCRM_RegisteredCompanyError,
    CCRM_ExistingCustomerError,
    CCRM_LeadDetailsSubText,
    MLCRM_Lead_MisMatch_Warning_Message
  };

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
    this.invokeOnReady();
  }

  disconnectedCallback() {
    clearInterval(this._interval);
  }

  async invokeOnReady() {
    this.isLoading = true;
    try {
      const leadConvertDataResult = await getLeadRecordForConversion({
        recordId: this.recordId
      });

      this.isLoading = false;
      this.leadConvertData = leadConvertDataResult;
      const validationResult = await this.validateLead();
      //remove close icon
      this.removeCloseIcon();
      //CC-857 Check and show warning if the lead details are mis matching with customer details
      if (validationResult && this.isMLCRMlead) {
        const isLeadMistmatched = await isLeadMisMatchCustomer({
          recordId: this.recordId
        });
        if (isLeadMistmatched) {
          this.misMatchWarning = true;
          this.misMatchLeadDetailsMessage =
            this.label.MLCRM_Lead_MisMatch_Warning_Message.replaceAll(
              "\n",
              "<br>"
            );
        } else {
          this.misMatchWarning = false;
        }
      }
      if (validationResult && !this.searchParty) {
        if (this.createPartyRequired) {
          this.leadDetails = false;
          this.createParty();
          this.createPartyRequired = false;
        } else if (!this.leadDetails && !this.isConvertLead) {
          this.initiateLeadConversion();
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  removeCloseIcon() {
    //remove close icon
    let style = document.createElement("style");
    style.innerText =
      ".slds-modal__header .slds-modal__close {display : none;}";
    this.template.querySelector(".slds-modal__container").appendChild(style);
  }

  initiateLeadConversion() {
    this.searchParty = false;
    this.isConvertLead = true;
    this.maintainPartyExist = false;
    this.isModalOpen = true;
    this.progress = 0;
    convertCCRMLead({
      accId: this.leadConvertData.leadRecord.FinServ__RelatedAccount__c,
      leadRec: this.leadConvertData.leadRecord
    })
      .then((result) => {
        this.isConverted = true;
        this.progress = 98;
        if (result === null || result === "undefined" || result === "") {
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

  validateLead() {
    this.isModalOpen = true;
    this.validationMessage = [];
    this.validLead = true;

    //# Setting Modal Title
    //CC-4587 ML Showcase Observations - Lead Conversion - company is not needed for ML
    this.updateModalTitle();
    if (
      this.leadConvertData.leadRecord.FinServ__RelatedAccount__c === null ||
      this.leadConvertData.leadRecord.FinServ__RelatedAccount__c === undefined
    ) {
      if (
        this.leadConvertData.leadRecord.RecordType.DeveloperName === "CCRM_Lead"
      ) {
        this.modalBodySubText = this.label.CCRM_LeadDetailsSubText;
      } else {
        this.modalBodySubText = this.label.MLCRM_LeadDetailsSubText;
      }
    }
    this.validateLeadCommon();
    if (
      this.leadConvertData.leadRecord.RecordType.DeveloperName === "CCRM_Lead"
    ) {
      this.validateLeadCCRM();
      this.isCCRMlead = true;
      if (
        !this.isIndividual &&
        (this.leadConvertData.leadRecord.Registered_Company__c === undefined ||
          this.leadConvertData.leadRecord.Registered_Company__c === "No") &&
        (this.leadConvertData.leadRecord.FinServ__RelatedAccount__c === null ||
          this.leadConvertData.leadRecord.FinServ__RelatedAccount__c ===
            undefined)
      ) {
        this.createPartyRequired = true;
        this.leadDetails = false;
      }
    } else if (
      this.leadConvertData.leadRecord.RecordType.DeveloperName === "MLCRM_Lead"
    ) {
      this.validateLeadMLCRM();
      this.isMLCRMlead = true;
      this.leadDetails = true;
    }
    return this.validLead;
  }

  validateLeadCommon() {
    leadCommonValidationMatrix.forEach((record) => {
      if (
        this.leadConvertData.leadRecord[record.fieldName] &&
        (record.replace
          ? this.leadConvertData.leadRecord[record.fieldName].replaceAll(
              record.replace,
              ""
            ).length > record.length
          : this.leadConvertData.leadRecord[record.fieldName].length >
            record.length)
      ) {
        this.setInvalidLead();
        this.validationMessage.push({
          id: this.validationMessage.length + 1,
          body: record.message
        });
      }
    });
  }

  validateLeadCCRM() {
    //# Criteria #1
    if (!this.leadConvertData.leadRecord.FinServ__ExpressedInterest__c) {
      this.setInvalidLead();
      this.validationMessage.push({
        id: this.validationMessage.length + 1,
        body: this.label.CCRM_CustomerNeedsError
      });
    }
    //# Criteria #2
    if (
      this.leadConvertData.leadRecord.FinServ__RelatedAccount__c === null ||
      this.leadConvertData.leadRecord.FinServ__RelatedAccount__c === undefined
    ) {
      this.leadDetails = true;
      if (this.leadConvertData.leadRecord.Address) {
        //# Criteria #3
        let street = this.leadConvertData.leadRecord.Street;
        let result = /P\.?\s?O\.?\sB[Oo][Xx]./.exec(street);
        if (result) {
          this.setInvalidLead();
          this.validationMessage.push({
            id: this.validationMessage.length + 1,
            body: this.label.CCRM_AddressError
          });
          //# Criteria #4
        } else if (!this.leadConvertData.leadRecord.Is_Valid_Address__c) {
          this.setInvalidLead();
          this.validationMessage.push({
            id: this.validationMessage.length + 1,
            body: "Please enter a valid address."
          });
        }
      }
      //# Criteria #5
      if (
        !this.isIndividual &&
        (this.leadConvertData.leadRecord.Industry__c === undefined ||
          this.leadConvertData.leadRecord.Industry__c === null)
      ) {
        this.setInvalidLead();
        this.validationMessage.push({
          id: this.validationMessage.length + 1,
          body: "Please select a valid ANZSIC Code."
        });
      }
      //# Criteria #6
      if (
        this.leadConvertData.leadRecord.Entity_Type__c === undefined ||
        this.leadConvertData.leadRecord.Entity_Type__c === null
      ) {
        this.setInvalidLead();
        this.validationMessage.push({
          id: this.validationMessage.length + 1,
          body: "Please select a valid Entity Type."
        });
      }
      //# Criteria #7
      if (
        this.leadConvertData.leadRecord.New_to_Bank__c === undefined ||
        this.leadConvertData.leadRecord.New_to_Bank__c === null
      ) {
        this.setInvalidLead();
        this.validationMessage.push({
          id: this.validationMessage.length + 1,
          body: "New to Bank field cannot be blank."
        });
      }
      //# Criteria #8
      if (
        this.leadConvertData.leadRecord.Registered_Company__c === "Yes" &&
        !this.isIndividual &&
        this.leadConvertData.leadRecord.ABN__c &&
        this.leadConvertData.leadRecord.ABN_Validation_Status__c !== "Active" &&
        this.leadConvertData.leadRecord.ACN__c &&
        this.leadConvertData.leadRecord.ACN_Validation_Status__c !== "Active"
      ) {
        this.setInvalidLead();
        this.validationMessage.push({
          id: this.validationMessage.length + 1,
          body: "Capture valid ABN and ACN details."
        });
      }
    }

    //# Criteria #9
    // Throw error IF Related Party = Business OR Individual AND
    //Supplied ABN OR ACN is Cancelled
    else if (
      (this.isIndividual || this.isOrgCustomer) &&
      ((this.leadConvertData.leadRecord.ABN__c &&
        this.leadConvertData.leadRecord.ABN_Validation_Status__c !==
          "Active") ||
        (this.leadConvertData.leadRecord.ACN__c &&
          this.leadConvertData.leadRecord.ACN_Validation_Status__c !==
            "Active"))
    ) {
      this.setInvalidLead();
      this.validationMessage.push({
        id: this.validationMessage.length + 1,
        body: "Capture valid ABN / ACN details."
      });
    } else if (this.leadConvertData.relatedAccountType === "isInvalid") {
      this.setInvalidLead();
      this.validationMessage.push({
        id: this.validationMessage.length + 1,
        body: this.label.CCRM_ExistingCustomerError
      });
    }

    //# Criteria #10
    if (
      (this.leadConvertData.leadRecord.ABN_Validation_Status__c === "Active" ||
        this.leadConvertData.leadRecord.ACN_Validation_Status__c ===
          "Active") &&
      (this.leadConvertData.leadRecord.Registered_Company__c === undefined ||
        this.leadConvertData.leadRecord.Registered_Company__c === "No")
    ) {
      this.setInvalidLead();
      this.validationMessage.push({
        id: this.validationMessage.length + 1,
        body: this.label.CCRM_RegisteredCompanyError
      });
    }
  }

  validateLeadMLCRM() {
    //# Criteria #1
    if (!this.leadConvertData.leadRecord.FinServ__ExpressedInterest__c) {
      this.setInvalidLead();
      this.validationMessage.push({
        id: this.validationMessage.length + 1,
        body: this.label.MLCRM_CustomerNeedsError
      });
    }
    //# Criteria #2
    if (
      this.leadConvertData.leadRecord.FinServ__PotentialValue__c === null ||
      this.leadConvertData.leadRecord.FinServ__PotentialValue__c === undefined
    ) {
      this.setInvalidLead();
      this.validationMessage.push({
        id: this.validationMessage.length + 1,
        body: this.label.MLCRM_AmountValidationError
      });
    }
    //# Criteria #3
    if (
      this.leadConvertData.leadRecord.LeadSource === null ||
      this.leadConvertData.leadRecord.LeadSource === undefined
    ) {
      this.setInvalidLead();
      this.validationMessage.push({
        id: this.validationMessage.length + 1,
        body: this.label.MLCRM_LeadSourceError
      });
    }
  }

  cancelAction() {
    this.initialise();
    this.dispatchEvent(new CustomEvent("closeconvertmodal"));
  }

  closeAction() {
    this.initialise();
    this.dispatchEvent(new CustomEvent("closeconvertmodal"));
  }

  convertLeadMLCRM() {
    if (
      this.leadConvertData.leadRecord.FinServ__RelatedAccount__c === null ||
      this.leadConvertData.leadRecord.FinServ__RelatedAccount__c === undefined
    ) {
      this.maintainPartyAction();
    } else {
      this.leadDetails = false;
      this.initiateLeadConversion();
    }
  }

  convertLeadIndividualCCRM() {
    this.maintainPartyAction();
  }

  maintainPartyAction() {
    this.searchParty = false;
    this.maintainPartyExist = false;
    this.isConvertLead = true;
    this.isModalOpen = true;
    this.progress = 0;
    this.leadDetails = false;
    this.leadTitle =
      "Converting Lead " +
      this.leadConvertData.leadRecord.Name +
      " into an Opportunity.";
    maintainParty({
      record: this.leadConvertData.leadRecord
    })
      .then((result) => {
        this.isLoading = false;
        this.leadDetails = false;
        if (result.isNewCustomer === false) {
          this.maintainPartyExist = true;
          this.isConvertLead = false;
          this.progress = 0;
          if (result.matchedResults.length === 0) {
            this.noDataFound = true;
            this.setTableHeight = "";
          } else {
            result.matchedResults.forEach((record) => {
              let tempRec = Object.assign({}, record);
              tempRec.accountName = "/" + tempRec.id;
              this.accountId = tempRec.id;
              this.cpId = tempRec.cpid;
              this.searchResults.push(tempRec);
            });
            //this.leadConvertData.leadRecord.FinServ__RelatedAccount__c = this.searchResults[0].id;
            //remove grey background from data table
            let style = document.createElement("style");
            style.innerText =
              ".resultTable2 .slds-table_header-fixed_container {background : white;}";
            this.template
              .querySelector(".convertLeadContianer")
              .appendChild(style);
          }
          this.leadTitle = "Lead Conversion - Add a Customer to this Lead";
          this.modalBodySubText =
            this.label.MLCRM_LeadConversionMaintainPartySubText;
        } else {
          this.isLoading = false;
          this.isConverted = true;
          this.progress = 98;
          if (
            result.oppID === null ||
            result.oppID === "undefined" ||
            result.oppID === ""
          ) {
            this.closeAction();
            handleErrorShowToast(
              this,
              "ERROR!",
              "",
              "Empty result. Lead Conversion Failed!",
              "pester"
            );
          } else if (result.oppID !== "") {
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
                recordId: result.oppID,
                objectApiName: "Opportunity",
                actionName: "view"
              }
            });
          }
        }
      })
      .catch((error) => {
        this.isLoading = false;
        this.handleError(error);
        //this.closeAction();
      });
  }

  convertLeadWithMatchedParty() {
    this.isLoading = true;
    this.maintainPartyExist = false;
    this.isConvertLead = true;
    this.isModalOpen = true;
    this.progress = 0;
    this.leadDetails = false;
    this.leadTitle =
      "Converting Lead " +
      this.leadConvertData.leadRecord.Name +
      " into an Opportunity.";
    convertLeadWithMatchedParty({
      accId: this.accountId,
      cpId: this.cpId,
      leadRec: this.leadConvertData.leadRecord
    })
      .then((result) => {
        this.isLoading = false;
        this.isConverted = true;
        this.progress = 98;
        if (result === null || result === "undefined" || result === "") {
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
        this.isLoading = false;
        this.handleError(error);
        //this.closeAction();
      });
  }

  createParty() {
    this.searchParty = false;
    this.isConvertLead = true;
    this.isModalOpen = true;
    this.progress = 0;
    this.updateModalTitle();
    createParty({
      record: this.leadConvertData.leadRecord
    })
      .then((result) => {
        this.isConverted = true;
        this.progress = 98;
        if (result === null || result === "undefined" || result === "") {
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

  updateModalTitle() {
    if (
      this.leadConvertData.leadRecord.RecordType.DeveloperName ===
        "CCRM_Lead" &&
      this.leadConvertData.leadRecord.Company !== null &&
      this.leadConvertData.leadRecord.Company !== undefined
    ) {
      this.leadTitle =
        "Converting " +
        this.leadConvertData.leadRecord.Company +
        " into an Opportunity.";
    } else {
      this.leadTitle =
        "Converting " +
        this.leadConvertData.leadRecord.Name +
        " into an Opportunity.";
    }
  }

  setInvalidLead() {
    this.validLead = false;
    this.leadTitle = this.label.CCRM_LeadConversionValidationHeading;
    this.modalBodySubText = this.label.CCRM_LeadConversionValidationSubText;
  }

  initialise() {
    this.validLead = false;
    this.leadTitle = "";
    this.modalBodySubText = "";
    this.isModalOpen = false;
    this.validationMessage = [];
    this.isConvertLead = false;
    this.progress = 0;
    this.processStatus = "";
    this.leadDetails = false;
    this.searchParty = false;
    this.maintainPartyExist = false;
    this.searchResults = [];
    this.leadSearchResultRows = [];
    this.enableCreatePartAndConvertButton = false;
    this.cpId = "";
    this.accountId = "";
  }

  handleError(error) {
    handleErrors(error);
    handleErrorShowToast(this, "ERROR!", error, this.errorMessage, "pester");
    this.closeAction();
  }

  searchForParty() {
    this.isLoading = true;
    searchPartyInfo({
      record: this.leadConvertData.leadRecord
    })
      .then((result) => {
        this.isLoading = false;
        this.searchParty = true;
        this.leadDetails = false;
        if (result.probableAndCertifiedResults.length === 0) {
          this.noDataFound = true;
          this.setTableHeight = "";
        } else {
          result.probableAndCertifiedResults.forEach((record) => {
            let tempRec = Object.assign({}, record);
            tempRec.accountName = "/" + tempRec.id;
            this.searchResults.push(tempRec);
          });

          //remove grey background from data table
          let style = document.createElement("style");
          style.innerText =
            ".resultTable .slds-table_header-fixed_container {background : white;}";
          this.template
            .querySelector(".convertLeadContianer")
            .appendChild(style);
        }
        this.leadTitle = "Lead Conversion - Add a Customer to this Lead";
        this.modalBodySubText =
          this.label.CCRM_LeadConversionSearchPartySubText;
      })
      .catch((error) => {
        this.isLoading = false;
        handleErrorShowToast(
          this,
          "Duplicate customer checking is down. Please make sure this Lead is not an existing ANZ customer and try again",
          error,
          "",
          "pester"
        );
        this.closeAction();
      });
  }

  getSelectedRow(event) {
    const selectedRows = event.detail.selectedRows;
    this.leadConvertData.leadRecord.FinServ__RelatedAccount__c =
      selectedRows[0].id;
    this.isConvertLeadButton = true;
    this.noMatchSelected = undefined;
    this.enableCreatePartAndConvertButton = false;
  }

  enableCreateNewCustomerConvertButton(event) {
    this.enableCreatePartAndConvertButton = true;
    this.isConvertLeadButton = false;
    this.setSelectedRow = [];
    this.noMatchSelected = event.target.value;
  }

  get isIndividual() {
    return this.leadConvertData.leadRecord.Entity_Type__c === "Individual"
      ? true
      : false;
  }

  get isOrgCustomer() {
    return this.leadConvertData.leadRecord.Entity_Type__c !== "Individual"
      ? true
      : false;
  }

  //get list of field Lead summary page
  get fields() {
    //return if Individual type of entity
    if (this.isIndividual) {
      return [
        "Name",
        "FinServ__RelatedAccount__c",
        "MobilePhone",
        "Email",
        "Home_Phone__c",
        "Address",
        "Work_Phone__c"
      ];
    }
    //return if Org type of entity
    return [
      "ABN__c",
      "ACN__c",
      "FirstName",
      "LastName",
      "MobilePhone",
      "Home_Phone__c",
      "Email",
      "Address"
    ];
  }

  get invalidLead() {
    // If this.validLead is false, return a value of true
    return this.validLead ? false : true;
  }
}
