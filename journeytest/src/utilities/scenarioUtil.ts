import scenariosData from "../../data/scenarios.json";
import cardsData from "../../data/cardsData.json";
import casesData from "../../data/casesData.json";
import accountsData from "../../data/accountsData.json";
import customerData from "../../data/customerData.json";

export class ScenarioUtil {
  /**
   * Takes no parameters
   * @returns All the test scenarios
   */
  static getAllScenarios = function () {
    let value;

    if (scenariosData.scenarios != null) value = scenariosData.scenarios;
    else value = null;

    return value;
  };

  /**
   * Takes no parameters
   * @returns All the card test data details
   */
  static getAllCards = function () {
    let value;

    if (cardsData.cards != null) value = cardsData.cards;
    else value = null;

    return value;
  };

  /**
   * @param scenarioId - scenario id
   * @returns Return card details based on scenario ID
   */
  static getCardDetails = function (scenarioId: string) {
    let value;

    scenariosData.scenarios.forEach((element) => {
      if (element.id === scenarioId) {
        cardsData.cards.forEach((cardElement) => {
          if (element.card === cardElement.card_id) {
            value = cardElement;
          }
        });
      }
    });

    return value;
  };

  /**
   * @param scenarioId - scenario id
   * @returns Return scenario details based on scenario ID
   */
  static getScenario = function (scenarioId: string) {
    let value;

    scenariosData.scenarios.forEach((element) => {
      if (element.id == scenarioId) {
        value = element;
      }
    });

    return value;
  };

  /**
   * Takes no parameters
   * @returns All the cases test data details
   */
  static getAllCases = function () {
    let value;

    if (casesData.cases != null) value = cardsData.cards;
    else value = null;

    return value;
  };

  /**
   * @param scenarioId - scenario id
   * @returns Return case details based on scenario ID and test type
   */
  static getCaseDetails = function (scenarioId: string) {
    let value;
    let caseId;

    scenariosData.scenarios.forEach((element) => {
      if (element.id == scenarioId) {
        if (element.cases.action.toUpperCase() === "CREATE") {
          casesData.cases.create.forEach((caseElem) => {
            if (element.cases.id === caseElem.create_dataId) {
              value = caseElem;
            }
          });
        } else if (element.cases.action.toUpperCase() === "EDIT") {
          casesData.cases.edit.forEach((caseElem) => {
            if (element.cases.id === caseElem.edit_dataId) {
              value = caseElem;
            }
          });
        } else if (element.cases.action.toUpperCase() === "VERIFY") {
          casesData.cases.verify.forEach((caseElem) => {
            if (element.cases.id === caseElem.verify_dataId) {
              value = caseElem;
            }
          });
        }
      }
    });

    return value;
  };

  /**
   * @param scenarioId - scenario id
   * @returns Return customer details based on scenario ID
   */
  static getCustomerDetails = function (scenarioId: string) {
    let value;

    scenariosData.scenarios.forEach((element) => {
      if (element.id == scenarioId) {
        customerData.customers.forEach((customerElem) => {
          if (element.customer === customerElem.customerDataId) {
            value = customerElem;
          }
        });
      }
    });

    return value;
  };

  /**
   * @param scenarioId - scenario id
   * @returns Return all account based on scenario ID
   */
  static getAllAccounts = function (scenarioId: string) {
    let value;

    scenariosData.scenarios.forEach((element) => {
      if (element.id == scenarioId) {
        value = element.accounts;
      }
    });

    return value;
  };

  /**
   * @param scenarioId - scenario id
   * @param accountType - account type - Possible values - EVERYDAY, SAVINGS
   * @returns Return account details based on scenario ID
   */
  static getAccountDetails = function (
    scenarioId: string,
    accountType: string
  ) {
    let value;

    scenariosData.scenarios.forEach((element) => {
      if (element.id === scenarioId) {
        element.accounts.forEach((accElement) => {
          if (accElement.type === accountType) {
            accountsData.accounts.forEach((accTestElement) => {
              if (accElement.id === accTestElement.accountDataId) {
                value = accElement;
              }
            });
          }
        });
      }
    });

    return value;
  };
}
