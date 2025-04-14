import { api, wire, track } from "lwc";
import LightningModal from "lightning/modal";
import {
  TYPE_MAP,
  handleFieldVisibility,
  handleAddDefaults,
  handleEditPayload
} from "./helper";
import DOLLAR_ICON from "@salesforce/resourceUrl/Dollar_sign_income";
import DOCUMENT_ICON from "@salesforce/resourceUrl/SOP_document_BW";
import addEditDebt from "@salesforce/apex/SOPController.addEditDebt";
import { handleErrorShowToast, showToast } from "c/utils";
import { publish, MessageContext } from "lightning/messageService";
import RefreshSOP from "@salesforce/messageChannel/RefreshSOP__c";
import ANZ_IMG from "@salesforce/resourceUrl/SOP_ANZ_Lotus_Circle";

export default class SopAddEditDebts extends LightningModal {
  @api recordId;
  @api debtType;
  @api actionType; //Determine if its add or edit
  @api parties;
  @api debtData;
  closedDebtImage = DOLLAR_ICON;
  evidenceProvidedImage = DOCUMENT_ICON;
  readableType;
  debtImage;
  loading;
  activeSections = [
    "Debt Details",
    "Debt Amounts",
    "Close Debt",
    "Debt Evidenced"
  ];
  yesNoOptions = [
    {
      label: "--Please Select--",
      value: "",
      disabled: true
    },
    { label: "Yes", value: "true" },
    { label: "No", value: "false" }
  ];

  repaymentFrequencyOptions = [
    {
      label: "--Please Select--",
      value: "",
      disabled: true
    },
    { label: "Weekly", value: "FREQUENCY_WEEKLY" },
    { label: "Fortnightly", value: "FREQUENCY_FORTNIGHTLY" },
    { label: "Monthly", value: "FREQUENCY_MONTHLY" }
  ];

  payload = {
    liability: {
      sources: [],
      institutionalLiability: {},
      account: {},
      studentLoan: {},
      paidOffAndClosed: null
    },
    evidenceProvided: null,
    name: null,
    uid: null,
    etag: null
  };

  //set default limit for edge case
  limitLabel = "Limit";
  umiLimitLabel = "Use updated Limit for UMI";
  creditBureauLimitLabel = "Credit Bureau Credit Limit";
  belongsToValue = "";
  arrangementType = "";
  belongsToOptions = [];
  //Set default source to Manual for Add
  debtSource = "Manual";
  _customerStatedClosed = null;
  _withheldFromPay = null;
  _paidInFull = null;
  _years = null;
  _months = null;
  showConnectedDataMessage = false;
  _limit = null;

  get institutionValue() {
    return this.debtData?.institutionalLiability?.financialInstitution;
  }

  get limit() {
    if (this._limit !== null) {
      return this._limit;
    }
    return -this.debtData?.institutionalLiability?.limitAmount;
  }

  set limit(value) {
    this._limit = value;
  }

  get balanceOwing() {
    return this.debtData?.outstandingBalance;
  }

  get paidInFull() {
    //Check this first as this is the value that is set by the user
    if (this._paidInFull !== null) {
      return this._paidInFull;
    }
    //Check if the debt data has a value
    if (
      this.debtData?.institutionalLiability &&
      this.debtData.institutionalLiability.paidInFull !== null &&
      this.debtData.institutionalLiability.paidInFull !== undefined
    ) {
      //Convert to string as combobox doesnt properly support boolean values
      return this.debtData.institutionalLiability.paidInFull.toString();
    }
    return "";
  }

  set paidInFull(value) {
    this._paidInFull = value;
  }

  get monthlyRepayment() {
    return this.debtData?.institutionalLiability?.repaymentAmount;
  }

  get paidOffAndClosed() {
    return this.debtData?.paidOffAndClosed;
  }

  get repaymentFrequency() {
    return this.debtData?.institutionalLiability?.repaymentFrequency;
  }

  get repaymentAmount() {
    return this.debtData?.institutionalLiability?.repaymentAmount;
  }

