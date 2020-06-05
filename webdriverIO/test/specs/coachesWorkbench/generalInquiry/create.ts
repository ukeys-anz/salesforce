/*** BASE IMPORTS ***/
import CoachesWorkbench from "../../../../pages/getHelp/coachesWorkbench";
import GeneralInquiry from "../../../../pages/getHelp/create/generalInquiry";

/*** UTILITIES IMPORTS ***/
import { jsForce } from "../../../../utilities/jsforce";
import * as faker from "faker";

/*** OBJECT STORE IMPORTS ***/
import { getFinAccount } from "../../../../objectStore/financialAccount";

/*** DECLARATIONS ***/
let accountId: String;
let accountName: String;
let financialAccountName: String;

describe("General Inquiry Record Creation", () => {
  before(() => {
    getFinAccount().then((finAccounts: any) => {
      financialAccountName = finAccounts[0].Name;
      accountId = finAccounts[0].FinServ__PrimaryOwner__c;
      jsForce.query(
        "SELECT Id, Name FROM Account WHERE Id = '" + accountId + "' LIMIT 1",
        async function(err: any, result: any) {
          if (err) {
            return console.error(err);
          }
          accountName = result.records[0].Name;
        }
      );
    });
  });

  it("should create a general inquiry case record", () => {
    CoachesWorkbench.login();
    CoachesWorkbench.loadApp("Coaches Workbench");
    CoachesWorkbench.navCases.click();
    $("=New").click();

    browser.pause(2000);

    $("span=General Inquiry").click();
    $("span=Next").click();

    browser.pause(3000);

    GeneralInquiry.subject.setValue(faker.lorem.text());
    GeneralInquiry.description.setValue(faker.lorem.text());

    GeneralInquiry.accountName.setValue(accountName.toString());
    $(`div=${accountName}`).click();

    GeneralInquiry.status.click();
    $(
      `=${faker.random.arrayElement([
        "Open",
        "Under Investigation",
        "On Hold",
        "Escalated",
        "Closed",
        "Re-opened"
      ])}`
    ).click();

    GeneralInquiry.type.click();
    $("=App Support").click();

    $("span=App Guide").click();
    GeneralInquiry.subTypeAdd.click();
    $("span=Device Support").click();
    GeneralInquiry.subTypeAdd.click();

    $("span=Bug Report & Feature").scrollIntoView();
    $("span=Bug Report & Feature").click();
    GeneralInquiry.additionalTypeAdd.click();

    GeneralInquiry.channelReceived.click();
    $(
      `=${faker.random.arrayElement([
        "Chat",
        "Voice Call",
        "Video Call",
        "Appointment",
        "Store"
      ])}`
    ).click();

    GeneralInquiry.caseReason.click();
    $(
      `=${faker.random.arrayElement([
        "User didn't attend training",
        "Complex functionality",
        "Existing problem",
        "Instructions not clear",
        "New problem"
      ])}`
    ).click();

    GeneralInquiry.priority.click();
    $("=Low").click();

    GeneralInquiry.financialAccount.setValue(financialAccountName.toString());
    $(`div=${financialAccountName}`).click();

    GeneralInquiry.save.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
