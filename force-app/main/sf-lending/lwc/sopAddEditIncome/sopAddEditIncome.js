import { api } from "lwc";
import OTHER_IMG from "@salesforce/resourceUrl/Other_income_img";
import LightningModal from "lightning/modal";
import addIncome from "@salesforce/apex/SOPController.addIncome";
import editIncome from "@salesforce/apex/SOPController.editIncome";
import { handleErrorShowToast, showToast } from "c/utils";
import { publish, createMessageContext } from "lightning/messageService";
import RefreshSOP from "@salesforce/messageChannel/RefreshSOP__c";

import {
  incomeTypeOptions,
  incomeTaxOptions,
  frequencyOptions,
  employmentTypeOptions,
  mandatoryFields,
  incomeDetailsFields,
  FIELDS_MISSING_MSG,
  INCOME_DETAIL_MISSING_MSG,
  FUTURE_DATE_MSG,
  typeMap,
  checkDateInPast
} from "./helper";

export default class SopAddEditIncome extends LightningModal {
  messageContext = createMessageContext();
  @api incomeDetails;
  @api isAddModal; //if true then add income else edit income

  addPayload = {
    parent: "",
    etag: "",
    income: {
      details: this.incomeTypesDetail,
      employment: this.employment
    },
    incomeVerified: this.incomeVerified
  };
  editPayload = {
    uid: "",
    name: "",
    etag: "",
    incomeVerifiedChanged: false,
    incomeVerified: this.incomeVerified,
    details: this.incomeTypesDetail,
    employment: this.employment
  };
  employment = {
    basis: "",
    businessName: "",
    partyId: "",
    startDate: { year: "", month: "", day: "" },
    type: "EMPLOYMENT_TYPE_PAYG",
    startDateValue: new Date()
  };
  belongsToOptions = [
    {
      label: "--Please Select--",
      value: ""
    }
  ];
  incomeTypesDetail = [
    {
      amountType: "",
      frequency: "",
      type: "INCOME_TYPE_BASE_SALARY"
    }
  ];

  logoOtherImage = OTHER_IMG;
  isEditModal;
  incomeVerifiedChanged;
  incomeVerifiedOriginal;
  showIncomeDetailError = false;
  incomeVerified = false;
  incomeAdded = "";
  incomeEdited = "";
  error;
  isLoading = false;

  incomeTypeOptions = incomeTypeOptions;
  incomeTaxOptions = incomeTaxOptions;
  frequencyOptions = frequencyOptions;
  employmentTypeOptions = employmentTypeOptions;

  connectedCallback() {
    this.createBelongToOption();
    if (this.isAddModal) {
      this.addPayload.parent = this.incomeDetails?.sopId ?? null;
      return;
    }
    this.populateEditDefaultValues();
  }

  createBelongToOption() {
    this.belongsToOptions = this.belongsToOptions.concat(
      Object.keys(this.incomeDetails.partyIdToFirstNameMap).map((key) => {
        return {
          label: this.incomeDetails.partyIdToFirstNameMap[key],
          value: key
        };
      })
    );
  }

  populateEditDefaultValues() {
    this.isEditModal = true;
    this.editPayload.uid = this.incomeDetails?.uid;
    this.editPayload.name = this.incomeDetails?.name;
    this.editPayload.etag = this.incomeDetails?.etag;
    this.editPayload.incomeVerifiedChanged = false;
    this.incomeVerified = this.incomeDetails?.incomeVerified;
    this.incomeVerifiedOriginal = this.incomeDetails?.incomeVerified;
    this.employment.basis = this.incomeDetails?.employmentType;
    this.employment.businessName = this.incomeDetails?.employer;
    this.employment.partyId = this.incomeDetails?.partyId;
    this.employment.startDateValue = this.getISOdate(
      this.incomeDetails?.startDate
    );
    this.incomeTypesDetail = [...this.incomeDetails.incomeItemDetails];
  }

  handleClose() {
    this.close();
  }

  getISOdate(dateStr) {
    const myDate = new Date(dateStr);
    const offset = myDate.getTimezoneOffset();
    const localDate = new Date(myDate.getTime() - offset * 60 * 1000);
    return localDate.toISOString().split("T")[0];
  }

  handleActionsMenuSelect(event) {
    this.hasIncomeDetailError(false);
    let valueSelected = event.detail.value;
    if (this.addItemDetail(valueSelected)) {
      this.incomeTypesDetail = [
        ...this.incomeTypesDetail,
        this.addItemDetail(valueSelected)
      ];
    }
  }

  addItemDetail(value) {
    let itemDetail = {};
    if (this.incomeTypesDetail.some((item) => item[value] === true)) {
      this.hasIncomeDetailError(true);
      return false;
    }
    itemDetail[value] = true;
    itemDetail.type = typeMap[value];
    return itemDetail;
  }

