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
  showAccChatTabHead = false;
  showCaseChatTabHead = false;
  @api recordId;
  @api showAppTab;
  @api showIntTab;
  @api maxRecords;

  handleShowAppointmentTab() {
    this.showAppointmentTab = true;
    this.showInteractionTab = false;
    this.showChatTab = false;
    this.appointmentTab = ACTIVE_TAB;
    this.interactionTab = NORMAL_TAB;
    this.chatTab = NORMAL_TAB;
  }

  handleShowInteractionTab() {
    this.showAppointmentTab = false;
    this.showInteractionTab = true;
    this.showChatTab = false;
    this.appointmentTab = NORMAL_TAB;
    this.interactionTab = ACTIVE_TAB;
    this.chatTab = NORMAL_TAB;
  }

  handleShowChatTab() {
    this.showAppointmentTab = false;
    this.showInteractionTab = false;
    this.showChatTab = true;
    this.appointmentTab = NORMAL_TAB;
    this.interactionTab = NORMAL_TAB;
    this.chatTab = ACTIVE_TAB;
  }

  connectedCallback() {
    if (!this.showAppTab) {
      this.handleShowInteractionTab();
    }

    getSObjectType({
      sId: this.recordId
    }).then((result) => {
      if (result != null) {
        this.sObjectType = result;
        if (result === "Account") {
          this.showAccChatTabHead = true;
        }
        if (result === "Case") {
          this.showCaseChatTabHead = true;
          this.handleShowChatTab();
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
      if (result != null) {
        this.appointmentList = result;
      }
    });
  }

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

  handleNewButton() {
    getNewRecordInfo({
      sId: this.recordId,
      isAppointment: this.showAppointmentTab
    }).then((result) => {
      let fieldName = result.fieldName;
      let selectRecordType = result.recordTypeInfo;
      let valueSet = {};
      valueSet[fieldName] = this.recordId;
      const defaultValues = encodeDefaultFieldValues(valueSet);
      this[NavigationMixin.Navigate]({
        type: "standard__objectPage",
        attributes: {
          objectApiName: "Interaction",
          actionName: "new"
        },
        state: {
          defaultFieldValues: defaultValues,
          nooverride: "1",
          recordTypeId: selectRecordType
        }
      });
    });
  }

  handleViewAll() {
    console.log(this.sObjectType);
    let relationshiptName = "Interactions__r";
    if (this.sObjectType === "Account") {
      relationshiptName = "Interactions";
    }
    this[NavigationMixin.Navigate]({
      type: "standard__recordRelationshipPage",
      attributes: {
        recordId: this.recordId,
        objectApiName: this.sObjectType,
        relationshipApiName: relationshiptName,
        actionName: "view"
      }
    });
  }
}
