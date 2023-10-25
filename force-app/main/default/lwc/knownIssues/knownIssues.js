import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { LightningElement, track } from "lwc";
import tmp from "./knownIssues.html";

const KNOWN_ISSUES = [
  {
    IDR_Channel_Received__c: "Phone",
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
    let product2 = {};
    let product3 = {};
    if (issue[0].Product__c) {
      product = {
        Id: issue[0].Product__c,
        Name: issue[0].Product__r.Name,
        ProductServiceName: issue[0].Product__r.Name
      };
    }
    if (issue[0].IDR_Product_2__c) {
      product2 = {
        Id: issue[0].IDR_Product_2__c,
        Name: issue[0].IDR_Product_2__r.Name,
        ProductServiceName2: issue[0].IDR_Product_2__r.Name
      };
    }
    if (issue[0].IDR_Product_3__c) {
      product3 = {
        Id: issue[0].IDR_Product_3__c,
        Name: issue[0].IDR_Product_3__r.Name,
        ProductServiceName3: issue[0].IDR_Product_3__r.Name
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
    ComplaintDetails["ProductServiceName-Block"] = product;
    ComplaintDetails.Issue2Checkbox = issue[0].IDR_Second_Issue__c
      ? "Yes"
      : "No";
    ComplaintDetails.IssueType2 = issue[0].IDR_Issue_Type_2__c;
    ComplaintDetails.SubsequentIssueType2 = issue[0].IDR_Subsequent_Issue_2__c;
    ComplaintDetails["ProductServiceName2-Block"] = product2;
    ComplaintDetails.AccountPolicyNumber2 = "N/A";
    ComplaintDetails.Issue3Checkbox = issue[0].IDR_Third_Issue__c
      ? "Yes"
      : "No";
    ComplaintDetails.IssueType3 = issue[0].IDR_Issue_Type_3__c;
    ComplaintDetails.SubsequentIssueType3 = issue[0].IDR_Subsequent_Issue_3__c;
    ComplaintDetails["ProductServiceName3-Block"] = product3;
    ComplaintDetails.AccountPolicyNumber3 = "N/A";
    ResolutionInformation.complaintRelatedHardship =
      issue[0].IDR_Written_Response_Required__c;
    ResolutionInformation.realFormRequired = "No";
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
      issue[0].IDR_Complaint_Sub_Remedy_1__c;
    ResolutionInformation.secondComplaintRemedyCheckbox = issue[0]
      .IDR_Complaint_Remedy_2__c
      ? "Yes"
      : "No";
    ResolutionInformation.ComplaintRemedy2 = issue[0].IDR_Complaint_Remedy_2__c;
    ResolutionInformation.ComplaintSubRemedy2 =
      issue[0].IDR_Complaint_Sub_Remedy_2__c;
    ResolutionInformation.thirdComplaintRemedyCheckbox = issue[0]
      .IDR_Complaint_Remedy_3__c
      ? "Yes"
      : "No";
    ResolutionInformation.ComplaintSubRemedy3 =
      issue[0].IDR_Complaint_Sub_Remedy_3__c;
    ResolutionInformation.custWrittenResponse =
      issue[0].IDR_Written_Response_Requested__c;
    Case.ComplaintDetails = ComplaintDetails;
    Case.ResolutionInformation = ResolutionInformation;
    this.omniApplyCallResp({ Case });
  }
}
