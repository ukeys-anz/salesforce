import { createElement } from "lwc";
import CreateComplaintForm from "c/createComplaintLWC";
import { ShowToastEventName } from "lightning/platformShowToastEvent";
import { setImmediate } from "timers";

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
      "lightning-combobox[data-id=caseStatus-id]"
    );
    complaintStatus.value = "Escalated";
    complaintStatus.dispatchEvent(new CustomEvent("change"));

    return flushPromises().then(() => {
      expect(complaintStatus.value).toBe("Escalated");
      const escalatedTo = element.shadowRoot.querySelector(
        "lightning-input-field[data-id=escalationReason-id]"
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

      const nominated3rdPartyComms = element.shadowRoot.querySelector(
        "lightning-input[data-id=thirdPartyNotification-id]"
      );
      expect(nominated3rdPartyComms).toBeTruthy();

      nominated3rdPartyComms.dispatchEvent(
        new CustomEvent("change", {
          detail: {
            value: "true"
          }
        })
      );

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

    const customerComms = element.shadowRoot.querySelector(
      "lightning-input[data-id=customerNotification-id]"
    );
    expect(customerComms).toBeTruthy();

    customerComms.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "true"
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
      "c-multi-select-combobox[data-id=accPolicyNum-id]"
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
      "lightning-textarea[data-id=descOfIssue-id]"
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
    //Populate user input - is real form required
    const realFormRequired = element.shadowRoot.querySelector(
      "lightning-radio-group[data-id=realFormRequiredGroup-id]"
    );
    //Populate user input - is real form submitted
    const realFormSubmitted = element.shadowRoot.querySelector(
      "lightning-radio-group[data-id=realFormSubmittedGroup-id]"
    );
    //Populate user input - real form reference number
    const realFormRefNo = element.shadowRoot.querySelector(
      "lightning-input[data-id=realFormRefNoGroup]"
    );
    realFormRequired.dispatchEvent(
      new CustomEvent("change", { detail: { value: "Yes" } }),
      () => {
        //Asserting for required scenario (positive)
        expect(realFormSubmitted.required).toBe(true);
        realFormSubmitted.dispatchEvent(
          new CustomEvent("change", { detail: { value: "Yes" } }),
          () => {
            realFormRefNo.dispatchEvent(
              new CustomEvent("change", { detail: { value: "123456789" } })
            );
          }
        );
      }
    );
    realFormRequired.dispatchEvent(
      new CustomEvent("change", { detail: { value: "No" } }),
      () => {
        //Asserting for not required scenario (negative)
        expect(realFormSubmitted.required).toBe(false);
      }
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

  it("check express cmos functionality", () => {
    const element = createElement("c-create-complaint-l-w-c", {
      is: CreateComplaintForm
    });
    element.recordTypeDevName = "Customer_Complaint";
    document.body.appendChild(element);

    const expressCMOSElement = element.shadowRoot.querySelector(
      "c-idr-express-complaint"
    );
    expect(expressCMOSElement).not.toBe(null);
    expressCMOSElement.dispatchEvent(
      new CustomEvent("togglechecked", { detail: { value: true } })
    );
    return Promise.resolve().then(() => {
      const issueTypeElement = element.shadowRoot.querySelector(
        '[data-id="issueType-id"]'
      );
      expect(issueTypeElement).not.toBe(null);
    });
  });

  it("check express cmos data load and unload", () => {
    const element = createElement("c-create-complaint-l-w-c", {
      is: CreateComplaintForm
    });
    element.recordTypeDevName = "Customer_Complaint";
    document.body.appendChild(element);
    const expressCMOSElement = element.shadowRoot.querySelector(
      "c-idr-express-complaint"
    );
    expressCMOSElement.dispatchEvent(
      new CustomEvent("togglechecked", { detail: { value: true } })
    );
    return Promise.resolve().then(() => {
      expressCMOSElement.dispatchEvent(
        new CustomEvent("selected", {
          detail: {
            IDR_Issue_Type__c: "13",
            IDR_Sub_Issue_Type__c: "9",
            Product__c: "01t2O000000vtZMQAY",
            IDR_Description_of_Issue__c: "Test",
            IDR_Customer_Desired_Outcome__c: "Test",
            IDR_Is_there_another_issue__c: false,
            IDR_Written_Response_Requested__c: "No",
            IDR_Written_Response_Required__c: "No",
            IDR_REAL_Form_Required__c: false,
            IDR_Possible_Systemic_Issue__c: "No",
            IDR_Status__c: "Closed",
            IDR_Complaint_Outcome__c: "1",
            IDR_Description_of_Outcome__c: "Test",
            IDR_Complaint_Remedy__c: "2",
            IDR_Non_Financial_Remedy__c: "1",
            IDR_Channel_Received__c: "Phone",
            IDR_Priority__c: "Standard"
          }
        })
      );
      return Promise.resolve().then(() => {
        const descriptionElement = element.shadowRoot.querySelector(
          '[data-id="descOfIssue-id"]'
        );
        expect(descriptionElement.value).toBe("Test");
        const issueType = element.shadowRoot.querySelector(
          "lightning-input-field[data-id=issueType-id]"
        );
        expect(issueType.value).toBe("13");
        const subIssueType = element.shadowRoot.querySelector(
          "lightning-input-field[data-id=subsequentIssue-id]"
        );
        expect(subIssueType.value).toBe("9");
        const complaintStatus = element.shadowRoot.querySelector(
          "lightning-combobox[data-id=caseStatus-id]"
        );
        expect(complaintStatus.value).toBe("Closed");
        // AR-6390 now test that data is unloaded if Express Case button is unchecked.
        expressCMOSElement.dispatchEvent(
          new CustomEvent("togglechecked", { detail: { value: false } })
        );
        return Promise.resolve().then(() => {
          expect(descriptionElement.value).toBe("");
          expect(issueType.value).toBe("");
          expect(subIssueType.value).toBe("");
          expect(complaintStatus.value).toBe("Open");
        });
      });
    });
  });

  //only check express cmos toggle without selecting known isssue
  it("check express cmos known issue validation", () => {
    const element = createElement("c-create-complaint-l-w-c", {
      is: CreateComplaintForm
    });
    element.recordTypeDevName = "Customer_Complaint";
    document.body.appendChild(element);

    const expressCMOSElement = element.shadowRoot.querySelector(
      "c-idr-express-complaint"
    );
    expect(expressCMOSElement).not.toBe(null);
    expressCMOSElement.dispatchEvent(
      new CustomEvent("togglechecked", { detail: { value: true } })
    );
    return Promise.resolve().then(() => {
      const submitBtnElement = element.shadowRoot.querySelector(
        '[data-id="submit-id"]'
      );
      submitBtnElement.dispatchEvent(
        new CustomEvent("click", {
          detail: {}
        })
      );

      return Promise.resolve().then(() => {
        const modalBox = element.shadowRoot.querySelector(
          '[data-id="modalMessage-id"]'
        );
        const errorMessage = modalBox.value;
        expect(errorMessage).not.toBe(null);
        expect(errorMessage).toContain(
          "Express Case Creation: A known issue must be selected in the This Complaint Is About field (If the complaint is not a 'Known Issue' please deselect the 'Express Case' toggle)"
        );
      });
    });
  });

  it("check if all accounts are selected for financial hardship issue type", () => {
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
    searchButton.dispatchEvent(
      new CustomEvent("click", {
        detail: {}
      })
    );
    return Promise.resolve().then(() => {
      const custInfo = element.shadowRoot.querySelector(
        "c-customer-information"
      );
      custInfo.dispatchEvent(
        new CustomEvent("custinfochecked", {
          detail: {}
        })
      );
      return Promise.resolve().then(() => {
        //Populate user input - Issue Type as Financial Hardship
        const issueType = element.shadowRoot.querySelector(
          "lightning-input-field[data-id=issueType-id]"
        );
        issueType.dispatchEvent(
          new CustomEvent("change", {
            detail: {
              value: "4"
            }
          })
        );
        return Promise.resolve().then(() => {
          //Verify if the Account number field is disabled
          const accNumber = element.shadowRoot.querySelector(
            "c-multi-select-combobox[data-id=accPolicyNum-id]"
          );
          expect(accNumber.disabled).toBe(true);
        });
      });
    });
  });

  it("check if no accounts are selected for all issue types except financial hardship", () => {
    const element = createElement("c-create-complaint-l-w-c", {
      is: CreateComplaintForm
    });
    element.recordTypeDevName = "Customer_Complaint";
    document.body.appendChild(element);

    const issueType = element.shadowRoot.querySelector(
      "lightning-input-field[data-id=issueType-id]"
    );
    issueType.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "12"
        }
      })
    );
    return Promise.resolve().then(() => {
      //Verify if the Account number field is not disabled
      const accNumber = element.shadowRoot.querySelector(
        "c-multi-select-combobox[data-id=accPolicyNum-id]"
      );
      expect(accNumber.disabled).toBe(false);
    });
  });

  it("check if close complaint child component is loaded if complaint is closed", () => {
    const element = createElement("c-create-complaint-l-w-c", {
      is: CreateComplaintForm
    });
    element.recordTypeDevName = "Customer_Complaint";
    document.body.appendChild(element);
    const complaintStatus = element.shadowRoot.querySelector(
      "lightning-combobox[data-id=caseStatus-id]"
    );
    complaintStatus.value = "Closed";
    complaintStatus.dispatchEvent(new CustomEvent("change"));
    return Promise.resolve().then(() => {
      const childCompElement = element.shadowRoot.querySelectorAll(
        "c-complaints-close-child"
      );
      expect(childCompElement).not.toBeNull;
      expect(childCompElement.length).toBe(1);
    });
  });

  it("create a closed case successfully", () => {
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

    const customerComms = element.shadowRoot.querySelector(
      "lightning-input[data-id=customerNotification-id]"
    );
    expect(customerComms).toBeTruthy();

    customerComms.dispatchEvent(
      new CustomEvent("change", {
        detail: {
          value: "true"
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
      "c-multi-select-combobox[data-id=accPolicyNum-id]"
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
      "lightning-textarea[data-id=descOfIssue-id]"
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
    //Populate user input - is real form required
    const realFormRequired = element.shadowRoot.querySelector(
      "lightning-radio-group[data-id=realFormRequiredGroup-id]"
    );
    //Populate user input - is real form submitted
    const realFormSubmitted = element.shadowRoot.querySelector(
      "lightning-radio-group[data-id=realFormSubmittedGroup-id]"
    );
    //Populate user input - real form reference number
    const realFormRefNo = element.shadowRoot.querySelector(
      "lightning-input[data-id=realFormRefNoGroup]"
    );
    realFormRequired.dispatchEvent(
      new CustomEvent("change", { detail: { value: "Yes" } }),
      () => {
        //Asserting for required scenario (positive)
        expect(realFormSubmitted.required).toBe(true);
        realFormSubmitted.dispatchEvent(
          new CustomEvent("change", { detail: { value: "Yes" } }),
          () => {
            realFormRefNo.dispatchEvent(
              new CustomEvent("change", { detail: { value: "123456789" } })
            );
          }
        );
      }
    );
    realFormRequired.dispatchEvent(
      new CustomEvent("change", { detail: { value: "No" } }),
      () => {
        //Asserting for not required scenario (negative)
        expect(realFormSubmitted.required).toBe(false);
      }
    );
    //Populate user input - possible systemic issue
    const possibleSystemicIssue = element.shadowRoot.querySelector(
      "lightning-radio-group[data-id=commoncomplaintGroup-id]"
    );
    possibleSystemicIssue.value = "No";
    possibleSystemicIssue.dispatchEvent(new CustomEvent("change"));

    const complaintStatus = element.shadowRoot.querySelector(
      "lightning-combobox[data-id=caseStatus-id]"
    );
    complaintStatus.value = "Closed";
    complaintStatus.dispatchEvent(new CustomEvent("change"));
    return Promise.resolve().then(() => {
      const childCompElement = element.shadowRoot.querySelector(
        "c-complaints-close-child"
      );
      //Select Complaint Outcome
      childCompElement.dispatchEvent(
        new CustomEvent("fieldvalueupdate", {
          detail: {
            field: "IDR_Complaint_Outcome__c",
            value: "1"
          }
        })
      );
      return Promise.resolve().then(() => {
        //Input Description of Outcome
        childCompElement.dispatchEvent(
          new CustomEvent("fieldvalueupdate", {
            detail: {
              field: "IDR_Description_of_Outcome__c",
              value: "Test_Description"
            }
          })
        );
        return Promise.resolve().then(() => {
          //Select Complaint Remedy 1
          childCompElement.dispatchEvent(
            new CustomEvent("fieldvalueupdate", {
              detail: {
                field: "IDR_Complaint_Remedy__c",
                value: "1"
              }
            })
          );
          return Promise.resolve().then(() => {
            //Select Complaint Sub Remedy
            childCompElement.dispatchEvent(
              new CustomEvent("fieldvalueupdate", {
                detail: {
                  field: "IDR_Complaint_Sub_Remedy__c",
                  value: "2"
                }
              })
            );
            return Promise.resolve().then(() => {
              //Input Financial Amount
              childCompElement.dispatchEvent(
                new CustomEvent("fieldvalueupdate", {
                  detail: {
                    field: "IDR_Financial_Compensation__c",
                    value: "1000"
                  }
                })
              );
              return Promise.resolve().then(() => {
                //Select Remedy 2
                childCompElement.dispatchEvent(
                  new CustomEvent("fieldvalueupdate", {
                    detail: {
                      field: "Remedy2",
                      value: true
                    }
                  })
                );
                return Promise.resolve().then(() => {
                  //Select Complaint Remedy 2
                  childCompElement.dispatchEvent(
                    new CustomEvent("fieldvalueupdate", {
                      detail: {
                        field: "IDR_Complaint_Remedy_2__c",
                        value: "4"
                      }
                    })
                  );
                  return Promise.resolve().then(() => {
                    //Select Complaint Sub Remedy 2
                    childCompElement.dispatchEvent(
                      new CustomEvent("fieldvalueupdate", {
                        detail: {
                          field: "IDR_Complaint_Sub_Remedy_2__c",
                          value: "8"
                        }
                      })
                    );
                    return Promise.resolve().then(() => {
                      //Select Remedy 3
                      childCompElement.dispatchEvent(
                        new CustomEvent("fieldvalueupdate", {
                          detail: {
                            field: "Remedy3",
                            value: true
                          }
                        })
                      );
                      return Promise.resolve().then(() => {
                        //Select Complaint Remedy 3
                        childCompElement.dispatchEvent(
                          new CustomEvent("fieldvalueupdate", {
                            detail: {
                              field: "IDR_Complaint_Remedy_3__c",
                              value: "2"
                            }
                          })
                        );
                        return Promise.resolve().then(() => {
                          //Select Complaint Sub Remedy 3
                          childCompElement.dispatchEvent(
                            new CustomEvent("fieldvalueupdate", {
                              detail: {
                                field: "IDR_Complaint_Sub_Remedy_3__c",
                                value: "1"
                              }
                            })
                          );
                          return Promise.resolve().then(() => {
                            //Save Complaint
                            //click Create Case button to validate fields entered
                            const saveButton = element.shadowRoot.querySelector(
                              ".saveButton"
                            );
                            saveButton.click();
                            expect(saveButton).toBeTruthy();

                            const complaintForm = element.shadowRoot.querySelector(
                              "lightning-record-edit-form"
                            );
                            complaintForm.submit = jest.fn();
                            //submit EVENT gets dispatched, which triggers a handler function that will call the submit FUNCTION
                            complaintForm.dispatchEvent(
                              new CustomEvent("submit", {
                                detail: { fields: {} }
                              })
                            );
                          });
                        });
                      });
                    });
                  });
                });
              });
            });
          });
        });
      });
    });
  });
});
