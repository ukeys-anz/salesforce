import { createElement } from "lwc";
import { CloseScreenEventName } from "lightning/actions";
import LogInteractionOnCustomer from "c/logInteractionOnCustomer";
import { getRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { setImmediate } from "timers";
import getCommentTypeMapping from "@salesforce/apex/CCRMLogInteractionController.getCommentTypeMapping";

const mockGetObjectInfo = require("./data/getObjectInfo.json");
const mockGetRecord = require("./data/getRecord.json");
const mockGetCapDiaryRecord = require("./data/getCapDiaryRecord.json");

jest.mock(
  "@salesforce/apex/CCRMLogInteractionController.getCommentTypeMapping",
  () => {
    return {
      default: jest.fn()
    };
  },
  { virtual: true }
);

const flushPromises = () => new Promise(setImmediate);

describe("c-log-interaction-on-customer", () => {
  //Prepare data before each test method
  beforeEach(() => {
    const mockCommentType = {
      commentType:
        '{"Administration/Guardianship Order Exists":"Administration/Guardianship Order Exists. Refer authority held at BSB [XXXX]","ANZ Home Loan KYC VOI Update":"KYC VOI completed in person in branch. KYC = Pass/Fail VOI = Pass/Fail","Contact number required":"Contact number required","Cust Advising O/S Travel":"Cust Advising O/S Travel Depart [DDMM] Return [DDMM] Countries [List Names]","International Phone Number":"International Phone Number() Country()","Joint Accounts-Dispute":"Dispute between parties has been advised; follow documented disputed process.","MyTell Maker/Checker":"[Purpose], evidence sighted [Y/N], disclosed risks associated to scams-taking cash, transferring to unrelated party [Y/N]","No ATM cards":"Customer has requested no cards to be ordered on the account.","Other":null,"Power of Attoney (POA)":"Power of Attorney (POA) exists. Refer authority held at BSB [XXXX]","Unable to contact customer":"Unable to contact customer."}'
    };
    getCommentTypeMapping.mockResolvedValue(mockCommentType);
    const element = createElement("c-log-interaction-on-customer", {
      is: LogInteractionOnCustomer
    });
    document.body.appendChild(element);
  });

  afterEach(() => {
    // The jsdom instance is shared across test cases in a single file so reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    jest.clearAllMocks();
  });

  it("Test banker close the form", () => {
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");
    const closeScreenHandler = jest.fn();

    lwcCmp.addEventListener(CloseScreenEventName, closeScreenHandler);

    lwcCmp.shadowRoot
      .querySelector(".btnCancel")
      .dispatchEvent(new CustomEvent("click"));

    return flushPromises().then(() => {
      expect(closeScreenHandler).toHaveBeenCalled();
    });
  });

  it("Test banker save the form", async () => {
    getObjectInfo.emit(mockGetObjectInfo);
    getRecord.emit(mockGetRecord);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");
    const form = lwcCmp.shadowRoot.querySelector("lightning-record-edit-form");
    form.submit = jest.fn();
    form.dispatchEvent(new CustomEvent("submit", { detail: { fields: {} } }));
  });

  it("Test save CAP Diary Comments", async () => {
    getObjectInfo.emit(mockGetObjectInfo);
    getRecord.emit(mockGetCapDiaryRecord);

    await flushPromises();
    const lwcCmp = document.querySelector("c-log-interaction-on-customer");
    const inputElement = lwcCmp.shadowRoot.querySelectorAll(
      "lightning-input-field"
    );
    inputElement[0].value = "CAP Diary Comments";
    inputElement[0].dispatchEvent(
      new CustomEvent("change", { detail: { value: "CAP Diary Comments" } })
    );
    await flushPromises();
    const lookupEle = lwcCmp.shadowRoot.querySelector("c-lookup");
    lookupEle.dispatchEvent(
      new CustomEvent("select", {
        detail: { selected: { id: "a0F9h000001GMjxEAG" } }
      })
    );
    const form = lwcCmp.shadowRoot.querySelector("lightning-record-edit-form");
    form.submit = jest.fn();
    form.dispatchEvent(new CustomEvent("submit", { detail: { fields: {} } }));
  });
});
