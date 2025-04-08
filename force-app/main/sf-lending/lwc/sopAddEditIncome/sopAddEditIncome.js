import { api } from "lwc";
import OTHER_IMG from "@salesforce/resourceUrl/Other_income_img";
import SALARY_WAGES from "@salesforce/resourceUrl/Salary_wages";
import HOME_IMG from "@salesforce/resourceUrl/SOP_Debt_Mortgage";
import DOLLAR_SIGN from "@salesforce/resourceUrl/Dollar_sign_income";
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
  rentalIncomeTypeOptions,
  mandatoryFields,
  incomeDetailsFields,
  incomeTypesDetailSalary,
  incomeTypesDetailRental,
  FIELDS_MISSING_MSG,
  INCOME_DETAIL_MISSING_MSG,
  FUTURE_DATE_MSG,
  typeMap,
  checkDateInPast,
  getISOdate,
  createIncomeOptions,
  createBelongsToOption
} from "./helper";

export default class SopAddEditIncome extends LightningModal {
  messageContext = createMessageContext();
  @api incomeDetails;
  @api isAddModal;
  addPayload = {
    parent: "",
    etag: "",
    income: {
      details: this.incomeTypesDetail,
      employment: this.employment
    },
    incomeVerified: false
  };

  editPayload = {
    uid: "",
    name: "",
    etag: "",
    incomeVerifiedChanged: false,
    incomeVerified: false,
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
  incomeTypesDetail = incomeTypesDetailSalary;

  logo = SALARY_WAGES;
  mortgage = HOME_IMG;
  isSalary = false;

  incomeVerifiedOriginal;
  showIncomeDetailError = false;
  incomeAdded = "";
  incomeEdited = "";
  isLoading = false;
  showIncomeOptions = false;
  showIncomeForm = false;
  error;
  noRental;

  incomeTypeOptions = incomeTypeOptions;
  incomeTaxOptions = incomeTaxOptions;
  frequencyOptions = frequencyOptions;
  employmentTypeOptions = employmentTypeOptions;
  rentalIncomeTypeOptions = rentalIncomeTypeOptions;
  incomeOptions;
  belongsToOptions;
  rentalPropertyOptions;
  propertyOwnerShipMap;
  selectedIncome = "";
  selectedRental = "";

  connectedCallback() {
    this.incomeData = JSON.parse(JSON.stringify(this.incomeDetails));
    this.belongsToOptions = createBelongsToOption(
      this.incomeData.partyIdToFirstNameMap
    );
    if (this.isAddModal) {
      this.showIncomeOptions = true;
      this.rentalPropertyOptions = this.incomeData?.rentalPropertyOptions
        .filter(
          (option, index, self) =>
            index === self.findIndex((t) => t.value === option.value)
        )
        .sort((a, b) => a.disabled - b.disabled);
      this.propertyOwnerShipMap = this.incomeData?.propertyOwnerShipMap;

      if (this.rentalPropertyOptions.length === 0) {
        this.noRental = true;
      }
      this.addPayload.parent = this.incomeData?.sopId ?? null;
      this.incomeOptions = createIncomeOptions(this.noRental);
      return;
    }
    this.isSalary = this.incomeData.isSalary;
    this.showIncomeForm = true;
    this.populateEditDefaultValues();
  }

  get isNextDisabled() {
    if (this.showIncomeOptions) {
      return !this.selectedIncome;
    }
    if (this.showRentalAddress) {
      return !this.selectedRental;
    }
    return false;
  }

  get IncomeVerifiedImage() {
    return this.isSalary ? OTHER_IMG : DOLLAR_SIGN;
  }

  get formTitleImage() {
    return this.isSalary ? OTHER_IMG : HOME_IMG;
  }

  get isEditModal() {
    return !this.isAddModal;
  }

  get ownerName() {
    if (this.isAddModal) {
      return this.propertyOwnerShipMap[this.selectedRental];
    }
    return this.incomeData.ownerName;
  }

  get agreementType() {
    return this.incomeData.agreementType;
  }

  get agreementTypeValue() {
    return this.isAddModal ? "" : this.incomeData.incomeItemDetails[0].type;
  }

  get showNextBtn() {
    return !this.showIncomeForm;
  }

  get showBackBtn() {
    return this.isAddModal && !this.showIncomeOptions;
  }

  get isRental() {
    return !this.isSalary;
  }

  get incomeVerified() {
    return this.isAddModal
      ? this.addPayload.incomeVerified
      : this.editPayload.incomeVerified;
  }

  get infoSectionHeader() {
    return this.isSalary ? "Employer Details" : "Rental Details";
  }

  get amountSectionHeader() {
    return this.isSalary ? "Income Details" : "Rental Income";
  }

  populateEditDefaultValues() {
    this.editPayload.uid = this.incomeData?.uid;
    this.editPayload.name = this.incomeData?.name;
    this.editPayload.etag = this.incomeData?.etag;
    this.editPayload.incomeVerifiedChanged = false;
    this.editPayload.incomeVerified = this.incomeData?.incomeVerified;
    this.incomeVerifiedOriginal = this.incomeData?.incomeVerified;
    if (this.isSalary) {
      this.employment.basis = this.incomeData?.employmentType;
      this.employment.businessName = this.incomeData?.employer;
      this.employment.partyId = this.incomeData?.partyId;
      this.employment.startDateValue = getISOdate(this.incomeData?.startDate);
    }
    this.incomeTypesDetail = [...this.incomeData.incomeItemDetails];
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

  handleAgreementTypeChange(event) {
    this.incomeTypesDetail = [
      {
        ...this.incomeTypesDetail[0],
        type: event.detail.value
      }
    ];
  }

  handleIncomeChange(event) {
    this.isSalary = event.target.value === "salary";
    this.selectedIncome = event.target.value;
    if (this.isRental) {
      this.incomeTypesDetail = incomeTypesDetailRental;
    }
  }

  handleRentalChange(event) {
    this.selectedRental = event.target.value;
    this.incomeData.singleLineAddress = event.target.dataset.label;
  }

  handleNext() {
    if (this.showIncomeOptions) {
      if (this.selectedIncome === "salary") {
        this.showIncomeOptions = false;
        this.showIncomeForm = true;
      } else if (this.selectedIncome === "rental") {
        this.showIncomeOptions = false;
        this.showRentalAddress = true;
      }
    } else if (this.showRentalAddress) {
      this.showRentalAddress = false;
      this.showIncomeForm = true;
    }
  }

  handleBack() {
    if (this.showIncomeForm) {
      if (this.selectedIncome === "rental") {
        // If we're in income form and came from rental, go back to rental address
        this.selectedRental = "";
        this.showIncomeForm = false;
        this.showRentalAddress = true;
        return;
      }
      // If we're in income form and came from salary, go back to income options
      this.selectedIncome = "";
      this.showIncomeForm = false;
      this.showIncomeOptions = true;
      return;
    }
    if (this.showRentalAddress) {
      // If we're in rental address, go back to income options
      this.selectedIncome = "";
      this.showRentalAddress = false;
      this.showIncomeOptions = true;
    }
  }

  handleIncomeVerify(event) {
    this.isAddModal
      ? (this.addPayload.incomeVerified = event.target.checked)
      : (this.editPayload.incomeVerified = event.target.checked);
  }

  handleBelongsToChange(event) {
    this.employment.partyId = event.detail.value;
  }

  handleClose() {
    this.close();
  }

  hasIncomeDetailError(isError) {
    this.showIncomeDetailError = isError && this.isSalary;
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
    this.addPayload.income.details = this.incomeTypesDetail;
    if (this.isSalary) {
      this.addPayload.income.employment = this.employment;
      this.handleStartDate(new Date(this.employment.startDateValue));
    }
    if (this.isRental) {
      this.addPayload.income.asset = this.selectedRental;
    }
    try {
      this.incomeAdded = await addIncome({
        loanId: this.incomeDetails?.loanId,
        incomeDetails: this.addPayload
      });
      if (this.incomeAdded === "Success") {
        showToast(
          this,
          "Add Income",
          "The income record was successfully added.",
          "",
          "Success",
          ""
        );
        publish(this.messageContext, RefreshSOP, { refresh: true });
      }
    } catch (ex) {
      handleErrorShowToast(
        this,
        "The income record couldn't be added. Please review and try again. Raise a fault through TechAssist if the problem persists.",
        "Add Income Error",
        ex
      );
      publish(this.messageContext, RefreshSOP, { refresh: true });
    }
  }

  async handleEditIncome() {
    this.editPayload.details = this.incomeTypesDetail;
    this.editPayload.incomeVerifiedChanged =
      this.incomeVerifiedOriginal !== this.editPayload.incomeVerified;
    if (this.isSalary) {
      this.editPayload.employment = this.employment;
      this.handleStartDate(new Date(this.employment.startDateValue));
    }
    if (this.isRental) {
      this.editPayload.asset = this.incomeData.asset;
    }
    try {
      this.incomeEdited = await editIncome({
        loanId: this.incomeDetails?.loanId,
        incomeDetails: this.editPayload
      });
      if (this.incomeEdited === "Success") {
        showToast(
          this,
          "Edit Income",
          "The income record was successfully updated.",
          "",
          "Success",
          ""
        );
        publish(this.messageContext, RefreshSOP, { refresh: "true" });
      }
    } catch (ex) {
      handleErrorShowToast(
        this,
        "The income record didn't save all the changes. Please review and try again. Raise a fault through TechAssist if the problem persists.",
        "Edit Income Error",
        ex
      );
      publish(this.messageContext, RefreshSOP, { refresh: true });
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
