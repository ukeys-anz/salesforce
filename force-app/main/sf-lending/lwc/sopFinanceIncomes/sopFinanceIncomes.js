//import SopUtils from "c/sopUtils";
import { api, LightningElement, wire } from "lwc";
import SALARY_WAGES from "@salesforce/resourceUrl/Salary_wages";
import OTHER_IMG from "@salesforce/resourceUrl/Other_income_img";
import DOLLAR_SIGN from "@salesforce/resourceUrl/Dollar_sign_income";
import INCOME_TRANSACTION from "@salesforce/resourceUrl/Income_Transaction_img";
import HOME_IMG from "@salesforce/resourceUrl/SOP_Debt_Mortgage";
import SopAddEditIncome from "c/sopAddEditIncome";
import hasAddPermission from "@salesforce/customPermission/SOP_Add";
import hasEditPermission from "@salesforce/customPermission/SOP_Edit";
import hasDeletePermission from "@salesforce/customPermission/SOP_Delete";

import SopFinanceDeleteModal from "c/sopFinanceDeleteModal";
import ANZ_IMG from "@salesforce/resourceUrl/ANZ_img";
import {
  EMP_TYPE_MAP,
  ITEM_TYPE_MAP,
  RENTAL_INCOME_TYPE_MAP,
  WAGE_ORDER
} from "./helper";
import { getRecord } from "lightning/uiRecordApi";

const FIELDS = ["ResidentialLoanApplication.Status"];

export default class SopFinanceIncomes extends LightningElement {
  //logos
  logo = SALARY_WAGES;
  logoOtherImage = OTHER_IMG;
  logoDollarSign = DOLLAR_SIGN;
  logoTransaction = INCOME_TRANSACTION;
  logoANZ = ANZ_IMG;

  //Js constants
  BEFORE_TAX = "Before Tax";
  AFTER_TAX = "After Tax";
  INCOME_AMOUNT_TYPE_NET = "INCOME_AMOUNT_TYPE_NET";
  INCOME_AMOUNT_TYPE_GROSS = "INCOME_AMOUNT_TYPE_GROSS";
  NOT_SPECIFIED = "Not Specified";
  UNSPECIFIED = "UNSPECIFIED";
  MANUAL = "Manual";
  INCOME_TYPE_BASE_SALARY = "INCOME_TYPE_BASE_SALARY";
  INCOME_TYPE_SALARY_WAGES = "INCOME_TYPE_SALARY_WAGES";
  INCOME_TYPE_BONUS = "INCOME_TYPE_BONUS";
  INCOME_TYPE_OVERTIME = "INCOME_TYPE_OVERTIME";
  INCOME_TYPE_COMMISSION = "INCOME_TYPE_COMMISSION";
  TRANSACTION = "Transactions";

  incomes = [];
  @api sopIncomeData;
  @api recordId;
  incomeData;
  sortedIncomes = [];
  allowEdit;
  allowAdd;
  allowDelete;
  rentalIncomes;

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredRecord({ data }) {
    if (data) {
      this.allowAdd =
        hasAddPermission && data.fields.Status.value === "STATE_REFERRED";
      this.allowEdit =
        hasEditPermission && data.fields.Status.value === "STATE_REFERRED";
      this.allowDelete =
        hasDeletePermission && data.fields.Status.value === "STATE_REFERRED";
    }
  }

  /**
   * @description If sopIncomeData is valid then adding isManual,isTransaction on sopIncomeData.
   * Similarly adding isBase,isBonuses,isOverTime,isCommission,readableFrequency and categoryOfIncome on incomes node.
   */
  connectedCallback() {
    //Need to clone data since data is proxied and cache is read only
    this.incomeData = JSON.parse(JSON.stringify(this.sopIncomeData));
    this.processIncomes();
  }
  processIncomes() {
    if (!this.incomeData?.incomes) {
      return;
    }
    let rental = this.incomeData.incomes
      .filter((income) =>
        income.incomeItemDetails.some((detail) =>
          Object.keys(RENTAL_INCOME_TYPE_MAP).includes(detail.type)
        )
      )
      .map((income) => {
        income = this.rentalView(income);
        return income;
      })
      .sort((a, b) =>
        a.ownerName.toLowerCase().localeCompare(b.ownerName.toLowerCase())
      );
    this.rentalIncomes = [...rental];
    let salary = this.incomeData.incomes
      .filter((income) => !rental.includes(income))
      .sort((a, b) =>
        a.ownerName.toLowerCase().localeCompare(b.ownerName.toLowerCase())
      )
      .map((income) => {
        income = this.salaryView(income);
        return income;
      })
      .map((income) => {
        // Sort the details array based on the order array
        income.incomeItemDetails.sort((a, b) => {
          return WAGE_ORDER.indexOf(a.type) - WAGE_ORDER.indexOf(b.type);
        });
        return income;
      });
    this.sortedIncomes = [];
    if (salary.length > 0) {
      this.sortedIncomes.push({
        header: "Salary and Wages",
        incomes: [...salary]
      });
    }
    if (rental.length > 0) {
      this.sortedIncomes.push({
        header: "Rental Income",
        incomes: [...rental]
      });
    }
  }

