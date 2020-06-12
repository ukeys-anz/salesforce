/*** BASE IMPORTS ***/
import CustomerComplaint from "../../../../pages/complaintMgt/edit/customerComplaint";

/*** UTILITIES IMPORTS ***/
import * as faker from "faker";

/*** OBJECT STORE IMPORTS ***/
import { createCaseList } from "../../../../objectStore/complaint";

/*** DECLARATIONS ***/
let caseId: any;
let recordType: String = "Customer_Complaint";

describe("Customer Record Edit", () => {
  before(() => {
    createCaseList(1, recordType).then((cases: any) => {
      caseId = cases[0].CaseNumber;
    });
  });

  it("should edit a customer complaint case record", () => {
    CustomerComplaint.login("idrlvl3");
    CustomerComplaint.loadApp("Complaint Mgt");
    $('button[title="Show Navigation Menu"]').click();
    $("=Cases").click();

    $(`.forceOutputLookup[title="${caseId}"]`).click();
    $("=Edit").click();

    CustomerComplaint.nominatedThirdName.setValue(
      faker.name.firstName() + " " + faker.name.lastName()
    );
    CustomerComplaint.nominatedThirdEmail.setValue(faker.internet.email());
    CustomerComplaint.nominatedThirdStreet.setValue(faker.address.streetName());
    CustomerComplaint.nominatedThirdSuburb.setValue(faker.address.city());
    CustomerComplaint.nominatedThirdPostcode.setValue(
      faker.address.zipCode("####")
    );
    CustomerComplaint.nominatedThirdMobile.setValue(
      faker.phone.phoneNumber("04########")
    );
    CustomerComplaint.nominatedThirdPhone.setValue(
      faker.phone.phoneNumber("97######")
    );

    $('input[title="Search Products"]').setValue("Netwealth");
    $("mark=Netwealth").click();

    CustomerComplaint.description.setValue(faker.lorem.text());
    CustomerComplaint.desiredOutcome.setValue(faker.lorem.text());

    CustomerComplaint.save.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