  get withheldFromPay() {
    //Check this first as this is the value that is set by the user
    if (this._withheldFromPay !== null) {
      return this._withheldFromPay;
    }
    //Check if the debt data has a value
    if (
      this.debtData?.studentLoan &&
      this.debtData.studentLoan.hecsWithheldPayment !== null
    ) {
      //Convert to string as combobox doesnt properly support boolean values
      return this.debtData.studentLoan.hecsWithheldPayment.toString();
    }
    return "";
  }

  set withheldFromPay(value) {
    this._withheldFromPay = value;
  }

  get bsb() {
    return this.debtData?.bsb;
  }

  get accountNumber() {
    return this.debtData?.accountNumber;
  }

  get accountStatusMessage() {
    return `Account status is ${this.debtData?.readableStatus}`;
  }

  get accountStatus() {
    return this.debtData?.readableStatus;
  }

  get availableRedraw() {
    return this.debtData?.institutionalLiability?.redrawAmount;
  }

  get customerStatedClosed() {
    //Check this first as this is the value that is set by the user
    if (this._customerStatedClosed !== null) {
      return this._customerStatedClosed;
    }
    //Check if the debt data has a value
    if (this.debtData?.customerStatedClosed !== null) {
      //Convert to string as combobox doesnt properly support boolean values
      return this.debtData.customerStatedClosed.toString();
    }
    return "";
  }

  set customerStatedClosed(value) {
    this._customerStatedClosed = value;
  }

  get creditBureauBalanceOwing() {
    return -this.debtData?.verifiedOutstandingBalance;
  }

  get creditBureauRemainingTerm() {
    return this.debtData?.institutionalLiability
      ?.readableVerifiedPrincipalInterestRemainingTerm;
  }

  get years() {
    if (this._years !== null) {
      return this._years;
    }
    return this.debtData?.institutionalLiability?.principalInterestRemainingTerm
      ? Math.floor(
          this.debtData.institutionalLiability.principalInterestRemainingTerm /
            12
        )
      : null;
  }

  set years(value) {
    this._years = value;
  }

  get months() {
    if (this._months !== null) {
      return this._months;
    }

    return this.debtData?.institutionalLiability?.principalInterestRemainingTerm
      ? this.debtData.institutionalLiability.principalInterestRemainingTerm % 12
      : null;
  }

  set months(value) {
    this._months = value;
  }

  get otherLoanDetailsLabel() {
    if (
      this.actionType === "Add" ||
      (this.actionType === "Edit" &&
        this.debtData?.type === "LIABILITY_TYPE_OTHER_LOAN")
    ) {
      return "Other Loan Details";
    }

    return `Other ${this.debtData.readableType} Details`;
  }

  get loanType() {
    return this.debtData?.termType;
  }

  get evidenceProvided() {
    return this.debtData?.evidenceProvided;
  }

  get remainingTermCheckbox() {
    return this.debtData?.institutionalLiability
      ?.validatedPrincipalInterestRemainingTerm;
  }

  get balanceOwingCheckbox() {
    return this.debtData?.validatedOutstandingBalance
      ? this.debtData.validatedOutstandingBalance
      : null;
  }

  get validatedLimit() {
    return this.debtData?.institutionalLiability?.validatedLimit;
  }

  @track fieldVisibility;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    if (this.actionType === "Edit") {
      if (this.debtData.sourceType !== "LIABILITY_SOURCE_TYPE_MANUAL") {
        this.showConnectedDataMessage = true;
      }
      this.debtSource = this.debtData.readableSourceType;
      this.payload = handleEditPayload(this.debtData);
    } else {
      this.payload = handleAddDefaults();
    }
    this.payload.liability.type = this.debtType;
    if (this.actionType === "Add") {
      this.payload.liability.institutionalLiability.debtType = this.debtType;
    }
    if (this.parties && this.parties.length > 0) {
      this.handleBelongsToOptions(this.parties);
    }
    this.readableType = TYPE_MAP[this.debtType].title;
    this.debtImage = TYPE_MAP[this.debtType].image;
    if (this.actionType === "Edit") {
      if (this.debtData.sourceType === "LIABILITY_SOURCE_TYPE_ANZ") {
        this.debtImage = ANZ_IMG;
      }
    }
    this.fieldVisibility = handleFieldVisibility(
      this.debtType,
      this.debtData,
      this.actionType
    );

