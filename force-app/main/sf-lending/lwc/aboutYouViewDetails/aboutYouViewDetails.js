import { LightningElement, wire, api } from "lwc";
import getSOP from "@salesforce/apex/BOHController.getSOP";
import updateSOPAndPartyCallout from "@salesforce/apex/BOHController.updateSOPAndParty";
import hasEditPermission from "@salesforce/customPermission/SOP_Edit";
import RLA_STATUS_APINAME from "@salesforce/schema/ResidentialLoanApplication.Status";
import RLA_ACCOUNT_OCVID from "@salesforce/schema/ResidentialLoanApplication.Account.OCV_ID__c";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { handleErrorShowToast, showToast } from "c/utils";

export default class AboutYouViewDetails extends LightningElement {
  @api recordId;
  componentSpinner = false;
  showViewScreen = false;
  showEditScreen = false;
  filteredSOPData;
  originalPartyData = {};
  applicationStatus;
  ocvId;
  isApplicationJoint = false;
  partiesData = {};
  dependentsFormatIncorrect = false;
  showGetSOPErrorScreen = false;

  updateSOPErrorMessage =
    "The changes to the dependants did not save. Please try again.";
  updatePartyErrorMessage =
    "The changes to the Sole Income Earner and / or relationship status did not save. Please try again.";
  updateApisErrorMessage =
    "The changes to About You did not save. Please try again.";
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
      this.isApplicationJoint = this.getJointApplication(result); // to check if application is join or not.
      this.filteredSOPData = JSON.parse(JSON.stringify(result));
      this.filteredSOPData.parties = this.filterSOPData(result); // filtered the sop data based on ocvId in new instance.
      this.partiesData = this.filteredSOPData?.parties[0] ?? {}; // assigning the primary party to display data
      this.originalPartyData = { ...this.partiesData };
      this.showViewScreen = true;
      this.showEditScreen = false;
    } catch (error) {
      this.filteredSOPData = null;
      this.showGetSOPErrorScreen = true;
    } finally {
      this.componentSpinner = false;
    }
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
    this.toggleScreen();
  }

  //method to assign old data on error cases
  assignExistingData() {
    this.partiesData = { ...this.originalPartyData };
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

  //method on save of edit page
  handleSave() {
    if (this.dependentsFormatIncorrect) {
      return;
    }
    this.filteredSOPData.parties[0] = this.partiesData;
    this.filteredSOPData.isSOPDataUpdated = this.checkIsSOPDataUpdated();
    this.filteredSOPData.isPartyDataUpdated = this.checkIsPartyDataUpdated();
    this.updateSOPAndParty();
  }

  //method to check if relationshipState or soleIncomeEarner data is updated
  checkIsPartyDataUpdated() {
    return (
      this.partiesData.relationshipState !==
        this.originalPartyData.relationshipState ||
      this.partiesData.soleIncomeEarner !==
        this.originalPartyData.soleIncomeEarner
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
