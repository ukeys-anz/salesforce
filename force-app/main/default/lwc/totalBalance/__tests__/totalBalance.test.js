import totalBalance from "c/totalBalance";
import { createElement } from "lwc";

describe("c-totalBalance", () => {
  //clean the dom and mocks in between test runs
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("load lwc", async () => {
    const element = createElement("c-totalBalance", {
      is: totalBalance
    });
  });
});
