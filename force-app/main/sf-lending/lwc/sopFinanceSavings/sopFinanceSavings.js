import { LightningElement, api } from "lwc";
import ERROR_IMG from "@salesforce/resourceUrl/No_savings_img";
import ANZ_PLUS_IMG from "@salesforce/resourceUrl/ANZ_Plus_img";
import ANZ_IMG from "@salesforce/resourceUrl/ANZ_img";
import OTHER_INST_IMG from "@salesforce/resourceUrl/Other_Inst";
import CASH_IMG from "@salesforce/resourceUrl/Cash";

const TYPE_MAP = {
  ASSET_TYPE_BANK_ACCOUNT: "Bank Account",
  ASSET_TYPE_CASH: "Cash"
};

const SOURCE_MAP = {
  ASSET_SOURCE_MANUAL: "Manual",
  ASSET_SOURCE_OPENBANKING: "Credit Bureau",
  ASSET_SOURCE_ANZ: "ANZ"
};

export const ACCOUNT_STATUS = {
  ACCOUNT_STATE_UNSPECIFIED: "Unspecified", // there is no info about what status the account is in
  ACCOUNT_STATE_OPEN: "Open", // the account is open
  ACCOUNT_STATE_ACTIVE: "Active", // the account is active
  ACCOUNT_STATE_SUSPENDED: "Suspended", // the account is suspended
  ACCOUNT_STATE_DORMANT: "Dormant", // the account is dormant
  ACCOUNT_STATE_CLOSED: "Closed" // the account is closed
};

export default class SopFinanceSavings extends LightningElement {
  @api sopSavingsData;
  noDataAvailable = false;
  error_img = ERROR_IMG;
  savings = [
    {
      title: "ANZ Plus",
      savings: []
    },
    {
      title: "ANZ",
      savings: []
    },
    {
      title: "Other Institutions",
      savings: []
    },
    {
      title: "Cash",
      savings: []
    }
  ];
  savingsData;

  connectedCallback() {
    //Check if data is not null
    if (
      this.sopSavingsData?.savings &&
      this.sopSavingsData?.savings.length > 0
    ) {
      //Need to clone data since cache is read only
      this.savingsData = JSON.parse(JSON.stringify(this.sopSavingsData));
      //Sort data in descending order by balance
      this.savingsData.savings.sort((a, b) => b.balance - a.balance);
      //Loop through savings data and sort into the savings sections
      this.savingsData.savings.forEach((saving) => {
        saving.readableType = TYPE_MAP[saving.type];
        saving.readableSource = SOURCE_MAP[saving.source];
        saving.readableStatus =
          saving.accountStatus !== null
            ? ACCOUNT_STATUS[saving.accountStatus]
            : "";
        saving.lastModified = this.setTimestamp(saving.updateTime);
        if (this.isANZPlusSavingItem(saving)) {
          let anzPlus = this.savings.find((sav) => sav.title === "ANZ Plus");
          this.handleFieldConditions("ANZ Plus", saving);
          anzPlus.savings.push(saving);
        } else if (this.isANZSavingItem(saving)) {
          let anz = this.savings.find((sav) => sav.title === "ANZ");
          this.handleFieldConditions("ANZ", saving);
          anz.savings.push(saving);
        } else if (this.isOtherInstitutionSavingItem(saving)) {
          let other = this.savings.find(
            (sav) => sav.title === "Other Institutions"
          );
          this.handleFieldConditions("Other", saving);
          other.savings.push(saving);
        } else if (this.isCashSavingItem(saving)) {
          let cash = this.savings.find((sav) => sav.title === "Cash");
          this.handleFieldConditions("Cash", saving);
          cash.savings.push(saving);
        }
      });

      //Remove any section that doesnt have any savings so we dont loop through
      this.savings = this.savings.filter((el) => el.savings.length > 0);
    } else {
      this.noDataAvailable = true;
    }
  }

  //Check if saving is ANZ Plus
  isANZPlusSavingItem(saving) {
    return (
      saving.type === "ASSET_TYPE_BANK_ACCOUNT" &&
      saving.financialInstitution === "ANZ Plus"
    );
  }

  //Check if saving is ANZ
  isANZSavingItem(saving) {
    return (
      saving.type === "ASSET_TYPE_BANK_ACCOUNT" &&
      saving.financialInstitution === "ANZ"
    );
  }

  //Check if saving is Other Institution
  isOtherInstitutionSavingItem(saving) {
    return (
      saving.type === "ASSET_TYPE_BANK_ACCOUNT" &&
      saving.financialInstitution !== "ANZ Plus" &&
      saving.financialInstitution !== "ANZ"
    );
  }

  //Check if saving is Cash
  isCashSavingItem(saving) {
    return (
      saving.type === "ASSET_TYPE_CASH" &&
      saving.financialInstitution !== "ANZ Plus" &&
      saving.financialInstitution !== "ANZ"
    );
  }

  //Used to determine visibility of fields
  handleFieldConditions(type, saving) {
    switch (type) {
      case "ANZ Plus":
        saving.showProductName = true;
        saving.showInstitution = true;
        saving.showBalance = true;
        saving.showAmount = false;
        saving.showBsb = true;
        saving.showAccountNumber = true;
        saving.showAccountStatus = true;
        saving.image = ANZ_PLUS_IMG;
        break;
      case "ANZ":
        saving.showProductName = saving.productName ? true : false;
        saving.showInstitution = true;
        saving.showBalance = true;
        saving.showAmount = false;
        saving.showBsb = true;
        saving.showAccountNumber = true;
        saving.showAccountStatus = true;
        saving.image = ANZ_IMG;
        break;
      case "Other":
        saving.showProductName = false;
        saving.showInstitution = true;
        saving.showBalance = true;
        saving.showAmount = false;
        saving.showBsb = false;
        saving.showAccountNumber = false;
        saving.image = OTHER_INST_IMG;
        break;
      case "Cash":
        saving.showProductName = false;
        saving.showInstitution = false;
        saving.showBalance = false;
        saving.showAmount = true;
        saving.showBsb = false;
        saving.showAccountNumber = false;
        saving.image = CASH_IMG;
        break;
      default:
        break;
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
}
