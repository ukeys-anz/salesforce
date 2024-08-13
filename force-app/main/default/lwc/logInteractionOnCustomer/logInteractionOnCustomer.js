import { LightningElement, wire, api, track } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import INTERACTION_OBJECT from "@salesforce/schema/Interaction";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import NAME_FIELD from "@salesforce/schema/Interaction.Name";
import CATEGORY_FIELD from "@salesforce/schema/Interaction.Category__c";
import CUSTOMER_FIELD from "@salesforce/schema/Interaction.AccountId";
import INTTYPE_FIELD from "@salesforce/schema/Interaction.InteractionType";
import STARTTIME_FIELD from "@salesforce/schema/Interaction.StartTime";
import OPTIONAL_NOTES_FIELD from "@salesforce/schema/Interaction.Optional_Notes__c";
import COMMENT_FIELD from "@salesforce/schema/Interaction.Comment__c";
import FINANCIAL_ACCOUNT_FIELD from "@salesforce/schema/Interaction.Financial_Account__c";
import EXPIRY_DATE_FIELD from "@salesforce/schema/Interaction.Expiry_Date__c";
import PERMANENT_FIELD from "@salesforce/schema/Interaction.Permanent__c";
import getCommentTypeMapping from "@salesforce/apex/CCRMLogInteractionController.getCommentTypeMapping";
import getSearchResult from "@salesforce/apex/CCRMLogInteractionController.getSearchResult";

export default class LogInteractionOnCustomer extends LightningElement {
  recordTypeId;
  interactionObject = INTERACTION_OBJECT;
  _hasRendered = false;
  @api recordId;
  nameField = NAME_FIELD;
  categoryField = CATEGORY_FIELD;
  customerField = CUSTOMER_FIELD;
  intTypeField = INTTYPE_FIELD;
  startTimeField = STARTTIME_FIELD;
  optionalNotesField = OPTIONAL_NOTES_FIELD;
  commentField = COMMENT_FIELD;
  FinancialAccountField = FINANCIAL_ACCOUNT_FIELD;
  expiryDateField = EXPIRY_DATE_FIELD;
  permanentField = PERMANENT_FIELD;
  accountId;
  showInteractionFields = true;
  showDiaryFields = false;
  @track interactionFields = {};
  category;
  commentTypeOptions = [];
  financialAccountValue;
  commentTypeValue;
  commentValue;
  expiryDateValue;
  permanentValue = false;
  dependentPicklistData;
  disabledExpiryDate = false;
  maxLength = false;
  isLoading = true;
  CONSTANT = {
    CAP_DIARY_COMMENT: "CAP Diary Comments",
    COMMENT_ERROR: "Comment must be limited to 256 characters.",
    EXPIRY_ERROR: "Please select a date greater than today's date.",
    INT_RT: "CCRM Interaction",
    FA_ROLE_OBJECT: "FinServ__FinancialAccountRole__c",
    FA_LABEL: "Financial Account",
    FA_PLACEHOLDER: "Search Financial Account..."
  };
  searchKey;
  searchResults = [];
  todayDate;
  defaultExpiryDate;

  @wire(getObjectInfo, { objectApiName: INTERACTION_OBJECT })
  Function({ error, data }) {
    if (data) {
      let objArray = data.recordTypeInfos;
      for (let i in objArray) {
        if (objArray[i].name === this.CONSTANT.INT_RT)
          this.recordTypeId = objArray[i].recordTypeId;
      }
    } else if (error) {
      this.showToast("Error", "Error", error.body.message, "Dismissable");
    }
  }

  connectedCallback() {
    let date = new Date();
    this.todayDate =
      date.getFullYear() +
      "-" +
      (date.getMonth() + 1) +
      "-" +
      (date.getDate() + 1);
    this.defaultExpiryDate =
      date.getFullYear() +
      7 +
      "-" +
      (date.getMonth() + 1) +
      "-" +
      date.getDate();
    getCommentTypeMapping()
      .then((result) => {
        if (result) {
          Object.keys(JSON.parse(result.commentType)).forEach((key) => {
            this.commentTypeOptions.push({ label: `${key}`, value: `${key}` });
          });
        }
        this.dependentPicklistData = JSON.parse(result.commentType);
      })
      .catch((error) => {
        this.showToast("Error", "Error", error.body.message, "Dismissable");
      });
  }

