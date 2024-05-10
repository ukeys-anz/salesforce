import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getInteractions from "@salesforce/apex/InteractionRelatedListController.getInteractions";
import getAppointments from "@salesforce/apex/InteractionRelatedListController.getAppointments";
import getSObjectType from "@salesforce/apex/InteractionRelatedListController.getSObjectType";
import getNewRecordInfo from "@salesforce/apex/InteractionRelatedListController.getNewRecordInfo";
import { encodeDefaultFieldValues } from "lightning/pageReferenceUtils";

const NORMAL_TAB = "slds-tabs_scoped__item";
const ACTIVE_TAB = "slds-tabs_scoped__item slds-is-active";

export default class InteractionRelatedList extends NavigationMixin(
  LightningElement
) {
  showAppointmentTab = true;
  showInteractionTab = false;
  showChatTab = false;
  appointmentTab = ACTIVE_TAB;
  interactionTab = NORMAL_TAB;
  chatTab = NORMAL_TAB;
  interactionList;
  appointmentList;
  sObjectType;
  showMessageTab = false;
  showCallTab = false;
  showStoreTab = false;
  messageTab = NORMAL_TAB;
  callTab = NORMAL_TAB;
  storeTab = NORMAL_TAB;
  lightningPageName = "InteractionCustomListViews";
  messageRecord = "Message";
  generalRecord = "General";
  storeRecord = "Store";
  appointmentRecord = "Appointment";
  showViewAll = false;
  showAppointmentRecords = false;
  interactionTabTitle = "Messages";
  _showActiveMsgInteraction;

  @api recordId;
  @api showAppTab;
  @api showIntTab;
  @api maxRecords;
  @api showMsgTab;
  @api showCallIntTab;
  @api showStoreIntTab;
  @api tabTitle;
  @api
  get showActiveMsgInteraction() {
    return this._showActiveMsgInteraction
      ? this._showActiveMsgInteraction
      : false;
  }

  set showActiveMsgInteraction(value) {
    this._showActiveMsgInteraction = value;
  }

  // This method will help in showing the list of appointments under appointment tab
  handleShowAppointmentTab() {
    this.showAppointmentTab = true;
    this.showInteractionTab = false;
    this.showChatTab = false;
    this.appointmentTab = ACTIVE_TAB;
    this.interactionTab = NORMAL_TAB;
    this.chatTab = NORMAL_TAB;
    this.showMessageTab = false;
    this.showCallTab = false;
    this.showStoreTab = false;
    this.messageTab = NORMAL_TAB;
    this.callTab = NORMAL_TAB;
    this.storeTab = NORMAL_TAB;
  }

  // This method will help in showing the list of Message interactions under Message tab
  handleShowMessageTab() {
    this.showAppointmentTab = false;
    this.showInteractionTab = false;
    this.showChatTab = false;
    this.appointmentTab = NORMAL_TAB;
    this.interactionTab = NORMAL_TAB;
    this.chatTab = NORMAL_TAB;
    this.showMessageTab = true;
    this.showCallTab = false;
    this.showStoreTab = false;
    this.messageTab = ACTIVE_TAB;
    this.callTab = NORMAL_TAB;
    this.storeTab = NORMAL_TAB;
  }

  // This method will help in showing the list of Call interactions under Call tab
  handleShowCallTab() {
    this.showAppointmentTab = false;
    this.showInteractionTab = false;
    this.showChatTab = false;
    this.appointmentTab = NORMAL_TAB;
    this.interactionTab = NORMAL_TAB;
    this.chatTab = NORMAL_TAB;
    this.showMessageTab = false;
    this.showCallTab = true;
    this.showStoreTab = false;
    this.messageTab = NORMAL_TAB;
    this.callTab = ACTIVE_TAB;
    this.storeTab = NORMAL_TAB;
  }

  // This method will help in showing the list of In Person interactions under In Person tab
  handleShowStoreTab() {
    this.showAppointmentTab = false;
    this.showInteractionTab = false;
    this.showChatTab = false;
    this.appointmentTab = NORMAL_TAB;
    this.interactionTab = NORMAL_TAB;
    this.chatTab = NORMAL_TAB;
    this.showMessageTab = false;
    this.showCallTab = false;
    this.showStoreTab = true;
    this.messageTab = NORMAL_TAB;
    this.callTab = NORMAL_TAB;
    this.storeTab = ACTIVE_TAB;
  }

  // this method help in making the default tab on pageload
  connectedCallback() {
    if (!this.showAppTab) {
      this.handleShowMessageTab();
    } else {
      this.handleShowAppointmentTab();
    }

    getSObjectType({
      sId: this.recordId
    }).then((result) => {
      if (result != null) {
        this.sObjectType = result;
        if (result === "Account") {
          this.handleShowMessageTab();
        }
        if (result === "Coaching_Summary__c") {
          this.handleShowMessageTab();
        }
        if (result === "ResidentialLoanApplication") {
          this.handleShowMessageTab();
        }
      }
    });

    getInteractions({
      sId: this.recordId,
      maxNumber: this.maxRecords
    }).then((result) => {
      if (result != null) {
        this.interactionList = result;
      }
    });

    getAppointments({
      sId: this.recordId,
      maxNumber: this.maxRecords
    }).then((result) => {
      if (result != null && result.length > 0) {
        this.appointmentList = result;
        this.showAppointmentRecords = true;
      }
    });
  }

  //This method will help in navigating to specific interaction after clicking on actual topic link etc
  handleViewRecord(evt) {
    evt.preventDefault();
    evt.stopPropagation();

    let rId = evt.currentTarget.dataset.id;

    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: rId,
        objectApiName: "Interaction",
        actionName: "view"
      }
    });
  }

  // This helps in creating a new interaction
  handleNewButton() {
    getNewRecordInfo({
      sId: this.recordId,
      isAppointment: this.showAppointmentTab
    }).then((result) => {
      let fieldName = result.fieldName;
      let selectRecordType = result.recordTypeInfo;
      let valueSet = {};
      let stateValue = null;

      valueSet[fieldName] = this.recordId;
      const defaultValues = encodeDefaultFieldValues(valueSet);

      if (selectRecordType) {
        stateValue = {
          defaultFieldValues: defaultValues,
          nooverride: "1",
          recordTypeId: selectRecordType
        };
      } else {
        stateValue = {
          defaultFieldValues: defaultValues,
          nooverride: "1",
          useRecordTypeCheck: "1"
        };
      }

      this[NavigationMixin.Navigate]({
        type: "standard__objectPage",
        attributes: {
          objectApiName: "Interaction",
          actionName: "new"
        },
        state: stateValue
      });
    });
  }

  // this method get the value from child and controls the visibilty of footer on parent record.
  fetchViewValue(event) {
    this.showViewAll = event.detail.showViewAll;
    this.interactionTabTitle = this.constructTabTitle(event);
  }

  constructTabTitle(event) {
    if (this.showActiveMsgInteraction) {
      return this.tabTitle + " (" + event.detail.totalInteractionCount + ")";
    }
    return this.tabTitle ? this.tabTitle : this.interactionTabTitle;
  }
}
