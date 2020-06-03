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
const jsforce = require("jsforce");
const { Base } = require("../objectStore/base");
const myBase = new Base();

declare namespace Cypress {
  interface Chainable<Subject> {
    login(): void;
    connect(): any;
    loadApp(appName: string): any;
    loadTab(tabName: string): void;

    selectDropdown(
      dropdownname: string,
      selval: string
    ): Cypress.Chainable<any>;

    selectLookup(
      labelname: string,
      labeltype: string,
      lookupName: string
    ): Cypress.Chainable<any>;

    multiSelect(labelname: string, selval: string): Cypress.Chainable<any>;

    typeLabel(
      labelname: string,
      labeltype: string,
      inputval: string
    ): Cypress.Chainable<any>;
    clickLabel(labelname: string): Cypress.Chainable<any>;
  }
}

//For this command to work correctly, a scratch org needs to be created
//and set as the default globally
Cypress.Commands.add("login", (): void => {
  //Check if access token or instance url are set first so we
  //can avoid running the sfdx command
  if (!myBase.AccessToken || !myBase.InstanceUrl) {
    cy.exec(
      'sfdx force:org:display --json | sed -E "s/[[:cntrl:]][[0-9]{1,3}m//g"'
    ).then(response => {
      let result = JSON.parse(response.stdout).result;

      //Error handling
      if (result === undefined) {
        console.log(response);
        throw new Error(
          response.stderr + " | Check console for more information."
        );
      }

      let accessToken = result.accessToken;
      let instanceUrl = result.instanceUrl;

      //Set the access token and instance url so we can retrieve them if we need to make
      //this call again
      myBase.setAccessToken(accessToken);
      myBase.setInstanceUrl(instanceUrl);
    });

    cy.log("Logging in...").then(() => {
      cy.request(
        `${myBase.InstanceUrl}/secur/frontdoor.jsp?sid=${myBase.AccessToken}`
      );
      cy.visit(`${myBase.InstanceUrl}/lightning`);
    });
  } else {
    cy.visit(`${myBase.InstanceUrl}/lightning`);
    //Added to fix issue all tests not running together
    Cypress.on("uncaught:exception", (err, runnable) => {
      return false;
    });
  }
});

Cypress.Commands.add("connect", (): void => {
  //Check if access token or instance url are set first so we
  //can avoid running the sfdx command
  if (!myBase.AccessToken || !myBase.InstanceUrl) {
    cy.exec(
      'sfdx force:org:display --json | sed -E "s/[[:cntrl:]][[0-9]{1,3}m//g"'
    ).then(response => {
      let result = JSON.parse(response.stdout).result;

      //Error handling
      if (result === undefined) {
        console.log(response);
        throw new Error(
          response.stderr + " | Check console for more information."
        );
      }

      let accessToken = result.accessToken;
      let instanceUrl = result.instanceUrl;

      //Set the access token and instance url so we can retrieve them if we need to make
      //this call again
      myBase.setAccessToken(accessToken);
      myBase.setInstanceUrl(instanceUrl);
    });
  }
  cy.log("Establishing connection...").then(() => {
    //Check if there is an existing JSForce connection
    if (myBase.JSForceConn) {
      return myBase.JSForceConn;
    }
    const conn = new jsforce.Connection({
      instanceUrl: myBase.InstanceUrl,
      accessToken: myBase.AccessToken
    });
    myBase.setJsForceConnection(conn);

    return conn;
  });
});

