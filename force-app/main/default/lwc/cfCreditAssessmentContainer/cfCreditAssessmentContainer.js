import { FlexCardMixin } from "omnistudio/flexCardMixin";
import { CurrentPageReference } from "lightning/navigation";
// import {
//   interpolateWithRegex,
//   interpolateKeyValue,
//   loadCssFromStaticResource
// } from "omnistudio/flexCardUtility";

import { LightningElement, api, track, wire } from "lwc";
// import pubsub from "omnistudio/pubsub";
import { getRecord } from "lightning/uiRecordApi";

import data from "./definition";

import styleDef from "./styleDefinition";

export default class cfCreditAssessmentContainer extends FlexCardMixin(
  LightningElement
) {
  currentPageReference;
  @wire(CurrentPageReference)
  setCurrentPageReference(currentPageReference) {
    this.currentPageReference = currentPageReference;
  }
  @api debug;
  @api recordId;
  @api objectApiName;

  @track record;

  pubsubEvent = [];
  customEvent = [];

  firstRender0 = true;
  @wire(getRecord, {
    recordId: "$recordId",
    fields: "Case.Id",
    optionalFields: $cmp.getWireOptionalFields(data.events[0])
  })
  wiredRecord0({ error, wiredData }) {
    if (this.objectApiName === "Case") {
      if (wiredData && this.firstRender0) {
        this.firstRender0 = false;
      } else {
        this.recordChangeEventHandler(error, wiredData, 0);
      }
    }
  }

  connectedCallback() {
    super.connectedCallback();
    this.setThemeClass(data);
    this.setStyleDefinition(styleDef);
    data.Session = {}; //reinitialize on reload

    this.setDefinition(data);
    this.registerEvents();
  }

  disconnectedCallback() {
    super.disconnectedCallback();

    this.unregisterEvents();
  }

  registerEvents() {}

  unregisterEvents() {}

  renderedCallback() {
    super.renderedCallback();
  }
}
