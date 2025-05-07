import { LightningElement, api } from "lwc";
import getAdditionFundsForLoanPreference from "@salesforce/apex/AdditionalFundsController.getAdditionFundsForLoanPreference";
import SOP_IMAGE from "@salesforce/resourceUrl/SOP_Images";
import loanPreferenceDeleteCashOutPurpose from "c/loanPreferenceDeleteCashOutPurpose";
import loanPreferenceAddFundsAndPurpose from "c/loanPreferenceAddFundsAndPurpose";
import hasDeletePermission from "@salesforce/customPermission/Loan_Preference_Delete";
import hasEditPermission from "@salesforce/customPermission/Loan_Preference_Edit";
import hasAddPermission from "@salesforce/customPermission/Loan_Preference_Add";
import styling from "@salesforce/resourceUrl/UpdateLoanStyling";
import { loadStyle } from "lightning/platformResourceLoader";

const RENOVATIONS_HELP_TEXT = "To fix up or spruce up a home";
const MOTOR_HELP_TEXT =
  "Four wheels, two wheels or no wheels... looking at a new ride?";
const LIFESTYLE_HELP_TEXT =
  "Wedding expenses, medical bills or travel, if extra money is needed for life's costs";
export default class LoanPreferenceAdditionalFundsDetailsDisplay extends LightningElement {
  @api recordId;
  @api additionalFundsData;
  @api loanPreferenceModel;
  renovations = `${SOP_IMAGE}/additionalFunds/Renovations.png`;
  motor = `${SOP_IMAGE}/additionalFunds/Motor.png`;
  lifestyle = `${SOP_IMAGE}/additionalFunds/Lifestyle.png`;
  checkIfAddFundExist = false;
  error;
  additionFundDetails = [];
  categoryWithAssociatedPurposeMap = [];
  additionFunds = [];
  purposeSubPurposeMap = new Map();
  showOther = false;
  isLoading = false;
  imageForCategory = new Map([
    ["Renovation", this.renovations],
    ["Personal", this.lifestyle],
    ["Vehicle purchase", this.motor]
  ]);

  helpTextForCategory = new Map([
    ["Renovation", RENOVATIONS_HELP_TEXT],
    ["Personal", LIFESTYLE_HELP_TEXT],
    ["Vehicle purchase", MOTOR_HELP_TEXT]
  ]);

  get showDeleteButton() {
    return hasDeletePermission;
  }

  get showAddButton() {
    return hasAddPermission;
  }

  get showEditButton() {
    return hasEditPermission;
  }

  connectedCallback() {
    Promise.all([loadStyle(this, styling)]);
    this.getPurposeMappingAndQueryData();
  }

  //Below method will check if the addition Funds data is received from the parent component , otherwise will make and ApexCallout for the funds data.c/accountBalances
  //Below method will also fetch the Category To Purpsoe Mapping data
  getPurposeMappingAndQueryData() {
    this.isLoading = true;
    const preferenceResult =
      (this.additionalFundsData?.additionalFunds?.length ?? 0) === 0
        ? getAdditionFundsForLoanPreference({ recordId: this.recordId })
        : this.additionalFundsData;
    Promise.all([preferenceResult])
      .then(([addFundsData]) => {
        this.additionFunds = addFundsData;
        if ((this.additionFunds?.additionalFunds?.length ?? 0) === 0) {
          return;
        }
        this.checkIfAddFundExist = true;
        this.categoryWithAssociatedPurposeMap =
          this.categoryWithAssociatedPurposeMapping(
            this.additionFunds.additionalFunds
          );
      })
      .catch((error) => {
        this.error = error;
        this.additionFunds = [];
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  //convert the data to Map with Category as key and Pupose details as value and return the array
  categoryWithAssociatedPurposeMapping(additionFundRecords) {
    if ((additionFundRecords?.length ?? 0) === 0) {
      return null;
    }
    additionFundRecords.forEach((fundRecord) => {
      const key = fundRecord.category || "Purpose Value";
      if (!this.purposeSubPurposeMap.has(key)) {
        this.purposeSubPurposeMap.set(key, []);
      }

      this.purposeSubPurposeMap.get(key).push(fundRecord);
    });

    return [...this.purposeSubPurposeMap].map(([name, value]) => ({
      name,
      value,
      imgSrc: this.imageForCategory.get(name),
      helpText: this.helpTextForCategory.get(name)
    }));
  }

  handleAddNewAction() {
    loanPreferenceAddFundsAndPurpose.open({
      size: "small",
      loanPreferenceData: this.loanPreferenceModel,
      fundRecords: this.categoryWithAssociatedPurposeMap
    });
  }

  handleEditAction(event) {
    loanPreferenceAddFundsAndPurpose.open({
      size: "small",
      fundRecords: this.categoryWithAssociatedPurposeMap,
      isEditScreenCalled: true,
      editPurposeName: event.target.dataset.name,
      loanPreferenceData: this.loanPreferenceModel
    });
  }

  //Method to delete seleted purpose entry
  handleDeleteAction(event) {
    loanPreferenceDeleteCashOutPurpose.open({
      size: "small",
      purposeName: event.target.dataset.name,
      fundRecords: this.categoryWithAssociatedPurposeMap,
      loanPreferenceData: this.loanPreferenceModel
    });
  }
}
