import { createCaseList } from "../../objectStore/complaint";
var caseid: any;
var recordType: String = "Customer_Complaint";
describe("Escalate Complaint", function() {
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

  it("Escalate Complaint", function() {
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
      .shadowFind('div[title="Escalate"]')
      .shadowClick();

    cy.selectDropdown("Escalated to", "Customer Advocate");

    cy.selectDropdown("Complaint Escalation Reason", "Customer Request");

    cy.get(".uiButton")
      .last()
      .click();

    cy.get(".forceToastMessage")
      .contains("Escalated!")
      .should("be.visible");
  });
});
