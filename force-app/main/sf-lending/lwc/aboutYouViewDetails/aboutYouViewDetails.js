import { LightningElement, wire, api } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import styling from "@salesforce/resourceUrl/sopStyling";
import {
  EnclosingTabId,
  getTabInfo,
  openSubtab
} from "lightning/platformWorkspaceApi";

import getSOP from "@salesforce/apex/BOHController.getSOP";
import hasEditPermission from "@salesforce/customPermission/Party_Edit";
import RLA_STATUS_APINAME from "@salesforce/schema/ResidentialLoanApplication.Status";
import RLA_ACCOUNT_OCVID from "@salesforce/schema/ResidentialLoanApplication.Account.OCV_ID__c";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

export default class AboutYouViewDetails extends LightningElement {
  @wire(EnclosingTabId) tabId;
  @api recordId;
  componentSpinner = false;
  showViewScreen = false;
  filteredSOPData;
  applicantData = [];
  applicationStatus;
  ocvId;
  isApplicationJoint = false;
  currentCircumstancesData = {};
  showGetSOPErrorScreen = false;
  livingSituationsMap = new Map([
    ["LIVING_STATUS_RENT", "Renter"],
    ["LIVING_STATUS_BOARD", "Boarder"],
    ["LIVING_STATUS_WITH_PARENTS", "Living with family or friends"],
    ["LIVING_STATUS_CARAVAN", "Caravanning or Mobile Home"],
    ["LIVING_STATUS_OTHER", "Other"],
    ["LIVING_STATUS_HOME_OWNER", "Home Owner"],
    ["LIVING_STATUS_UNSPECIFIED", ""]
  ]);
  sopAPIErrorHeader = "An unexpected error has occurred, please try again";
  sopAPIErrorDetail =
    "An error has occurred. Please refresh and try again. If the problem persists, please contact your System Administrator.";

  get isFieldEditable() {
    return (
      hasEditPermission && this.isPartyDataAvailable && this.isDataReferred
    );
  }

  get isSoleIncomeEarnerVisible() {
    return (
      (this.currentCircumstancesData.shareFinanceWithPartner === "Yes" ??
        false) &&
      !this.isApplicationJoint
    );
  }

  get isDataReferred() {
    return this.applicationStatus === "STATE_REFERRED";
  }

  get isPartyDataAvailable() {
    return Object.entries(this.currentCircumstancesData).length > 0;
  }

  connectedCallback() {
    Promise.all([loadStyle(this, styling)]);
  }
  //wired method to get residential loan data
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [RLA_STATUS_APINAME, RLA_ACCOUNT_OCVID]
  })
  wiredAccount({ data }) {
    if (data) {
      this.applicationStatus = getFieldValue(data, RLA_STATUS_APINAME); // Storing the loan status field value
      this.ocvId = getFieldValue(data, RLA_ACCOUNT_OCVID); // Storing the account ocvId field value
      this.loadGetSOPData(); // calling getSOP API after getting ocvId
    }
  }
  //apex method to get getSOP API data
  async loadGetSOPData() {
    this.componentSpinner = true;
    try {
      let result = await getSOP({ loanId: this.recordId }); // Call Apex method
      if (!result?.parties) {
        this.showGetSOPErrorScreen = true;
        return;
      }
      // to check if application is joint or not.
      this.isApplicationJoint = this.getJointApplication(result);

      //transforming parties data on applicant level
      result.parties = this.transformPartiesData(result.parties);

      this.filteredSOPData = JSON.parse(JSON.stringify(result));

      // assigning the primary party for current circumstances details data
      this.currentCircumstancesData = this.filterSOPData(result)?.[0] ?? {};

      //assigning parties data to display in applicants tab
      this.applicantData = result.parties;
      this.showViewScreen = true;
    } catch (error) {
      this.filteredSOPData = null;
      this.showGetSOPErrorScreen = true;
    } finally {
      this.componentSpinner = false;
    }
  }

  //Transforming data to map label from API values and editibility of fields on Applicant level
  transformPartiesData(parties) {
    return parties.map((party, index) => {
      return {
        ...party,
        isLivingSituationEditable: this.isLivingStatusEditable(
          party.currentHousingStatus
        ),
        livingSituationValue: this.getLivingSituationLabel(
          party.currentHousingStatus
        ),
        applicantLabel: this.isApplicationJoint
          ? "Applicant " + (index + 1)
          : "Applicant",
        livingSituationDescriptionVisible: party.livingStatusOther != null
      };
    });
  }

  // Used the map to get the label, or fall back to the currentHousingStatus itself
  getLivingSituationLabel(currentHousingStatus) {
    return (
      this.livingSituationsMap.get(currentHousingStatus) ?? currentHousingStatus
    );
  }

  // Determines if the party should be editable based on currentHousingStatus
  isLivingStatusEditable(currentHousingStatus) {
    return (
      currentHousingStatus !== "LIVING_STATUS_HOME_OWNER" &&
      hasEditPermission &&
      this.isDataReferred
    );
  }

  //check if the application is joint or single
  getJointApplication(sopData) {
    return sopData.parties.length > 1;
  }

  //method to filter SOP data based on RLA ocvId.
  filterSOPData(data) {
    return data?.parties?.filter((party) => party.ocvId === this.ocvId) ?? [];
  }

  //Method to call Edit model upon click on Edit button
  handleEditApplicant(e) {
    //In design under development - TBD
  }

  async navigateToRecordViewPage(event) {
    const recordIdToOpen = event.currentTarget.dataset.id;
    if (!this.tabId) {
      return;
    }

    const tabInfo = await getTabInfo(this.tabId);
    const primaryTabId = tabInfo.isSubtab ? tabInfo.parentTabId : tabInfo.tabId;

    // Open a record as a subtab of the current tab
    await openSubtab(primaryTabId, { recordId: recordIdToOpen, focus: true });
  }
}