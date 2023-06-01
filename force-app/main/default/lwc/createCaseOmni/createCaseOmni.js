import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track } from "lwc";
export default class CreateCaseOmni extends OmniscriptBaseMixin(
  LightningElement
) {
  loading = false;
  showError = false;
  @track missingFields = [];
  @track modalMsg;
  @track showModal = false;
  @track modalHeader = "Error";

  closeModal() {
    this.showModal = false;
  }

  callCreateCaseIP() {
    this.missingFields = [];
    this.modalMsg = "";
    this.valCustomerFields();
    if (this.missingFields.length > 0) {
      if (this.missingFields.length > 0) {
        this.modalMsg =
          "Please complete all required fields: " +
          this.missingFields.join(", ");
        if (
          this.omniJsonData.Case.isThisCustomerComplaint === "Yes" &&
          !this.omniJsonData.Case.CustomerDetails["Customer-Block"].Customer
        ) {
          this.modalMsg +=
            "<br><br>Customer number must be numbers and atleast 10 digits long";
        }
      }
      this.showModal = true;
    } else {
      this.showModal = false;
      this.loading = true;
      const inputs = {
        Case: this.omniJsonData.Case,
        Response: this.omniJsonData.Response
      };

      // Invoking Integration procedure(IP) to create a case
      const params = {
        input: JSON.stringify(inputs),
        sClassName: "omnistudio.IntegrationProcedureService",
        sMethodName: "Case_CreateCase",
        options: {}
      };

      // Navigate to the case record that is closed
      this.omniRemoteCall(params, true).then((res) => {
        console.log("res ", JSON.parse(JSON.stringify(res)));
        let result = res.result.IPResult;
        this.loading = false;
        if (result.CaseId) {
          let url = window.location.origin + "/" + result.CaseId;
          window.open(url, "_self");
        }
      });
    }
  }

  // validate that all the required fields data has been provided
  valCustomerFields() {
    let details = this.omniJsonData.Case.CustomerDetails;
    if (this.omniJsonData.Case.isThisCustomerComplaint === "Yes") {
      this.checkFields(details, this.omniJsonData.custMap);
    } else if (this.omniJsonData.Case.isThisCustomerComplaint === "No") {
      this.checkFields(details, this.omniJsonData.nonCustMap);
    }
    if (details.thirdPartyRepCheckbox === "Yes") {
      this.checkFields(details, this.omniJsonData.thirdPartyMap);
    }
    details = this.omniJsonData.Case.ComplaintDetails;
    this.checkFields(details, this.omniJsonData.cmpMap);
    if (details.Issue2Checkbox === "Yes") {
      this.checkFields(details, this.omniJsonData.secCmpMap);
    }
    if (details.Issue3Checkbox === "Yes") {
      this.checkFields(details, this.omniJsonData.thirdCmpMap);
    }
    details = this.omniJsonData.Case.ResolutionInformation;
    this.checkFields(details, this.omniJsonData.resInfoMap);
    if (
      details.ComplaintStatus === "Closed" ||
      details.ComplaintStatus === "Provisionally Closed"
    ) {
      this.checkFields(details, this.omniJsonData.closeCmpMap);
    }
    if (details.realFormRequired === "Yes")
      this.checkFields(details, this.omniJsonData.realMap);
    if (details.systemicIssue === "Yes")
      this.checkFields(details, this.omniJsonData.sysIssueMap);
    if (details.CAC) this.checkFields(details, this.omniJsonData.cacMap);
    if (details.secondComplaintRemedyCheckbox === "Yes")
      this.checkFields(details, this.omniJsonData.secRemedyMap);
    if (details.thirdComplaintRemedyCheckbox === "Yes")
      this.checkFields(details, this.omniJsonData.thirdRemedyMap);
  }

  checkFields(detail, reMap) {
    reMap.forEach((field) => {
      if (!detail[Object.keys(field)[0]]) {
        this.missingFields.push(Object.values(field)[0]);
      }
    });
  }
}
