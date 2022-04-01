import { LightningElement, track, api, wire } from "lwc";
import getCaseDurationTime from "@salesforce/apex/CaseDurationService.getCaseDurationTime";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { getRecord } from "lightning/uiRecordApi";
import CASE_STATUS_FIELD from "@salesforce/schema/Case.Status";

const STATUS = {
  Closed: "Closed",
  On_Hold: "On Hold",
  Resolved: "Resolved",
  Withdrawn: "Withdrawn"
};

export default class CaseDuration extends LightningElement {
  @track durationTime;
  @api recordId;
  @track caseStatus;
  @track durationStop = false;
  timeIntervalInstance;
  totalSeconds = 0;
  hours;
  minutes;
  days;
  dayCounter = 0;
  dayString;
  hourString;
  minuteString;
  durationString;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [CASE_STATUS_FIELD]
  })
  wiredProject({ data }) {
    if (data) {
      this.caseStatus = data.fields.Status.value;
      if (this.isCaseStopped()) {
        this.stopTimer();
      }
    }
  }

  connectedCallback() {
    // Get case duration time
    this.handleGetCaseDurationTime(); // Call this once before starting the interval
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.timeIntervalInstance = setInterval(() => {
      this.handleGetCaseDurationTime();
    }, 60000);
  }

  disconnectedCallback() {
    clearInterval(this.timeIntervalInstance); // Making sure we're not making calls to server when case page is closed
  }

  handleGetCaseDurationTime() {
    getCaseDurationTime({
      caseId: this.recordId
    })
      .then((result) => {
        this.durationTime = result;
        this.days = Math.floor(this.durationTime.hours / 24);
        if (this.isCaseStopped()) {
          this.stopTimer();
        } else {
          this.durationStop = false;
        }

        this.handleDate(this.durationTime.hours, this.durationTime.minutes);
      })
      .catch((error) => {
        let errorMessage = "Failed to load case duration";
        if (error.body && error.body.message) {
          errorMessage = error.body.message;
        }
        this.showToast("Case Duration Load Failed", errorMessage, error);
      });
  }

  showToast(theTitle, theMessage, theVariant) {
    const event = new ShowToastEvent({
      title: theTitle,
      message: theMessage,
      variant: theVariant
    });
    this.dispatchEvent(event);
  }

  handleDate(hours, minutes) {
    let date = new Date();

    date.setMinutes(minutes);
    date.setHours(hours);

    this.minutes = date.getMinutes();
    this.hours = date.getHours();

    this.dayString =
      this.days === 0
        ? ""
        : this.days === 1
        ? `${this.days} Day `
        : `${this.days} Days `;

    this.hourString =
      this.hours === 0
        ? ""
        : this.hours === 1
        ? `${this.hours} Hour `
        : `${this.hours} Hours `;

    this.minuteString =
      this.minutes === 0
        ? ""
        : this.minutes === 1
        ? `${this.minutes} Minute`
        : `${this.minutes} Minutes`;

    if (!this.dayString && !this.hourString && !this.minuteString) {
      this.minuteString = `${this.minutes} Minutes`;
    }

    this.durationString = `${this.dayString} ${this.hourString} ${this.minuteString}`;

    if (!this.isCaseStopped()) {
      if (
        date.getHours() === 23 &&
        date.getMinutes() === 59 &&
        date.getSeconds() === 59
      ) {
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
          this.dayCounter++;
          this.days += this.dayCounter;
          this.durationString = `${this.dayString} ${this.hourString} ${this.minuteString}`;
        }, 1000);
      }
    }
  }

  isCaseStopped() {
    if (
      this.caseStatus === STATUS.On_Hold ||
      this.caseStatus === STATUS.Closed ||
      this.caseStatus === STATUS.Resolved ||
      this.caseStatus === STATUS.Withdrawn
    ) {
      return true;
    }
    return false;
  }

  stopTimer() {
    this.durationStop = true;
    clearInterval(this.timeIntervalInstance);
  }
}
