import { LightningElement, track, api, wire } from "lwc";
import getCaseDurationTime from "@salesforce/apex/CaseDurationService.getCaseDurationTime";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { getRecord } from "lightning/uiRecordApi";
import CASE_STATUS_FIELD from "@salesforce/schema/Case.Status";

export default class CaseDuration extends LightningElement {
  @track durationTime;
  @api recordId;
  @track caseStatus;
  @track caseOnHold = false;
  pulseClass;
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
    }
  }

  connectedCallback() {
    getCaseDurationTime({
      caseId: this.recordId
    })
      .then((result) => {
        this.durationTime = result;
        if (this.caseStatus === "On Hold" || this.caseStatus === "Closed") {
          this.durationStop = true;
          this.hours = this.durationTime.hours;
          this.minutes = this.durationTime.minutes;
        } else {
          this.pulseClass = "pulsate";
          let parentThis = this;
          this.days = Math.floor(this.durationTime.hours / 24);

          // eslint-disable-next-line @lwc/lwc/no-async-operation
          this.timeIntervalInstance = setInterval(() => {
            let date = new Date();

            date.setMinutes(parentThis.durationTime.minutes);
            date.setHours(parentThis.durationTime.hours);
            date.setSeconds(parentThis.totalSeconds);

            parentThis.minutes = date.getMinutes();
            parentThis.hours = date.getHours();

            parentThis.dayString =
              parentThis.days === 0
                ? ""
                : parentThis.days === 1
                ? `${parentThis.days} Day `
                : `${parentThis.days} Days `;
            parentThis.hourString =
              parentThis.hours === 0
                ? ""
                : parentThis.hours === 1
                ? `${parentThis.hours} Hour `
                : `${parentThis.hours} Hours `;
            parentThis.minuteString =
              parentThis.minutes === 0
                ? ""
                : parentThis.minutes === 1
                ? `${parentThis.minutes} Minute`
                : `${parentThis.minutes} Minutes`;

            if (
              date.getHours() === 23 &&
              date.getMinutes() === 59 &&
              date.getSeconds() === 59
            ) {
              // eslint-disable-next-line @lwc/lwc/no-async-operation
              setTimeout(() => {
                parentThis.dayCounter++;
                parentThis.days += parentThis.dayCounter;
                parentThis.durationString = `${parentThis.dayString} ${parentThis.hourString} ${parentThis.minuteString}`;
              }, 1000);
            } else {
              parentThis.durationString = `${parentThis.dayString} ${parentThis.hourString} ${parentThis.minuteString}`;
            }

            parentThis.totalSeconds += 1;
          }, 1000);
        }
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
}
