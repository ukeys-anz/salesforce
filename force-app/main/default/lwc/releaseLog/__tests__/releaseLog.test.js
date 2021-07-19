import releaseLog from "c/releaseLog";
import countTotalRecords from "@salesforce/apex/ReleaseLogServerController.countTotalRecords";
import { createElement } from "lwc";
import getReleases from "@salesforce/apex/ReleaseLogServerController.getReleases";
import { release } from "os";

jest.mock(
  "@salesforce/apex/ReleaseLogServerController.getReleases",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

jest.mock(
  "@salesforce/apex/ReleaseLogServerController.countTotalRecords",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const APEX_RELEASE_EMPTY = require("./data/releaseEmpty.json");

const APEX_RELEASE_SUCCESS = require("./data/releaseSuccess.json");

describe("c-releaseLog", () => {
  //clean the dom and mocks in between test runs
  beforeEach(() => {
    jest.resetAllMocks();
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });
  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("tests load more functionality", () => {
    getReleases.mockResolvedValue(APEX_RELEASE_SUCCESS);
    countTotalRecords.mockResolvedValue(5);

    const element = createElement("c-release-log", {
      is: releaseLog
    });
    document.body.appendChild(element);

    return flushPromises()
      .then(() => {
        const loadMoreButton = element.shadowRoot.querySelector(
          'button[data-id="load-more-button"]'
        );
        loadMoreButton.click();
        expect(loadMoreButton).toBeTruthy();
      })
      .then(() => {
        const loadMoreButton = element.shadowRoot.querySelector(
          'button[data-id="load-more-button"]'
        );
        loadMoreButton.click();
        expect(loadMoreButton).toBeTruthy();
      })
      .then(() => {
        const loadMoreButton = element.shadowRoot.querySelector(
          'button[data-id="load-more-button"]'
        );
        expect(loadMoreButton).toBeFalsy();
      });
  });

  it("test release success section", () => {
    getReleases.mockResolvedValue(APEX_RELEASE_SUCCESS);
    countTotalRecords.mockResolvedValue(5);

    const element = createElement("c-release-log", {
      is: releaseLog
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const releaseName = element.shadowRoot.querySelector(
        'strong[data-id="release-name"]'
      );
      expect(releaseName).not.toBeNull;
    });
  });

  it("test release addition section", () => {
    getReleases.mockResolvedValue(APEX_RELEASE_SUCCESS);
    countTotalRecords.mockResolvedValue(5);

    const element = createElement("c-release-log", {
      is: releaseLog
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const releaseAdditions = element.shadowRoot.querySelector(
        'ul[data-id="release-additions"]'
      );
      expect(releaseAdditions).not.toBeNull;
    });
  });

  it("test release changes section", () => {
    getReleases.mockResolvedValue(APEX_RELEASE_SUCCESS);
    countTotalRecords.mockResolvedValue(5);

    const element = createElement("c-release-log", {
      is: releaseLog
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const releaseChanges = element.shadowRoot.querySelector(
        'ul[data-id="release-changes"]'
      );
      expect(releaseChanges).not.toBeNull;
    });
  });

  it("test release fixes section", () => {
    getReleases.mockResolvedValue(APEX_RELEASE_SUCCESS);
    countTotalRecords.mockResolvedValue(5);

    const element = createElement("c-release-log", {
      is: releaseLog
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const releaseFixes = element.shadowRoot.querySelector(
        'ul[data-id="release-fixes"]'
      );
      expect(releaseFixes).not.toBeNull;
    });
  });

  it("test release image section", () => {
    getReleases.mockResolvedValue(APEX_RELEASE_SUCCESS);
    countTotalRecords.mockResolvedValue(5);

    const element = createElement("c-release-log", {
      is: releaseLog
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const releaseImage = element.shadowRoot.querySelector(
        'ul[data-id="release-image"]'
      );
      expect(releaseImage).not.toBeNull;
    });
  });

  it("test release empty section", () => {
    getReleases.mockResolvedValue(APEX_RELEASE_EMPTY);
    countTotalRecords.mockResolvedValue(0);
    const element = createElement("c-release-log", {
      is: releaseLog
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const noRelease = element.shadowRoot.querySelector(
        'strong[data-id="no-release"]'
      );
      expect(noRelease).toBeTruthy();
    });
  });
});
