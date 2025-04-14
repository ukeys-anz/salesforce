//import SopUtils from "c/sopUtils";
import { api, LightningElement, wire } from "lwc";
import SALARY_WAGES from "@salesforce/resourceUrl/Salary_wages";
import OTHER_IMG from "@salesforce/resourceUrl/Other_income_img";
import DOLLAR_SIGN from "@salesforce/resourceUrl/Dollar_sign_income";
import INCOME_TRANSACTION from "@salesforce/resourceUrl/Income_Transaction_img";
import SopAddEditIncome from "c/sopAddEditIncome";
import hasAddPermission from "@salesforce/customPermission/SOP_Add";
import hasEditPermission from "@salesforce/customPermission/SOP_Edit";
import hasDeletePermission from "@salesforce/customPermission/SOP_Delete";

import SopFinanceDeleteModal from "c/sopFinanceDeleteModal";
import ANZ_IMG from "@salesforce/resourceUrl/ANZ_img";
import { EMP_TYPE_MAP, ITEM_TYPE_MAP } from "./helper";
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
  allowEdit;
  allowAdd;
  allowDelete;

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
    this.transformData();
  }
  transformData() {
    if (!this.sopIncomeData?.incomes) {
      return;
    }

    //Need to clone data since data is proxied and cache is read only
    this.incomeData = JSON.parse(JSON.stringify(this.sopIncomeData));
    //sort by first name
    this.incomeData.incomes.sort((a, b) => {
      const firstNameA = a.ownerName.toLowerCase();
      const firstNameB = b.ownerName.toLowerCase();
      return firstNameA.localeCompare(firstNameB);
    });
    this.incomeData.incomes.forEach((income, index) => {
      //Level1 Data transformation to get readable income details
      income = this.incomeDataTransform(income, index);

      //If income is manual then get readable incometype(base,overtime,commission, bonus) details
      if (income.isManual) {
        this.incomeItemManualTransform(income);
      } else if (income.isTransaction) {
        income = this.incomeItemTransactionTransform(income);
      }

      //sort income based on heading
      this.sortIncomeByItemHeading(income);
    });
    this.incomes = this.incomeData.incomes;
  }

  sortIncomeByItemHeading(income) {
    const order = ["Base Salary", "Overtime", "Commission", "Bonuses"];
    return income.incomeItemDetails.sort((a, b) => {
      return order.indexOf(a.itemHeading) - order.indexOf(b.itemHeading);
    });
  }

  incomeDataTransform(income, index) {
    income.index = index; // Will use for Edit And Delete Buttons
    income.readableEmpType = EMP_TYPE_MAP[income.employmentType];
    income.readableStartDate = this.startDateTransform(income.startDate);
    income.logo = this.logoSelection(income.employer);
    income.isManual = income.incomeSource === "Manual";
    income.isTransaction = income.incomeSource === "Transactions";
    income.lastModified = this.setTimestamp(income.updateTime);
    income.readableIncomeVerified = this.incomeVerificationDetails(
      income.incomeVerified
    );
    return income;
  }

  incomeItemManualTransform(income) {
    income.incomeItemDetails = income.incomeItemDetails.map((incomeItem) => ({
      ...incomeItem,
      isBonuses: incomeItem.type === this.INCOME_TYPE_BONUS,
      readableFrequency: this.getReadableFreq(incomeItem.frequency),
      categoryOfIncome: this.getCategoryOfIncome(incomeItem.amountType),
      itemHeading: ITEM_TYPE_MAP[incomeItem.type]
    }));
    return income;
  }

  incomeItemTransactionTransform(income) {
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

  handleAddClick() {
    SopAddEditIncome.open({
      size: "medium",
      incomeDetails: this.setupBaseIncomeDetail(),
      isAddModal: true
    });
  }
  setupBaseIncomeDetail() {
    return {
      incomeSource: "Manual",
      partyIdToFirstNameMap: this.incomes[0].partyIdToFirstNameMap ?? null,
      sopId: this.incomes[0].sopId ?? null,
      loanId: this.recordId ?? null,
      incomeItemDetails: [
        {
          isBase: true,
          isOverTime: false,
          isCommission: false,
          isBonuses: false,
          type: this.INCOME_TYPE_BASE_SALARY
        }
      ]
    };
  }

  handleEditClick(event) {
    SopAddEditIncome.open({
      size: "medium",
      incomeDetails: this.setupEditIncomeDetail(
        this.incomes[event.target.dataset.id]
      ),
      isAddModal: false
    });
  }
  setupEditIncomeDetail(income) {
    income.incomeItemDetails.forEach((item) => {
      item.isBase =
        item.type === this.INCOME_TYPE_BASE_SALARY ||
        item.type === this.INCOME_TYPE_SALARY_WAGES;
      item.isOverTime = item.type === this.INCOME_TYPE_OVERTIME;
      item.isBonuses = item.type === this.INCOME_TYPE_BONUS;
      item.isCommission = item.type === this.INCOME_TYPE_COMMISSION;
    });
    income.loanId = this.recordId;
    return income;
  }

  get totalIncomeAmount() {
    return this.sopIncomeData?.totalAmount;
  }

  handleDeleteClick(event) {
    let allowIncomeDelete = true;
    if (this.incomes.length <= 1) {
      allowIncomeDelete = false;
    }

    SopFinanceDeleteModal.open({
      size: "small",
      recordDetails: this.incomes[event.target.dataset.id],
      isDeletionAllowed: allowIncomeDelete,
      sopType: "Income",
      recordId: this.recordId
    });
  }
}
