import { LightningElement, wire, api } from "lwc";
import {
  EnclosingTabId,
  getTabInfo,
  openSubtab
} from "lightning/platformWorkspaceApi";

import getSOP from "@salesforce/apex/BOHController.getSOP";
import updateSOPAndPartyCallout from "@salesforce/apex/BOHController.updateSOPAndParty";
import hasEditPermission from "@salesforce/customPermission/Party_Edit";
import RLA_STATUS_APINAME from "@salesforce/schema/ResidentialLoanApplication.Status";
import RLA_ACCOUNT_OCVID from "@salesforce/schema/ResidentialLoanApplication.Account.OCV_ID__c";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { handleErrorShowToast, showToast } from "c/utils";

export default class AboutYouViewDetails extends LightningElement {
  @wire(EnclosingTabId) tabId;
  @api recordId;
  componentSpinner = false;
  showViewScreen = false;
  showEditScreen = false;
  filteredSOPData;
  originalPartyData = {};
  originalApplicantData = [];
  applicantData = [];
  applicationStatus;
  ocvId;
  isApplicationJoint = false;
  partiesData = {};
  dependentsFormatIncorrect = false;
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
  updateApisErrorMessage =
    "The changes to the About You section did not save. Please review and try again.";
  sopAPIErrorHeader = "An unexpected error has occurred, please try again";
  sopAPIErrorDetail =
    "An error has occurred. Please refresh and try again. If the problem persists, please contact your System Administrator.";
  dependantsIncorrectFormatError =
    "Your entry does not match the allowed pattern for Dependants.";
  aboutYouSuccessMessage = "The about you details were successfully updated.";

  get isSoleIncomeEarnerEditable() {
    return (
      this.isFieldEditable &&
      this.partiesData?.relationshipState === "In a relationship" &&
      this.partiesData?.soleIncomeEarner !== "" &&
      !this.isApplicationJoint
    );
  }

  get isSoleIncomeEarnerReadOnly() {
    return (
      this.partiesData?.relationshipState !== "In a relationship" ||
      this.isApplicationJoint
    );
  }

  get isRelationshipStateRequired() {
    return !this.isApplicationJoint;
  }

  get isFieldEditable() {
    return (
      hasEditPermission && this.isPartyDataAvailable && this.isDataReferred
    );
  }

  get isRelationshipStateEditable() {
    return (
      this.isFieldEditable &&
      this.partiesData?.relationshipState &&
      !this.isApplicationJoint
    );
  }

  get isDataReferred() {
    return this.applicationStatus === "STATE_REFERRED";
  }

  get isPartyDataAvailable() {
    return Object.entries(this.partiesData).length > 0;
  }

  get relationshipStatusOptions() {
    return [
      { label: "Single", value: "Single" },
      { label: "In a relationship", value: "In a relationship" }
    ];
  }

  get soleIncomesOptions() {
    return [
      { label: "Yes", value: "Yes" },
      { label: "No", value: "No" }
    ];
  }

  get livingSituationOptions() {
    return [
      { label: "Renter", value: "LIVING_STATUS_RENT" },
      { label: "Boarder", value: "LIVING_STATUS_BOARD" },
      {
        label: "Living with family or friends",
        value: "LIVING_STATUS_WITH_PARENTS"
      },
      { label: "Caravanning or Mobile Home", value: "LIVING_STATUS_CARAVAN" },
      { label: "Other", value: "LIVING_STATUS_OTHER" }
    ];
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
      //transforming parties data on applicant level
      result.parties = this.transformPartiesData(result.parties);

      // to check if application is joint or not.
      this.isApplicationJoint = this.getJointApplication(result);

      this.filteredSOPData = JSON.parse(JSON.stringify(result));

      // assigning the primary party to display data
      this.partiesData = this.filterSOPData(result)?.[0] ?? {};

      //assign values to display applicants Data
      if (this.isApplicationJoint) {
        this.applicantData = result?.parties; // for multiple applicants
      } else {
        this.applicantData = [this.partiesData]; // for single applicant filtered data
      }

      //assigning original data for parties and applicant
      this.originalPartyData = { ...this.partiesData };
      this.originalApplicantData = JSON.parse(
        JSON.stringify(this.applicantData)
      );
      this.showViewScreen = true;
      this.showEditScreen = false;
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
        applicantLabel: "Applicant " + (index + 1),
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
    return sopData?.parties?.length > 1;
  }

  //method to filter SOP data based on RLA ocvId.
  filterSOPData(data) {
    return data?.parties?.filter((party) => party.ocvId === this.ocvId) ?? [];
  }

  //method to toggle between view and edit screen
  toggleScreen() {
    this.showEditScreen = !this.showEditScreen;
    this.showViewScreen = !this.showViewScreen;
  }

