// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })

/// <reference path="../../node_modules/cypress-shadow-dom/index.d.ts" />

declare namespace Cypress {
  interface Chainable<Subject> {
    selectLightningDropdown(
      appname: string,
      dropdownname: string,
      selval: string
    ): Cypress.Chainable<any>;
    saveLightningButton(appname: string): Cypress.Chainable<any>;
    typeLightningText(
      appname: string,
      textboxname: string,
      inputval: string
    ): Cypress.Chainable<any>;
    typeLightningTextarea(
      appname: string,
      textareaname: string,
      inputval: string
    ): Cypress.Chainable<any>;
    selectLightningCheckbox(
      appname: string,
      checkboxlabel: string
    ): Cypress.Chainable<any>;
    selectLightningRadio(
      appname: string,
      radiolabel: string,
      selval: string
    ): Cypress.Chainable<any>;
  }
}

Cypress.Commands.add(
  "selectLightningDropdown",
  (appname, dropdownname, selval) => {
    cy.shadowGet(appname)
      .shadowFind("lightning-record-edit-form")
      .shadowFind("lightning-input-field")
      .shadowFind("lightning-picklist")
      .shadowFind("lightning-combobox")
      .shadowFind("lightning-base-combobox")
      .shadowFind("input[name=" + dropdownname + "]")
      .shadowClick();
    cy.shadowGet("c-create-complaint-l-w-c")
      .shadowFind("lightning-record-edit-form")
      .shadowFind("lightning-input-field")
      .shadowFind("lightning-picklist")
      .shadowFind("lightning-combobox")
      .shadowFind("lightning-base-combobox")
      .shadowFind("lightning-base-combobox-item")
      //.shadowEq(selval) to select index
      .shadowFind('span[title="' + selval + '"]')
      .shadowClick();
  }
);

Cypress.Commands.add("selectLightningCheckbox", (appname, checkboxlabel) => {
  cy.shadowGet(appname)
    .shadowFind("lightning-record-edit-form")
    .shadowFind("lightning-input")
    .shadowFind("label")
    .contains(checkboxlabel)
    .shadowClick();
});

Cypress.Commands.add("selectLightningRadio", (appname, radiolabel, selval) => {
  cy.shadowGet(appname)
    .shadowFind("lightning-record-edit-form")
    .shadowFind("lightning-radio-group")
    .contains(radiolabel)

    .shadowFind("input[value=" + selval + "]")
    .shadowClick();
});

Cypress.Commands.add("typeLightningText", (appname, textboxname, inputval) => {
  cy.shadowGet(appname)
    .shadowFind("lightning-record-edit-form")
    .shadowFind("lightning-input-field")
    .shadowFind("lightning-input")
    .shadowFind("input[name=" + textboxname + "]")
    .shadowType(inputval);
});

Cypress.Commands.add(
  "typeLightningTextarea",
  (appname, textareaname, inputval) => {
    cy.shadowGet(appname)
      .shadowFind("lightning-record-edit-form")
      .shadowFind("lightning-input-field")
      .shadowFind("lightning-textarea")
      .shadowFind("textarea[name=" + textareaname + "]")
      .shadowType(inputval)
      .shadowTrigger("input");
  }
);

Cypress.Commands.add("saveLightningButton", appname => {
  cy.shadowGet(appname)
    .shadowFind("lightning-record-edit-form")
    .shadowFind("lightning-button")
    .shadowFind('button[name="save"]')
    .shadowClick({ force: true });
});
