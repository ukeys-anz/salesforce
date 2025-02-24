import { createElement } from "lwc";
import CloseCurrentTab from "c/closeCurrentTab";
import { getFocusedTabInfo } from "lightning/platformWorkspaceApi";

describe("c-close-current-tab", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  it("Close the current tab", () => {
    const element = createElement("c-close-current-tab", {
      is: CloseCurrentTab
    });

    document.body.appendChild(element);

    expect(getFocusedTabInfo).toHaveBeenCalled();
  });
});
