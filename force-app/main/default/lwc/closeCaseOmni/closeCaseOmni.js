import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track } from "lwc";
const SUB_REMS = ["16", "20", "Repayment arrangement"];
const SERVICE_QUALITY = "9";
const FAILURE_TO_RESPOND = "61";
const REFERRED_TO_PRODUCT = "3";
const OTHER = "99";
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
        this.modalMsg = "";
        if (res.result && res.result.IPResult && res.result.IPResult.result) {
          let errorPath = res.result.IPResult.result.errorsAsJson;
          if (errorPath.DRError) {
            this.modalMsg =
              "Update Failed: You are not authorized to make updates to this field.";
            this.showModal = true;
          }
        } else {
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
    if (
      details.ComplaintRemedy1 === REFERRED_TO_PRODUCT &&
      !details.detailsOfComplaint1
    )
      this.missingFields.push(
        "The details of this complaint have been provided to the product manufacturer"
      );
    if (
      SUB_REMS.includes(details.ComplaintSubRemedy1) &&
      !details.durationOfRemedy1
    )
      this.missingFields.push("Duration Of Remedy (months) 1");
    if (details.ComplaintSubRemedy1 === OTHER && !details.otherRemedy1)
      this.missingFields.push("Other Remedy 1");
    if (
      details.ComplaintSubRemedy1 === "Reward Points" &&
      !details.rewardPoints1
    )
      this.missingFields.push("Reward Points 1");
    if (details.SecondComplaintCheckbox === "Yes") {
      this.checkFields(details, this.omniJsonData.secCmpMap);
      if (
        details.ComplaintRemedy2 === REFERRED_TO_PRODUCT &&
        !details.detailsOfComplaint2
      )
        this.missingFields.push(
          "The details of this complaint have been provided to the product manufacturer 2"
        );
      if (
        SUB_REMS.includes(details.ComplaintSubRemedy2) &&
        !details.durationOfRemedy2
      )
        this.missingFields.push("Duration Of Remedy (months) 2");
      if (details.ComplaintSubRemedy2 === OTHER && !details.otherRemedy2)
        this.missingFields.push("Other Remedy 2");
      if (
        details.ComplaintSubRemedy2 === "Reward Points" &&
        !details.rewardPoints2
      )
        this.missingFields.push("Reward Points 2");
    }
    if (details.ThirdComplaintCheckbox === "Yes") {
      this.checkFields(details, this.omniJsonData.thirdCmpMap);
      if (
        details.ComplaintRemedy3 === REFERRED_TO_PRODUCT &&
        !details.detailsOfComplaint3
      )
        this.missingFields.push(
          "The details of this complaint have been provided to the product manufacturer 3"
        );
      if (
        SUB_REMS.includes(details.ComplaintSubRemedy3) &&
        !details.durationOfRemedy3
      )
        this.missingFields.push("Duration Of Remedy (months) 3");
      if (details.ComplaintSubRemedy3 === OTHER && !details.otherRemedy3)
        this.missingFields.push("Other Remedy 3");
      if (
        details.ComplaintSubRemedy3 === "Reward Points" &&
        !details.rewardPoints3
      )
        this.missingFields.push("Reward Points 3");
    }
    if (details.realFormRequired === "Yes")
      this.checkFields(details, this.omniJsonData.realFormMap);
    if (details.isSystemicIssue === "Yes")
      this.checkFields(details, this.omniJsonData.sysIssueMap);
    if (
      ((details.Type === SERVICE_QUALITY &&
        details.IDR_Subsequent_Issue__c === FAILURE_TO_RESPOND) ||
        (details.IDR_Issue_Type_2__c === SERVICE_QUALITY &&
          details.IDR_Subsequent_Issue_2__c === FAILURE_TO_RESPOND) ||
        (details.IDR_Issue_Type_3__c === SERVICE_QUALITY &&
          details.IDR_Subsequent_Issue_3__c === FAILURE_TO_RESPOND)) &&
      !details.IsthisComplaintAboutComplaint
    ) {
      this.missingFields.push("Is this a complaint about a complaint?");
    }
    if (details.IsthisComplaintAboutComplaint === "Yes")
      this.checkFields(details, this.omniJsonData.cacMap);
    if (
      details.avoidableEscalation === "Yes" &&
      !details.avoidableEscalationReason
    )
      this.missingFields.push("Avoidable Escalation Reason");
  }

  checkFields(detail, reMap) {
    reMap.forEach((field) => {
      let ele = Object.keys(field)[0];
      if (ele.includes("Block")) {
        if (!detail[ele] || (detail[ele] && !detail[ele][ele.split("-")[0]])) {
          this.missingFields.push(Object.values(field)[0]);
        }
      } else if (!detail[ele]) {
        this.missingFields.push(Object.values(field)[0]);
      }
    });
  }
}
