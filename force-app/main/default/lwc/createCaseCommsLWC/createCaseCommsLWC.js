import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import getTemplateList from "@salesforce/apex/CreateCommsController.getTemplateList";
import fetchTemplateFields from "@salesforce/apex/CreateCommsController.fetchTemplateFields";
import createComms from "@salesforce/apex/CreateCommsController.createComms";
const ERROR_UNKNOWN_TITLE = "An error has occurred.";
const columns = [
    { label: "Field Name", fieldName: "fieldLabel" ,  wrapText: true },
    { label: "Enter Value" , fieldName: "fieldValue" , wrapText: true , editable: true }
  ];
export default class CreateComplaintLWC extends NavigationMixin(
    LightningElement
  ) {
    @api recordId;
    @track template;
    showOptions = false;
    templateList = [];
    showTemplateDetails = false;
    @track fieldData = [];
    columns = columns;
    isEmail=false;
    isLetter=false;
    lineItemList=[];

    showModal = false;
    modalMessage = ERROR_UNKNOWN_TITLE;
    modalHeader = "Error";
    draftValues = [];

    showSuccess = false;

    connectedCallback() {
        console.log('getTemplateOptions');
        getTemplateList()
        .then((result) => {
            console.log('getTemplateList');
            let tempList = result;

           for(let i=0; i<tempList.length; i++){
                console.log('tempList:'+tempList[i]);
                this.templateList.push( { label: tempList[i] , value: tempList[i] } );
            }
            this.showOptions = true;
        })
        .catch((error) => {
            console.log("error:" + error);
            console.log("errorbody:" + JSON.stringify(error));
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
    }
    handleTemplateSelection(event){
        this.template = event.detail.value;
        this.showSuccess = false;
        console.log('template:' + this.template);
        fetchTemplateFields({template: this.template})
        .then((result) => {
            let data = result;    
            console.log('data:'+JSON.stringify(data)); 
            this.fieldData = [];    
            this.fieldData = data;
            this.lineItemList = [];
            for(let i =0 ; i<data.length ; i++){
               this.lineItemList.push({fieldLabel : data[i].fieldLabel , fieldValue: '' , fieldId: '' }) ;
            }
            this.showTemplateDetails = true;
        })
        .catch((error) => {
            console.log("error:" + error);
            console.log("errorbody:" + JSON.stringify(error));
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
        }) 
    }

    handlelineItemUpdate(event){
            let draftlineItem = event.detail.draftValues;
            let index = draftlineItem[0].fileId.split("row-");
            this.lineItemList[index[1]].fieldValue = draftlineItem[0].fieldValue;
            console.log('updated fieldData:'+JSON.stringify(this.lineItemList));
    }

    handleEmail(event){
        this.isEmail = event.target.checked;
    }

    handleLetter(event){
        this.isLetter= event.target.checked;
    }

    validateFields(){
        console.log('updated fieldData:'+JSON.stringify(this.lineItemList));
        console.log('isEmail:'+this.isEmail);
        console.log('isLetter:'+this.isLetter);
        console.log('caserecordid :'+this.recordId);

        if(!this.isEmail && !this.isLetter){
            let msg = 'Please select atleast one of Email or Letter for this comms';
            this.openModal(msg);
        }else{
            createComms({caseId: this.recordId, isEmail: this.isEmail , isLetter: this.isLetter ,template: this.template, lineItems: this.lineItemList})
            .then((result) => {
                this.showSuccess = true;
                this.showTemplateDetails = false;
            })
            .catch((error)=>{
            console.log("errorbody:" + JSON.stringify(error));
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

            })
        }


      }

    openModal(msg) {
      //  this.template.querySelector(".slds-card").classList.add("slds-hide");
        this.modalMessage = msg;
        this.showModal = true;
      }
    
      closeModal() {
       // this.template.querySelector(".slds-hide").classList.remove("slds-hide");
        this.showModal = false;
      }
  }