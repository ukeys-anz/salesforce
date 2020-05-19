import * as faker from "faker";
import { createFinAccountList } from "../../objectStore/financialAccount";
import { doesNotMatch } from "assert";
var accId: String;
var accName: String;
var finAccName: String;
var fsRecordType: String = "SavingsAccount";
var recordType: String = "General_Inquiry";

describe("Anonymous Complaint Edit Page", function() {
  before(function() {
    cy.login();

    cy.connect().then((connection: any) => {
      cy.log("Creating FS Account...");
      createFinAccountList(connection, 1, fsRecordType).then(
        (finAccounts: any) => {
          console.log(finAccounts);
          finAccName = finAccounts[0].Name;
          accId = finAccounts[0].FinServ__PrimaryOwner__c;
          connection.query(
            "SELECT Id, Name FROM Account WHERE Id = '" + accId + "' LIMIT 1",
            async function(err: any, result: any) {
              if (err) {
                return console.error(err);
              }

              if (result.records.length > 0) {
                console.log(accId);
                accName = result.records[0].Name;
              }
            }
          );
        }
      );
    });

    cy.loadApp("Coaches Workbench");
    cy.loadTab("Cases", "Standard");
  });

  it("Update case", function() {
    cy.get(".forceActionLink[title=New]", { timeout: 10000 })
      .should("be.visible")
      .click({ force: true });

    cy.get(".slds-form-element__label")
      .contains("General Inquiry")
      .click();
    cy.get(".uiButton", { timeout: 10000 })
      .contains("Next")
      .click({ force: true });
    //Add explicit wait for modal to show up as url doesnt change cypress doesnt wait for it.
    cy.wait(3000);

    cy.typeLabel("Description of Issue", "textarea", faker.lorem.text());

    cy.selectLookup("Account Name", "input", accName.toString());

    cy.selectDropdown("Status", "Open");

    cy.selectDropdown("Type", "Coaching");

    cy.selectDropdown("Channel Received", "Chat");

    cy.selectLookup("Financial Account", "input", finAccName.toString());

    cy.get(".uiButton")
      .last()
      .click();
  });
});
