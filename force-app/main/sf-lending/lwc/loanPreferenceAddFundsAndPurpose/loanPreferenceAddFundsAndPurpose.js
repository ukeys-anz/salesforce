import { api, wire } from "lwc";
import LightningModal from "lightning/modal";
import { handleErrorShowToast, showToast } from "c/utils";
import styling from "@salesforce/resourceUrl/UpdateLoanStyling";
import { loadStyle } from "lightning/platformResourceLoader";
import getCategoryToPurposeMapping from "@salesforce/apex/AdditionalFundsController.getCategoryToPurposeMapping";
import updateLoanPreference from "@salesforce/apex/LoanPreferenceController.updateLoanPreference";
import loanPreferenceDeleteCashOutPurpose from "c/loanPreferenceDeleteCashOutPurpose";
import { publish, MessageContext } from "lightning/messageService";
import RefreshLoanPreference from "@salesforce/messageChannel/RefreshLoanPreference__c";
import SOP_IMAGE from "@salesforce/resourceUrl/SOP_Images";

const RENOVATIONS_HELP_TEXT = "To fix up or spruce up a home";
const MOTOR_HELP_TEXT =
  "Four wheels, two wheels or no wheels... looking at a new ride?";
const LIFESTYLE_HELP_TEXT =
  "Wedding expenses, medical bills or travel, if extra money is needed for life's costs";
const TOAST_SUCCESS_MSG =
  "Changes to Loan Preferences were successfully saved.";
const TOAST_ERROR_MSG =
  "The changes to the Additional Funds and Purpose did not save. Please try again.";
