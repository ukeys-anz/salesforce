import { createElement } from "lwc";
import FinancialGoalsPersonAccount from "c/financialGoalsPersonAccount";

const GOAL_DATA = require("./data/goalData.json").account_buckets;
describe("c-financial-goals-person-account", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("test goals are visible", () => {
    const element = createElement("c-financial-goals-person-account", {
      is: FinancialGoalsPersonAccount
    });
    element.goalData = GOAL_DATA;
    document.body.appendChild(element);

    let goal = element.shadowRoot.querySelector("div[data-id='goal-body']");

    expect(goal).toBeTruthy();
  });

  it("test no goals", () => {
    const element = createElement("c-financial-goals-person-account", {
      is: FinancialGoalsPersonAccount
    });
    element.goalData = [];
    document.body.appendChild(element);

    let noGoals = element.shadowRoot.querySelector("span[data-id='no-goals']");

    expect(noGoals).toBeTruthy();
  });

  it("test total info modal", () => {
    const element = createElement("c-financial-goals-person-account", {
      is: FinancialGoalsPersonAccount
    });
    element.goalData = GOAL_DATA;
    document.body.appendChild(element);
    let goal = element.shadowRoot.querySelector("div[data-id='goal-body']");
    let infoButton = element.shadowRoot.querySelector(
      "lightning-icon[data-id='total-info']"
    );

    expect(goal).toBeTruthy();
    expect(infoButton).toBeTruthy();
    infoButton.click();

    return Promise.resolve().then(() => {
      let totalSavedModal = element.shadowRoot.querySelector(
        "section[data-id='total-info-modal']"
      );
      expect(totalSavedModal).toBeTruthy();
    });
  });
});
