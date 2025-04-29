import { api, wire, track } from "lwc";
import LightningModal from "lightning/modal";
import {
  TYPE_MAP,
  handleFieldVisibility,
  handleAddDefaults,
  handleEditPayload,
  handleExcludedDebtChangeVisibility
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
  @api refinancedAssets;
  @api propertyAssets;
  closedDebtImage = DOLLAR_ICON;
  evidenceProvidedImage = DOCUMENT_ICON;
  readableType;
  debtImage;
  loading;
  activeSections = [
    "Debt Details",
    "Debt Amounts",
    "Close Debt",
    "Debt Evidenced",
    "Linked Property"
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
  @track ownerDetails = [
    { owner: null, split: null, isNotFirst: false, key: Math.random() }
  ];
  @track propertyDetails = [
    { property: null, isNotFirst: false, partyId: null, key: Math.random() }
  ];
  propertyOptions = [];
  disableAddOwner = false;
  mustBeFullOwner = false;
  disableAddProperty = false;

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

  get interestRateValidated() {
    return this.debtData?.institutionalLiability?.interestRateValidated;
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

  get showAddOwnerButton() {
    return (
      this.actionType === "Add" ||
      this.debtData?.sourceType === "LIABILITY_SOURCE_TYPE_MANUAL"
    );
  }

  get interestRate() {
    if (this.debtData?.institutionalLiability?.originalInterestRateValue) {
      return (
        parseFloat(
          this.debtData.institutionalLiability.originalInterestRateValue
        ) / 100
      ).toFixed(2);
    }

    return null;
  }

  //Used to hide the delete owner icon (mostly during edit)
  get preventAllOwnerDelete() {
    return (
      this.actionType === "Edit" &&
      this.debtData?.sourceType !== "LIABILITY_SOURCE_TYPE_MANUAL"
    );
  }

  get taxDeductiblePercentage() {
    return (
      this.debtData?.institutionalLiability?.taxDeductiblePercentageOriginal ??
      0
    );
  }

  get undrawnAmount() {
    return this.debtData?.undrawnAmount;
  }

  get subsequentInterestRate() {
    return this.debtData?.institutionalLiability?.subsequentInterestRate;
  }

  get redrawLabel() {
    return this.debtData?.sourceType === "LIABILITY_SOURCE_TYPE_ANZ"
      ? "Redraw Amount"
      : "Available Redraw";
  }

  get productName() {
    return this.debtData?.productName;
  }

  get rateType() {
    return this.debtData?.rateType ? this.debtData.rateType : "Unspecified";
  }

  get repaymentType() {
    return this.debtData?.repaymentType
      ? this.debtData.repaymentType
      : "Unspecified";
  }
  @track fieldVisibility;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    if (this.actionType === "Edit") {
      if (this.debtData?.sourceType !== "LIABILITY_SOURCE_TYPE_MANUAL") {
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
    this.handlePropertyOptions(this.propertyAssets);
    if (this.parties && this.parties.length > 0) {
      this.handleBelongsToOptions(this.parties);
    }
    this.readableType = TYPE_MAP[this.debtType].title;
    this.debtImage = TYPE_MAP[this.debtType].image;
    if (
      this.actionType === "Edit" &&
      this.debtData?.sourceType === "LIABILITY_SOURCE_TYPE_ANZ"
    ) {
      this.debtImage = ANZ_IMG;
    }

    //Below debts can only have a single owner
    if (
      this.debtType === "LIABILITY_TYPE_STUDENT_LOAN" ||
      this.debtType === "LIABILITY_TYPE_BPL_FACILITY" ||
      this.debtType === "LIABILITY_TYPE_BPL_LOAN"
    ) {
      this.disableAddOwner = true;
      this.mustBeFullOwner = true;
    }

    this.fieldVisibility = handleFieldVisibility(
      this.debtType,
      this.debtData,
      this.actionType
    );

    //Options will equal 2 if there is a single option ("Please Select" is an option)
    //disable ownership split if its not joint
    if (
      this.belongsToOptions.length === 2 &&
      this.actionType === "Edit" &&
      (this.debtData?.sourceType === "LIABILITY_SOURCE_TYPE_ANZ" ||
        this.debtData?.sourceType === "LIABILITY_SOURCE_CREDIT_BUREAU")
    ) {
      this.fieldVisibility.disableOwnershipSplit = true;
    }

    let editableANZSource = [
      "LIABILITY_TYPE_LINE_OF_CREDIT",
      "LIABILITY_TYPE_HOME_LOAN"
    ];
    //Prevent change of ownership split for ANZ LOC and HL sources with a single owner
    //and for other debt types
    if (
      this.actionType === "Edit" &&
      this.debtData?.sourceType === "LIABILITY_SOURCE_TYPE_ANZ" &&
      ((this.ownerDetails.length === 1 &&
        editableANZSource.includes(this.debtType)) ||
        !editableANZSource.includes(this.debtType))
    ) {
      this.fieldVisibility.disableOwnershipSplit = true;
    }

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

  handleAddOwner() {
    this.ownerDetails.push({
      owner: null,
      split: null,
      isNotFirst: true,
      key: Math.random()
    });
    this.payload.liability.ownership.push({
      partyId: null,
      proportion: { value: null }
    });
    //Minus 1 on belongs to options to not cater for "Please Select" option
    if (this.ownerDetails.length === this.belongsToOptions.length - 1) {
      this.disableAddOwner = true;
    }
  }

  handleDeleteOwner(event) {
    let index = event.target.dataset.id;
    this.ownerDetails.splice(index, 1);
    this.payload.liability.ownership.splice(index, 1);
    //Minus 1 on belongs to options to not cater for "Please Select" option
    if (this.ownerDetails.length < this.belongsToOptions.length - 1) {
      this.disableAddOwner = false;
    }
    let splitFields = this.template.querySelectorAll(
      "lightning-input[data-name='ownershipSplit']"
    );
    //Check if ownership split total is valid after removing an owner
    splitFields.forEach((field) => {
      this.checkOwnershipSplitValidity(field);
    });
    this.checkDuplicateSelections("belongsTo", index, true);
  }

  handleBelongsToChange(event) {
    if (event.detail.value) {
      let index = event.target.dataset.id;
      this.ownerDetails[index].owner = event.detail.value;
      this.payload.liability.ownership[index].partyId = event.detail.value;
      this.checkDuplicateSelections("belongsTo", index, false);
    } else {
      this.ownerDetails[event.target.dataset.id].owner = null;
      this.payload.liability.ownership[event.target.dataset.id].partyId = null;
    }
  }

  handleOwnershipSplit(event) {
    let index = event.target.dataset.id;
    this.ownerDetails[index].split = this.payload.liability.ownership[
      index
    ].proportion.value = parseInt(event.detail.value);

    let splitFields = this.template.querySelectorAll(
      "lightning-input[data-name='ownershipSplit']"
    );
    //Check if the total ownership split is valid
    splitFields.forEach((field) => {
      this.checkOwnershipSplitValidity(field);
    });
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
    this.fieldVisibility = handleExcludedDebtChangeVisibility(
      this.debtType,
      event.detail.value,
      this.fieldVisibility,
      this.payload
    );
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

  handleTaxDeductible(event) {
    this.payload.liability.institutionalLiability.taxDeductiblePercentage =
      event.detail.value;
  }

  handlePropertyAddressChange(event) {
    let index = parseInt(event.target.dataset.id);
    if (event.detail.value) {
      this.propertyDetails[index].property = event.detail.value;
      this.payload.liability.assets[index] = event.detail.value;
      this.checkDuplicateSelections("propertyAddress", index, false);
    } else {
      this.propertyDetails[index].property = null;
      this.payload.liability.assets.splice(index, 1);
    }
  }

  handleAddProperty() {
    this.propertyDetails.push({
      property: null,
      isNotFirst: true,
      partyId: null,
      key: Math.random()
    });
    //Minus 1 on belongs to options to not cater for "Please Select" option
    if (this.propertyDetails.length === this.propertyOptions.length - 1) {
      this.disableAddProperty = true;
    }
  }

  handleDeleteProperty(event) {
    let index = parseInt(event.target.dataset.id);
    this.propertyDetails.splice(index, 1);
    this.payload.liability.assets.splice(index, 1);
    this.checkDuplicateSelections("propertyAddress", index, true);
    //Minus 1 on belongs to options to not cater for "Please Select" option
    if (this.propertyDetails.length < this.propertyOptions.length - 1) {
      this.disableAddProperty = false;
    }
  }

  handlePropertyOptions(propertyList) {
    this.propertyOptions.push({ label: "--Please Select--", value: "" });
    if (propertyList.length === 0) {
      return;
    }
    let propertyValues = Object.values(propertyList);
    //Remove duplicate values (data has duplicates uses 'name' and 'propertyId' as keys)
    propertyValues = propertyValues.filter(
      (value, index, self) =>
        index === self.findIndex((t) => t.name === value.name)
    );
    propertyValues.forEach((property) => {
      //Remove refinanced assets from the list
      if (this.refinancedAssets.includes(property.name)) {
        return;
      }
      this.propertyOptions.push({
        label: property.address.singleLineAddress,
        value: property.name
      });
    });

    if (this.actionType === "Edit") {
      this.payload.liability.assets = [];
      this.debtData.assets.forEach((asset, index) => {
        let propDetails = propertyList[asset];

        this.propertyDetails[index] = {
          property: propDetails.name,
          isNotFirst: index !== 0
        };
        this.payload.liability.assets[index] = propDetails.name;
      });
    }

    //Options will equal 2 if there is a single option ("Please Select" is an option)
    if (this.propertyOptions.length === 2) {
      this.disableAddProperty = true;
    }
  }

  handleBelongsToOptions(parties) {
    parties.forEach((party, key) => {
      //If disabled is true, then value is "Please Select", and assign no value for validation
      this.belongsToOptions[key] = {
        label: party.label,
        value: party.disabled ? "" : party.partyId,
        disabled: party.disabled
      };
    });

    //Options will equal 2 if there is a single option ("Please Select" is an option)
    if (this.belongsToOptions.length === 2) {
      this.disableAddOwner = true;
    }

    if (this.actionType === "Edit") {
      this.payload.liability.ownership = [];
      this.debtData.ownership.forEach((owner, index) => {
        let name = parties.find((p) => p.partyId === owner.partyId).label;
        let ownerValue = this.belongsToOptions.find((o) => {
          return o.label === name;
        }).value;

        this.ownerDetails[index] = {
          owner: ownerValue,
          split: parseInt(owner.proportion),
          isNotFirst: index !== 0 && !this.preventAllOwnerDelete
        };
        this.payload.liability.ownership[index] = {
          partyId: owner.partyId,
          proportion: { value: owner.proportion }
        };
      });

      //Minus 1 on belongs to options to not cater for "Please Select" option
      if (this.ownerDetails.length === this.belongsToOptions.length - 1) {
        this.disableAddOwner = true;
      }
    }
  }

  handleInterestRateChange(event) {
    //Interest rate sent as basis value, 5.5% -> 550
    this.payload.liability.institutionalLiability.interestRate =
      parseFloat(event.detail.value) * 100;
  }

  handleInterestRateUMICheckbox(event) {
    this.payload.liability.institutionalLiability.interestRateValidated =
      event.detail.checked;
  }

  handleUndrawnAmount(event) {
    this.payload.liability.undrawnAmountValue = Math.abs(event.detail.value);
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
          this.debtData?.sourceType !== "LIABILITY_SOURCE_TYPE_ANZ") ||
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

  //Check if all fields are valid
  areFieldsValid() {
    let allValid = [
      ...this.template.querySelectorAll(
        "lightning-input, lightning-combobox, lightning-input[data-name='ownershipSplit']"
      )
    ].reduce((validSoFar, inputCmp) => {
      this.checkOwnershipSplitValidity(inputCmp);
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);

    return allValid;
  }

  //Check if the total ownership split is valid
  checkOwnershipSplitValidity(field) {
    if (field.getAttribute("data-name") !== "ownershipSplit") {
      return;
    }
    let ownerSplitSum = parseInt(
      this.ownerDetails.reduce((a, b) => a + b.split, 0)
    );

    //Full owner must have 100% ownership on HECS and BNPL
    if (ownerSplitSum !== 100 && this.mustBeFullOwner) {
      field.setCustomValidity(
        "100% of this debt type must be allocated to the owner."
      );
      field.reportValidity();
      return;
    }

    if (parseInt(field.value) === 0) {
      //Owners must have an ownership split greater than 0%
      field.setCustomValidity("Cannot have an owner with 0% ownership.");
      field.reportValidity();
      return;
    }
    if (ownerSplitSum > 100) {
      //Only add error message if field is not empty
      if (field.value !== "") {
        field.setCustomValidity("The total ownership split exceeds 100%.");
      }
    } else if (ownerSplitSum === 0) {
      //Only add error message if field is not empty
      if (field.value !== "") {
        field.setCustomValidity(
          "The total ownership split must be greater than 0%."
        );
      }
    } else {
      field.setCustomValidity("");
    }
    field.reportValidity();
  }

  //Handle duplicate selections
  checkDuplicateSelections(dataName, index, isDelete) {
    let fieldType = dataName === "belongsTo" ? "owner" : "propertyAddress";

    //Use as Array to be able to filter if its delete
    let fieldList = Array.from(
      this.template.querySelectorAll(
        `lightning-combobox[data-name='${dataName}']`
      )
    );

    //remove from the field list based on data id index when delete
    if (isDelete) {
      fieldList = fieldList.filter(
        (field) => parseInt(field.dataset.id) !== parseInt(index)
      );
    }

    let message =
      fieldType === "owner"
        ? "This applicant has already been selected. Please select another applicant on this application."
        : "This property has already been selected. Please select another property on this application.";

    const dataSet = new Set();
    const duplicates = new Set();
    fieldList.forEach((field) => {
      if (!field.value) {
        return;
      }
      if (dataSet.has(field.value)) {
        duplicates.add(field.value);
      } else {
        dataSet.add(field.value);
      }
    });

    fieldList.forEach((field) => {
      if (duplicates.has(field.value)) {
        field.setCustomValidity(message);
      } else {
        field.setCustomValidity("");
      }
      field.reportValidity();
    });
  }
}
