import { createElement } from "lwc";
import ModifyProduct from "c/modifyProduct";
import { CloseScreenEventName } from "lightning/actions";
import { setImmediate } from "timers";
import getProducts from "@salesforce/apex/ModifyProductController.getProducts";

const RECORD_ID = "13Z9p000000AkKvEAK";

describe("c-modify-product", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  function flushPromises() {
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("Banker clicks on Cancel", () => {
    const element = createElement("c-modify-product", {
      is: ModifyProduct
    });
    document.body.appendChild(element);

    return flushPromises().then(() => {
      const closeScreenHandler = jest.fn();
      element.addEventListener(CloseScreenEventName, closeScreenHandler);
      const cancelBtn = element.shadowRoot.querySelector(".btnCancel");
      cancelBtn.dispatchEvent(new CustomEvent("click"));
      expect(closeScreenHandler).toHaveBeenCalledTimes(1);
    });
  });
});
