import IMAGE_INCOME from "@salesforce/resourceUrl/Salary_wages";
import IMAGE_EXPENSE from "@salesforce/resourceUrl/SOP_Expense_Calculator";
import IMAGE_SAVING from "@salesforce/resourceUrl/goal_themes";
import IMAGE_SOP from "@salesforce/resourceUrl/SOP_Images";
import IMAGE_TICK from "@salesforce/resourceUrl/SOP_tick_img";
import SOP_CONNECTED_APP from "@salesforce/resourceUrl/SOP_Connected_App";
import { api, LightningElement } from "lwc";

export default class SopFinanceProgressNew extends LightningElement {
  tickimg = IMAGE_TICK;
  sopAppImage = SOP_CONNECTED_APP;

  componentConfig = {
    COMPONENT_TYPE_SAVINGS: {
      type: "Savings",
      imgsrc: `${IMAGE_SAVING}/SAVINGS_JAR.png`
    },
    COMPONENT_TYPE_ASSETS: {
      type: "Assets",
      imgsrc: `${IMAGE_SOP}/SOP_car.png`
    },
    COMPONENT_TYPE_LIABILITIES: {
      type: "Debts",
      imgsrc: `${IMAGE_SOP}/SOP_progress_debt.png`
    },
    COMPONENT_TYPE_INCOMES: { type: "Income", imgsrc: IMAGE_INCOME },
    COMPONENT_TYPE_EXPENSES: { type: "Spending", imgsrc: IMAGE_EXPENSE }
  };

  owners;

  @api
  get financeSummaryData() {
    return this._financeSummaryData;
  }

  set financeSummaryData(value) {
    this._financeSummaryData = value;
    this.loadFinanceSummaryData();
  }

  _financeSummaryData;

  finances = [
    {
      type: "Savings"
    },
    {
      type: "Assets"
    },
    {
      type: "Debts"
    },
    {
      type: "Income"
    },
    {
      type: "Spending"
    }
  ];

  loadFinanceSummaryData() {
    if (this.financeSummaryData) {
      //get owners
      this.owners = [
        ...new Set(
          this.financeSummaryData.components
            .flatMap((component) => component.partyConfirmations || [])
            .map((confirmation) => confirmation.ownerName)
        )
      ];

      // create a default object with ownerName of owners and status as false
      const defaultConfirmation = this.owners.map((ownerName) => ({
        ownerName,
        status: false
      }));

      //confirmation object i.e owner value column
      const mapConfirmation = (confirmation) => ({
        ownerName: confirmation?.ownerName,
        status: !!confirmation?.confirmedTime
      });

      //other columns
      const mapComponent = (component) => {
        const config = this.componentConfig[component.type];
        const confirmationMap = defaultConfirmation.map((defaultConf) => {
          const matchingConf = component.partyConfirmations.find(
            (conf) => conf.ownerName === defaultConf.ownerName
          );
          return matchingConf ? mapConfirmation(matchingConf) : defaultConf;
        });

        let totalAmount = component.totalAmount;
        if (
          confirmationMap.every((conf) => !conf.status) &&
          totalAmount === 0
        ) {
          totalAmount = undefined;
        }

        return {
          type: config.type,
          imgsrc: config.imgsrc,
          confirmation: confirmationMap,
          totalAmount: totalAmount
        };
      };

      //map to the finances object
      const financeComponents =
        this.financeSummaryData.components.map(mapComponent);
      this.finances = this.finances.map((summary) => {
        const matchingComponent = financeComponents.find(
          (finance) => finance.type === summary.type
        );
        return matchingComponent
          ? { ...summary, ...matchingComponent }
          : summary;
      });
    }
  }
}