  rentalView(income) {
    income.isRental = true;
    income.logo = HOME_IMG;
    income.isManual = income.incomeSource === "Manual";
    income.agreementType =
      RENTAL_INCOME_TYPE_MAP[income.incomeItemDetails[0].type];
    income.lastModified = this.setTimestamp(income.updateTime);
    income.readableIncomeVerified = this.incomeVerificationDetails(
      income.incomeVerified
    );
    income.incomeItemDetails = income.incomeItemDetails.map((incomeItem) => ({
      ...incomeItem,
      readableFrequency: this.getReadableFreq(incomeItem.frequency),
      categoryOfIncome: this.getCategoryOfIncome(incomeItem.amountType)
    }));
    return income;
  }

  salaryView(income) {
    income.isSalary = true;
    income.readableEmpType = EMP_TYPE_MAP[income.employmentType];
    income.readableStartDate = this.startDateTransform(income.startDate);
    income.logo = this.logoSelection(income.employer);
    income.isManual = income.incomeSource === "Manual";
    income.isTransaction = income.incomeSource === "Transactions";
    income.lastModified = this.setTimestamp(income.updateTime);
    income.readableIncomeVerified = this.incomeVerificationDetails(
      income.incomeVerified
    );
    if (income.isManual) {
      income = this.salaryManualTransform(income);
    } else if (income.isTransaction) {
      income = this.salaryTransactionTransform(income);
    }
    return income;
  }

  salaryManualTransform(income) {
    income.incomeItemDetails = income.incomeItemDetails.map((incomeItem) => ({
      ...incomeItem,
      isBonuses: incomeItem.type === this.INCOME_TYPE_BONUS,
      readableFrequency: this.getReadableFreq(incomeItem.frequency),
      categoryOfIncome: this.getCategoryOfIncome(incomeItem.amountType),
      itemHeading: ITEM_TYPE_MAP[incomeItem.type]
    }));
    return income;
  }

  salaryTransactionTransform(income) {
    income.transactionIncomeItem.readableFrequency = this.getReadableFreq(
      income.transactionIncomeItem.frequency
    );
    const transBaseItem = income.incomeItemDetails.find(
      (item) =>
        item.type === this.INCOME_TYPE_BASE_SALARY ||
        item.type === this.INCOME_TYPE_SALARY_WAGES
    );
    if (!transBaseItem) {
      income.incomeItemDetails = [];
    } else {
      transBaseItem.readableFrequency = this.getReadableFreq(
        transBaseItem.frequency
      );
      transBaseItem.categoryOfIncome = this.getCategoryOfIncome(
        transBaseItem.amountType
      );
      transBaseItem.itemHeading = "";
      transBaseItem.isBonuses = false;
      income.incomeItemDetails = [transBaseItem];
    }
    return income;
  }

  /**
   * @param frequency
   * @input INCOME_FREQUENCY_MONTHLY, INCOME_FREQUENCY_WEEKLY,INCOME_FREQUENCY_ANNUALLY
   * @return Monthly, Weekly, Annually
   */
  getReadableFreq(frequency) {
    if (!frequency) {
      return null;
    }

    let words = frequency.split("_").splice(2);
    let freq = words[0];

    if (!freq) {
      return null;
    }

    return freq === this.UNSPECIFIED
      ? this.NOT_SPECIFIED
      : freq.toUpperCase().substring(0, 1) + freq.substring(1).toLowerCase();
  }

