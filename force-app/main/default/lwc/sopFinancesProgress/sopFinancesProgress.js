import { LightningElement, api } from "lwc";
import { FlexCardMixin } from "omnistudio/flexCardMixin";
import IMAGE_INCOME from "@salesforce/resourceUrl/Salary_wages";
import IMAGE_EXPENSE from "@salesforce/resourceUrl/SOP_Expense_Calculator";
import IMAGE_SAVING from "@salesforce/resourceUrl/goal_themes";
import IMAGE_SOP from "@salesforce/resourceUrl/SOP_Images";
import IMAGE_TICK from "@salesforce/resourceUrl/SOP_tick_img";
export default class FlexTestComponent extends FlexCardMixin(LightningElement) {
  @api assetTotalAmount;
  @api incomeTotalAmount;
  @api debtTotalAmount;
  @api expenseTotalAmount;
  @api savingsTotalAmount;
  @api column1header;

  savingsLogo = `${IMAGE_SAVING}/SAVINGS_JAR.png`;
  incomeLogo = IMAGE_INCOME;
  expenseLogo = IMAGE_EXPENSE;
  assetLogo = `${IMAGE_SOP}/SOP_car.png`;
  debtLogo = `${IMAGE_SOP}/SOP_progress_debt.png`;
  tickimg = IMAGE_TICK;

  _column2header;
  _components;
  _statusSavingAccount1;
  _statusSavingAccount2;
  _statusAssetAccount1;
  _statusAssetAccount2;
  _statusdebtAccount1;
  _statusdebtAccount2;
  _statusExpenseAccount1;
  _statusExpenseAccount2;
  _statusIncomeAccount1;
  _statusIncomeAccount2;

  @api set componentsToString(value) {
    this._components = value;
    this.setConfirmation(JSON.parse(this._components));
  }

  get componentsToString() {
    return JSON.stringify(this._components);
  }

  @api set column2header(value) {
    if (this.isTrue(value)) {
      this._column2header = value;
    } else {
      this._column2header = false;
    }
  }
  get column2header() {
    return this._column2header;
  }

  setConfirmation(value) {
    for (const component of value) {
      switch (component.type) {
        case "COMPONENT_TYPE_INCOMES": {
          this._statusIncomeAccount1 = this.isTrue(
            component?.partyConfirmations[0]?.confirmedTime
          );
          this._statusIncomeAccount2 = this.isTrue(
            component?.partyConfirmations[1]?.confirmedTime
          );

          break;
        }
        case "COMPONENT_TYPE_ASSETS": {
          this._statusAssetAccount1 = this.isTrue(
            component?.partyConfirmations[0]?.confirmedTime
          );
          this._statusAssetAccount2 = this.isTrue(
            component?.partyConfirmations[1]?.confirmedTime
          );

          break;
        }
        case "COMPONENT_TYPE_LIABILITIES": {
          this._statusdebtAccount1 = this.isTrue(
            component?.partyConfirmations[0]?.confirmedTime
          );
          this._statusdebtAccount2 = this.isTrue(
            component?.partyConfirmations[1]?.confirmedTime
          );

          break;
        }
        case "COMPONENT_TYPE_EXPENSES": {
          this._statusExpenseAccount1 = this.isTrue(
            component?.partyConfirmations[0]?.confirmedTime
          );
          this._statusExpenseAccount2 = this.isTrue(
            component?.partyConfirmations[1]?.confirmedTime
          );

          break;
        }
        case "COMPONENT_TYPE_SAVINGS": {
          this._statusSavingAccount1 = this.isTrue(
            component?.partyConfirmations[0]?.confirmedTime
          );
          this._statusSavingAccount2 = this.isTrue(
            component?.partyConfirmations[1]?.confirmedTime
          );

          break;
        }
        default: {
          break;
        }
      }
    }
  }

  isTrue(value) {
    if (value && value !== "null" && value !== "undefined") {
      return true;
    }
    return false;
  }

  get rows() {
    return [
      {
        type: "Savings",
        TotalAmount: this.handleTotalAmountFormat(
          this.savingsTotalAmount,
          this._statusSavingAccount1,
          this._statusSavingAccount2
        ),
        imgsrc: this.savingsLogo,
        firstUserStatus: this._statusSavingAccount1,
        secondUserStatus: this._statusSavingAccount2
      },
      {
        type: "Assets",
        TotalAmount: this.handleTotalAmountFormat(
          this.assetTotalAmount,
          this._statusAssetAccount1,
          this._statusAssetAccount2
        ),
        imgsrc: this.assetLogo,
        firstUserStatus: this._statusAssetAccount1,
        secondUserStatus: this._statusAssetAccount2
      },
      {
        type: "Debts",
        TotalAmount: this.handleTotalAmountFormat(
          this.debtTotalAmount,
          this._statusdebtAccount1,
          this._statusdebtAccount2
        ),
        imgsrc: this.debtLogo,
        firstUserStatus: this._statusdebtAccount1,
        secondUserStatus: this._statusdebtAccount2
      },
      {
        type: "Income",
        TotalAmount: this.handleTotalAmountFormat(
          this.incomeTotalAmount,
          this._statusIncomeAccount1,
          this._statusIncomeAccount2
        ),
        imgsrc: this.incomeLogo,
        firstUserStatus: this._statusIncomeAccount1,
        secondUserStatus: this._statusIncomeAccount2
      },
      {
        type: "Spending",
        TotalAmount: this.handleTotalAmountFormat(
          this.expenseTotalAmount,
          this._statusExpenseAccount1,
          this._statusExpenseAccount2
        ),
        imgsrc: this.expenseLogo,
        firstUserStatus: this._statusExpenseAccount1,
        secondUserStatus: this._statusExpenseAccount2
      }
    ];
  }

  handleTotalAmountFormat(total, firstApplicantStatus, secondApplicantStatus) {
    //Don't show total if value is unconfirmed by applicants and is 0
    if (
      !firstApplicantStatus &&
      !secondApplicantStatus &&
      (!total || total === "0")
    ) {
      return "";
    }

    return total;
  }
}
