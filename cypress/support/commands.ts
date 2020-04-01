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
    loadComplaintApp(): void;
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
  }
  cy.log("Logging in...").then(() => {
    cy.request(
      `${myBase.InstanceUrl}/secur/frontdoor.jsp?sid=${myBase.AccessToken}`
    );
    cy.visit(`${myBase.InstanceUrl}/lightning`);
  });
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

Cypress.Commands.add("loadComplaintApp", (): void => {
  //Check if we are already on the Complaint Mgt App
  cy.get("div.slds-context-bar__item > div > span").then(span => {
    let title = span.text();
    if (title === "Complaint Mgt") {
      return true;
    }

    // cy.shadowGet("one-appnav")
    //   .shadowFind("one-app-launcher-header")
    //   .shadowFind("button.slds-button")
    //   .shadowClick();

    cy.get("nav.appLauncher").click();

    cy.shadowGet("one-app-launcher-menu")
      .shadowFind("one-app-launcher-search-bar")
      .shadowFind("lightning-input")
      .shadowFind('input[type="search"]')
      .shadowType("Complaint Mgt");

    cy.shadowGet("one-app-launcher-menu")
      .shadowFind("one-app-launcher-menu-item")
      .shadowFind("lightning-formatted-rich-text")
      .shadowFind("p.slds-truncate")
      .shadowContains("Complaint Mgt")
      .shadowClick();

    cy.wait(5000);
  });
});
