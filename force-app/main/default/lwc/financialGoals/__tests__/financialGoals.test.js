import financialGoals from "c/financialGoals";
import { createElement } from "lwc";

const GOAL_DATA = [
  {
    Id: "a0c2O00000197sUQAQ",
    name: "Savings",
    accountNumber: "12312312",
    targetAmount: 50,
    currentBalance: 50,
    startDate: "2021-03-05T04:56:48.000+0000",
    targetDate: "2021-03-05T04:56:48.000+0000"
  }
];

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

    let goal = element.shadowRoot.querySelector("div[data-id='goal-body']");

    expect(goal).toBeTruthy();
  });

  it("test error is displayed", () => {
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    element.error = "An error has occurred";
    document.body.appendChild(element);

    let error = element.shadowRoot.querySelector("c-error[data-id='error']");
    let goal = element.shadowRoot.querySelector("div[data-id='goal-body']");

    expect(error).toBeTruthy();
    expect(goal).toBeFalsy();
  });

  it("test no goal data", () => {
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    element.goalData = EMPTY_GOALS;
    document.body.appendChild(element);
    let goal = element.shadowRoot.querySelector("div[data-id='goal-body']");
    expect(goal).toBeFalsy();
  });

  it("test total saved modal", () => {
    const element = createElement("c-financialGoals", {
      is: financialGoals
    });
    element.goalData = GOAL_DATA;
    document.body.appendChild(element);
    let goal = element.shadowRoot.querySelector("div[data-id='goal-body']");
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
