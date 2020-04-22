import * as faker from "faker";
import { createCaseList } from "../../objectStore/complaint";
var caseid: any;
var recordType: String = "Non_Customer_Complaint";

describe("Anonymous Complaint Edit Page", function() {
  before(function() {
    cy.login();
    cy.connect().then((response: any) => {
      cy.log("Creating cases...");
      createCaseList(response, 1, recordType).then((cases: any) => {
        caseid = cases[0].CaseNumber;
      });
    });
    cy.loadApp("Complaint Mgt");
    cy.loadTab("Cases");
  });

  it("Update complaint", function() {
    cy.get("a[title=Cases]", { timeout: 10000 })
      .should("be.visible")
      .click({ force: true });

    cy.get('.forceOutputLookup[title="' + caseid + '"]', {
      timeout: 10000
    }).click({ force: true });
    //Add explicit wait for page to appear  as cypress unable to find element.
    cy.wait(3000);
    cy.shadowGet("one-record-home-flexipage2")
      .last()
      .shadowFind(
        "forcegenerated-flexipage_complaint_record_page_case__view_js"
      )
      .shadowFind("flexipage-record-page-decorator")
      .shadowFind("flexipage-record-home-template-desktop2")
      .shadowFind("flexipage-component2")
      .shadowFind("force-progressive-renderer")
      .shadowFind("records-lwc-highlights-panel")
      .shadowFind("records-lwc-record-layout")
      .shadowFind(".forcegenerated-record-layout2")
      .shadowFind("force-highlights2")
      .shadowFind('div[title="Edit"]')
      .shadowClick();
    //Add explicit wait for modal to show up as url doesnt change cypress doesnt wait for it.
    cy.wait(3000);
    cy.typeLabel("Phone", "input", faker.phone.phoneNumber("03########"));
    cy.typeLabel("Nominated 3rd party name", "input", faker.name.firstName());
    cy.typeLabel(
      "Nominated 3rd party email address",
      "input",
      faker.internet.email()
    );
    cy.typeLabel(
      "Nominated 3rd party street",
      "input",
      faker.address.streetName()
    );
    cy.typeLabel("Nominated 3rd party suburb", "input", faker.address.city());
    cy.typeLabel(
      "Nominated 3rd party postcode",
      "input",
      faker.address.zipCode("####")
    );
    cy.typeLabel(
      "Nominated 3rd party mobile",
      "input",
      faker.phone.phoneNumber("04########")
    );
    cy.typeLabel(
      "Nominated 3rd party phone",
      "input",
      faker.phone.phoneNumber("03########")
    );
    // value: "Australia"
    cy.selectDropdown("Nominated 3rd party country", 13);
    // value: "VIC"
    cy.selectDropdown("Nominated 3rd party state", 2);

    cy.typeLabel("Office", "input", "dockland");
    // value: "Customer Request"
    cy.selectDropdown("Complaint Escalation Reason", 2);
    // value: "Customer Advocate"
    cy.selectDropdown("Escalated to", 2);

    cy.typeLabel("Case Notes", "textarea", "Escalation notes");

    // value: "In favour of complainant in full"
    cy.selectDropdown("Complaint Outcome", 1);
    // value: "Financial remedy"
    cy.selectDropdown("Complaint Remedy", 1);
    // value: "1–49"
    cy.selectDropdown("Financial Compensation", 1);

    cy.typeLabel("Description of Outcome", "textarea", faker.lorem.text());

    cy.typeLabel("Date Re-Opened", "input", "16/03/2020");
    cy.typeLabel("Date closed after re-opening", "input", "16/03/2020");
    // value: "Referred back from AFCA"
    cy.selectDropdown("Reason for re-opening", 1);

    cy.clickLabel("Is this a common complaint?");
    cy.clickLabel("Is a REAL form required?");

    cy.typeLabel("Systemic Issue Description", "textarea", faker.lorem.text());
    // value: "System Issue"
    cy.selectDropdown("Systemic Issue Category", 1);
    // value: "Yes"
    cy.selectDropdown("Is a Written Response Requested?", 1);
    // value: "Yes"
    cy.selectDropdown("Is a Written Response Required?", 1);

    cy.typeLabel("AFCA Number", "input", faker.random.number().toString());
    cy.typeLabel("AFCA Date", "input", "16/03/2020");
    // value: "Yes"
    cy.selectDropdown("AFCA Status", 1);
    // value: "AFS licence"
    cy.selectDropdown("Licence or registration type", 1);

    cy.typeLabel("Licence Number", "input", faker.random.number().toString());
    cy.typeLabel(
      "Representative/Credit Identifier Number",
      "input",
      faker.random.number().toString()
    );

    cy.clickLabel("Is Related to a Representative/Credit?");

    cy.typeLabel(
      "CFMS Complaint Number",
      "input",
      faker.random.number().toString()
    );

    cy.get(".uiButton")
      .last()
      .click();

    cy.get(".forceToastMessage")
      .contains('Case "' + caseid + '" was saved.')
      .should("be.visible");
  });
});
