import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track } from "lwc";
export default class CloseCaseOmni extends OmniscriptBaseMixin(
  LightningElement
) {
  loading = false;
  @track missingFields = [];
  @track modalMsg;
  @track showModal = false;
  @track modalHeader = "Error";

  closeModal() {
    this.showModal = false;
  }

  callCloseCaseIP() {
    this.missingFields = [];
    this.modalMsg = "";
    this.validateFields();
    if (this.missingFields.length > 0) {
      if (this.missingFields.length > 0) {
        this.modalMsg =
          "Please complete all required fields: " +
          this.missingFields.join(", ");
      }
      this.showModal = true;
    } else {
      this.showModal = false;
      this.loading = true;
      const inputs = {
        Case: this.omniJsonData.Case,
        isCloseCase: true
      };
      // Invoking Integration procedure(IP) to close a case
      const params = {
        input: JSON.stringify(inputs),
        sClassName: "omnistudio.IntegrationProcedureService",
        sMethodName: "Case_CreateCase",
        options: {}
      };
      // Navigate to the case record that has been closed by IP
      this.omniRemoteCall(params, true).then((res) => {
        console.log("res ", JSON.parse(JSON.stringify(res)));
        this.loading = false;
        if (this.omniJsonData.recordId) {
          let url = window.location.origin + "/" + this.omniJsonData.recordId;
          window.open(url, "_self");
        }
      });
    }
  }

  // validate that all the required fields data has been provided
  validateFields() {
    let details = this.omniJsonData.Case;
    this.checkFields(details, this.omniJsonData.closeReqMap);
    if (details.SecondComplaintCheckbox)
      this.checkFields(details, this.omniJsonData.secCmpMap);
    if (details.ThirdComplaintCheckbox)
      this.checkFields(details, this.omniJsonData.thirdCmpMap);
    if (details.realFormRequired === "Yes")
      this.checkFields(details, this.omniJsonData.realFormMap);
    if (details.isSystemicIssue === "Yes")
      this.checkFields(details, this.omniJsonData.sysIssueMap);
    if (details.IsthisComplaintAboutComplaint === "Yes")
      this.checkFields(details, this.omniJsonData.cacMap);
  }

  checkFields(detail, reMap) {
    reMap.forEach((field) => {
      if (!detail[Object.keys(field)[0]]) {
        this.missingFields.push(Object.values(field)[0]);
      }
    });
  }
}
