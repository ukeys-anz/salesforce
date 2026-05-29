import { LightningElement, wire, api, track } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import INTERACTION_OBJECT from "@salesforce/schema/Interaction";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getRecord } from "lightning/uiRecordApi";
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
import INTERACTION_TYPE_FIELD from "@salesforce/schema/Interaction.Interaction_Type__c";
import SOURCE_SYSTEM_NAME_FIELD from "@salesforce/schema/Account.Source_System_Name__c";
import logCAPNote from "@salesforce/customPermission/LogCAPNote";
import { SimpleToast } from "c/utils";

export default class LogInteractionOnCustomer extends LightningElement {
  interactionObject = INTERACTION_OBJECT;
  _hasRendered = false;
  @api recordId;
  nameField = NAME_FIELD;
  categoryField = CATEGORY_FIELD;
  customerField = CUSTOMER_FIELD;
  intTypeField = INTTYPE_FIELD;
  interactionTypeField = INTERACTION_TYPE_FIELD;
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
  _financialAccountValue;
  interactionTypeValue;
  _commentTypeValue;
  _commentValue;
  _expiryDateValue;
  _permanentValue = false;
  dependentPicklistData;
  _disabledExpiryDate = false;
  maxLength = false;
  isLoading = true;
  CONSTANT = {
    CAP_DIARY_COMMENT: "CAP Diary Comments",
    COMMENT_ERROR: "Comment must be limited to 256 characters.",
    EXPIRY_ERROR: "Please select a date greater than today's date.",
    CCRM_INT_RT: "CCRM Interaction",
    RETAIL_INT_RT: "Retail Interaction",
    FA_ROLE_OBJECT: "FinServ__FinancialAccountRole__c",
    FA_LABEL: "Financial Account",
    FA_PLACEHOLDER: "Search Financial Account...",
    CACHE: "CACHE",
    CAP_NOTE_INFO:
      "Notes have been submitted to CAP, but we cannot confirm whether it has been saved successfully. Please check the CAP Diary Comments table to verify.",
    CAP_NOTE_CREATE_SUCCESS: "Interaction Created Successfully.",
    CAP_NOTE_PERMANENT_INFO: `Only 1 permanent note is allowed per customer profile or account record. 
      If a permanent note already exists, this note will not be logged in CAP.`
  };
  _searchKey;
  searchResults = [];
  @api retailLogCAPNote = logCAPNote;
  toast = new SimpleToast(this);

  @api
  get searchKey() {
    return this._searchKey;
  }
  set searchKey(value) {
    this._searchKey = value;
  }

  @api
  get financialAccountValue() {
    return this._financialAccountValue;
  }
  set financialAccountValue(value) {
    this._financialAccountValue = value;
  }

  @api
  get commentTypeValue() {
    return this._commentTypeValue;
  }
  set commentTypeValue(value) {
    this._commentTypeValue = value;
  }

  @api
  get commentValue() {
    return this._commentValue;
  }
  set commentValue(value) {
    this._commentValue = value;
  }

  @api
  get expiryDateValue() {
    return this._expiryDateValue;
  }
  set expiryDateValue(value) {
    this._expiryDateValue = value;
  }

  @api
  get permanentValue() {
    return this._permanentValue;
  }
  set permanentValue(value) {
    this._permanentValue = value;
  }

