import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track } from "lwc";
import tmp from "./knownIssues.html";

const KNOWN_ISSUES = [
  {
    IDR_Channel_Received__c: " ",
    IDR_Priority__c: " ",
    IDR_Issue_Type__c: "",
    IDR_Sub_Issue_Type__c: "",
    IDR_Description_of_Issue__c: "",
    IDR_Customer_Desired_Outcome__c: "",
    IDR_Written_Response_Required__c: null,
    IDR_Is_there_another_issue__c: "",
    IDR_REAL_Form_Required__c: "",
    IDR_Possible_Systemic_Issue__c: "",
    IDR_Status__c: "Open",
    IDR_Complaint_Outcome__c: "",
    IDR_Description_of_Outcome__c: "",
    IDR_Complaint_Remedy__c: "",
    IDR_Non_Financial_Remedy__c: "",
    IDR_Written_Response_Requested__c: null,
    Product__c: true,
    Product__r: { Name: "" }
  }
];

export default class KnownIssues extends OmniscriptBaseMixin(LightningElement) {
  @track options = [];
  @track value;
  @track expressCase;

  render() {
    if (this.omniJsonData && this.omniJsonData.KnownIssue) {
      this.omniJsonData.KnownIssue.forEach((issue) => {
        this.options.push({ label: issue.Name, value: issue.Id });
      });
    }
    if (
      this.omniJsonData &&
      this.omniJsonData.Case &&
      this.omniJsonData.Case.CustomerDetails
    ) {
      let Case = this.omniJsonData.Case.CustomerDetails;
      if (Case.expressCaseCreationCheckbox === "Yes") {
        this.expressCase = "Yes";
      }
      if (
        Case.expressCaseCreationCheckbox === "No" &&
        this.expressCase === "Yes" &&
        this.value
      ) {
        let issue = KNOWN_ISSUES;
        let caseObj = JSON.parse(JSON.stringify(this.omniJsonData.Case));
        this.value = "";
        this.populateIssues(caseObj, issue);
        this.omniUpdateDataJson("");
      }
    }
    return tmp;
  }

  // Displaying the default values of the fields that has to be shown based on selected Known Issue type
  handleChange(event) {
    this.value = event.target.value;
    this.omniUpdateDataJson(this.value);
    let issue = this.omniJsonData.KnownIssue.filter(
      (ele) => ele.Id === this.value
    );
    let Case = JSON.parse(JSON.stringify(this.omniJsonData.Case));
    this.populateIssues(Case, issue);
  }

  populateIssues(Case, issue) {
    let ComplaintDetails = Case.ComplaintDetails;
    let ResolutionInformation = Case.ResolutionInformation;
    let product = {};
    if (issue[0].Product__c) {
      product = {
        Id: issue[0].Product__c,
        Name: issue[0].Product__r.Name,
        ProductServiceName: issue[0].Product__r.Name
      };
    }
    ComplaintDetails.ChannelReceived = issue[0].IDR_Channel_Received__c;
    ComplaintDetails.Priority = issue[0].IDR_Priority__c;
    ComplaintDetails.IssueType = issue[0].IDR_Issue_Type__c;
    ComplaintDetails.AccountPolicyNumber = "N/A";
    ComplaintDetails.SubSequentIssueType = issue[0].IDR_Sub_Issue_Type__c;
    ComplaintDetails.DescriptionOfIssue = issue[0].IDR_Description_of_Issue__c;
    ComplaintDetails.CustomerDesiredOutcome =
      issue[0].IDR_Customer_Desired_Outcome__c;
    ComplaintDetails.Issue2Checkbox = issue[0].IDR_Is_there_another_issue__c;
    ComplaintDetails["ProductServiceName-Block"] = product;
    ResolutionInformation.complaintRelatedHardship =
      issue[0].IDR_Written_Response_Required__c;
    ResolutionInformation.realFormRequired = issue[0].IDR_REAL_Form_Required__c
      ? "true"
      : "false";
    ResolutionInformation.systemicIssue = issue[0]
      .IDR_Possible_Systemic_Issue__c
      ? issue[0].IDR_Possible_Systemic_Issue__c
      : "No";
    ResolutionInformation.ComplaintStatus = issue[0].IDR_Status__c;
    ResolutionInformation.ComplaintOutcome = issue[0].IDR_Complaint_Outcome__c;
    ResolutionInformation.ComplaintDescription =
      issue[0].IDR_Description_of_Outcome__c;
    ResolutionInformation.ComplaintRemedy1 = issue[0].IDR_Complaint_Remedy__c;
    ResolutionInformation.ComplaintSubRemedy1 =
      issue[0].IDR_Non_Financial_Remedy__c;
    ResolutionInformation.custWrittenResponse =
      issue[0].IDR_Written_Response_Requested__c;
    ResolutionInformation.secondComplaintRemedyCheckbox = "No";
    Case.ComplaintDetails = ComplaintDetails;
    Case.ResolutionInformation = ResolutionInformation;
    this.omniApplyCallResp({ Case });
  }
}
