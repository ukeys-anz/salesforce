import { LightningElement, wire } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { CurrentPageReference } from "lightning/navigation";
import CASE_ACCOUNT_FIELD from "@salesforce/schema/Case.AccountId";

const FIELDS = [
  "Account.Source_System_ID__c",
  "Account.RecordTypeId",
  "Account.FirstName",
  "Account.LastName",
  "Account.MiddleName",
  "Account.Gender__pc",
  "Account.FinServ__Age__pc",
  "Account.CPID__c",
  "Account.OCV_ID__c",
  "Account.PersonBirthdate",
  "Account.Other_Email__c",
  "Account.PersonEmail",
  "Account.PersonOtherPhone",
  "Account.PersonMobilePhone",
  "Account.BillingStreet",
  "Account.BillingCity",
  "Account.BillingState",
  "Account.BillingPostalCode",
  "Account.BillingCountry",
  "Account.PersonOtherCity",
  "Account.PersonOtherCountry",
  "Account.PersonOtherPostalCode",
  "Account.PersonOtherState",
  "Account.PersonOtherStreet",
  "Account.ShippingCity",
  "Account.ShippingCountry",
  "Account.ShippingPostalCode",
  "Account.ShippingState",
  "Account.ShippingStreet",
  "Account.RecordType.Name",
  "Account.Migration_Status__c",
  "Account.Migration_Status_Date__c",
  "Account.Controlling_Post__c",
  "Account.Controlling_Post__r.Responsible_Employee_Name__c",
  "Account.Controlling_Post__r.CPID_Phone__c",
  "Account.Controlling_Post__r.CPID_Address__c",
  "Account.ExtraCareReason__c",
  "Account.ExtraCareTimePeriod__c"
];
export default class AccountLookup extends OmniscriptBaseMixin(
  LightningElement
) {
  recId;
  caseId;
  account;
  custNo;
  isDisabled = false;

  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    this.pageReference = currentPageReference;
  }

  get accountIdStr() {
    try {
      if (this.recId) {
        return this.recId;
      }

      const inContextVal = this.getURLParameterByName("inContextOfRef");
      const wsParam = this.pageReference?.state?.ws;

      if (!wsParam) {
        return null;
      }

      if (!inContextVal) {
        return this.extractAccountIdFromWs(wsParam);
      }

      return this.extractAccountIdFromContext(inContextVal);
    } catch (err) {
      this.recId = "";
      return null;
    }
  }

  extractAccountIdFromWs(wsParam) {
    const match = wsParam.match(/\/Account\/([a-zA-Z0-9]{15,18})\//);
    if (!match?.[1]) {
      return null;
    }
    this.recId = match?.[1];
    this.isDisabled = true;
    this.setCaseAccountId();
    return this.recId;
  }

  extractAccountIdFromContext(inContextVal) {
    const context = JSON.parse(window.atob(inContextVal));
    let recordIdFromURL = context?.attributes?.recordId;
    let objectName = context?.attributes?.objectApiName;

    if (objectName !== "Account" && context?.state?.ws) {
      const parts = context.state.ws.split("/");
      this.recId = this.checkTypeOfRecordId(parts?.[4]);
      this.isDisabled = true;
      this.setCaseAccountId();
      return this.recId;
    }

    if (!this.recId) {
      this.recId = recordIdFromURL;
    }
    this.isDisabled = true;
    this.setCaseAccountId();
    return this.recId;
  }

  handleChange(event) {
    this.recId = event.target.value;
    this.setCaseAccountId();
  }

  setCaseAccountId() {
    let isEcf = this.recId ? true : false;
    this.omniApplyCallResp({ Case: { AccountId: this.recId }, isEcf });
  }

  checkTypeOfRecordId(recdId) {
    if (!recdId?.startsWith("500")) {
      return recdId;
    }
    this.caseId = recdId;
    return this.caseId;
  }
  getURLParameterByName(name) {
    var regex, results, url;
    url = window.location.href;
    name = name.replace(/[[\]]/g, "$&");
    regex = new RegExp("[?&]" + name + "(=1.([^&#]*)|&|#|$)");
    results = regex.exec(url);
    if (!results) return null;
    if (!results?.[2]) return "";
    return decodeURIComponent(results[2].replace(/\+/g, " "));
  }

  @wire(getRecord, { recordId: "$recId", fields: FIELDS })
  wiredAccount({ error, data }) {
    let isEcf = false;
    let readOnlyPriority = null;
    if (data) {
      this.account = data.fields;
      this.error = null;
      isEcf = !["Not required", null].includes(
        data.fields.ExtraCareTimePeriod__c.value
      );
      if (isEcf) {
        readOnlyPriority = "Vulnerable Customer";
      }
    } else if (error) {
      this.account = null;
      this.error = error.body.message;
    }
    this.omniApplyCallResp({
      data,
      isEcf,
      Case: { ComplaintDetails: { ReadOnlyPriority: readOnlyPriority } }
    });
  }
  @wire(getRecord, { recordId: "$caseId", fields: [CASE_ACCOUNT_FIELD] })
  wiredCase({ data }) {
    if (!data) {
      return;
    }
    let accId = getFieldValue(data, CASE_ACCOUNT_FIELD);
    if (!accId || accId === this.recId) {
      return;
    }
    this.recId = accId;
    this.setCaseAccountId();
  }
}
