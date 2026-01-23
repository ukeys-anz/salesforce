import { LightningElement, api, track, wire } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import getOpportunityLineItems from "@salesforce/apex/LaunchAppOnOppController.getOpportunityLineItems";
import createApplication from "@salesforce/apex/LaunchAppOnOppController.createApplication";
import populateRecordTypeWrapper from "@salesforce/apex/LaunchAppOnOppController.populateRecordTypeWrapper";
import validateOpportunity from "@salesforce/apex/LaunchAppOnOppController.validateOpportunity";
import getAMBITResponse from "@salesforce/apex/LaunchAppOnOppController.getAMBITResponse";
import validateSelectedOppLineItems from "@salesforce/apex/LaunchAppOnOppController.validateSelectedOppLineItems";
import ConfirmationModal from "c/confirmationModal";
import { NavigationMixin } from "lightning/navigation";
import { publish, MessageContext } from "lightning/messageService";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";
import { showToast, handleErrorShowToast } from "c/utils"; // Importing the methods from Utils.js
export default class LaunchAppOnOpp extends NavigationMixin(LightningElement) {
  disableNext = true;
  showRecordTypes = true;
  @track
  data = [];
  @track
  isLoading = false;
  CONSTANT = {
    HEADER_TEXT: "Where would you like to launch this application?",
    CANCEL: "Cancel",
    SAVE: "Save",
    BACK: "Back",
    PRODUCT: "Product",
    UNITPRICE: "Unit Price",
    FUNDINGPURPOSE: "Funding Purpose",
    OPP_PRODUCT: "Sequence"
  };
  buttonLabel;
  noOppItemsMessage = "No opportunity line items found";
  showTable = false;
  @track selectedRowIds = [];
  allRowsSelected = false;
  @track
  recordTypeList = [];
  allowMultiple;
  _recordId;
  invalidOpportunity = false;
  @track validationMessage = [];
  @api
  set recordId(value) {
    this._recordId = value;
    this.getAppFormRecordTypeWrapper();
  }
  recordTypeRec;
  recordTypeIdValue;

  get recordId() {
    return this._recordId;
  }

  get disableSave() {
    return this.selectedRowIds.length > 0 ? false : true;
  }

  @wire(MessageContext)
  messageContext;

