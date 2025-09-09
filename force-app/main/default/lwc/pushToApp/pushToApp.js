import { LightningElement, wire, api } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import {
  EnclosingTabId,
  getTabInfo,
  openSubtab
} from "lightning/platformWorkspaceApi";
import getAemContentData from "@salesforce/apex/PushToAppController.getAemContentData";
import createTaskAndRelatedRecords from "@salesforce/apex/PushToAppController.createTaskAndRelatedRecords";
const TASK_CREATION_FAILED =
  "Task Creation Failed: We encountered an issue while creating the task. Raise a fault though TechAssist if the issue persist.";
const TEMPLATE_FETCH_ERROR =
  "Unable to fetch template: There was an error retrieving content from AEM. Try again or raise a fault through TechAssist if the issue persists.";
const FIELD_MAP = {
  Case: [{ fieldApiName: "CaseNumber", objectApiName: "Case" }]
};

export default class PushToApp extends LightningElement {
  @api recordId;
  @api objectApiName;
  @api templateOptions = [];
  fields = [];
  _showPushTaskButton = true;
  isSendNowDisabled = true;
  _showPushTaskScreen = false;
  _showSuccessScreen = false;
  _showAdditionalFields = false;
  _hasError = false;
  isLoading = false;
  steps = [];
  actions = [];
  caseRecordId;
  caseNumber;
  expiryDate;
  notificationPreview;
  taskRecordId;
  callToActionValues;
  notificationConfigTitle;
  notificationConfigId;
  aemContentData;
  errorMsg;
  taskNumber;

  @wire(EnclosingTabId) tabId;

  get showPushTaskButton() {
    return this._showPushTaskButton;
  }
  @api showPushTaskButtonFromParent(value) {
    this._showPushTaskButton = !value;
    this._showPushTaskScreen = value;
    this._showSuccessScreen = value;
  }

  get showPushTaskScreen() {
    return this._showPushTaskScreen;
  }

  get showAdditionalFields() {
    return this._showAdditionalFields;
  }

  get showSuccessScreen() {
    return this._showSuccessScreen;
  }

  get hasError() {
    return this._hasError;
  }

  connectedCallback() {
    if (this.objectApiName && FIELD_MAP[this.objectApiName]) {
      this.fields = FIELD_MAP[this.objectApiName];
    }
  }

  @wire(getRecord, { recordId: "$recordId", fields: "$fields" })
  getCaseRecordData({ data, error }) {
    if (data) {
      const fieldEntryMap = FIELD_MAP[this.objectApiName];
      const fieldName = fieldEntryMap[0].fieldApiName;
      this.caseNumber = data.fields[fieldName].value;
    } else if (error) {
      this.handleError(error);
    }
  }

  async handleTemplateSelect(event) {
    try {
      if (!event.target.value) {
        return;
      }
      let result = await getAemContentData({
        aemContentId: event.target.value,
        recordId: this.recordId
      });
      const pushToAppData = result.data.pushToAppList.items[0];
      if (pushToAppData) {
        // to check if error has occured earlier if yes, clear the error message from UI
        if (this._hasError) {
          this._hasError = false;
        }
        this._showAdditionalFields = true;
        this.isSendNowDisabled = false;
        this.aemContentData = pushToAppData;
        this.notificationConfigTitle = pushToAppData.title;
        this.notificationPreview = pushToAppData.bodyText;
        this.expiryDate = pushToAppData.expiryDate;
        this.notificationConfigId = pushToAppData.notificationConfigId;
        this.actions = [];
        pushToAppData.steps.forEach((step) => {
          this.actions = [...this.actions, ...step.actions];
        });
        this.callToActionValues = this.actions
          .map((action) => action.description)
          .join(", ");
      }
    } catch (error) {
      this.handleError(TEMPLATE_FETCH_ERROR);
      this._showAdditionalFields = false;
      this.isSendNowDisabled = true;
    }
  }

  handlePushTaskClick() {
    this._showPushTaskScreen = true;
    this._showPushTaskButton = false;
    this.disptachEventForParentLwc("pushtaskbuttonclick");
  }

  async handleSendNow() {
    this.isLoading = true;
    if (this._hasError) {
      this._hasError = false;
    }
    const notifDataWrapperValue = {
      aemContentData: JSON.stringify(this.aemContentData),
      aemContentObject: this.aemContentData
    };
    const taskResponseWrapperValue = {
      subject: this.notificationConfigTitle,
      activityDate: this.expiryDate,
      description: this.notificationPreview,
      notificationConfigId: this.notificationConfigId,
      whatId: this.recordId,
      callToAction: this.callToActionValues,
      caseNumber: this.caseNumber
    };
    try {
      let taskData = await createTaskAndRelatedRecords({
        pushToAppTaskData: taskResponseWrapperValue,
        customerTaskData: notifDataWrapperValue
      });
      this.taskRecordId = taskData.Id;
      this.taskNumber = taskData.TaskNumber__c;
      this._showPushTaskScreen = false;
      this._showSuccessScreen = true;
    } catch (error) {
      this.handleError(TASK_CREATION_FAILED);
    }
    this.isLoading = false;
  }

  handleCancel() {
    this.handleShowPushATaskButton();
    this.disptachEventForParentLwc("cancelclick");
  }

  handleRefresh() {
    this.handleShowPushATaskButton();
    this._showSuccessScreen = false;
    this.disptachEventForParentLwc("cancelclick");
  }

  disptachEventForParentLwc(eventName) {
    this.dispatchEvent(new CustomEvent(eventName));
  }

  handleShowPushATaskButton() {
    if (this._hasError) {
      this._hasError = false;
    }
    this._showPushTaskButton = true;
    this._showPushTaskScreen = false;
    this._showAdditionalFields = false;
    this.isSendNowDisabled = true;
  }

  async handleTaskClick() {
    if (!this.tabId) {
      return;
    }
    const tabInfo = await getTabInfo(this.tabId);
    const primaryTabId = tabInfo.isSubtab ? tabInfo.parentTabId : tabInfo.tabId;
    await openSubtab(primaryTabId, {
      recordId: this.taskRecordId,
      parentTabId: primaryTabId
    });
  }

  handleError = (error) => {
    this._hasError = true;
    this.errorMsg = error;
  };
}
