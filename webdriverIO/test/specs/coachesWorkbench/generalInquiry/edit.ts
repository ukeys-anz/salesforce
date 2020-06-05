/*** BASE IMPORTS ***/
import CoachesWorkbench from "../../../../pages/getHelp/coachesWorkbench";
import GeneralInquiry from "../../../../pages/getHelp/edit/generalInquiry";

/*** UTILITIES IMPORTS ***/
import { jsForce } from "../../../../utilities/jsforce";

/*** OBJECT STORE IMPORTS ***/
import { getFinAccount } from "../../../../objectStore/financialAccount";
import { createBlankCase } from "../../../../objectStore/case";

/*** DECLARATIONS ***/
let caseNumber: String;
let accountId: String;
let accountName: String;
let financialAccountName: String;
let recordType: String = "General_Inquiry";

describe("General Inquiry Record Edit", () => {
  before(() => {
    createBlankCase(1, recordType).then((cases: any) => {
      caseNumber = cases[0].CaseNumber;
    });

    getFinAccount().then((finAccounts: any) => {
      financialAccountName = finAccounts[0].Name;
      accountId = finAccounts[0].FinServ__PrimaryOwner__c;
      jsForce.query(
        `SELECT Id, Name FROM Account WHERE Id = '${accountId}' LIMIT 1`,
        async function(err: any, result: any) {
          if (err) {
            return console.error(err);
          }
          accountName = result.records[0].Name;
        }
      );
    });
  });

  it("should edit a general inquiry case record", () => {
    CoachesWorkbench.login();
    CoachesWorkbench.loadApp("Coaches Workbench");
    CoachesWorkbench.navCases.click();
    $(`.forceOutputLookup[title="${caseNumber}"]`).click();
    $("=Edit").click();

    GeneralInquiry.subject.setValue("Edited Value");
    GeneralInquiry.description.setValue("Edited Description");

    GeneralInquiry.accountName.setValue(accountName.toString());
    $(`div=${accountName}`).click();

    GeneralInquiry.type.click();
    $("=App Support").click();

    $("span=Bug Report & Feature").scrollIntoView();
    $("span=Bug Report & Feature").click();
    GeneralInquiry.additionalTypeAdd.click();

    GeneralInquiry.channelReceived.click();
    $("=Voice Call").click();

    GeneralInquiry.caseReason.click();
    $("=Existing problem").click();

    GeneralInquiry.priority.click();
    $("=Low").click();

    GeneralInquiry.financialAccount.setValue(financialAccountName.toString());
    $(`div=${financialAccountName}`).click();

    GeneralInquiry.save.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
