import DOLLAR_SIGN_INCOME from "@salesforce/resourceUrl/Dollar_sign_income";
import TICK_SIGN from "@salesforce/resourceUrl/SOP_tick_img";
import CROSS_SIGN from "@salesforce/resourceUrl/SOP_cross_img";
import RLA_BROKER_CODE from "@salesforce/schema/ResidentialLoanApplication.Assisted_Broker_TPMI_SAO__c";
import { api, LightningElement, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { setTimestamp } from "c/utils";
import CREATED_DATE_LABEL from "@salesforce/label/c.NoIllionDataForCreditBureau";

export default class SopCreditBureauCheck extends LightningElement {
  dollarSign = DOLLAR_SIGN_INCOME;
  tickSign = TICK_SIGN;
  crossSign = CROSS_SIGN;

  creditBureauCheck;
  isApplicationBroker;

  @api partyConsent;
  @api recordId;

  @api
  get creditBureauData() {
    return this._creditBureauData;
  }

  set creditBureauData(value) {
    this._creditBureauData = value;
    this.loadCreditBureauData();
  }

  //wired method to get residential loan data
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [RLA_BROKER_CODE]
  })
  wiredAccount({ data }) {
    if (data) {
      this.isApplicationBroker =
        getFieldValue(data, RLA_BROKER_CODE) != null ?? false;
    }
  }

  _creditBureauData;

  _creditBureauModel = (ownerName) => ({
    ownerName,
    liabilitySources: [
      {
        subType: "Equifax",
        isLiabilityCompleted: false,
        retrievedTime: "",
        isLiabilityHidden: false
      },
      {
        subType: "Experian",
        isLiabilityCompleted: false,
        retrievedTime: "",
        isLiabilityHidden: false
      },
      {
        subType: "Illion",
        isLiabilityCompleted: false,
        retrievedTime: "",
        isLiabilityHidden: false
      }
    ],
    consentNotReceived: !this.creditBureauData.consentReceived
  });

  loadCreditBureauData() {
    if (this.creditBureauData) {
      const ownerBureauMap = new Map();

      this.creditBureauData.creditBureauChecks.forEach((check) => {
        if (!ownerBureauMap.has(check.ownerName)) {
          ownerBureauMap.set(
            check.ownerName,
            this._creditBureauModel(check.ownerName)
          );
        }

        const creditCheckDetail = ownerBureauMap.get(check.ownerName);

        //update static liability sources
        const liabilitySource = creditCheckDetail.liabilitySources.find(
          (source) => source.subType === check.subType
        );
        if (liabilitySource) {
          if (
            check.retrievedTime >= CREATED_DATE_LABEL &&
            check.subType == "Illion"
          ) {
            liabilitySource.isLiabilityHidden = true;
            return;
          }
          liabilitySource.isLiabilityCompleted =
            check.liabilityState === "LOAD_BUREAU_LIABILITIES_STATE_COMPLETE";
          liabilitySource.retrievedTime = liabilitySource.isLiabilityCompleted
            ? `Credit Check completed on ${setTimestamp(check.retrievedTime)}`
            : "Credit check attempted";
        }
      });
      this.creditBureauCheck = [...ownerBureauMap.values()];
    }
  }

  //condition is based on SOP_Finances_Savings (omni) implementation
  get hasLiabilitySourceConsent() {
    return this.creditBureauData?.consentReceived;
  }

  get allPartiesAndBurueaConsented() {
    return this.partyConsent && this.hasLiabilitySourceConsent;
  }
}
