import * as faker from "faker";

describe("Anonymous Customer Complaint Page", function() {
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
      .contains("Non-Customer Complaint")
      .click();
    cy.get(".uiButton")
      .contains("Next")
      .click();

    cy.shadowGet("c-create-complaint-l-w-c")
      .shadowFind("lightning-record-edit-form")
      .shadowFind("lightning-radio-group")
      .shadowFind('input[value="Disagrees"]')
      .shadowClick();

    cy.selectLightningDropdown(
      "c-create-complaint-l-w-c",
      "IDR_Complainant_Type__c",
      "Individual"
    );

    cy.typeLightningText(
      "c-create-complaint-l-w-c",
      "IDR_NC_First_Name__c",
      faker.name.firstName()
    );
    cy.typeLightningText(
      "c-create-complaint-l-w-c",
      "IDR_NC_Last_Name__c",
      faker.name.lastName()
    );
    cy.typeLightningText(
      "c-create-complaint-l-w-c",
      "IDR_NC_Email__c",
      faker.internet.email()
    );
    cy.typeLightningText(
      "c-create-complaint-l-w-c",
      "IDR_NC_Mobile__c",
      faker.phone.phoneNumber("04########")
    );
    cy.typeLightningText(
      "c-create-complaint-l-w-c",
      "IDR_NC_Street__c",
      faker.address.streetName()
    );
    cy.typeLightningText(
      "c-create-complaint-l-w-c",
      "IDR_NC_Suburb__c",
      faker.address.city()
    );
    cy.typeLightningText(
      "c-create-complaint-l-w-c",
      "IDR_NC_Postcode__c",
      faker.address.zipCode("####")
    );

    cy.selectLightningDropdown(
      "c-create-complaint-l-w-c",
      "IDR_NC_Age__c",
      "25 - 34 years"
    );

    cy.selectLightningDropdown(
      "c-create-complaint-l-w-c",
      "IDR_NC_Gender__c",
      "Male"
    );

    cy.selectLightningDropdown(
      "c-create-complaint-l-w-c",
      "IDR_NC_Descent__c",
      "No"
    );

    cy.selectLightningDropdown(
      "c-create-complaint-l-w-c",
      "IDR_NC_State__c",
      "VIC"
    );

    cy.selectLightningDropdown("c-create-complaint-l-w-c", "Type", "About ANZ");

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
    cy.selectLightningCheckbox(
      "c-create-complaint-l-w-c",
      "Is this a common complaint?"
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