  /**
   *@param amountType
   *@description if amounttype is gross then return before tax. And if amounttype is net then return after tax
   */
  getCategoryOfIncome(amountType) {
    switch (amountType) {
      case this.INCOME_AMOUNT_TYPE_GROSS:
        return this.BEFORE_TAX;
      case this.INCOME_AMOUNT_TYPE_NET:
        return this.AFTER_TAX;
      default:
        return null;
    }
  }
  setTimestamp(timestamp) {
    //Create timestamp for last updated
    let lastModified = new Date(timestamp);
    lastModified =
      lastModified.getDate() +
      " " +
      lastModified.toLocaleString("en-AU", {
        month: "long"
      }) +
      " " +
      lastModified.getFullYear() +
      " | " +
      lastModified.toLocaleString("en-AU", {
        hour: "numeric",
        minute: "numeric",
        hour12: true
      });
    return lastModified;
  }

  //2024-04-21 --> 21 April 2024
  startDateTransform(startDate) {
    if (!startDate) {
      return null;
    }
    const date = new Date(startDate);
    const month = date.toLocaleString("default", { month: "long" });
    return `${date.getDate()} ${month} ${date.getFullYear()}`;
  }

  logoSelection(employer) {
    if (employer === "ANZ Bank Ltd") {
      return this.logoANZ;
    }
    return this.logoOtherImage;
  }

  incomeVerificationDetails(incomeVerified) {
    return incomeVerified ? "Yes" : "No";
  }

  handleAddClick() {
    SopAddEditIncome.open({
      size: "medium",
      incomeDetails: this.setupAddIncomeDetail(),
      isAddModal: true
    });
  }
  setupAddIncomeDetail() {
    return {
      incomeSource: "Manual",
      partyIdToFirstNameMap:
        this.incomeData.incomes[0].partyIdToFirstNameMap ?? null,
      sopId: this.incomeData.incomes[0].sopId ?? null,
      loanId: this.recordId ?? null,
      rentalPropertyOptions: this.createRentalOptions(),
      propertyOwnerShipMap: this.incomeData.propertyOwnerShipMap
    };
  }

  createRentalOptions() {
    let rentalOptions = [];
    let allowAddRental = false;
    const rentalIncomeNames = this.rentalIncomes.map((income) => income.asset);
    for (const key in this.incomeData?.assetPropertyLookup) {
      const property = this.incomeData.assetPropertyLookup[key];
      const isDisabled = rentalIncomeNames.includes(property.name);
      if (!isDisabled) {
        allowAddRental = true;
      }
      rentalOptions.push({
        label: property.address.singleLineAddress,
        value: property.name,
        disabled: isDisabled
      });
    }

    return allowAddRental ? rentalOptions : [];
  }

  handleEditClick(event) {
    const uid = event.target.dataset.id;
    const income = this.findIncomeByUid(uid);
    SopAddEditIncome.open({
      size: "medium",
      incomeDetails: this.setupEditIncomeDetail(income),
      isAddModal: false
    });
  }
  setupEditIncomeDetail(income) {
    income.loanId = this.recordId;
    if (income.isSalary) {
      income.incomeItemDetails.forEach((item) => {
        item.isBase =
          item.type === this.INCOME_TYPE_BASE_SALARY ||
          item.type === this.INCOME_TYPE_SALARY_WAGES;
        item.isOverTime = item.type === this.INCOME_TYPE_OVERTIME;
        item.isBonuses = item.type === this.INCOME_TYPE_BONUS;
        item.isCommission = item.type === this.INCOME_TYPE_COMMISSION;
      });
    }
    return income;
  }

  get totalIncomeAmount() {
    return this.incomeData.totalAmount;
  }

  handleDeleteClick(event) {
    const uid = event.target.dataset.id;
    const income = this.findIncomeByUid(uid);
    let allowIncomeDelete = true;
    if (this.incomeData.incomes.length <= 1) {
      allowIncomeDelete = false;
    }

    SopFinanceDeleteModal.open({
      size: "small",
      recordDetails: income,
      isDeletionAllowed: allowIncomeDelete,
      sopType: "Income",
      recordId: this.recordId
    });
  }

  findIncomeByUid(uid) {
    return this.incomeData.incomes.find((income) => income.uid === uid);
  }
}
