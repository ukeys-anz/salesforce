import { LightningElement, api, wire } from "lwc";
import { getRecord, updateRecord } from "lightning/uiRecordApi";
import {
  EnclosingTabId,
  getFocusedTabInfo
} from "lightning/platformWorkspaceApi";
import { showToast, handleWireError } from "c/utils";
import { computeLogic } from "./helper";
import { openPrompt } from "./actions/prompt";
import { openAlert } from "./actions/alert";
import { openConfirm } from "./actions/confirm";
import { RefreshEvent } from "lightning/refresh";
import CASE_ID_FIELD from "@salesforce/schema/Case.Id";
import CASE_COMMENTS_FIELD from "@salesforce/schema/Case.Comments";
import CURRENT_USER_ID from "@salesforce/user/Id";

const GENERIC_ERROR_MESSAGE =
  "Error occurred while performing operation. Please contact your system administrator.";

export default class CaseModal extends LightningElement {
  @api action; //Alert, Confirm, Prompt
  @api comment; //Used for Alert and Confirm ONLY
  @api condition; //Fields, Field Values and Operators to be met (in JSON format)
  @api message; //Modal message text
  @api theme; //Modal color theme
  @api title; //Modal header text
  @api variant; //Modal variant: header or headerless
  @api toastMessages; //Object which contains messages for success, error, warning when saving Case.Comments

  oldData;
  @api recordId;
  fields = [];

  @wire(EnclosingTabId) enclosingTabId;
  @wire(getRecord, { recordId: "$recordId", fields: "$fields" })
  async wiredRecord({ error, data }) {
    if (error) {
      handleWireError(this, "Error Occurred", error);
      return;
    }
    if (!data) {
      return;
    }

    const { tabId } = await getFocusedTabInfo();
    if (!this.oldData || tabId !== this.enclosingTabId) {
      this.oldData = data;
      return;
    }
    if (CURRENT_USER_ID !== data.lastModifiedById) {
      return;
    }

    try {
      const isValid = computeLogic(this._condition, this.oldData, data);
      this.oldData = data;

      if (!isValid) {
        return;
      }
      this.handleAction();
    } catch (e) {
      this.showError();
    }
  }

  _condition = [];
  _toastMessages = {};
  connectedCallback() {
    if (this.condition) {
      this._condition = JSON.parse(this.condition);
      this.fields = this._condition.map((a) => a.field);
    }
    if (this.toastMessages) {
      this._toastMessages = JSON.parse(this.toastMessages);
    }
  }

  handleAction() {
    if (!this.action) {
      return;
    }

    const actionsMap = {
      Prompt: () => openPrompt.call(this),
      Alert: () => openAlert.call(this),
      Confirm: () => openConfirm.call(this)
    };

    const actionHandler = actionsMap[this.action];
    if (actionHandler) {
      actionHandler();
    }
  }

  async addCaseComment(response = this.comment) {
    if (!response) {
      this.showWarning();
      return;
    }
    const recordInput = {
      fields: {
        [CASE_ID_FIELD.fieldApiName]: this.recordId,
        [CASE_COMMENTS_FIELD.fieldApiName]: response
      }
    };

    try {
      await updateRecord(recordInput);
      this.showSuccess();
      this.dispatchEvent(new RefreshEvent());
    } catch (e) {
      this.showError();
    }
  }

  showSuccess() {
    const message = this._toastMessages.success;
    if (message) {
      showToast(this, "Success", message, "", "success");
    }
  }

  showError() {
    showToast(
      this,
      "Error!",
      this._toastMessages.error ?? GENERIC_ERROR_MESSAGE,
      null,
      "error"
    );
  }

  showWarning() {
    const message = this._toastMessages.warning;
    if (message) {
      showToast(this, "Warning", message, "", "warning");
    }
  }
}
