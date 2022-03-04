import financialGoals from "c/financialGoals";
import { createElement } from "lwc";

const GOAL_DATA = require("./data/bucketResponse.json");

const EMPTY_GOALS = [];

describe("c-financialGoals", () => {
  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("test goal is visible", () => {
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    element.goalData = GOAL_DATA;
    document.body.appendChild(element);

    let goal = element.shadowRoot.querySelector(
      "div[data-id='goal-container']"
    );

    expect(goal).toBeTruthy();
  });

  it("test error is displayed", () => {
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    element.error = "An error has occurred";
    document.body.appendChild(element);

    let error = element.shadowRoot.querySelector("c-error[data-id='error']");
    let goal = element.shadowRoot.querySelector(
      "div[data-id='goal-container']"
    );

    expect(error).toBeTruthy();
    expect(goal).toBeFalsy();
  });

  it("test no goal data", () => {
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    element.goalData = EMPTY_GOALS;
    document.body.appendChild(element);
    let goal = element.shadowRoot.querySelector("span[data-id='no-goals']");
    expect(goal).toBeTruthy();
  });

  it("test total saved modal", () => {
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    element.goalData = GOAL_DATA;
    document.body.appendChild(element);
    let goal = element.shadowRoot.querySelector(
      "div[data-id='goal-container']"
    );
    let infoButton = element.shadowRoot.querySelector(
      "lightning-icon[data-id='total-saved-info']"
    );

    expect(goal).toBeTruthy();
    expect(infoButton).toBeTruthy();
    infoButton.click();

    return Promise.resolve().then(() => {
      let totalSavedModal = element.shadowRoot.querySelector(
        "section[data-id='total-saved-modal']"
      );
      expect(totalSavedModal).toBeTruthy();
    });
  });
});