  getAppFormRecordTypeWrapper() {
    this.isLoading = true;
    populateRecordTypeWrapper({
      oppId: this._recordId
    })
      .then((result) => {
        if (result) {
          this.recordTypeList = result;
          this.showRecordTypes = this.recordTypeList.length > 0;
        } else {
          handleErrorShowToast(
            this,
            "Error",
            result,
            "Loan Origination Systems could not be retrieved.",
            "dismissable"
          );
        }
      })
      .catch((error) => {
        handleErrorShowToast(
          this,
          "Error",
          error,
          "Error fetching Loan Origination Systems.",
          "dismissable"
        );
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  handleClick(event) {
    this.isLoading = true;
    this.invalidOpportunity = false;
    this.validationMessage = [];
    this.buttonLabel = event.target.label;
    const row = this.recordTypeList.find(
      (recType) => recType.recordTypeName === this.buttonLabel
    );
    this.allowMultiple = row.allowMultiple;
    this.showRecordTypes = false;
    this.selectedRowIds = [];
    this.showTable = false;
    this.validateOpportunityDetails(row);
  }

  validateOpportunityDetails(row) {
    const selectedRecordType = row.recordTypeName;
    switch (selectedRecordType) {
      case "AMBIT":
        validateOpportunity({
          oppId: this._recordId
        })
          .then((result) => {
            if (result) {
              this.isLoading = false;
              this.invalidOpportunity = true;
              this.validationMessage.push({
                id: this.validationMessage.length + 1,
                body: result
              });
            } else {
              this.getOpportunityLineItemsDetails();
            }
          })
          .catch((error) => {
            this.showToast("Error", "Error", error.body.message, "Dismissable");
            this.isLoading = false;
          });
        break;
      default:
        this.getOpportunityLineItemsDetails();
    }
  }

  getOpportunityLineItemsDetails() {
    getOpportunityLineItems({
      oppId: this._recordId,
      recordTypeName: this.buttonLabel
    })
      .then((result) => {
        this.showTable = result && result.length > 0;
        if (result.length > 0) {
          this.data = result;
        } else {
          this.invalidOpportunity = true;
          this.validationMessage.push({
            id: this.validationMessage.length + 1,
            body: this.noOppItemsMessage
          });
        }
      })
      .catch((error) => {
        handleErrorShowToast(
          this,
          "Error",
          error,
          "Error fetching Opportunity Line Items.",
          "dismissable"
        );
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  handleBack() {
    this.showRecordTypes = true;
    this.data = [];
    this.selectedRowIds = [];
  }

  // Handle the individual checkbox/radio selection
  handleChange(event) {
    const rowId = event.target.dataset.id;
    const name = event.target.dataset.name;
    const checked = event.target.checked;

    // Find the row by id and update its selected state for checkbox
    const row = this.data.find((item) => item.oppLineItemId === rowId);
    if (row) {
      row.isSelected = checked;
    }
    // Find the rows and update their selected/unselected state for radio
    if (name === "radioGroup") {
      this.data.forEach((x) => {
        x.isSelected = x.oppLineItemId === rowId;
      });
    }
    this.getSelectedOppLineItemIds();
  }

  // Handle the 'Select All' checkbox selection
  handleSelectAll(event) {
    const checked = event.target.checked;

    // Update all rows selected state based on 'Select All' checkbox
    this.data.forEach((row) => {
      row.isSelected = checked;
    });
    this.getSelectedOppLineItemIds();
  }

  getSelectedOppLineItemIds() {
    this.selectedRowIds = this.data
      .filter((row) => row.isSelected)
      .map((row) => row.oppLineItemId);
    this.allRowsSelected = this.selectedRowIds.length === this.data.length;
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleSave() {
    this.recordTypeRec = this.recordTypeList.filter(
      (recType) => recType.recordTypeName === this.buttonLabel
    );
    this.recordTypeIdValue = this.recordTypeRec?.[0]?.recordTypeId ?? "";
    switch (this.recordTypeRec?.[0]?.recordTypeName) {
      case "AMBIT":
        this.isLoading = true;
        this.processAmbitFlow();
        break;
      default:
        this.checkDuplicateProducts();
    }
  }

  processAmbitFlow() {
    getAMBITResponse({
      oppId: this._recordId,
      oppLineItemId: this.selectedRowIds[0]
    })
      .then((result) => {
        if (result === true) {
          this.createAFAndAFP();
        }
      })
      .catch((error) => {
        handleErrorShowToast(
          this,
          "Error",
          "",
          error.body.message,
          "Dismissable"
        );
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  checkDuplicateProducts() {
    validateSelectedOppLineItems({
      oppId: this._recordId,
      selectedLineItemIds: this.selectedRowIds
    }).then((result) => {
      if (result && result.length > 0) {
        const productNames = [
          ...new Set(
            result
              .map(
                (afp) =>
                  afp.Opportunity_Product__r?.Opp_Product_name__c ??
                  afp.Product?.Name
              )
              .filter((name) => name !== "")
          )
        ];

        const productNamesLabel =
          productNames.length > 0
            ? `${productNames.join(", ")}`
            : "Selected Product(s): ";

        let content = `The selected product(s) <b>${productNamesLabel}</b> were already launched previously. Do you want to continue?`;

        this.openModal(
          "small",
          "Product(s) selected already launched",
          content
        );
      } else {
        this.createAFAndAFP();
      }
    });
  }

  openModal(size, description, content) {
    ConfirmationModal.open({
      size: size,
      description: description,
      content: content,
      onselect: (e) => {
        e.stopPropagation();
        if (e.detail === "confirm") {
          this.createAFAndAFP();
        }
        if (e.detail === "cancel") {
          this.isLoading = false;
          this.showTable = true;
        }
      }
    });
  }

  createAFAndAFP() {
    this.isLoading = true;
    this.showTable = false;
    createApplication({
      oppId: this._recordId,
      oppLineItemIds: this.selectedRowIds,
      recordTypeId: this.recordTypeIdValue
    })
      .then((result) => {
        this.dispatchEvent(new CloseActionScreenEvent());
        if (result && result.length > 0) {
          this.refresh();
          showToast(
            this,
            "Success",
            "Application Created Successfully",
            "",
            "success",
            "sticky"
          );
          this.openOriginationSystemLink(this.recordTypeRec[0]?.url);
        } else {
          handleErrorShowToast(
            this,
            "Error",
            result,
            "Some error occurred while creating the application.",
            "dismissable"
          );
        }
      })
      .catch((error) => {
        handleErrorShowToast(
          this,
          "Error",
          error,
          "Error creating the application.",
          "dismissable"
        );
      })
      .finally(() => {
        this.isLoading = false;
      });
  }

  refresh() {
    publish(this.messageContext, CloseModal, {
      name: "launchAppOnOpp"
    });
  }

  openOriginationSystemLink(url) {
    if (!url) {
      return;
    }
    if (url.includes("{OppProductId}")) {
      url = url.replace("{OppProductId}", this.selectedRowIds[0]);
    }
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: url
      }
    });
  }
}
