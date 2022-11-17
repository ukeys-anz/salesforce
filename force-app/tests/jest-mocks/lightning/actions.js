/**
 * For the original lightning/platformShowToastEvent mock that comes by default with
 * @salesforce/sfdx-lwc-jest, see:
 * https://github.com/salesforce/sfdx-lwc-jest/blob/master/src/lightning-stubs/platformShowToastEvent/platformShowToastEvent.js
 */
export const CloseScreenEventName = "lightning__actionsclosescreen";

export class CloseActionScreenEvent extends CustomEvent {
  constructor() {
    super(CloseScreenEventName, { bubbles: false, composed: false });
  }
}
