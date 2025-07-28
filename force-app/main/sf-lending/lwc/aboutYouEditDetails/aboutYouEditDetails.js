import { wire, api } from "lwc";
import LightningModal from "lightning/modal";
import updateSOPAndPartyCallout from "@salesforce/apex/BOHController.updateSOPAndParty";
import SOP_IMAGE from "@salesforce/resourceUrl/SOP_Images";
import { handleErrorShowToast, showToast } from "c/utils";
import RefreshSOP from "@salesforce/messageChannel/RefreshSOP__c";
import { publish, MessageContext } from "lightning/messageService";

export default class AboutYouEditDetails extends LightningModal {
  @api recordId;
  @api partiesData;
  @api filteredSOPData;
  @api applicantData;
  @api editModelAction;
  @api isApplicationJoint;
  @api ocvId;
  editPartyData;
  editApplicantData;
  originalApplicantData;
  editSopPayload;
  dependentsFormatIncorrect = false;
  componentSpinner = false;
  sopProfileImage = `${SOP_IMAGE}/SOP_Profile.png`;
  sopRelationshipImage = `${SOP_IMAGE}/SOP_Relationship.png`;
  currentCircumstancesLabel = "Current Circumstances";
  aboutYouSuccessMessage = "Changes to About You were successfully saved.";
  dependantsIncorrectFormatError =
    "Your entry does not match the allowed pattern for Dependants.";

  @wire(MessageContext)
  messageContext;

  get soleIncomesAndShareFinancesOptions() {
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

  get isEditApplicantDetails() {
    return this.editModelAction === "editApplicant";
  }

  get isSoleIncomeEarnerVisible() {
    return (
      this.editPartyData?.shareFinanceWithPartner === "Yes" &&
      this.editPartyData?.soleIncomeEarner !== "" &&
      !this.isApplicationJoint
    );
  }

  get errorMessageLabel() {
    return this.editApplicantDetails
      ? this.editApplicantData.applicantLabel
      : this.currentCircumstancesLabel;
  }

  get errorMessage() {
    return (
      "The changes to the " +
      this.errorMessageLabel +
      " did not save. Please review and try again."
    );
  }

  connectedCallback() {
    this.handleEditModel();
  }

  handleEditModel() {
    this.editPartyData = JSON.parse(JSON.stringify(this.partiesData));
    this.editApplicantData = JSON.parse(JSON.stringify(this.applicantData));
    this.editSopPayload = JSON.parse(JSON.stringify(this.filteredSOPData));
  }

  //method to get input values
  handleCurrentCircumstancesChange(event) {
    const input = event.target;
    const field = input.dataset.id;
    this.editPartyData[field] = input.value;
    if (field === "soleIncomeEarner") {
      this.editPartyData.spouseEarnsIncome = input.value === "No";
    }
    // to maintain reactivity on data change
    this.editPartyData = { ...this.editPartyData };
  }

  handleDependentsChange(event) {
    const input = event.target;
    const field = input.dataset.id;
    this.editPartyData[field] = Number(input.value);
    this.dependentsFormatIncorrect = !input.reportValidity();
  }

  //Method to get Applicant Data values
  handleApplicantChange(event) {
    const input = event.target;
    const field = input.dataset.id;
    if (field === "currentHousingStatus") {
      this.editApplicantData.livingSituationDescriptionVisible =
        input.value === "LIVING_STATUS_OTHER";
      if (!this.editApplicantData.livingSituationDescriptionVisible) {
        this.editApplicantData.livingStatusOther = null;
      }
    }
    if (field === "livingStatusOther") {
      this.checkLivingSituationDescriptionValidity();
    }
    this.editApplicantData[field] = input.value;

    // to maintain reactivity on data change
    this.editApplicantData = { ...this.editApplicantData };
  }

  //Method to check validity of field in Applicant Data
  checkLivingSituationDescriptionValidity() {
    let fieldValityCheck = this.refs.livingStatusOther;
    fieldValityCheck.reportValidity();
    return fieldValityCheck.validity.valid;
  }

  //Method on save of edit page
  handleSave() {
    if (
      this.dependentsFormatIncorrect ||
      (this.isEditApplicantDetails &&
        this.editApplicantData.livingSituationDescriptionVisible &&
        !this.checkLivingSituationDescriptionValidity())
    ) {
      return;
    }
    this.editSopPayload.parties = this.isEditApplicantDetails
      ? [this.editApplicantData]
      : [this.editPartyData];
    this.editSopPayload.dependantsCount =
      this.editPartyData.partyDependantsCount;
    this.editSopPayload.isSOPDataUpdated = this.checkIsSOPDataUpdated(); //identifier to make callout for updateSOP API
    this.editSopPayload.isPartyDataUpdated = this.checkIsPartyDataUpdated(); //identifier to make callout for updateParty API
    this.updateSOPAndParty();
  }

  //method to check if shareFinanceWithPartner or soleIncomeEarner data is updated
  checkIsPartyDataUpdated() {
    return (
      this.editPartyData.shareFinanceWithPartner !==
        this.partiesData.shareFinanceWithPartner ||
      this.editPartyData.soleIncomeEarner !==
        this.partiesData.soleIncomeEarner ||
      this.editApplicantData.currentHousingStatus !==
        this.applicantData.currentHousingStatus ||
      this.editApplicantData.livingStatusOther !==
        this.applicantData.livingStatusOther
    );
  }

  //check if SOP dependents data is updated
  checkIsSOPDataUpdated() {
    return (
      this.editPartyData.partyDependantsCount !==
      this.partiesData.partyDependantsCount
    );
  }

  ///calling update sop and party api
  updateSOPAndParty() {
    this.componentSpinner = true;
    updateSOPAndPartyCallout({
      sopModel: this.editSopPayload,
      loanId: this.recordId,
      ocvId: this.ocvId
    })
      .then((response) => {
        if (
          response != null &&
          !response.isUpdateSOPFailed &&
          !response.isUpdatePartyFailed
        ) {
          //Displaying toast message when API callout success
          showToast(
            this,
            "",
            this.aboutYouSuccessMessage,
            "",
            "Success",
            "dismissable"
          );
        }
        //Displaying toast message when any one of the API fails
        else {
          handleErrorShowToast(
            this,
            "",
            "Error",
            this.errorMessage,
            "dismissable"
          );
        }
        //refreshing data by calling getSOPAPI to fetch the latest response and assign values to respective properties.
        publish(this.messageContext, RefreshSOP, {
          refresh: true
        });
        this.close("okay");
      })
      .catch((error) => {
        console.log(error);
        handleErrorShowToast(
          this,
          "",
          "Error",
          this.errorMessage,
          "dismissable"
        );
      })
      .finally(() => {
        this.componentSpinner = false;
      });
  }

  //Close modal on the click of cancel button
  handleClose() {
    this.close("okay");
  }
}
