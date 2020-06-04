/*** BASE IMPORTS ***/
import NonCustomerComplaint from "../../../../pages/complaints/edit/nonCustomerComplaint";

/*** UTILITIES IMPORTS ***/
import * as faker from "faker";

/*** OBJECT STORE IMPORTS ***/
import { createCaseList } from "../../../../objectStore/complaint";

/*** DECLARATIONS ***/
var caseId: any;
var recordType: String = "Non_Customer_Complaint";

describe("Non Customer Record Edit", () => {
  before(() => {
    createCaseList(1, recordType).then((cases: any) => {
      caseId = cases[0].CaseNumber;
    });
  });

  it("should edit a non customer complaint case record", () => {
    NonCustomerComplaint.login();
    NonCustomerComplaint.loadApp("Complaint Mgt");
    $('button[title="Show Navigation Menu"]').click();
    $("=Cases").click();

    $(`.forceOutputLookup[title="${caseId}"]`).click();
    $("=Edit").click();

    NonCustomerComplaint.descent.click();
    $(
      `a[role="menuitemradio"]=${faker.random.arrayElement([
        "No",
        "Yes, Aboriginal",
        "Yes, Torres Strait Islander",
        "Not stated/unknown"
      ])}`
    ).click();

    NonCustomerComplaint.phone.setValue(faker.phone.phoneNumber("04########"));

    NonCustomerComplaint.nominatedThirdName.setValue(
      faker.name.firstName() + " " + faker.name.lastName()
    );
    NonCustomerComplaint.nominatedThirdEmail.setValue(faker.internet.email());
    NonCustomerComplaint.nominatedThirdStreet.setValue(
      faker.address.streetName()
    );
    NonCustomerComplaint.nominatedThirdSuburb.setValue(faker.address.city());
    NonCustomerComplaint.nominatedThirdPostcode.setValue(
      faker.address.zipCode("####")
    );
    NonCustomerComplaint.nominatedThirdMobile.setValue(
      faker.phone.phoneNumber("04########")
    );
    NonCustomerComplaint.nominatedThirdPhone.setValue(
      faker.phone.phoneNumber("97######")
    );

    NonCustomerComplaint.writtenResponseRequested.click();
    $("=Yes").click();
    NonCustomerComplaint.writtenResponseRequired.click();
    $("=No").click();

    NonCustomerComplaint.save.click();

    const toastMessage = $(".forceToastMessage");
    expect(toastMessage).toBeVisible();
  });
});