  onTypeDelete(event) {
    this.hasIncomeDetailError(false);
    let dataname = event.currentTarget.dataset.name;
    let index = this.incomeTypesDetail.findIndex(
      (item) => item.type === typeMap[dataname]
    );
    if (index !== -1) {
      this.incomeTypesDetail.splice(index, 1);
      this.incomeTypesDetail = [...this.incomeTypesDetail];
    }
  }

  handleEmpDetailChange(event) {
    let val = event.detail.value;
    let dataname = event.currentTarget.dataset.name;
    this.employment[dataname] = val;
  }

  handleDetailsChanges(event) {
    let datatype = event.currentTarget.dataset.id;
    let dataname = event.currentTarget.dataset.name;
    let val = event.detail.value;
    this.incomeTypesDetail = this.incomeTypesDetail.map((item) => {
      if (item.type === datatype) {
        return { ...item, [dataname]: val };
      }
      return item;
    });
  }
  handleIncomeVerify(event) {
    this.incomeVerified = event.target.checked;
  }

  handleBelongsToChange(event) {
    this.employment.partyId = event.detail.value;
  }

  hasIncomeDetailError(isError) {
    this.showIncomeDetailError = isError;
  }

  getErrorMessage(fieldName) {
    if (mandatoryFields.includes(fieldName)) {
      return FIELDS_MISSING_MSG;
    } else if (incomeDetailsFields.includes(fieldName)) {
      return INCOME_DETAIL_MISSING_MSG;
    }
    return "";
  }

  async handleSubmit() {
    this.isLoading = true;

    this.validateBeforeSubmit();
    if (this.error) {
      this.isLoading = false;
      return;
    }
    if (this.isAddModal) {
      await this.handleAddIncome();
    } else {
      await this.handleEditIncome();
    }
    this.isLoading = false;
    this.close();
  }

  async handleAddIncome() {
    this.addPayload.income.employment = this.employment;
    this.addPayload.income.details = this.incomeTypesDetail;
    this.addPayload.incomeVerified = this.incomeVerified;
    this.handleStartDate(new Date(this.employment.startDateValue));
    try {
      this.incomeAdded = await addIncome({
        loanId: this.incomeDetails?.loanId,
        incomeDetails: this.addPayload
      });
      if (this.incomeAdded === "Success") {
        showToast(
          this,
          "Add Income",
          "Successfully added new income.",
          "",
          "Success",
          ""
        );
        publish(this.messageContext, RefreshSOP, { refresh: true });
      }
    } catch (ex) {
      handleErrorShowToast(
        this,
        "",
        ex,
        "The income record couldn't be added. Please review and try again. Raise a fault through TechAssist if the problem persists."
      );
    }
  }

  async handleEditIncome() {
    this.editPayload.employment = this.employment;
    this.editPayload.details = this.incomeTypesDetail;
    this.editPayload.incomeVerified = this.incomeVerified;
    this.editPayload.incomeVerifiedChanged =
      this.incomeVerifiedOriginal !== this.incomeVerified;
    this.handleStartDate(new Date(this.employment.startDateValue));
    try {
      this.incomeEdited = await editIncome({
        loanId: this.incomeDetails?.loanId,
        incomeDetails: this.editPayload
      });
      if (this.incomeEdited === "Success") {
        showToast(
          this,
          "Edit Income",
          "Successfully Edited income.",
          "",
          "Success",
          ""
        );
        publish(this.messageContext, RefreshSOP, { refresh: "true" });
      }
    } catch (ex) {
      handleErrorShowToast(
        this,
        "",
        ex,
        "The income record didn't save all the changes. Please review and try again. Raise a fault through TechAssist if the problem persists."
      );
    }
  }

  handleStartDate(startDate) {
    this.employment.startDate.year = startDate.getFullYear();
    this.employment.startDate.month = startDate.getMonth() + 1;
    this.employment.startDate.day = startDate.getDate();
  }

  validateBeforeSubmit() {
    this.hasIncomeDetailError(false);
    this.error = [
      ...this.template.querySelectorAll(
        "lightning-input, lightning-select,lightning-combobox"
      )
    ].reduce((errorMessage, inputCmp) => {
      inputCmp.reportValidity();
      if (!inputCmp.checkValidity()) {
        errorMessage += errorMessage.includes(
          this.getErrorMessage(inputCmp.dataset.name)
        )
          ? ""
          : this.getErrorMessage(inputCmp.dataset.name);
      }
      return errorMessage;
    }, "");
    if (!checkDateInPast(new Date(this.employment.startDateValue))) {
      this.error += FUTURE_DATE_MSG;
    }
  }
}
