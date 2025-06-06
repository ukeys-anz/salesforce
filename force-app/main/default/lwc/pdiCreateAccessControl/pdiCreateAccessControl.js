import { LightningElement, api, wire, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { EnclosingTabId, closeTab } from "lightning/platformWorkspaceApi";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { SimpleToast, SimpleNav } from "c/utils";

export default class PdiCreateAccessControl extends NavigationMixin(
  LightningElement
) {
  toast = new SimpleToast(this);
  nav = new SimpleNav(this);

  @api recordId;
  @api objectApiName;
  @api parentId;
  @api parentObjectApiName;

  layoutInfo;
  objectInfo;
  fieldCounter = 0;
  @track record = {};

  @wire(EnclosingTabId) tabId;

  //NOTE: field names are hard-coded since importing from schema is bugged for external objects.
  @wire(getRecord, {
    recordId: "$parentId",
    fields: [
      "PersonDigitalIdentity__x.UUID__c",
      "PersonDigitalIdentity__x.Persona_ID__c"
    ]
  })
  wireParentRecord({ error, data }) {
    if (error) {
      this.toast.error("Error loading parent record");
      this.handler.close();
    }
    if (!data) return;

    this.record = {
      PersonId__c: getFieldValue(data, "PersonDigitalIdentity__x.UUID__c"),
      PersonaId__c: getFieldValue(
        data,
        "PersonDigitalIdentity__x.Persona_ID__c"
      )
    };
  }

  get sections() {
    return this.layoutInfo.filter((section) => {
      let visible = true;
      if (section.heading === "Conditional Advice") {
        visible = this.record.Policy__c === "POLICY_CONDITIONAL";
      }
      section.fields.forEach((field) => {
        if (!visible) {
          delete this.record[field.apiName];
        }
        field.value = this.record[field.apiName];
      });
      return visible;
    });
  }

  connectedCallback() {
    if (this.parentId) return;

    this.toast.error("Parent record not found");
    closeTab(this.tabId);
  }

  handler = {
    load: (e) => {
      if (this.objectInfo) return;

      this.objectInfo = e.detail.objectInfos.AccessControl__x;
      this.layoutInfo = this.helper.transformLayout(e.detail.layout);
    },
    change: (e) => (this.record[e.target.dataset.apiname] = e.detail.value),
    submit: (e) => {
      e.preventDefault();
      this.template.querySelector("lightning-record-edit-form").submit({
        ...e.detail.fields,
        ...this.record
      });
    },
    error: (e) => this.toast.error(e.detail.message),
    success: (e) => {
      this.toast.success(`${this.objectInfo.label} created successfully`);
      this.nav.toRecord(e.detail.id);
    },
    close: () => this.nav.toRecord(this.parentId)
  };

  helper = {
    transformLayout: (layoutInfo) =>
      layoutInfo.sections
        .map((section) => ({
          heading: section.heading,
          fields: section.layoutRows
            .flatMap((row) => row.layoutItems)
            .flatMap((item) => this.helper.transformLayoutItem(item))
        }))
        .filter((section) => section.fields.some((field) => field.is.visible)),
    transformLayoutItem: (item) =>
      item.layoutComponents.map((cmp) => {
        const editable = this.helper.fieldEditable(cmp.apiName);
        const readonly = item.uiBehavior === "Readonly";
        return {
          id: this.fieldCounter++,
          is: {
            [cmp.apiName ?? "blankSpace"]: true,
            required: item.required,
            visible: editable,
            disabled: readonly && editable
          },
          ...cmp
        };
      }),
    fieldEditable: (field) => {
      return this.recordId
        ? this.objectInfo.fields[field].updateable
        : this.objectInfo.fields[field].createable;
    }
  };
}
