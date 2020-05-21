import { createCaseList } from "../../objectStore/complaint";
var caseid: any;
var recordType: String = "Customer_Complaint";
describe("Resolved Complaint", function() {
  before(function() {
    cy.login();
    cy.connect().then((response: any) => {
      cy.log("Creating cases...");
      createCaseList(response, 1, recordType).then((cases: any) => {
        caseid = cases[0].CaseNumber;
      });
      cy.log(response);
    });
    cy.loadApp("Complaint Mgt");
    cy.loadTab("Cases");
  });

  it("Resolved Complaint", function() {
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
      .shadowFind('div[title="Resolve"]')
      .shadowClick();

    cy.selectDropdown("Status", "Resolved");

    cy.selectDropdown("Complaint Outcome", "In favour of complainant in full");

    cy.selectDropdown("Complaint Remedy", "Financial remedy");

    cy.selectDropdown("Financial Compensation", "1–49");

    cy.typeLabel("Description of Outcome", "textarea", "Outcome description");

    cy.get(".uiButton")
      .last()
      .click();

    cy.get(".forceToastMessage")
      .contains("Resolved!")
      .should("be.visible");
  });
});
