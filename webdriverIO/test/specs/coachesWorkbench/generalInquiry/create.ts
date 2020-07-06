/*** BASE IMPORTS ***/
import CoachesWorkbench from "../../../../pages/coachesWorkbench/coachesWorkbench";
import GeneralInquiry from "../../../../pages/coachesWorkbench/create/generalInquiry";

/*** UTILITIES IMPORTS ***/
import { jsForce } from "../../../../utilities/jsforce";
import * as faker from "faker";
import CustomError from "../../../../utilities/customErrorHandler";

/*** OBJECT STORE IMPORTS ***/
import { getFinAccount } from "../../../../objectStore/financialAccount";

/*** COMMON VALUE IMPORTS ***/
import {
  status,
  channelReceived
} from "../../../../pages/coachesWorkbench/common/generalInquiry";

/*** DECLARATIONS ***/
let accountId: string;
let accountName: string;
let financialAccountName: string;

describe("General Inquiry Record Creation", () => {
  before(() => {
    getFinAccount().then((finAccounts: any) => {
      financialAccountName = finAccounts[0].Name;
      accountId = finAccounts[0].FinServ__PrimaryOwner__c;
      jsForce.query(
        "SELECT Id, Name FROM Account WHERE Id = '" + accountId + "' LIMIT 1",
        async function (err: any, result: any) {
          if (err) {
            throw new CustomError("Failed to retrieve Account", err);
          }
          accountName = result.records[0].Name;
        }
      );
    });
  });

  it("should create a general inquiry case record", () => {
    CoachesWorkbench.login("coach");
    CoachesWorkbench.loadApp("Coaches Workbench");
    CoachesWorkbench.navCases.click();
    $("=New").click();

    GeneralInquiry.description.setValue(faker.lorem.text());

    GeneralInquiry.accountName.setValue(accountName.toString());
    $(`div=${accountName}`).click();

    GeneralInquiry.status.click();
    $(`=${faker.random.arrayElement(status)}`).click();

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
    $(`=${faker.random.arrayElement(channelReceived)}`).click();

    GeneralInquiry.priority.click();
    $("=Low").click();

    GeneralInquiry.financialAccount.setValue(financialAccountName.toString());
    $(`div=${financialAccountName}`).click();

    GeneralInquiry.save.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
