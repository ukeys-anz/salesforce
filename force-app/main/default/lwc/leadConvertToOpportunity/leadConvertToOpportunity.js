import { LightningElement, api, track } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { NavigationMixin } from "lightning/navigation";
import searchPartyInfo from "@salesforce/apex/CCRMLeadConversionActions.searchPartyInfoLWC";
import createParty from "@salesforce/apex/CCRMLeadConversionActions.createPartyLWC";
import getLeadRecordForConversion from "@salesforce/apex/CCRMLeadConversion.getLeadRecordForConversion";
import convertLead from "@salesforce/apex/CCRMLeadConversion.convertLead";
import { handleErrorShowToast, showToast, handleErrors } from "c/utils";

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
  }
];
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
  @track errorMessage;
  columns = columns;
  certifiedResults = [];
  probableResults = [];
  isLoading = false;
  searchParty = false;
  leadDetails = false;
  isConvertLead = false;
  noDataCertified = false;
  noDataProbable = false;
  setCertifiedSelectedRow = [];
  setProbableSelectedRow = [];
  isConvertLeadButton = false;
  setCertifiedTableHeight = "height: 200px";
  setProbableTableHeight = "height: 200px";

  fields = [
    "FirstName",
    "LastName",
    "ABN__c",
    "ACN__c",
    "MobilePhone",
    "Home_Phone__c",
    "Email",
    "Address"
  ];

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
    this.isLoading = true;
    try {
      const leadConvertDataResult = await getLeadRecordForConversion({
        recordId: this.recordId
      });
      this.isLoading = false;
      this.leadConvertData = leadConvertDataResult;
      const validationResult = await this.validateLead();
      if (validationResult && !this.searchParty) {
        if (this.leadConvertData.leadRecord.Not_Registered__c) {
          this.createParty();
        } else if (!this.leadDetails) {
          this.initiateLeadConversion();
        }
      }
    } catch (error) {
      this.handleError(error);
    }
  }

  initiateLeadConversion() {
    this.searchParty = false;
    this.isConvertLead = true;
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
    if (!this.leadConvertData.leadRecord.FinServ__ExpressedInterest__c) {
      this.validLead = false;
      this.validationMessage.push({
        id: this.validationMessage.length + 1,
        body:
          "Expressed Interest - Please select a product category from Expressed Interest field."
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
          this.validLead = false;
          this.validationMessage.push({
            id: this.validationMessage.length + 1,
            body:
              "Please enter a valid address. A PO Box address cannot be entered."
          });
          //# Criteria #4
        } else if (!this.leadConvertData.leadRecord.Is_Valid_Address__c) {
          this.validLead = false;
          this.validationMessage.push({
            id: this.validationMessage.length + 1,
            body: "Please enter a valid address."
          });
        }
      }
      //# Criteria #5
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
      //# Criteria #6
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
      //# Criteria #7
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
      //# Criteria #8
      if (
        !this.leadConvertData.leadRecord.Not_Registered__c &&
        this.leadConvertData.leadRecord.Entity_Type__c !== "Individual" &&
        this.leadConvertData.leadRecord.ABN__c &&
        this.leadConvertData.leadRecord.ABN_Validation_Status__c !== "Active" &&
        this.leadConvertData.leadRecord.ACN__c &&
        this.leadConvertData.leadRecord.ACN_Validation_Status__c !== "Active"
      ) {
        this.validLead = false;
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
      (this.leadConvertData.relatedAccountType === "isIndividual" ||
        this.leadConvertData.relatedAccountType === "isBusiness") &&
      ((this.leadConvertData.leadRecord.ABN__c &&
        this.leadConvertData.leadRecord.ABN_Validation_Status__c !==
          "Active") ||
        (this.leadConvertData.leadRecord.ACN__c &&
          this.leadConvertData.leadRecord.ACN_Validation_Status__c !==
            "Active"))
    ) {
      this.validLead = false;
      this.validationMessage.push({
        id: this.validationMessage.length + 1,
        body: "Capture valid ABN / ACN details."
      });
    } else if (this.leadConvertData.relatedAccountType === "isInvalid") {
      this.validLead = false;
      this.validationMessage.push({
        id: this.validationMessage.length + 1,
        body:
          "Related Party - Please select a valid Party for Conversion. This includes Organisation, Individual, CLG, Prospect Customers."
      });
    }

    //# Criteria #10
    if (
      (this.leadConvertData.leadRecord.ABN_Validation_Status__c === "Active" ||
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
    return this.validLead;
  }

  closeAction() {
    this.dispatchEvent(new CloseActionScreenEvent());
    this.initialise();
  }

  createParty() {
    if (this.leadConvertData.leadRecord.Entity_Type__c === "Individual") {
      handleErrorShowToast(
        this,
        "ERROR!",
        "",
        "You cannot create Individual prospect using CAP API",
        "pester"
      );
    } else {
      this.isLoading = true;
      createParty({
        record: this.leadConvertData.leadRecord
      })
        .then(() => {
          this.isLoading = false;
          showToast(
            this,
            "SUCCESS!",
            "Lead Updated Successfully with CAPCIS ID",
            "",
            "Success",
            ""
          );
        })
        .catch((error) => {
          this.isLoading = false;
          handleErrorShowToast(
            this,
            "An error has occurred. Please try again later or contact your system administrator.",
            error,
            "",
            "pester"
          );
        });
    }
    this.closeAction();
  }

  initialise() {
    this.validLead = false;
    this.leadTitle = "";
    this.isModalOpen = false;
    this.validationMessage = [];
    this.progress = 0;
    this.processStatus = "";
    this.leadDetails = false;
    this.searchParty = false;
    this.certifiedResults = [];
    this.probableResults = [];
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
        if (result.certifiedResults.length === 0) {
          this.noDataCertified = true;
          this.setCertifiedTableHeight = "";
        } else {
          result.certifiedResults.forEach((record) => {
            let tempRec = Object.assign({}, record);
            tempRec.accountName = "/" + tempRec.id;
            this.certifiedResults.push(tempRec);
          });
        }
        if (result.probableResults.length === 0) {
          this.noDataProbable = true;
          this.setProbableTableHeight = "";
        } else {
          result.probableResults.forEach((record) => {
            let tempRec = Object.assign({}, record);
            tempRec.accountName = "/" + tempRec.id;
            this.probableResults.push(tempRec);
          });
        }
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

  getCertifiedSelectedRow(event) {
    const selectedRows = event.detail.selectedRows;
    this.leadConvertData.leadRecord.FinServ__RelatedAccount__c =
      selectedRows[0].id;
    this.isConvertLeadButton = true;
    this.setProbableSelectedRow = []; // empty selection.
  }

  getProbableSelectedRow(event) {
    const selectedRows = event.detail.selectedRows;
    this.leadConvertData.leadRecord.FinServ__RelatedAccount__c =
      selectedRows[0].id;
    this.isConvertLeadButton = true;
    this.setCertifiedSelectedRow = []; // empty selection.
  }
}
