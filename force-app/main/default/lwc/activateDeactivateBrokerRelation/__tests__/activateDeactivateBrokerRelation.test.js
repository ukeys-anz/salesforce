import { createElement } from "lwc";
import activateDeactivateBrokerRelation from "c/activateDeactivateBrokerRelation";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
const mockData = require("./data/brokerRelationData.json");

describe("c-activate-deactivate-broker-relation", () => {
  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });

  // Helper function to wait until the microtask queue is empty. This is needed for promise
  async function flushPromises() {
    return Promise.resolve();
  }

  it("check invoke method", async () => {
    const element = createElement("c-activate-deactivate-broker-relation", {
      is: activateDeactivateBrokerRelation
    });
    document.body.appendChild(element);

    // Emit mock record into the wired field
    const brokerSetMock = JSON.parse(JSON.stringify(mockData));
    brokerSetMock.fields.RecordType.value.fields.DeveloperName.value =
      "Broker_Set";
    brokerSetMock.fields.IsActive__c = false;
    getRecord.emit(brokerSetMock);
    await flushPromises();

    element.recordId = "a2oAD000000Yq0zYAC";
    await element.invoke();
    await flushPromises();
    expect(updateRecord).toHaveBeenCalled();
  });

  it("check updateRecord method", async () => {
    const element = createElement("c-activate-deactivate-broker-relation", {
      is: activateDeactivateBrokerRelation
    });
    document.body.appendChild(element);

    // Emit mock record into the wired field
    getRecord.emit(mockData);
    await flushPromises();

    const toastHandler = jest.fn();
    element.addEventListener("lightning__showtoast", toastHandler);

    updateRecord.mockResolvedValue({
      fields: {
        IsActive__c: {
          value: false
        },
        Name: {
          value: "OG 4 1"
        },
        RecordType: {
          value: {
            fields: {
              DeveloperName: {
                value: "Office_Group"
              }
            }
          }
        }
      }
    });
    element.recordId = "a2oAD000000Yq0zYAC";
    await element.invoke();
    await flushPromises();

    expect(updateRecord).toHaveBeenCalled();
    expect(toastHandler).toHaveBeenCalled();
    expect(toastHandler.mock.calls[0][0].detail.variant).toBe("Success");
    expect(toastHandler.mock.calls[0][0].detail.title).toBe("Success");
  });

  it("handle toast event success", async () => {
    const element = createElement("c-activate-deactivate-broker-relation", {
      is: activateDeactivateBrokerRelation
    });
    document.body.appendChild(element);

    // Emit mock record into the wired field
    getRecord.emit(mockData);
    await flushPromises();

    const toastHandler = jest.fn();
    element.addEventListener("lightning__showtoast", toastHandler);

    element.recordId = "a2oAD000000Yq0zYAC";
    await element.invoke();
    await flushPromises();

    expect(updateRecord).toHaveBeenCalled();
    expect(toastHandler).toHaveBeenCalled();
    expect(toastHandler.mock.calls[0][0].detail.variant).toBe("Success");
    expect(toastHandler.mock.calls[0][0].detail.title).toBe("Success");
  });

  it("handle toast event error", async () => {
    const element = createElement("c-activate-deactivate-broker-relation", {
      is: activateDeactivateBrokerRelation
    });
    document.body.appendChild(element);

    getRecord.emit(mockData);
    await flushPromises();

    const toastHandler = jest.fn();
    element.addEventListener("lightning__showtoast", toastHandler);

    // Emit mock record into the wired field
    const errorMsg = "Update failed";
    updateRecord.mockRejectedValue({
      body: {
        output: {
          errors: [
            {
              message: errorMsg
            }
          ]
        }
      }
    });
    await flushPromises();

    element.recordId = "a2oAD000000Yq0zYAC";
    await element.invoke();
    await flushPromises();

    expect(updateRecord).toHaveBeenCalled();
    expect(toastHandler).toHaveBeenCalled();
    expect(toastHandler.mock.calls[0][0].detail.variant).toBe("Error");
    expect(toastHandler.mock.calls[0][0].detail.title).toBe("Error Occurred");
    expect(toastHandler.mock.calls[0][0].detail.message).toContain(errorMsg);
  });
});
