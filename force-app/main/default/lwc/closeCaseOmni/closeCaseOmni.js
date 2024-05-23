import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track } from "lwc";
import { handleErrorShowToast } from "c/utils";
const SUB_REMS = ["16", "20", "Repayment arrangement"];
const SERVICE_QUALITY = "9";
const FAILURE_TO_RESPOND = "61";
const REFERRED_TO_PRODUCT = "3";
const OTHER = "99";
const REMS = ["1", "10", "18"];

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
    let shouldBreak = this.validateIssueTypeFieldValues();
    if (shouldBreak) {
      return;
    }
    if (this.validateRealFormID()) {
      handleErrorShowToast(
        this,
        "Real Form ID Validation",
        undefined,
        "Please Validate Real Form ID."
      );
      return;
    }
    if (
      this.omniJsonData.Case.realFormRequired === "Yes" &&
      this.omniJsonData.Case.REALFormMAXID !==
        this.omniJsonData.Case.REALFormMAXID_OLD &&
      this.omniJsonData.validatedEventNumber !==
        this.omniJsonData.Case.REALFormMAXID
    ) {
      handleErrorShowToast(
        this,
        "Real Form ID Validation",
        undefined,
        "Revalidate Risk Event ID"
      );
      this.loading = false;
      return;
    }
    this.validateFields();
    if (this.missingFields.length > 0) {
      this.modalMsg =
        "Please complete all required fields: " + this.missingFields.join(", ");
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
          if (errorPath && errorPath.DRError) {
            if (errorPath.DRError.includes("required")) {
              this.modalMsg = errorPath.DRError;
            } else {
              this.modalMsg =
                "Update Failed: You are not authorized to make updates to this field.";
            }
            this.showModal = true;
          } else {
            let url = window.location.origin + "/" + this.omniJsonData.recordId;
            window.open(url, "_self");
          }
        } else {
          let url = window.location.origin + "/" + this.omniJsonData.recordId;
          window.open(url, "_self");
        }
      });
    }
  }
  validateIssueTypeFieldValues() {
    let details = this.omniJsonData.Case;
    let issueTypeCombinationMap = this.omniJsonData.issueTypeCombinationMap;
    let originalValues = this.omniJsonData.originalValues;
    let proceed = false;
    if (
      originalValues.Type !== details.Type ||
      originalValues.IDR_Subsequent_Issue__c !== details.IDR_Subsequent_Issue__c
    ) {
      if (details.Type in issueTypeCombinationMap) {
        let issueTypeArray = issueTypeCombinationMap[details.Type];
        if (issueTypeArray.includes(details.IDR_Subsequent_Issue__c)) {
          proceed = true;
        }
      }
      if (originalValues.Type in issueTypeCombinationMap) {
        let issueTypeArray = issueTypeCombinationMap[originalValues.Type];
        if (issueTypeArray.includes(originalValues.IDR_Subsequent_Issue__c)) {
          proceed = true;
        }
      }
    }
    if (proceed) {
      this.showModal = true;
      this.modalMsg =
        "If editing or updating an issue type that triggers a collection stop, please make the amendment on the case record directly";
    }
    return proceed;
  }
  // validate that all the required fields data has been provided
  validateFields() {
    let details = this.omniJsonData.Case;
    if (
      this.omniJsonData.Case.ComplaintStatus === "Closed" &&
      this.omniJsonData.Case.CustomerAcceptTheResolution === "No"
    )
      this.checkFields(details, this.omniJsonData.closeReqMap);
    if (
      this.omniJsonData.Case.ComplaintStatus === "Closed" &&
      this.omniJsonData.Case.CustomerAcceptTheResolution === "Yes"
    )
      this.checkFields(details, this.omniJsonData.closeReqMapAccepted);
    if (this.omniJsonData.Case.ComplaintStatus === "Provisionally Closed")
      this.checkFields(details, this.omniJsonData.closeReqMapOffered);
    if (
      details.Type === undefined ||
      details.Type === null ||
      details.Type === ""
    )
      this.missingFields.push("Issue Type");
    if (
      details.IDR_Subsequent_Issue__c === undefined ||
      details.IDR_Subsequent_Issue__c === null ||
      details.IDR_Subsequent_Issue__c === ""
    )
      this.missingFields.push("Subsequent Issue Type");
    if (
      details.ComplaintRemedy1 === REFERRED_TO_PRODUCT &&
      !details.detailsOfComplaint1
    )
      this.missingFields.push(
        "The details of this complaint have been provided to the product manufacturer"
      );
    if (
      details.ComplaintRemedy1Offered === REFERRED_TO_PRODUCT &&
      !details.OfferedDetails1 &&
      details.ComplaintStatus === "Provisionally Closed"
    )
      this.missingFields.push(
        "Offered to provide details of this complaint to the product manufacturer 1"
      );
    if (
      SUB_REMS.includes(details.ComplaintSubRemedy1) &&
      !details.durationOfRemedy1
    )
      this.missingFields.push("Duration Of Remedy (months) 1");
    if (
      SUB_REMS.includes(details.ComplaintSubRemedy1Offered) &&
      !details.DurationofRemedy1Offered
    )
      this.missingFields.push("Duration Of Remedy (months) 1 Offered");
    if (
      SUB_REMS.includes(details.ComplaintSubRemedy1Accepted) &&
      !details.DurationofRemedy1Accepted
    )
      this.missingFields.push("Duration Of Remedy (months) 1");

    if (details.ComplaintSubRemedy1 === OTHER && !details.otherRemedy1)
      this.missingFields.push("Other Remedy 1");
    if (
      details.ComplaintSubRemedy1Offered === OTHER &&
      !details.OtherRemedy1Offered
    )
      this.missingFields.push("Other Remedy 1 offered");

    if (
      details.ComplaintSubRemedy1Accepted === OTHER &&
      !details.otherRemedy1Accepted
    )
      this.missingFields.push("Other Remedy 1");
    if (
      details.ComplaintSubRemedy1 === "Reward Points" &&
      !details.RewardPoints1
    )
      this.missingFields.push("Reward Points 1");
    if (
      details.ComplaintSubRemedy1Offered === "Reward Points" &&
      !details.RewardPoints1Offered
    )
      this.missingFields.push("Reward Points 1 Offered");
    if (
      details.ComplaintSubRemedy1Accepted === "Reward Points" &&
      !details.RewardPoints1Accepted
    )
      this.missingFields.push("Reward Points 1");
    if (
      (REMS.includes(details.ComplaintRemedy1) ||
        REMS.includes(details.ComplaintSubRemedy1)) &&
      !details.PaymentAmountProvided1
    )
      this.missingFields.push("Payment Amount Provided 1");
    if (
      (REMS.includes(details.ComplaintRemedy1Offered) ||
        REMS.includes(details.ComplaintSubRemedy1Offered)) &&
      !details.PaymentAmount1Offered
    )
      this.missingFields.push("Payment Amount 1 Offered");

    if (
      (REMS.includes(details.ComplaintRemedy1Accepted) ||
        REMS.includes(details.ComplaintSubRemedy1Accepted)) &&
      !details.PaymentAmountProvided1Accepted
    )
      this.missingFields.push("Payment Amount Provided 1");

    if (
      details.SecondComplaintCheckbox === "Yes" &&
      details.ComplaintStatus === "Closed" &&
      details.CustomerAcceptTheResolution === "No"
    ) {
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
      if (
        (REMS.includes(details.ComplaintRemedy2) ||
          REMS.includes(details.ComplaintSubRemedy2)) &&
        !details.PaymentAmountProvided2
      )
        this.missingFields.push("Payment Amount Provided 2");
    }
    if (
      details.SecondComplaintCheckbox === "Yes" &&
      details.ComplaintStatus === "Closed" &&
      details.CustomerAcceptTheResolution === "Yes"
    ) {
      this.checkFields(details, this.omniJsonData.SeccloseReqMapAccepted);
      /*  if (
        details.ComplaintRemedy2Accepted === REFERRED_TO_PRODUCT &&
        !details.OfferedDetails2
      )
        this.missingFields.push(
          "Offered to provide details of this complaint to the product manufacturer"
        );*/

      if (
        SUB_REMS.includes(details.ComplaintSubRemedy2Accepted) &&
        !details.durationOfRemedy2Accepted
      )
        this.missingFields.push("Duration Of Remedy (months) 2");

      if (
        details.ComplaintSubRemedy2Accepted === OTHER &&
        !details.otherRemedy2Accepted
      )
        this.missingFields.push("Other Remedy 2");
      if (
        details.ComplaintSubRemedy2Accepted === "Reward Points" &&
        !details.rewardPoints2Accepted
      )
        this.missingFields.push("Reward Points 2");
      if (
        (REMS.includes(details.ComplaintRemedy2Accepted) ||
          REMS.includes(details.ComplaintSubRemedy2Accepted)) &&
        !details.PaymentAmountProvided2Accepted
      )
        this.missingFields.push("Payment Amount Provided 2");
    }
    if (
      details.ThirdComplaintCheckbox === "Yes" &&
      details.ComplaintStatus === "Closed" &&
      details.CustomerAcceptTheResolution === "No"
    ) {
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
      if (
        (REMS.includes(details.ComplaintRemedy3) ||
          REMS.includes(details.ComplaintSubRemedy3)) &&
        !details.PaymentAmountProvided3
      )
        this.missingFields.push("Payment Amount Provided 3");
    }
    if (
      details.ThirdComplaintCheckbox === "Yes" &&
      details.ComplaintStatus === "Closed" &&
      details.CustomerAcceptTheResolution === "Yes"
    ) {
      this.checkFields(details, this.omniJsonData.thirdCmpMapAccepted);
      /* if (
        details.ComplaintRemedy3Accepted === REFERRED_TO_PRODUCT &&
        !details.detailsOfComplaint3Accepted
      )
        this.missingFields.push(
          "Offered to provide details of this complaint to the product manufacturer 3"
        ); */
      if (
        SUB_REMS.includes(details.ComplaintSubRemedy3Accepted) &&
        !details.durationOfRemedy3Accepted
      )
        this.missingFields.push("Duration Of Remedy (months) 3");
      if (
        details.ComplaintSubRemedy3Accepted === OTHER &&
        !details.otherRemedy3Accepted
      )
        this.missingFields.push("Other Remedy 3");
      if (
        details.ComplaintSubRemedy3Accepted === "Reward Points" &&
        !details.rewardPoints3Accepted
      )
        this.missingFields.push("Reward Points 3");
      if (
        (REMS.includes(details.ComplaintRemedy3Accepted) ||
          REMS.includes(details.ComplaintSubRemedy3Accepted)) &&
        !details.PaymentAmountProvided3Accepted
      )
        this.missingFields.push("Payment Amount Provided 3");
    }

    if (
      details.ComplaintStatus === "Provisionally Closed" &&
      details.SecondComplaintRemedyOffered === "Yes"
    ) {
      this.checkFields(details, this.omniJsonData.SeccloseReqMapOffered);
      if (
        details.ComplaintRemedy2Offered === REFERRED_TO_PRODUCT &&
        !details.OfferedDetails2
      )
        this.missingFields.push(
          "Offered to provide details of this complaint to the product manufacturer"
        );

      if (
        SUB_REMS.includes(details.ComplaintSubRemedy2Offered) &&
        !details.DurationofRemedy2Offered
      )
        this.missingFields.push("Duration Of Remedy (months) 2 Offered");

      if (
        details.ComplaintSubRemedy2Offered === OTHER &&
        !details.otherRemedy2Offered
      )
        this.missingFields.push("Other Remedy 2 Offered");
      if (
        details.ComplaintSubRemedy2Offered === "Reward Points" &&
        !details.rewardPoints2Offered
      )
        this.missingFields.push("Reward Points 2 Offered");
      if (
        (REMS.includes(details.ComplaintRemedy2Offered) ||
          REMS.includes(details.ComplaintSubRemedy2Offered)) &&
        !details.PaymentAmount2Offered
      )
        this.missingFields.push("Payment Amount Offered 2");
    }

    if (
      details.ComplaintStatus === "Provisionally Closed" &&
      details.ThirdComplaintRemedyOffered === "Yes"
    ) {
      this.checkFields(details, this.omniJsonData.thirdCmpMapOffered);
      if (
        details.ComplaintRemedy3Offered === REFERRED_TO_PRODUCT &&
        !details.OfferedDetails3
      )
        this.missingFields.push(
          "Offered to provide details of this complaint to the product manufacturer 3"
        );
      if (
        SUB_REMS.includes(details.ComplaintSubRemedy3Offered) &&
        !details.DurationofRemedy3Offered
      )
        this.missingFields.push("Duration Of Remedy (months) 3 offered");
      if (
        details.ComplaintSubRemedy3Offered === OTHER &&
        !details.OtherRemedy3Offered
      )
        this.missingFields.push("Other Remedy 3 Offered");
      if (
        details.ComplaintSubRemedy3Offered === "Reward Points" &&
        !details.RewardPoints3Offered
      )
        this.missingFields.push("Reward Points 3 Offered");
      if (
        (REMS.includes(details.ComplaintRemedy3Offered) ||
          REMS.includes(details.ComplaintSubRemedy3Offered)) &&
        !details.PaymentAmount3Offered
      )
        this.missingFields.push("Payment Amount 3 Offered");
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

  validateRealFormID() {
    if (
      this.omniJsonData.Case.ComplaintStatus === "Closed" &&
      this.omniJsonData.Case.realFormRequired === "Yes" &&
      (this.omniJsonData.Case.REALFormMAXID !== undefined ||
        this.omniJsonData.Case.REALFormMAXID !== null) &&
      this.omniJsonData.Case.REALFormMAXID !==
        this.omniJsonData.Case.REALFormMAXID_OLD &&
      !(
        this.omniJsonData.apiRun &&
        this.omniJsonData.apiSuccess &&
        this.omniJsonData.RiskFormIDValid
      )
    ) {
      return true;
    }
    return false;
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