    this.arrangementType =
      this.debtType === "LIABILITY_TYPE_BPL_FACILITY"
        ? "Spend Limit"
        : this.debtType === "LIABILITY_TYPE_BPL_LOAN"
          ? "Fixed Amount"
          : "";

    switch (this.debtType) {
      case "LIABILITY_TYPE_BPL_FACILITY":
        this.limitLabel = "Spend Limit";
        this.umiLimitLabel = "Use updated Spend Limit for UMI";
        this.creditBureauLimitLabel = "Credit Bureau Spend Limit";
        break;
      case "LIABILITY_TYPE_CREDIT_CARD":
      case "LIABILITY_TYPE_MARGIN_LOAN":
      case "LIABILITY_TYPE_LINE_OF_CREDIT":
        this.limitLabel = "Credit Limit";
        this.umiLimitLabel = "Use updated Credit Limit for UMI";
        this.creditBureauLimitLabel = "Credit Bureau Credit Limit";
        break;
      case "LIABILITY_TYPE_OVERDRAFT":
        this.limitLabel = "Overdraft Limit";
        this.umiLimitLabel = "Use updated Overdraft Limit for UMI";
        this.creditBureauLimitLabel = "Credit Bureau Overdraft Limit";
        break;
      default:
        break;
    }
  }

  disconnectedCallback() {
    //Reset payload
    this.payload = handleAddDefaults();
  }

  handleBelongsToChange(event) {
    if (event.detail.value) {
      this.belongsToValue = this.belongsToOptions[event.detail.value].value;

      let partyDetails = this.parties[event.detail.value];
      this.payload.liability.ownership = [
        {
          partyId: partyDetails.partyId1,
          proportion: { value: partyDetails.proportion }
        }
      ];
      if (partyDetails.partyId2) {
        this.payload.liability.ownership.push({
          partyId: partyDetails.partyId2,
          proportion: { value: partyDetails.proportion }
        });
      }
    } else {
      this.belongsToValue = "";
    }
  }

  handleInstitutionChange(event) {
    this.payload.liability.institutionalLiability.financialInstitution =
      event.detail.value;
    this.payload.liability.account.financialInstitution = event.detail.value;
  }

  handleLimitChange(event) {
    this._limit = event.detail.value;
    this.payload.liability.institutionalLiability.limitValue = Math.abs(
      event.detail.value
    );
  }

  handleBalanceOwingChange(event) {
    this.payload.liability.outstandingBalanceValue = Math.abs(
      event.detail.value
    );
  }

  handlePaidInFullChange(event) {
    this.payload.liability.institutionalLiability.paidInFull =
      event.detail.value === "true" ? true : false;

    if (event.detail.value === "false") {
      this.fieldVisibility.showMonthlyRepayment = true;
    } else if (event.detail.value === "true" || event.detail.value === "") {
      this.fieldVisibility.showMonthlyRepayment = false;
    }
  }

  handleRepaymentAmountChange(event) {
    this.payload.liability.institutionalLiability.repaymentAmountValue =
      Math.abs(event.detail.value);
  }

  handleMonthlyRepayment(event) {
    //Set repayment amount on monthly repayment as backend accepts same field, front end different label
    this.payload.liability.institutionalLiability.repaymentAmountValue =
      Math.abs(event.detail.value);
  }

  handleYears(event) {
    this._years = event.detail.value;
  }

  handleMonths(event) {
    this._months = event.detail.value;
  }

  handlePaidOffAndClosed(event) {
    this.payload.liability.paidOffAndClosed = event.detail.checked;
  }

  handleRepaymentFrequencyChange(event) {
    this.payload.liability.institutionalLiability.repaymentFrequency =
      event.detail.value;
  }

  handleWithheldFromPayChange(event) {
    this.payload.liability.studentLoan.hecsWithheldPayment =
      event.detail.value === "true" ? true : false;
  }

  handleCustomerExcludedDebt(event) {
    this.customerStatedClosed = event.detail.value;

    //Need to convert string back to boolean
    this.payload.liability.customerStatedClosed =
      event.detail.value === "true" ? true : false;
    //handle visibility based on value of excluded debt
    if (
      (this.debtType === "LIABILITY_TYPE_BPL_FACILITY" ||
        this.debtType === "LIABILITY_TYPE_CREDIT_CARD") &&
      event.detail.value === "false"
    ) {
      this.fieldVisibility.showLimit = true;
      if (this.debtType === "LIABILITY_TYPE_BPL_FACILITY") {
        this.fieldVisibility.showBalanceOwingOtherDetails = true;
      } else {
        this.fieldVisibility.showBalanceOwing = true;
      }
      this.fieldVisibility.showPaidInFull = true;
      this.fieldVisibility.showMonthlyRepayment =
        this.payload.liability.institutionalLiability.paidInFull === false
          ? true
          : false;
      this.fieldVisibility.showUMICheckbox = true;
    } else if (
      (this.debtType === "LIABILITY_TYPE_BPL_FACILITY" ||
        this.debtType === "LIABILITY_TYPE_CREDIT_CARD") &&
      event.detail.value === "true"
    ) {
      this.fieldVisibility.showLimit = false;
      this.fieldVisibility.showBalanceOwing = false;
      this.fieldVisibility.showBalanceOwingOtherDetails = false;
      this.fieldVisibility.showPaidInFull = false;
      this.fieldVisibility.showMonthlyRepayment = false;
      this.fieldVisibility.showUMICheckbox = false;
    }

    let debtTypes = [
      "LIABILITY_TYPE_OTHER_LOAN",
      "LIABILITY_TYPE_LEASE_HIRE_PURCHASE",
      "LIABILITY_TYPE_VEHICLE_LOAN",
      "LIABILITY_TYPE_BPL_LOAN",
      "LIABILITY_TYPE_PERSONAL_LOAN"
    ];

    if (debtTypes.includes(this.debtType) && event.detail.value === "false") {
      this.fieldVisibility.showBalanceOwing = true;
      this.fieldVisibility.showRemainingTermTitle = true;
      this.fieldVisibility.showYears = true;
      this.fieldVisibility.showMonths = true;
      this.fieldVisibility.showRepaymentAmount = true;
      this.fieldVisibility.showRepaymentFrequency = true;
      this.fieldVisibility.showRemainingTermCheckbox = true;
      this.fieldVisibility.showBalanceOwingCheckbox = true;
    } else if (
      debtTypes.includes(this.debtType) &&
      event.detail.value === "true"
    ) {
      this.fieldVisibility.showBalanceOwing = false;
      this.fieldVisibility.showRemainingTermTitle = false;
      this.fieldVisibility.showYears = false;
      this.fieldVisibility.showMonths = false;
      this.fieldVisibility.showRepaymentAmount = false;
      this.fieldVisibility.showRepaymentFrequency = false;
      this.fieldVisibility.showRemainingTermCheckbox = false;
      this.fieldVisibility.showBalanceOwingCheckbox = false;
    }

    if (
      this.debtType === "LIABILITY_TYPE_OVERDRAFT" &&
      event.detail.value === "false"
    ) {
      this.fieldVisibility.showBalanceOwing = true;
      this.fieldVisibility.showLimit = true;
      this.fieldVisibility.showUMICheckbox = true;
    } else if (
      this.debtType === "LIABILITY_TYPE_OVERDRAFT" &&
      event.detail.value === "true"
    ) {
      this.fieldVisibility.showBalanceOwing = false;
      this.fieldVisibility.showLimit = false;
      this.fieldVisibility.showUMICheckbox = false;
    }
  }

  handleUMICheckbox(event) {
    this.payload.liability.institutionalLiability.validatedLimit =
      event.detail.checked;
  }

  handleMinimumMonthlyRepaymentChange(event) {
    this.payload.liability.institutionalLiability.repaymentAmountValue =
      Math.abs(event.detail.value);
  }

  handleEvidenceReceived(event) {
    this.payload.liability.evidenceProvided = event.detail.checked;
  }

  handleBalanceOwingCheckbox(event) {
    this.payload.liability.validatedOutstandingBalance = event.detail.checked;
  }

  handleAvailableRedrawChange(event) {
    this.payload.liability.institutionalLiability.redrawAmountValue = Math.abs(
      event.detail.value
    );
  }

  handleRemainingTermCheckbox(event) {
    this.payload.liability.institutionalLiability.validatedPrincipalInterestRemainingTerm =
      event.detail.checked;
  }

  handleBelongsToOptions(parties) {
    parties.forEach((party, key) => {
      //If disabled is true, then value is "Please Select", and assign no value for validation
      this.belongsToOptions[key] = {
        label: party.label,
        value: party.disabled ? "" : key,
        disabled: party.disabled
      };
    });
    if (this.actionType === "Edit") {
      //Set default for edit scenarios
      this.belongsToValue = this.belongsToOptions.find(
        (p) => p.label === this.debtData.ownerName
      ).value;
      let partyDetails = this.parties[this.belongsToValue];

      this.payload.liability.ownership = [
        {
          partyId: partyDetails.partyId1,
          proportion: { value: partyDetails.proportion }
        }
      ];
      if (partyDetails.partyId2) {
        this.payload.liability.ownership.push({
          partyId: partyDetails.partyId2,
          proportion: { value: partyDetails.proportion }
        });
      }
    }
  }

  @api
  async handleAddEditDebt() {
    if (!this.areFieldsValid()) {
      return false;
    }

    try {
      this.loading = true;
      if (this.actionType === "Add") {
        this.payload.liability.sources.push("LIABILITY_SOURCE_TYPE_MANUAL");
      }
      //BPL Facility and Credit Card needs to default to monthly payment
      if (
        (this.debtType === "LIABILITY_TYPE_BPL_FACILITY" ||
          this.debtType === "LIABILITY_TYPE_CREDIT_CARD") &&
        !this.payload.liability.institutionalLiability.paidInFull
      ) {
        this.payload.liability.institutionalLiability.repaymentFrequency =
          "FREQUENCY_MONTHLY";
      }

      if (
        this.payload?.liability?.institutionalLiability?.paidInFull &&
        ((this.actionType === "Edit" &&
          this.debtData.sourceType !== "LIABILITY_SOURCE_TYPE_ANZ") ||
          this.actionType === "Add")
      ) {
        this.payload.liability.institutionalLiability.repaymentAmountValue =
          null;
        this.payload.liability.institutionalLiability.repaymentFrequency = null;
      }

      //Need to manually set years value if theres no change made to it
      if (
        this._years === null &&
        this.debtData?.institutionalLiability?.principalInterestRemainingTerm
      ) {
        this.years = Math.floor(
          this.debtData.institutionalLiability.principalInterestRemainingTerm /
            12
        );
      }

      //Need to manually set month value if theres no change made to it
      if (
        this._months === null &&
        this.debtData?.institutionalLiability?.principalInterestRemainingTerm
      ) {
        this.months =
          this.debtData.institutionalLiability.principalInterestRemainingTerm %
          12;
      }

      if (this._years !== null && this._months !== null) {
        this.payload.liability.institutionalLiability.principalInterestRemainingTerm =
          Number(this._years) * 12 + Number(this._months);
      }

      let debtChange = await addEditDebt({
        loanId: this.recordId,
        debtDetails: this.payload,
        action: this.actionType
      });

      if (debtChange) {
        publish(this.messageContext, RefreshSOP, {
          refresh: true
        });
        let toastMsg =
          this.actionType === "Add"
            ? "The new debt was successfully added."
            : "The changes to this debt were successfully saved.";
        showToast(this, `${this.actionType} Debt`, toastMsg, "", "Success", "");
      }

      return debtChange;
    } catch (error) {
      let errorMessage =
        this.actionType === "Add"
          ? "The new debt couldn't be added. Please review and try again. Raise a fault through TechAssist if the problem persists"
          : "All the changes to this debt didn't save. Please review and try again. Raise a fault through TechAssist if the problem persists";
      handleErrorShowToast(
        this,
        `${this.actionType} Debt Failure`,
        error,
        errorMessage
      );
    } finally {
      this.loading = false;
    }

    return true;
  }

  areFieldsValid() {
    let allValid = [
      ...this.template.querySelectorAll("lightning-input, lightning-combobox")
    ].reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);

    return allValid;
  }
}
