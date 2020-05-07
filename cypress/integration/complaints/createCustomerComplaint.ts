import * as faker from "faker";

describe("Customer Complaint Page", function() {
  before(function() {
    cy.login();
    cy.loadApp("Complaint Mgt");
    cy.loadTab("Cases");
  });

  it("Creates new case", function() {
    cy.get("a[title=Cases]", { timeout: 10000 })
      .should("be.visible")
      .click({ force: true });
    cy.get(".forceActionLink[title=New]", { timeout: 10000 })
      .should("be.visible")
      .click({ force: true });

    cy.get(".topdown-radio--label")
      .contains("Customer Complaint")
      .click();
    cy.get(".uiButton", { timeout: 10000 })
      .contains("Next")
      .click({ force: true });

    cy.typeLightningText(
      "c-create-complaint-l-w-c",
      "IDR_Customer_Number__c",
      "12345"
    );

    cy.selectLightningDropdown(
      "c-create-complaint-l-w-c",
      "IDR_Complainant_Type__c",
      "Small business"
    );

    cy.selectLightningDropdown(
      "c-create-complaint-l-w-c",
      "IDR_NC_Descent__c",
      "No"
    );
    cy.selectLightningCheckbox(
      "c-create-complaint-l-w-c",
      "Does Customer wish to be represented by a nominated third party?"
    );
    //Added to appear section after selection otherwise cypress cannot find element
    cy.wait(3000);

    cy.typeLightningText(
      "c-create-complaint-l-w-c",
      "IDR_3rdParty_Name__c",
      faker.name.firstName()
    );
    cy.typeLightningText(
      "c-create-complaint-l-w-c",
      "IDR_3rdParty_Email__c",
      faker.internet.email()
    );
    cy.typeLightningText(
      "c-create-complaint-l-w-c",
      "IDR_3rdParty_Mobile__c",
      faker.phone.phoneNumber("04########")
    );
    cy.selectLightningDropdown(
      "c-create-complaint-l-w-c",
      "IDR_3rdParty_State__c",
      "VIC"
    );

    cy.selectLightningDropdown(
      "c-create-complaint-l-w-c",
      "Type",
      "Rates, Fees and Charges"
    );
    cy.selectLightningDropdown(
      "c-create-complaint-l-w-c",
      "IDR_Product_or_Service_Line__c",
      "Superannuation"
    );

    cy.selectLightningDropdown(
      "c-create-complaint-l-w-c",
      "IDR_Product_or_Service_Category__c",
      "Retirement savings account"
    );

    cy.selectLightningDropdown(
      "c-create-complaint-l-w-c",
      "IDR_Product_or_Service_Type__c",
      "Total and permanent disability (Retirement savings account)"
    );
    cy.typeLightningText(
      "c-create-complaint-l-w-c",
      "IDR_Account_Card_Policy_Number__c",
      "122333"
    );

    cy.selectLightningCheckbox(
      "c-create-complaint-l-w-c",
      "Is this a common complaint?"
    );
    cy.selectLightningRadio(
      "c-create-complaint-l-w-c",
      "Is the customer requesting a written response?",
      "No"
    );
    cy.selectLightningRadio(
      "c-create-complaint-l-w-c",
      "Is the complaint relating to hardship, a declined insurance claim, the value of an insurance claim or a decision of a superannuation trustee?",
      "Yes"
    );
    cy.typeLightningTextarea(
      "c-create-complaint-l-w-c",
      "Description",
      "Issue description"
    );
    cy.typeLightningTextarea(
      "c-create-complaint-l-w-c",
      "IDR_Complainant_Desired_Outcome__c",
      "Desired outcome"
    );

    cy.saveLightningButton("c-create-complaint-l-w-c");

    cy.get(".forceToastMessage")
      .contains("Complaint has been created successfully.")
      .should("be.visible");
  });
});
