import { FlexCardMixin } from "omnistudio/flexCardMixin";
import { CurrentPageReference } from "lightning/navigation";
import { interpolateWithRegex } from "omnistudio/flexCardUtility";

import { LightningElement, api, track, wire } from "lwc";
import pubsub from "omnistudio/pubsub";
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
  wiredRecord0({ error, wiredDdata }) {
    if (this.objectApiName === "Case") {
      if (wiredDdata && this.firstRender0) {
        this.firstRender0 = false;
      } else {
        this.recordChangeEventHandler(error, wiredDdata, 0);
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

  registerEvents() {
    this.pubsubEvent[0] = {
      [interpolateWithRegex(
        `closeFlyout`,
        this._allMergeFields,
        this._regexPattern,
        "noparse"
      )]: this.handleEventAction.bind(this, data.events[1], 1)
    };
    this.pubsubChannel0 = interpolateWithRegex(
      `CreditAssessmentParent`,
      this._allMergeFields,
      this._regexPattern,
      "noparse"
    );
    pubsub.register(this.pubsubChannel0, this.pubsubEvent[0]);
  }

  unregisterEvents() {
    pubsub.unregister(this.pubsubChannel0, this.pubsubEvent[0]);
  }

  renderedCallback() {
    super.renderedCallback();
  }
}