export default class LoanPreferenceAddFundsAndPurpose extends LightningModal {
  @api loanPreferenceData;
  @api fundRecords;
  @api editPurposeName;
  @api isEditScreenCalled = false;
  fundRecordsForEdit;
  logoImage = `${SOP_IMAGE}/additionalFunds/UpdateLoanAddFunds.png`;
  selectedCategory = "";
  purposeValueMappingModel = "";
  helpTextValue = "";
  selectedPurpose = [];
  purposeOptions = [];
  addFundsOptions = [];
  selectedAddFunds = [];
  fundWithAmountGreaterZero = [];
  updatedFundsWithAmountAndOtherReason = [];
  addFundRecordsWithValidAmount = [];
  categoryOptions = [];
  additionalFundsModel;
  errorMessage;
  showCategoryScreen = true;
  showPurposeScreen = false;
  disableNextButton = true;
  hideBackButton = true;
  isLoading = false;
  disableSaveButton = true;
  showPurposeDetailScreen = false;
  showOtherReason = false;
  calloutResponse;
  addFundRecordsWithValidAmountModel;
  helpTextForCategory = new Map([
    ["Renovation", RENOVATIONS_HELP_TEXT],
    ["Personal", LIFESTYLE_HELP_TEXT],
    ["Vehicle purchase", MOTOR_HELP_TEXT]
  ]);

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    Promise.all([loadStyle(this, styling)]); //Global stylesheet added for radio button styling and Add Additional Funds button styling
    this.getCategoryToPurposeData();
  }

  /*Call apex method to get category to purpose mapping*/
  async getCategoryToPurposeData() {
    this.isLoading = true;
    try {
      this.purposeValueMappingModel = await getCategoryToPurposeMapping();
      if ((this.purposeValueMappingModel?.length ?? 0) === 0) {
        handleErrorShowToast(this, "", "", TOAST_ERROR_MSG, "pester");
        return;
      }
      const typeInvestorOrOwnerOccupied =
        this.loanPreferenceData?.propertyUse === "LOAN_PRODUCT_TYPE_INVESTOR"
          ? "LENDING_PURPOSE_ALTERATIONS_DWELLING_EXISTING"
          : "LENDING_PURPOSE_ALTERATIONS_DWELLING_EXISTING_INVESTOR";
      this.purposeValueMappingModel = this.purposeValueMappingModel.map(
        (category) => ({
          ...category,
          purpose: category.purpose.filter(
            (purposeItem) => purposeItem.value !== typeInvestorOrOwnerOccupied
          )
        })
      );
      if (this.isEditScreenCalled) {
        this.handleEditScreen();
      }
      this.categoryOptions = this.purposeValueMappingModel.map((item) => ({
        label: item.category,
        value: item.category,
        disabled: this.isCategoryDisabled(item.category),
        isChecked: false
      }));
      this.isLoading = this.categoryOptions.length <= 0;
    } catch (error) {
      this.errorMessage = error;
      handleErrorShowToast(this, "", error, TOAST_ERROR_MSG, "pester");
    } finally {
      this.isLoading = false;
    }
  }

  /*To check if given category and all related purposes already selected.*/
  isCategoryDisabled(categoryToVerify) {
    const requiredPurposeValues =
      this.getRequiredPurposeValues(categoryToVerify);

    /*To disable Debt consolidation & Property purchase option*/
    if (requiredPurposeValues[0]?.value == null) {
      return true;
    }
    const availablePurposeValues =
      this.getAvailablePurposeValues(categoryToVerify);
    if (!availablePurposeValues) {
      return false;
    }
    const requiredValues = requiredPurposeValues.map(
      (purpose) => purpose.value
    );
    return requiredValues.every((value) =>
      availablePurposeValues.includes(value)
    );
  }

  /*To get available purpose for selected category*/
  getPurposeOptions() {
    const purposeValueMappingList = this.getRequiredPurposeValues(
      this.selectedCategory
    );
    const availablePurposeList =
      this.getAvailablePurposeValues(this.selectedCategory) || [];

    return purposeValueMappingList.map((purpose) => {
      const isDisabled = availablePurposeList.includes(purpose.value);
      return {
        ...purpose,
        disabled: isDisabled
      };
    });
  }

  /*To get available purpose for selected category from apex metadata*/
  getRequiredPurposeValues(categoryToVerify) {
    const category = this.purposeValueMappingModel.find(
      (fund) => fund.category === categoryToVerify
    );
    return category?.purpose || [];
  }

  /*To get available purpose for selected category from already selected additional funds*/
  getAvailablePurposeValues(categoryToVerify) {
    if ((this.fundRecords?.length ?? 0) === 0) {
      return null;
    }
    const fundRecord = this.fundRecords.find(
      (fund) => fund.name === categoryToVerify
    );
    return fundRecord ? fundRecord.value.map((fund) => fund.purpose) : null;
  }

  get showSelectTextLogoAndButton() {
    return this.showCategoryScreen || this.showPurposeScreen;
  }

  get addFundDisabled() {
    return this.addFundsOptions?.length === 0;
  }

  /*Capture selected category and enable Next button*/
  handleCategoryChange(event) {
    this.selectedCategory = event.target.value;
    this.categoryOptions = this.categoryOptions.map((category) => {
      return {
        ...category,
        isChecked: category.label === this.selectedCategory
      };
    });
    this.purposeOptions = this.getPurposeOptions();
    this.helpTextValue = this.helpTextForCategory.get(this.selectedCategory);
    if ((this.purposeOptions?.length ?? 0) === 0) {
      return;
    }
    this.disableNextButton = false;
  }

  /*Display second screen to display purpose*/
  handleNext() {
    if (this.showCategoryScreen) {
      this.showCategoryScreen = false;
      this.showPurposeScreen = true;
      this.showPurposeDetailScreen = false;
      this.hideBackButton = false;
      this.selectedPurpose = [];
      this.updatedFundsWithAmountAndOtherReason = [];
      this.purposeOptions = this.purposeOptions.map((purpose) => {
        return { ...purpose, isChecked: false };
      });
      this.disableNextButton = this.selectedPurpose.length === 0;
      this.disableNextButton = true;
      this.disableSaveButton = true;
      return;
    }
    if (this.showPurposeScreen) {
      this.showCategoryScreen = false;
      this.showPurposeScreen = false;
      this.showPurposeDetailScreen = true;
      this.disableSaveButton = true;
      this.disableNextButton = !this.selectedPurpose.length > 0;
      this.getAddAdditionalFundsOptions();
    }
  }

  //Close modal on the click of cancel button
  handleClose() {
    this.close("okay");
  }

  /*Display first screen to display category*/
  handleBack() {
    if (this.showPurposeScreen) {
      this.showPurposeScreen = false;
      this.showCategoryScreen = true;
      this.hideBackButton = true;
      this.selectedPurpose = [];
      this.fundWithAmountGreaterZero = [];
      this.updatedFundsWithAmountAndOtherReason = [];
      this.disableNextButton = !this.categoryOptions.some(
        (option) => option.isChecked === true
      );
      this.disableSaveButton = true;
    }
    if (this.showPurposeDetailScreen) {
      this.showPurposeDetailScreen = false;
      this.showPurposeScreen = true;
      this.showCategoryScreen = false;
      this.hideBackButton = false;
      this.fundWithAmountGreaterZero = [];
      this.updatedFundsWithAmountAndOtherReason = [];
      this.disableSaveButton = true;
    }
  }

  //Get the list of purpose to display when Add Additional Funds is clicked
  getAddAdditionalFundsOptions() {
    const validLabel = new Set(this.selectedPurpose);
    this.selectedAddFunds = this.purposeOptions.filter((item) =>
      validLabel.has(item.value)
    );
    this.updatedFundsWithAmountAndOtherReason = this.selectedAddFunds.map(
      (fund) => {
        let updateFund = this.updatedFundsWithAmountAndOtherReason.filter(
          (fundResult) => fundResult.value === fund.value
        );
        return {
          ...fund,
          amount:
            updateFund?.length > 0 && "amount" in updateFund[0]
              ? updateFund[0].amount
              : 0.0,
          otherReason:
            updateFund?.length > 0 && "otherReason" in updateFund[0]
              ? updateFund[0].otherReason
              : "",
          showOtherReason: fund.label === "Other"
        };
      }
    );
    if (this.isEditScreenCalled) {
      this.addFundsOptions = this.purposeOptions.filter(
        (item) => !validLabel.has(item.value)
      );
    } else {
      this.addFundsOptions = this.purposeOptions.filter(
        (item) => !validLabel.has(item.value) && !item.disabled
      );
    }
    this.showOtherReason = this.selectedAddFunds.some(
      (fund) => fund.label === "Other"
    );
  }

  /*Handle checkbox selection for purpose options*/
  handlePurposeChange(event) {
    const checkedValue = event.target.value;
    if (event.target.checked) {
      this.selectedPurpose = [...this.selectedPurpose, checkedValue];
    } else {
      this.selectedPurpose = this.selectedPurpose.filter(
        (val) => val !== checkedValue
      );
    }

    this.purposeOptions = this.purposeOptions.map((purposeRecords) => {
      const selectedData = this.selectedPurpose.filter(
        (selectedResult) => selectedResult === purposeRecords.value
      );
      return {
        ...purposeRecords,
        isChecked: selectedData?.length > 0
      };
    });
    this.disableNextButton = this.selectedPurpose.length <= 0;
  }

  //Handle the Selected purpose to be added in the Modal
  handleAddAdditionalFunds(event) {
    const selectedValue = event.detail.value;
    if (selectedValue) {
      this.selectedPurpose = [...this.selectedPurpose, selectedValue];
    }
    this.disableSaveButton = true;
    this.getAddAdditionalFundsOptions();
    this.handlePurposeChange(event);
  }

  //Delete Purpose from the selected List of purposes
  handleDelete(event) {
    const itemId = event.target.dataset.id;
    if (itemId) {
      this.selectedPurpose = this.selectedPurpose.filter(
        (item) => item !== itemId
      );
    }
    this.updatedFundsWithAmountAndOtherReason =
      this.updatedFundsWithAmountAndOtherReason.filter(
        (fund) => fund.value !== itemId
      );

    if (this.isEditScreenCalled) {
      this.fundRecordsForEdit = this.fundRecordsForEdit.map((category) => {
        return {
          ...category,
          value: category.value.filter((item) => item.purpose !== itemId)
        };
      });
      if (this.updatedFundsWithAmountAndOtherReason.length === 0) {
        loanPreferenceDeleteCashOutPurpose
          .open({
            size: "small",
            purposeName: this.editPurposeName,
            fundRecords: this.fundRecordsForEdit,
            loanPreferenceData: this.loanPreferenceData
          })
          .then((result) => {
            if (result === undefined || result === "okay") {
              this.handleClose();
            }
          });
      }
    }
    this.disableSaveButton =
      this.updatedFundsWithAmountAndOtherReason.some(
        (fund) => fund.amount <= 0.0
      ) || this.updatedFundsWithAmountAndOtherReason.length <= 0;
    this.getAddAdditionalFundsOptions();
    this.handlePurposeChange(event);
  }

  //Handle change in the value of the amount for different purposes and enable Save button accordingly
  handleAmountChange(event) {
    let amountVal = event.target.value;
    let purposeDetails = event.target.dataset.id;
    const indexWithSelectedPurpose =
      this.updatedFundsWithAmountAndOtherReason.findIndex(
        (fund) => fund.value === purposeDetails
      );
    if (indexWithSelectedPurpose !== -1) {
      this.updatedFundsWithAmountAndOtherReason[
        indexWithSelectedPurpose
      ].amount = amountVal === "" ? 0.0 : amountVal;
      this.updatedFundsWithAmountAndOtherReason = [
        ...this.updatedFundsWithAmountAndOtherReason
      ];
    }
    this.disableSaveButton = this.updatedFundsWithAmountAndOtherReason.some(
      (fund) => fund.amount <= 0.0
    );
  }

  handleAmountSelect(event) {
    let amountVal = event.target.value;
    let purposeDetails = event.target.dataset.id;
    if (amountVal <= 0.0) {
      let amtVal = this.template.querySelector(
        `lightning-input[data-id=${purposeDetails}]`
      );
      amtVal.value = null;
    }
  }

  handleAmountDefaultValue(event) {
    let amountVal = event.target.value;
    let purposeDetails = event.target.dataset.id;
    if (amountVal <= 0.0 || !amountVal) {
      let amtVal = this.template.querySelector(
        `lightning-input[data-id=${purposeDetails}]`
      );
      amtVal.value = 0.0;
    }
  }
  //Handle Other Reason details
  handleOtherReason(event) {
    let otherReasonDetail = event.target.value;
    const purposeDetail = event.target.dataset.id;
    let selectedFundWithPurpose =
      this.updatedFundsWithAmountAndOtherReason.find(
        (fund) => fund.value === purposeDetail
      );
    if (selectedFundWithPurpose) {
      selectedFundWithPurpose.otherReason = otherReasonDetail;
    }
    this.validateReason(purposeDetail);
  }

  //Method called on edit button callout from loan preference tab
  handleEditScreen() {
    //toggle identifiers to display edit screen
    this.showCategoryScreen = false;
    this.showPurposeScreen = false;
    this.disableSaveButton = false;
    this.fundRecordsForEdit = [...this.fundRecords];
    //filtering the purpose value for which edit is called
    let fundRecordsList = this.fundRecords?.filter(
      (fund) => fund.name === this.editPurposeName
    );

    //assigning the filtered list to existing property to display data
    fundRecordsList.forEach((category) => {
      category.value.forEach((item) => {
        this.updatedFundsWithAmountAndOtherReason.push({
          label: item.purposeLabel,
          value: item.purpose,
          amount: item.amount,
          otherReason: item.otherReason || "",
          showOtherReason: item.otherReason ? true : false
        });
        this.selectedPurpose = [...this.selectedPurpose, item.purpose];
      });
    });
    this.selectedCategory = this.editPurposeName;
    this.helpTextValue = this.helpTextForCategory.get(this.selectedCategory);
    this.purposeOptions = this.getPurposeOptions();
    this.addFundsOptions = this.purposeOptions.filter(
      (item) => !this.selectedPurpose.includes(item.value)
    );
    this.getAddAdditionalFundsOptions();
  }

  handleSave() {
    let mergedListOfFunds;
    const index = this.updatedFundsWithAmountAndOtherReason.find(
      (fund) => fund.label === "Other"
    );
    if (index) {
      this.validateReason(index.value);
      if (this.isInvalid) {
        return;
      }
    }
    if (this.isEditScreenCalled) {
      this.removeDuplicateRecords();
      mergedListOfFunds = this.getMergedListOfFunds(this.fundRecordsForEdit);
    } else {
      mergedListOfFunds = this.getMergedListOfFunds(this.fundRecords);
    }
    this.transformToAddFundsModel(mergedListOfFunds);
    this.makeUpdateLoanCallout();
  }

  //Merge already existing additional funds with the current fund list
  getMergedListOfFunds(fundList) {
    if ((fundList?.length ?? 0) === 0) {
      return this.updatedFundsWithAmountAndOtherReason;
    }
    return [...this.updatedFundsWithAmountAndOtherReason, ...fundList];
  }

  //Method to remove duplicates from fundRecords
  removeDuplicateRecords() {
    // Remove duplicate records based on Purpose values
    // Update the fundRecordsForEdit with filtered values
    this.fundRecordsForEdit = this.fundRecordsForEdit.map((category) => {
      // Use spread syntax to keep the rest of the category properties intact
      return {
        ...category, // Keep other properties of category
        value: category.value.filter((record) => {
          // Check if the current record's Purpose is not in the updatedFundsWithAmountAndOtherReason list
          return !this.updatedFundsWithAmountAndOtherReason.some(
            (removedRecord) => removedRecord.value === record.purpose
          );
        })
      };
    });
  }

  /*Transform mergedListOfFunds to additional Funds View Model*/
  transformToAddFundsModel(fundsList) {
    this.additionalFundsModel = {
      additionalFunds: []
    };
    fundsList.forEach((fundItem) => {
      if (Array.isArray(fundItem.value)) {
        const transformedSubItems = fundItem.value.map((fundSubItem) => ({
          amount: fundSubItem.amount,
          purpose: fundSubItem.purpose,
          otherReason: fundSubItem.otherReason ? fundSubItem.otherReason : ""
        }));
        this.additionalFundsModel.additionalFunds.push(...transformedSubItems);
      } else {
        this.additionalFundsModel.additionalFunds.push({
          amount: Number(fundItem.amount),
          purpose: fundItem.value,
          otherReason: fundItem.otherReason ? fundItem.otherReason : ""
        });
      }
    });
    return this.additionalFundsModel;
  }

  //handles callout
  async makeUpdateLoanCallout() {
    this.isLoading = true;
    try {
      this.calloutResponse = await updateLoanPreference({
        updateLoanPreferenceData: this.loanPreferenceData,
        additionalFundsData: this.additionalFundsModel
      });
      if (this.calloutResponse) {
        showToast(this, "", TOAST_SUCCESS_MSG, "", "Success", "dismissable");
        publish(this.messageContext, RefreshLoanPreference, {
          refresh: true
        });
        this.close("okay");
      }
    } catch (error) {
      this.errorMessage = error;
      let errorMessage = TOAST_ERROR_MSG;
      if (error?.body?.message !== "Failed to update loan preference") {
        errorMessage = error.body.message;
      }

      handleErrorShowToast(this, "", null, errorMessage, "pester");
    } finally {
      this.isLoading = false;
    }
  }

  //check field validity, if the amount for purpose "Other" is greater than 0 and otherReason is empty, the validation will trigger
  validateReason(purpose) {
    const purposeRecord = this.updatedFundsWithAmountAndOtherReason.find(
      (purposeValue) => purposeValue.value === purpose
    );
    let otherReason = purposeRecord?.otherReason;
    let otherReasonField = this.template.querySelectorAll(".otherReason");
    otherReasonField = Array.from(otherReasonField);
    if (!otherReason) {
      otherReasonField[0].setCustomValidity("Please provide reason details");
      this.isInvalid = true;
    } else {
      otherReasonField[0].setCustomValidity("");
      this.isInvalid = false;
    }

    otherReasonField[0].reportValidity();
  }
}