  //method to handle cancel functionality
  handleCancel() {
    this.partiesData = { ...this.originalPartyData };
    this.applicantData = JSON.parse(JSON.stringify(this.originalApplicantData));
    this.toggleScreen();
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

  //method to assign old data on error cases
  assignExistingData() {
    this.partiesData = { ...this.originalPartyData };
    this.applicantData = JSON.parse(JSON.stringify(this.originalApplicantData));
  }

  //method to get input values
  handleChange(event) {
    const field = event.target.dataset.id;
    const input = event.target;
    this.partiesData[field] = input.value;
    this.dependentsFormatIncorrect =
      field === "partyDependantsCount" && !input.checkValidity();
    if (field === "soleIncomeEarner") {
      this.partiesData.spouseEarnsIncome = input.value === "No";
    }
  }

  //Method to get Applicant Data values
  handleLivingSituationChange(event) {
    const field = event.target.dataset.id;
    const input = event.target;
    const index = event.target.dataset.index;
    if (field === "currentHousingStatus") {
      this.applicantData[index].livingSituationDescriptionVisible =
        input.value === "LIVING_STATUS_OTHER";
    }
    this.applicantData[index][field] = input.value;

    // to maintain reactivity on data change
    this.applicantData = [...this.applicantData];
  }

  //Method to check validity of field in Applicant Data
  checkLivingSituationDescriptionValidity(data) {
    return data.some(
      (party) =>
        party.livingSituationDescriptionVisible &&
        (!party.livingStatusOther || party.livingStatusOther.trim() === "")
    );
  }

  //method on save of edit page
  handleSave() {
    if (
      this.dependentsFormatIncorrect ||
      this.checkLivingSituationDescriptionValidity(this.applicantData)
    ) {
      return;
    }
    this.filteredSOPData.parties = this.mergeWithList(
      this.applicantData,
      this.partiesData
    );
    this.filteredSOPData.dependantsCount =
      this.partiesData.partyDependantsCount;
    this.filteredSOPData.isSOPDataUpdated = this.checkIsSOPDataUpdated();
    this.filteredSOPData.isPartyDataUpdated = this.checkIsPartyDataUpdated();
    this.updateSOPAndParty();
  }

  //method to merge parties data and applicant data list
  mergeWithList(applicantDetails, partyDetails) {
    return applicantDetails.map((item) => {
      // Check if ocvId matches between list1 and the single object in partyDetails
      if (item.ocvId === partyDetails.ocvId) {
        // Merge the necessary fields from partyDetails into the item from list1
        return {
          ...item, // Retain the fields of the item from applicantDetails
          partyDependantsCount: partyDetails.partyDependantsCount, // Override specific fields
          relationshipState: partyDetails.relationshipState,
          soleIncomeEarner: partyDetails.soleIncomeEarner,
          spouseEarnsIncome: partyDetails.spouseEarnsIncome
        };
      }
      return item; // Return the item unchanged if no match
    });
  }

  //method to check if relationshipState or soleIncomeEarner data is updated
  checkIsPartyDataUpdated() {
    const isCurrentHousingStatusUpdated = this.applicantData.some(
      (item, index) => {
        const originalItem = this.originalApplicantData[index];

        // Compare the currentHousingStatus field and living status other for each object
        return (
          item.currentHousingStatus !== originalItem.currentHousingStatus ||
          item.livingStatusOther !== originalItem.livingStatusOther
        );
      }
    );
    return (
      this.partiesData.relationshipState !==
        this.originalPartyData.relationshipState ||
      this.partiesData.soleIncomeEarner !==
        this.originalPartyData.soleIncomeEarner ||
      isCurrentHousingStatusUpdated
    );
  }

  //check if SOP dependents data is updated
  checkIsSOPDataUpdated() {
    return (
      this.partiesData.partyDependantsCount !==
      this.originalPartyData.partyDependantsCount
    );
  }

  //calling update sop and party api
  updateSOPAndParty() {
    this.componentSpinner = true;
    updateSOPAndPartyCallout({
      sopModel: this.filteredSOPData,
      loanId: this.recordId
    })
      .then((response) => {
        if (
          response != null &&
          !response.isUpdateSOPFailed &&
          !response.isUpdatePartyFailed
        ) {
          //refreshing data by calling getSOPAPI to fetch the latest response and assign values to respective properties.
          this.refreshData();
          //Displaying toast message when API callout success
          showToast(
            this,
            "",
            this.aboutYouSuccessMessage,
            "",
            "Success",
            "dismissable"
          );
          this.toggleScreen();
        }
        //Displaying toast message when any one of the API fails
        else if (
          !response?.isUpdateSOPFailed ||
          !response?.isUpdatePartyFailed
        ) {
          this.refreshData();
          let errorMessage = response.isUpdateSOPFailed
            ? this.updateSOPErrorMessage
            : this.updatePartyErrorMessage;
          handleErrorShowToast(this, "", "Error", errorMessage, "dismissable");
        }
        //Displaying toast message and assigning back the old values when the callout is failed or network issue
        else {
          this.assignExistingData();
          handleErrorShowToast(
            this,
            "",
            "Error",
            this.updateApisErrorMessage,
            "dismissable"
          );
        }
      })
      .catch((error) => {
        this.assignExistingData();
        handleErrorShowToast(
          this,
          "",
          "Error",
          this.updateApisErrorMessage,
          "dismissable"
        );
      })
      .finally(() => {
        this.componentSpinner = false;
      });
  }

  refreshData() {
    this.showViewScreen = false;
    this.loadGetSOPData();
  }
}
