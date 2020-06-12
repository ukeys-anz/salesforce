/*** BASE IMPORTS ***/
import CoachesWorkbench from "../../../../pages/coachesWorkbench/coachesWorkbench";
import GeneralInquiry from "../../../../pages/coachesWorkbench/edit/generalInquiry";

/*** UTILITIES IMPORTS ***/
import { jsForce } from "../../../../utilities/jsforce";
import * as faker from "faker";

/*** OBJECT STORE IMPORTS ***/
import { getFinAccount } from "../../../../objectStore/financialAccount";
import { createBlankCase } from "../../../../objectStore/case";

/*** COMMON VALUE IMPORTS ***/
import {
  status,
  channelReceived,
  caseReason
} from "../../../../pages/coachesWorkbench/common/generalInquiry";

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
    CoachesWorkbench.login("coach");
    CoachesWorkbench.loadApp("Coaches Workbench");
    CoachesWorkbench.navCases.click();
    $(`.forceOutputLookup[title="${caseNumber}"]`).click();
    $("=Edit").click();

    GeneralInquiry.subject.setValue(faker.lorem.text());
    GeneralInquiry.description.setValue(faker.lorem.text());

    GeneralInquiry.accountName.setValue(accountName.toString());
    $(`div=${accountName}`).click();

    GeneralInquiry.status.click();
    $(`a[role="menuitemradio"]=${faker.random.arrayElement(status)}`).click();

    GeneralInquiry.type.click();
    $("=App Support").click();

    $("span=Bug Report & Feature").scrollIntoView();
    $("span=Bug Report & Feature").click();
    GeneralInquiry.additionalTypeAdd.click();

    GeneralInquiry.channelReceived.click();
    $(`=${faker.random.arrayElement(channelReceived)}`).click();

    GeneralInquiry.caseReason.click();
    $(`=${faker.random.arrayElement(caseReason)}`).click();

    GeneralInquiry.financialAccount.setValue(financialAccountName.toString());
    $(`div=${financialAccountName}`).click();

    GeneralInquiry.save.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
