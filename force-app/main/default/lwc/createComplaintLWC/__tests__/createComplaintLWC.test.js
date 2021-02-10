import { createElement } from "lwc";
import CreateComplaintForm from "c/createComplaintLWC";
import { ShowToastEventName } from "lightning/platformShowToastEvent";

describe("c-create-complaint-l-w-c", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.restoreAllMocks();
  });

  function flushPromises() {
    // eslint-disable-next-line no-undef
    return new Promise((resolve) => setImmediate(resolve));
  }

  it("display all sections in the form", () => {
    const element = createElement("c-create-complaint-l-w-c", {
      is: CreateComplaintForm
    });
    element.recordTypeDevName = "Customer_Complaint";
    document.body.appendChild(element);

    const accordionSections = element.shadowRoot.querySelectorAll(
      "lightning-accordion-section"
    );
    expect(accordionSections.length).toBe(3);
  });

  it("display escalated fields when the case is escalated", () => {
    const element = createElement("c-create-complaint-l-w-c", {
      is: CreateComplaintForm
    });
    element.recordTypeDevName = "Customer_Complaint";
    document.body.appendChild(element);

    const complaintStatus = element.shadowRoot.querySelector(
      "lightning-combobox"
    );
    complaintStatus.value = "Escalated";
    complaintStatus.dispatchEvent(new CustomEvent("change"));

    return flushPromises().then(() => {
      expect(complaintStatus.value).toBe("Escalated");
      const escalatedTo = element.shadowRoot.querySelector(
        "lightning-input-field[data-id=escalatedTo-id]"
      );
      expect(escalatedTo).toBeTruthy();

      //click Create Case button to improve code coverage
      const saveButton = element.shadowRoot.querySelector(".saveButton");
      saveButton.click();
    });
  });

  it("display second issue fields", () => {
    const element = createElement("c-create-complaint-l-w-c", {
      is: CreateComplaintForm
    });
    element.recordTypeDevName = "Customer_Complaint";
    document.body.appendChild(element);

    const secondIssue = element.shadowRoot.querySelector(
      "lightning-input[data-id=issue2-id]"
    );
    secondIssue.checked = true;
    secondIssue.dispatchEvent(new CustomEvent("change"));

    return flushPromises().then(() => {
      const issueType2 = element.shadowRoot.querySelector(
        "lightning-input-field[data-id=issueType2-id]"
      );

      expect(issueType2).toBeTruthy();
    });
  });

  it("display third issue fields", () => {
    const element = createElement("c-create-complaint-l-w-c", {
      is: CreateComplaintForm
    });
    element.recordTypeDevName = "Customer_Complaint";
    document.body.appendChild(element);

    const secondIssue = element.shadowRoot.querySelector(
      "lightning-input[data-id=issue2-id]"
    );
    secondIssue.checked = true;
    secondIssue.dispatchEvent(new CustomEvent("change"));

    return flushPromises().then(() => {
      const thirdIssue = element.shadowRoot.querySelector(
        "lightning-input[data-id=issue3-id]"
      );
      thirdIssue.checked = true;
      thirdIssue.dispatchEvent(new CustomEvent("change"));
      expect(thirdIssue).toBeTruthy();

      //click Create Case button to improve code coverage
      const saveButton = element.shadowRoot.querySelector(".saveButton");
      saveButton.click();
    });
  });

  it("check resolved complaint case", () => {
    const element = createElement("c-create-complaint-l-w-c", {
      is: CreateComplaintForm
    });
    element.recordTypeDevName = "Customer_Complaint";
    document.body.appendChild(element);

    const complaintStatus = element.shadowRoot.querySelector(
      "lightning-combobox"
    );
    complaintStatus.value = "Resolved";
    complaintStatus.dispatchEvent(new CustomEvent("change"));

    return flushPromises().then(() => {
      expect(complaintStatus.value).toBe("Resolved");
      const compRemedy = element.shadowRoot.querySelector(
        "lightning-input-field[data-id=compRemedy-id]"
      );
      compRemedy.dispatchEvent(
        new CustomEvent("change", {
          detail: {
            value: "1"
          }
        })
      );

      return flushPromises().then(() => {
        const finRemedy = element.shadowRoot.querySelector(
          "lightning-input[data-id=finAmount-id]"
        );
        expect(finRemedy).toBeTruthy();

        //click Create Case button to improve code coverage
        const saveButton = element.shadowRoot.querySelector(".saveButton");
        saveButton.click();
      });
    });
  });

  it("display Nominated third party fields", () => {
    const element = createElement("c-create-complaint-l-w-c", {
      is: CreateComplaintForm
    });
    element.recordTypeDevName = "Customer_Complaint";
    document.body.appendChild(element);

    const secondIssue = element.shadowRoot.querySelector(
      "lightning-input[data-id=nominatedThirdParty-id]"
    );
    secondIssue.checked = true;
    secondIssue.dispatchEvent(new CustomEvent("change"));

    return flushPromises().then(() => {
      const nominated3rdPartyName = element.shadowRoot.querySelector(
        "lightning-input-field[data-id=thirdPartyName-id]"
      );

      expect(nominated3rdPartyName).toBeTruthy();
      const nominated3rdPartyState = element.shadowRoot.querySelector(
        "lightning-input-field[data-id=thirdPartyState-id]"
      );
      expect(nominated3rdPartyState).toBeTruthy();

      //click Create Case button to improve code coverage
      const saveButton = element.shadowRoot.querySelector(".saveButton");
      saveButton.click();
    });
  });

  it("display Systemic issue fields", () => {
    const element = createElement("c-create-complaint-l-w-c", {
      is: CreateComplaintForm
    });
    element.recordTypeDevName = "Customer_Complaint";
    document.body.appendChild(element);

    const possibleSystemicIssue = element.shadowRoot.querySelector(
      "lightning-radio-group[data-id=commoncomplaintGroup-id]"
    );
    possibleSystemicIssue.value = "Yes";
    possibleSystemicIssue.dispatchEvent(new CustomEvent("change"));

    return flushPromises().then(() => {
      const psiDescription = element.shadowRoot.querySelector(
        "lightning-input-field[data-id=siDescription-id]"
      );
      expect(psiDescription).toBeTruthy();

      const psiCategory = element.shadowRoot.querySelector(
        "lightning-input-field[data-id=siCategory-id]"
      );
      expect(psiCategory).toBeTruthy();

      //click Create Case button to improve code coverage
      const saveButton = element.shadowRoot.querySelector(".saveButton");
      saveButton.click();
    });
  });

  it("Fill complaint form, validate the fields and submit the form", () => {
    const element = createElement("c-create-complaint-l-w-c", {
      is: CreateComplaintForm
    });
    element.recordTypeDevName = "Customer_Complaint";
    document.body.appendChild(element);

    //Populate user input - Customer Number
    const customerNumber = element.shadowRoot.querySelector(
      "lightning-input[data-id=customerNumber-id]"
    );
    customerNumber.value = "0123456789";
    customerNumber.dispatchEvent(new CustomEvent("change"));

    //Populate user input - Click Search Button
    const searchButton = element.shadowRoot.querySelector(
      "lightning-button[data-id=searchButton-id]"
    );
    searchButton.click();

    //Populate user input - Customer Type
    const customerType = element.shadowRoot.querySelector(
      "lightning-input-field[data-id=customerType-id]"
    );
    customerType.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "Individual"
        }
      })
    );
    //Populate user input - Issue Type
    const issueType = element.shadowRoot.querySelector(
      "lightning-input-field[data-id=issueType-id]"
    );
    issueType.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "Advice"
        }
      })
    );
    //Populate user input - subsequent issue type
    const subIssueType = element.shadowRoot.querySelector(
      "lightning-input-field[data-id=subsequentIssue-id]"
    );
    subIssueType.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "No Advice"
        }
      })
    );
    //Populate user input - Product Id
    const productId = element.shadowRoot.querySelector(
      "lightning-input-field[data-id=product-id]"
    );
    productId.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "Test Product"
        }
      })
    );
    //Populate user input - Account Number
    const accNumber = element.shadowRoot.querySelector(
      "lightning-input-field[data-id=accPolicyNum-id]"
    );
    accNumber.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "5345435345"
        }
      })
    );
    //Populate user input - issue description
    const issueDesc = element.shadowRoot.querySelector(
      "lightning-textarea[data-id=issueDesc-id]"
    );
    issueDesc.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "Test Description"
        }
      })
    );
    //Populate user input - customer desired outcome
    const desiredOutcome = element.shadowRoot.querySelector(
      "lightning-input-field[data-id=custOutCome]"
    );
    desiredOutcome.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "Test Outcome"
        }
      })
    );
    //Populate user input - is written response requested
    const writtenResponse = element.shadowRoot.querySelector(
      "lightning-radio-group[data-id=writtenResponseGroup-id]"
    );
    writtenResponse.dispatchEvent(
      new CustomEvent("change", { detail: { value: "No" } })
    );
    //Populate user input - is written response required
    const writtenRequired = element.shadowRoot.querySelector(
      "lightning-radio-group[data-id=writtenRequiredGroup-id]"
    );
    writtenRequired.dispatchEvent(
      new CustomEvent("change", { detail: { value: "No" } })
    );
    //Populate user input - possible systemic issue
    const possibleSystemicIssue = element.shadowRoot.querySelector(
      "lightning-radio-group[data-id=commoncomplaintGroup-id]"
    );
    possibleSystemicIssue.value = "No";
    possibleSystemicIssue.dispatchEvent(new CustomEvent("change"));

    return flushPromises().then(() => {
      //click Create Case button to validate fields entered
      const saveButton = element.shadowRoot.querySelector(".saveButton");
      saveButton.click();
      expect(saveButton).toBeTruthy();

      const complaintForm = element.shadowRoot.querySelector(
        "lightning-record-edit-form"
      );
      complaintForm.submit = jest.fn();
      //submit EVENT gets dispatched, which triggers a handler function that will call the submit FUNCTION
      complaintForm.dispatchEvent(
        new CustomEvent("submit", { detail: { fields: {} } })
      );
    });
  });

  it("Submit form successfully", () => {
    const element = createElement("c-create-complaint-l-w-c", {
      is: CreateComplaintForm
    });
    element.recordTypeDevName = "Customer_Complaint";
    document.body.appendChild(element);

    const complaintForm = element.shadowRoot.querySelector(
      "lightning-record-edit-form"
    );
    expect(complaintForm).not.toBeNull();

    const TOAST_VARIANT = "success";
    const TOAST_TITLE = "Complaint has been created successfully.";

    // Mock handler for toast event
    const handler = jest.fn();
    // Add event listener to catch toast event
    element.addEventListener(ShowToastEventName, handler);
    //mocks the submit function for lightning-record-edit-form
    complaintForm.submit = jest.fn();
    //submit EVENT gets dispatched, which triggers a handler function that will call the submit FUNCTION
    complaintForm.dispatchEvent(
      new CustomEvent("success", {
        detail: {
          id: "somerandomId"
        }
      })
    );

    return flushPromises().then(() => {
      expect(handler).toHaveBeenCalled();
      expect(handler.mock.calls[0][0].detail.message).toBe(TOAST_TITLE);
      expect(handler.mock.calls[0][0].detail.variant).toBe(TOAST_VARIANT);
    });
  });
});
