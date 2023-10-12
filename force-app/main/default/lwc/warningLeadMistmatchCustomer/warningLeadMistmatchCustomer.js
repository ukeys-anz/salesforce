import { LightningElement, track, api, wire } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { getRecord } from "lightning/uiRecordApi";
// import controller method
import isLeadMisMatchCustomer from "@salesforce/apex/CCRMLeadConversionActions.isLeadMisMatchCustomer";
// import static resource
import WARNING_ICON from "@salesforce/resourceUrl/Warning_Icon";
// import custom labels
import MLCRM_Lead_MisMatch_Warning_Message from "@salesforce/label/c.MLCRM_Lead_MisMatch_Warning_Message";

const warningMsgConstant = "Warning";

export default class WarningLeadMistmatchCustomer extends LightningElement {
  //Initial Declaration
  @api recordId;
  @track misMatchWarning = false; //CC-857
  @track misMatchLeadDetailsMessage = null; //CC-857
  warningSignUrl = WARNING_ICON; //CC-857
  warningMsgConstant = warningMsgConstant; //CC-857
  @track leads;
  error;

  closeAction() {
    this.misMatchWarning = false;
    this.misMatchLeadDetailsMessage = null;
    this.dispatchEvent(new CloseActionScreenEvent());
  }

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      "Lead.FirstName",
      "Lead.MiddleName",
      "Lead.LastName",
      "Lead.Home_Phone__c",
      "Lead.Work_Phone__c",
      "Lead.MobilePhone",
      "Lead.Email",
      "Lead.Street",
      "Lead.City",
      "Lead.State",
      "Lead.Country",
      "Lead.PostalCode",
      "Lead.FinServ__RelatedAccount__c"
    ]
  })
  getLeadRecord({ data, error }) {
    if (data) {
      this.leads = data;
      this.isLeadMisMatchCustomerAction();
    } else if (error) {
      this.leads = undefined;
      this.error = error;
    }
  }

  isLeadMisMatchCustomerAction() {
    //CC-857 Check and show warning if the lead details are mis matching with customer details
    isLeadMisMatchCustomer({
      recordId: this.recordId
    })
      .then((result) => {
        if (result != null) {
          this.misMatchWarning = true;
          this.misMatchLeadDetailsMessage =
            MLCRM_Lead_MisMatch_Warning_Message +
            result.replaceAll("\n", "<br>");
        } else {
          this.closeAction();
        }
      })
      .catch((error) => {
        this.error = error;
        this.closeAction();
      });
  }
}
