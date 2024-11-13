import { LightningElement, api, track, wire } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import OPPORTUNITY_ID from "@salesforce/schema/Opportunity.Opp_Id__c";
import SOURCE_SYSTEM_ID from "@salesforce/schema/Opportunity.Account.Source_System_ID__c";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import getOpportunityLineItems from "@salesforce/apex/LaunchAppOnOppController.getOpportunityLineItems";
import createApplication from "@salesforce/apex/LaunchAppOnOppController.createApplication";
import BBD_Link from "@salesforce/label/c.BBD_Link";
import CLP_Link from "@salesforce/label/c.CLP_Link";
import { NavigationMixin } from "lightning/navigation";
import { publish, MessageContext } from "lightning/messageService";
import CloseModal from "@salesforce/messageChannel/CloseModal__c";

const columns = [
  {
    label: "Product",
    fieldName: "productURL",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "productName"
      },
      target: "_self"
    },
    sortable: true
  },
  {
    label: "Unit Price",
    fieldName: "unitPrice",
    type: "currency",
    cellAttributes: { alignment: "left" }
  },
  { label: "Funding Purpose", fieldName: "fundingPurpose" }
];
const fields = [OPPORTUNITY_ID, SOURCE_SYSTEM_ID];

export default class LaunchAppOnOpp extends NavigationMixin(LightningElement) {
  disableNext = true;
  disableSave = true;
  showRadio = true;
  @api recordId;
  @track
  data = [];
  @track
  columns = columns;
  isLoading = true;
  CONSTANT = {
    HEADER_TEXT: "Where would you like to launch this application?",
    AMBIT: "AMBIT",
    BBD: "BBD",
    CLP: "CLP",
    INTERNAL_APPLICATION: "Internal Application",
    CANCEL: "Cancel",
    SAVE: "Save",
    BACK: "Back"
  };
  selectedProductIds = [];
  buttonLabel;
  oppId;
  sourceSystemId;
  originationSystemLinks = [
    {
      BBD: BBD_Link
    },
    { CLP: CLP_Link }
  ];
  noOppItemsMessage = "No opportunity line items found";
  showTable = false;
  @track appFormRecordTypes = [];

  @wire(MessageContext)
  messageContext;

  @wire(getObjectInfo, { objectApiName: "ApplicationForm" })
  getObjectInfo({ error, data }) {
    if (data) {
      this.appFormRecordTypes = [];
      for (let key in data.recordTypeInfos) {
        if (data.recordTypeInfos[key].name !== "Master") {
          this.appFormRecordTypes.push({
            value: key,
            label: data.recordTypeInfos[key].name
          });
        }
      }
    } else if (error) {
      this.showToast("Error", "Error", error.body.message, "Dismissable");
      this.appFormRecordTypes = [];
    }
  }

  @wire(getRecord, { recordId: "$recordId", fields }) record({ data }) {
    if (data) {
      this.oppId = getFieldValue(data, OPPORTUNITY_ID);
      this.sourceSystemId = getFieldValue(data, SOURCE_SYSTEM_ID);
    }
  }

  handleClick(event) {
    this.buttonLabel = event.target.label;
    this.showRadio = this.buttonLabel ? false : true;
    if (this.showRadio) {
      return;
    }
    getOpportunityLineItems({
      oppId: this.recordId
    })
      .then((result) => {
        this.showTable = result && result.length > 0;
        if (result) {
          this.data = result;
        }
      })
      .catch((error) => {
        this.showToast("Error", "Error", error.body.message, "Dismissable");
      })
      .finally(() => {
        this.isLoading = false;
      });
  }
  handleBack() {
    this.showRadio = true;
  }

  getSelectedRow(event) {
    this.selectedProductIds = [];
    const selectedRows = event.detail.selectedRows;
    this.disableSave = selectedRows.length > 0 ? false : true;
    for (let row in selectedRows) {
      if (selectedRows[row].productId) {
        this.selectedProductIds.push(selectedRows[row].productId);
      }
    }
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  handleSave() {
    this.isLoading = true;
    let recordTypeRec = this.appFormRecordTypes.filter(
      (recType) => recType.label === this.buttonLabel
    );
    let recordTypeId =
      recordTypeRec && recordTypeRec.length > 0 ? recordTypeRec[0].value : "";

    createApplication({
      oppId: this.recordId,
      productIds: this.selectedProductIds,
      recordTypeId: recordTypeId
    })
      .then((result) => {
        if (result && result.length > 0) {
          this.dispatchEvent(new CloseActionScreenEvent());
          this.refresh();
          this.showToast(
            "Success",
            "Success",
            "Application Created Successfully",
            "Dismissable"
          );
          this.openOriginationSystemLink();
        } else {
          this.dispatchEvent(new CloseActionScreenEvent());
          this.showToast(
            "Error",
            "Error",
            "Some error occured!",
            "Dismissable"
          );
        }
      })
      .catch((error) => {
        this.showToast("Error", "Error", error.body.message, "Dismissable");
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

  // method to show toast message
  showToast(title, variant, message, mode) {
    const toastEvent = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: mode
    });
    this.dispatchEvent(toastEvent);
  }
  openOriginationSystemLink() {
    let systemName = this.buttonLabel;
    let url;
    this.originationSystemLinks.forEach(function (record) {
      if (record[systemName]) {
        url = record[systemName];
      }
    });
    this.navigateToUrl(url, systemName);
  }
  navigateToUrl(url, systemName) {
    let sourceSystemId = this.sourceSystemId;
    let oppId = this.oppId;
    if (!url) {
      return;
    }
    if (systemName === "BBD") {
      url = url
        .replace("{!Account.Source_System_ID__c}", sourceSystemId)
        .replace("{!Opportunity.Opp_Id__c}", oppId);
    }
    this[NavigationMixin.Navigate]({
      type: "standard__webPage",
      attributes: {
        url: url
      }
    });
  }
}
