import { LightningElement, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import getTemplateList from "@salesforce/apex/CreateCommsController.getTemplateList";
import fetchTemplateFields from "@salesforce/apex/CreateCommsController.fetchTemplateFields";
import createComms from "@salesforce/apex/CreateCommsController.createComms";
import { getRecord } from "lightning/uiRecordApi";
import CASE_OWNER from "@salesforce/schema/Case.IsOwner__c";
import CASE_OWNER_Manager from "@salesforce/schema/Case.Is_Owner_s_Line_Manager_Me__c";
import { CurrentPageReference } from "lightning/navigation";
const ERROR_UNKNOWN_TITLE = "An error has occurred.";
const columns = [
  { label: "Description", fieldName: "fieldDesc", wrapText: true },
  {
    label: "Enter your inputs",
    fieldName: "fieldValue",
    wrapText: true,
    editable: true
  }
];
export default class CreateComplaintLWC extends NavigationMixin(
  LightningElement
) {
  @wire(CurrentPageReference) currentPageReference;
  recordId;
  @track template;
  showOptions = false;
  templateList = [];
  showTemplateDetails = false;
  @track fieldData = [];
  columns = columns;
  isEmail = false;
  isLetter = false;
  lineItemList = [];
  CaseOwner = false;
  OwnersManager = false;

  showModal = false;
  modalMessage = ERROR_UNKNOWN_TITLE;
  modalHeader = "Error";
  draftValues = [];

  showSuccess = false;
  showAuthError = false;

  connectedCallback() {
    this.recordId = this.currentPageReference.state.c__recordId;
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [CASE_OWNER, CASE_OWNER_Manager]
  })
  wiredProject({ data }) {
    if (data) {
      this.CaseOwner = data.fields.IsOwner__c.value;
      this.OwnersManager = data.fields.Is_Owner_s_Line_Manager_Me__c.value;
      if (this.CaseOwner || this.OwnersManager) {
        getTemplateList()
          .then((result) => {
            let tempList = result;
            for (let i = 0; i < tempList.length; i++) {
              this.templateList.push({
                label: tempList[i],
                value: tempList[i]
              });
            }
            this.showOptions = true;
          })
          .catch((error) => {
            let errorMessage = "Failed to retrieve templates";
            if (error.body) {
              if (Array.isArray(error.body)) {
                errorMessage = error.body.map((e) => e.message).join(", ");
              } else if (typeof error.body.message === "string") {
                errorMessage = error.body.message;
              }
            }
            const toastEvent = new ShowToastEvent({
              message: errorMessage,
              variant: "error"
            });
            this.dispatchEvent(toastEvent);
          });
      } else {
        let msg =
          "You are not authorised. Please contact the case owner or their line manager if a letter or email is required to be created for this case.";
        this.openModal(msg);
      }
    }
  }

  handleTemplateSelection(event) {
    this.template = event.detail.value;
    this.showSuccess = false;
    fetchTemplateFields({ template: this.template, caseId: this.recordId })
      .then((result) => {
        let data = result;
        this.fieldData = [];
        this.fieldData = data;
        this.lineItemList = [];
        for (let i = 0; i < data.length; i++) {
          this.lineItemList.push({
            fieldDesc: data[i].fieldDesc,
            fieldLabel: data[i].fieldLabel,
            fieldValue: data[i].fieldValue,
            fieldId: ""
          });
        }
        this.showTemplateDetails = true;
      })
      .catch((error) => {
        let errorMessage = "Failed to retrieve template fields";
        if (error.body) {
          if (Array.isArray(error.body)) {
            errorMessage = error.body.map((e) => e.message).join(", ");
          } else if (typeof error.body.message === "string") {
            errorMessage = error.body.message;
          }
        }
        const toastEvent = new ShowToastEvent({
          message: errorMessage,
          variant: "error"
        });
        this.dispatchEvent(toastEvent);
      });
  }

  handlelineItemUpdate(event) {
    let draftlineItem = event.detail.draftValues;
    let index = draftlineItem[0].fileId.split("row-");
    this.lineItemList[index[1]].fieldValue = draftlineItem[0].fieldValue;
  }

  handleEmail(event) {
    this.isEmail = event.target.checked;
  }

  handleLetter(event) {
    this.isLetter = event.target.checked;
  }

  validateFields() {
    if ((!this.isEmail && !this.isLetter) || (this.isEmail && this.isLetter)) {
      let msg =
        "Please select one of Email or Letter for sending this communication";
      this.openModal(msg);
    } else {
      let otherDetails = [];
      otherDetails.push({
        caseId: this.recordId,
        isEmail: this.isEmail,
        isLetter: this.isLetter,
        template: this.template
      });
      createComms({
        otherDetails: otherDetails,
        caseId: this.recordId,
        isEmail: this.isEmail,
        isLetter: this.isLetter,
        template: this.template,
        lineItems: this.lineItemList
      })
        .then((result) => {
          this.showOptions = false;
          this.showTemplateDetails = false;
          this.showSuccess = true;
          let commId = result;
          this[NavigationMixin.Navigate](
            {
              type: "standard__recordPage",
              attributes: {
                recordId: commId,
                objectApiName: "CaseComms__c",
                actionName: "view"
              }
            },
            ["replace"]
          );
        })
        .catch((error) => {
          let errorMessage = "Failed to retrieve template fields";
          if (error.body) {
            if (Array.isArray(error.body)) {
              errorMessage = error.body.map((e) => e.message).join(", ");
            } else if (typeof error.body.message === "string") {
              errorMessage = error.body.message;
            }
          }
          const toastEvent = new ShowToastEvent({
            message: errorMessage,
            variant: "error"
          });
          this.dispatchEvent(toastEvent);
        });
    }
  }

  openModal(msg) {
    this.modalMessage = msg;
    this.showModal = true;
  }

  closeModal() {
    this.showModal = false;
  }
}
