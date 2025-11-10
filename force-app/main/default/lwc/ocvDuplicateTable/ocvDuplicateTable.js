import { LightningElement, api } from "lwc";
import getAllCustomersByOCVId from "@salesforce/apex/OCVDuplicateTableController.getAllCustomersByOCVId";
const COLUMNS = [
  {
    label: "Name",
    fieldName: "NameUrl",
    type: "url",
    typeAttributes: {
      label: { fieldName: "Name" },
      target: "_self"
    }
  },
  {
    label: "Source System Name",
    fieldName: "Source_System_Name__c",
    type: "text"
  },
  { label: "Source System Id", fieldName: "Source_System_ID__c", type: "text" },
  { label: "OCV Id", fieldName: "OCV_ID__c", type: "text" }
];
export default class OcvDuplicateTable extends LightningElement {
  @api recordId;
  ocvId = "";
  customerList = [];
  columns = COLUMNS;
  isLoading = false;

  get showTable() {
    return this.customerList && this.customerList.length > 0;
  }

  async connectedCallback() {
    try {
      this.isLoading = true;
      let customerResult = await getAllCustomersByOCVId({
        recordId: this.recordId
      });
      this.customerList = customerResult.map((item) => ({
        ...item,
        NameUrl: `/${item.Id}`
      }));
      this.isLoading = false;
    } catch (error) {
      console.error(JSON.stringify(error));
      this.customerList = null;
      this.isLoading = false;
    }
  }
}
