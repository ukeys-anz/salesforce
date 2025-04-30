import { LightningElement, api, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";

import styling from "@salesforce/resourceUrl/sopStyling";
import SOP_CONNECTED_APP from "@salesforce/resourceUrl/SOP_Connected_App";
import getConsolidatedSOP from "@salesforce/apex/SOPController.getConsolidatedSOP";
import {
  subscribe,
  unsubscribe,
  MessageContext
} from "lightning/messageService";
import RefreshSOP from "@salesforce/messageChannel/RefreshSOP__c";

export default class SopFinances extends LightningElement {
  @api recordId;

  sop;
  errorMessage;
  sopAppImage = SOP_CONNECTED_APP;
  componentSpinner = false;
  errorMsg =
    "Failed to retrieve SOP details. Please refresh and try again. Raise a fault through TechAssist if the problem persists.";

  get hasPartiesConsentAndliabilitySources() {
    return this.sop?.sopSummaryViewModel?.allPartiesConsented;
  }

  @wire(MessageContext)
  messageContext;
  subscription;
  activeSections;

  async loadSOPData(activeSections) {
    this.sop = undefined;
    this.componentSpinner = true;
    try {
      this.sop = await getConsolidatedSOP({ loanId: this.recordId });
      this.errorMessage = undefined;
      if (Array.isArray(activeSections)) {
        this.activeSections = activeSections;
      } else {
        this.activeSections = [];
      }
    } catch (error) {
      this.errorMessage = error;
      this.sop = undefined;
    } finally {
      this.componentSpinner = false;
    }
  }

  connectedCallback() {
    this.loadSOPData();
    Promise.all([loadStyle(this, styling)]);
    this.subscribeToMessageChannel();
  }
  disconnectedCallback() {
    if (this.subscription) {
      unsubscribe(this.subscription);
      this.subscription = null;
    }
  }

  refreshAmounts(activeSections) {
    this.loadSOPData(activeSections);
  }

  subscribeToMessageChannel() {
    if (!this.subscription) {
      this.subscription = subscribe(
        this.messageContext,
        RefreshSOP,
        (message) => {
          if (message.refresh) {
            this.refreshAmounts(this.activeSections);
          }
        }
      );
    }
  }

  handleSectionToggle(event) {
    this.activeSections = event.detail.openSections;
  }
}