Cypress.Commands.add("loadApp", (appName): any => {
  cy.wait(5000);
  cy.get("body").then($body => {
    if ($body.find("div.desktop").hasClass("lafStandardLayoutContainer")) {
      cy.log("Standard View");
      cy.get("one-appnav")
        .shadowFind("div")
        .shadowFind("div")
        .shadowFind("div")
        .shadowFind("span.appName")
        .then(span => {
          let title = span.text();
          if (title === appName) {
            cy.log("Already on app");
          } else {
            cy.get("one-appnav")
              .shadowFind("div")
              .shadowFind("div")
              .shadowFind("div")
              .shadowFind("nav.appLauncher")
              .shadowFind("one-app-launcher-header")
              .shadowFind("span")
              .shadowClick({
                force: true
              });
            cy.shadowGet("one-app-launcher-menu")
              .shadowFind("one-app-launcher-search-bar")
              .shadowFind("lightning-input")
              .shadowFind('input[type="search"]')
              .shadowType(`${appName}`);
            cy.shadowGet("one-app-launcher-menu")
              .shadowFind("one-app-launcher-menu-item")
              .shadowFind("lightning-formatted-rich-text")
              .shadowFind("p.slds-truncate")
              .shadowContains(`${appName}`)
              .wait(1000)
              .shadowClick();
          }
        });
    } else if (
      $body.find("div.desktop").hasClass("oneConsoleLayoutContainer2")
    ) {
      cy.log("Console View");
      cy.get("div.appName").then(span => {
        let title = span.text();
        if (title == appName) {
          cy.log("Already on app");
        } else {
          cy.get("nav.appLauncher").click();
          cy.shadowGet("one-app-launcher-menu")
            .shadowFind("one-app-launcher-search-bar")
            .shadowFind("lightning-input")
            .shadowFind('input[type="search"]')
            .shadowType(`${appName}`);
          cy.shadowGet("one-app-launcher-menu")
            .shadowFind("one-app-launcher-menu-item")
            .shadowFind("lightning-formatted-rich-text")
            .shadowFind("p.slds-truncate")
            .shadowContains(`${appName}`)
            .wait(1000)
            .shadowClick();
        }
      });
    }
  });
  //Added to fix issue all tests not running together
  Cypress.on("uncaught:exception", (err, runnable) => {
    return false;
  });
  cy.wait(5000);
});

Cypress.Commands.add("loadTab", (tabName): void => {
  cy.get("body").then($body => {
    if ($body.find("div.desktop").hasClass("lafStandardLayoutContainer")) {
      cy.shadowGet("one-appnav")
        .shadowFind("one-app-nav-bar.slds-grid")
        .shadowFind('nav[role="navigation"]')
        .shadowFind('div[role="list"]')
        .shadowFind("one-app-nav-bar-item-root")
        .shadowFind(`a[title="${tabName}"]`)
        .shadowFind("span")
        .shadowContains(`${tabName}`)
        .shadowClick();
    } else if (
      $body.find("div.desktop").hasClass("oneConsoleLayoutContainer2")
    ) {
      cy.get(".oneAppNavMenu", {
        timeout: 10000
      })
        .should("be.visible")
        .click()
        .get('a[title="' + tabName + '"]')
        .first()
        .click();
    }
    cy.wait(3000);
  });
});

Cypress.Commands.add("selectDropdown", (dropdownname, selval) => {
  cy.get(".uiInput--select")
    .contains(dropdownname)
    .parent()
    .parent()
    .find(".select")
    .click({ force: true });
  cy.get('ul[role="presentation"]')
    .last()
    .within(() => {
      cy.get("li")
        //.eq(selval) to select index
        .find('a[title="' + selval + '"]')
        .click();
    });
});

Cypress.Commands.add("selectLookup", (labelname, labeltype, lookupName) => {
  cy.get("label")
    .contains(labelname)
    .parent()
    .parent()
    .find(labeltype)
    .clear()
    .type(lookupName, { force: true });

  cy.get('ul[role="presentation"]')
    .find('div[title="' + lookupName + '"]')
    .first()
    .click({ force: true });
});

Cypress.Commands.add("multiSelect", (labelname, selval) => {
  cy.get("lightning-picklist")
    .shadowContains(labelname)
    .shadowContains("Available")
    .shadowFind("ul")
    .shadowFind('li[role="presentation"]')
    .shadowFind('div[data-value="' + selval + '"]')
    .shadowClick();

  cy.get("lightning-picklist")
    .shadowFind("lightning-dual-listbox")
    .shadowFind("div")
    .shadowFind("lightning-button-icon")
    .shadowFind('button[title="Move selection to Chosen"]')
    .shadowClick();
});

Cypress.Commands.add("typeLabel", (labelname, labeltype, inputval) => {
  cy.get("label")
    .contains(labelname)
    .parent()
    .parent()
    .find(labeltype)
    .clear({ force: true })
    .type(inputval, { force: true });
});

Cypress.Commands.add("clickLabel", labelname => {
  cy.get("label")
    .contains(labelname)
    .parent()
    .parent()
    .find("input")
    .click();
});
