import { createElement } from "lwc";
import ReleaseLogLink from "c/releaseLogLink";
import { getNavigateCalledWith } from "lightning/navigation";
import { setImmediate } from "timers";

describe("c-release-log-link", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("test click link then navigate to release notes tab", () => {
    const element = createElement("c-release-log-link", {
      is: ReleaseLogLink
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      //click Release Notes link
      const linkBtn = element.shadowRoot.querySelector("lightning-button");
      linkBtn.click();

      const { pageReference } = getNavigateCalledWith();

      expect(pageReference.type).toBe("standard__navItemPage");
      expect(pageReference.attributes.apiName).toBe("Release_Notes");
    });
  });
});