  @api
  get disabledExpiryDate() {
    return this._disabledExpiryDate;
  }
  set disabledExpiryDate(value) {
    this._disabledExpiryDate = value;
  }
  tomorrowDateFormatted;
  defaultExpiryDate;
  objectData;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [SOURCE_SYSTEM_NAME_FIELD]
  })
  account;

  @wire(getObjectInfo, { objectApiName: INTERACTION_OBJECT })
  Function({ error, data }) {
    if (data) {
      this.objectData = data.recordTypeInfos;
    } else if (error) {
      this.toast.error(error.body.message);
    }
  }

  get recordTypeId() {
    if (!this.objectData) return null;

    const recordTypes = Object.values(this.objectData);
    return this.retailLogCAPNote
      ? recordTypes.find((rt) => rt.name === this.CONSTANT.RETAIL_INT_RT)
          .recordTypeId
      : recordTypes.find((rt) => rt.name === this.CONSTANT.CCRM_INT_RT)
          .recordTypeId;
  }

  get header() {
    return this.retailLogCAPNote ? "Log CAP Note" : "Log Interaction";
  }

  get showPermFlagInfo() {
    return (
      this.retailLogCAPNote && this.category === this.CONSTANT.CAP_DIARY_COMMENT
    );
  }

  connectedCallback() {
    let date = new Date();
    let tomorrowDate = new Date(date.getTime() + 86400000);
    this.tomorrowDateFormatted =
      tomorrowDate.getFullYear() +
      "-" +
      (tomorrowDate.getMonth() + 1) +
      "-" +
      tomorrowDate.getDate();
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
          this.commentTypeOptions = [];
          Object.keys(JSON.parse(result.commentType)).forEach((key) => {
            this.commentTypeOptions.push({ label: `${key}`, value: `${key}` });
          });
        }
        this.dependentPicklistData = JSON.parse(result.commentType);
        this.setRetailDefaultCommentType();
      })
      .catch((error) => {
        this.toast.error(error.body.message);
      });
  }

  setRetailDefaultCommentType() {
    if (this.retailLogCAPNote) {
      this._commentTypeValue = "Other";
      this.handleCommentTypeChange({ target: { value: "Other" } });
    }
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
        this.toast.error(error.body.message);
      });
  }

  handleSearch(event) {
    this._searchKey = event.detail.searchKey;
    this.doSearch();
  }

  handleFinancialAccountChange(event) {
    event.preventDefault();
    this._financialAccountValue = event.detail.selected?.id;
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
    this._commentTypeValue = event.target.value;
    this._commentValue = "";
    if (this.dependentPicklistData) {
      for (let key in this.dependentPicklistData) {
        if (this._commentTypeValue === key) {
          this._commentValue = this.dependentPicklistData[key];
        }
      }
    }
  }
  handleCommentChange(event) {
    this._commentValue = event.target.value;
    this.reportValidity();
  }

  handleExpiryDateChange(event) {
    this._expiryDateValue = event.target.value;
    this.reportValidity();
  }

  handlePermanentChange(event) {
    this._permanentValue = event.target.checked;
    if (this._permanentValue === true) {
      this._expiryDateValue = undefined;
      this.refs.expiryElement.value = "";
      this._disabledExpiryDate = true;
      this.reportValidity();
    } else {
      this._disabledExpiryDate = false;
    }
  }

  handleInteractionSuccess() {
    this.isLoading = false;
    this.dispatchEvent(new CloseActionScreenEvent());

    if (this.retailLogCAPNote) {
      this.toast.info(this.CONSTANT.CAP_NOTE_INFO);
    } else {
      this.toast.success(this.CONSTANT.CAP_NOTE_CREATE_SUCCESS);
    }
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
    event.preventDefault();
    if (
      this.account?.data?.fields?.Source_System_Name__c?.value ===
        this.CONSTANT.CACHE &&
      this.category === this.CONSTANT.CAP_DIARY_COMMENT
    ) {
      this.toast.error(
        "You can't create CAP diary comment for cache customer."
      );
      return;
    }
    this.isLoading = true;
    if (this.reportValidity()) {
      const fields = event.detail.fields;
      if (this.category === this.CONSTANT.CAP_DIARY_COMMENT) {
        this.interactionFields.Interaction_Type__c = "COI Proactive";
        this.interactionFields.Category__c = fields.Category__c;
        this.interactionFields.Name = this.CONSTANT.CAP_DIARY_COMMENT;
        this.interactionFields.Channel = "Call";
        this.interactionFields.StartTime = new Date().toISOString();
        this.interactionFields.AccountId = this.recordId;
        this.interactionFields.Comment__c = this.commentValue;
        if (this.expiryDateValue) {
          this.interactionFields.Expiry_Date__c = this.expiryDateValue;
        } else if (this.permanentValue === false) {
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
}