  renderedCallback() {
    if (!this._hasRendered && this.recordId) {
      this.doSearch();
      this._hasRendered = true;
      this.isLoading = false;
    }
  }

  doSearch() {
    getSearchResult({ recordId: this.recordId, searchKey: this.searchKey })
      .then((result) => {
        this.searchResults = result;
      })
      .catch((error) => {
        this.showToast("Error", "Error", error.body.message, "Dismissable");
      });
  }

  handleSearch(event) {
    this.searchKey = event.detail.searchKey;
    this.doSearch();
  }

  handleFinancialAccountChange(event) {
    event.preventDefault();
    this.financialAccountValue = event.detail.selected?.id;
  }

  handleInteractionLoad() {
    this.accountId = this.recordId;
  }

  handleCategoryChange(event) {
    this.category = event.detail.value;
    if (this.category === this.CONSTANT.CAP_DIARY_COMMENT) {
      this.showInteractionFields = false;
      this.showDiaryFields = true;
    } else {
      this.showInteractionFields = true;
      this.showDiaryFields = false;
      this.interactionFields = {};
    }
  }

  handleCommentTypeChange(event) {
    this.commentTypeValue = event.target.value;
    this.commentValue = "";
    if (this.dependentPicklistData) {
      for (let key in this.dependentPicklistData) {
        if (this.commentTypeValue === key) {
          this.commentValue = this.dependentPicklistData[key];
        }
      }
    }
  }

  handleCommentChange(event) {
    this.commentValue = event.target.value;
    this.reportValidity();
  }

  handleExpiryDateChange(event) {
    this.expiryDateValue = event.target.value;
    this.reportValidity();
  }

  handlePermanentChange(event) {
    this.permanentValue = event.target.checked;
    if (this.permanentValue === true) {
      this.expiryDateValue = undefined;
      this.refs.expiryElement.value = "";
      this.disabledExpiryDate = true;
      this.reportValidity();
    } else {
      this.disabledExpiryDate = false;
    }
  }

  handleInteractionSuccess() {
    this.dispatchEvent(new CloseActionScreenEvent());
    this.showToast(
      "Success",
      "Success",
      "Interaction Created Successfully",
      "Dismissable"
    );
    this.isLoading = false;
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  checkValidity() {
    let isValid = true;
    if (this.refs.commentElement) {
      let commentElement = this.refs.commentElement;
      if (this.commentValue && this.commentValue.length > 256) {
        commentElement.setCustomValidity(this.CONSTANT.COMMENT_ERROR);
        isValid = false;
      } else {
        commentElement.setCustomValidity("");
      }
    }
    if (this.refs.expiryElement) {
      let expiryElement = this.refs.expiryElement.checkValidity();
      isValid = !expiryElement ? false : isValid;
    }
    return isValid;
  }

  reportValidity() {
    let isValid = this.checkValidity();
    if (this.refs.commentElement) {
      this.refs.commentElement.reportValidity();
    }
    if (this.refs.expiryElement) {
      this.refs.expiryElement.reportValidity();
    }
    return isValid;
  }

  handleSubmit(event) {
    this.isLoading = true;
    event.preventDefault();
    if (this.reportValidity()) {
      const fields = event.detail.fields;
      if (this.category === this.CONSTANT.CAP_DIARY_COMMENT) {
        this.interactionFields.Category__c = fields.Category__c;
        this.interactionFields.Name = this.CONSTANT.CAP_DIARY_COMMENT;
        this.interactionFields.Channel = "Call";
        this.interactionFields.StartTime = new Date().toISOString();
        this.interactionFields.AccountId = this.recordId;
        this.interactionFields.Comment__c = this.commentValue;
        if (this.expiryDateValue) {
          this.interactionFields.Expiry_Date__c = this.expiryDateValue;
        } else {
          this.interactionFields.Expiry_Date__c = this.defaultExpiryDate;
        }
        this.interactionFields.Permanent__c = this.permanentValue;
        this.interactionFields.Financial_Account__c =
          this.financialAccountValue;
      } else {
        this.interactionFields = fields;
      }
      this.template
        .querySelector("lightning-record-edit-form")
        .submit(this.interactionFields);
    } else {
      this.isLoading = false;
    }
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
}
