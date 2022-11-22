/**
 * @author Stew Mikh + Mouhamed "Mo" Assafiri
 * @date Aug 2021
 */

import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import createTask from "@salesforce/apex/CaseLogCallController.createTask";
import { getRecord } from "lightning/uiRecordApi";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import SUBJECT from "@salesforce/schema/Case.Subject";
import AUTH_OPTIONS from "@salesforce/schema/Task.Authentication_Method__c";
import { handleErrorShowToast } from "c/utils";

export default class CaseLogACall extends NavigationMixin(LightningElement) {
  @api recordId;
  @track errorMessage = false;
  auth = []; //Authentication Picklist

  // showMore (boolean) - when set to false the LWC will be minimised, when set to true it is in expanded mode
  @track showMore = false;

  //Used to show loader
  @track isLoading = false;

  // Define the fields that we're submitting to task
  fields = {
    recordId: false,
    subject: "",
    auth: "--None--",
    voiceCall: "",
    comment: ""
  };
  // Use Regex to Validate the entries on the fields are OK
  fieldValidation = {
    subject: /[A-Z]{0,255}/,
    auth: /^((?!--None--).)*$/,
    voiceCall: /(CA|CF)([A-Z0-9]{32})$/i,
    comment: /^(.*)$/
  };
  // If the Regex test fails, display the corresponding error
  fieldErrorMessages = {
    subject: "Please enter a subject",
    auth: "Please select an Authorisation type",
    voiceCall:
      "Ensure this ID is a valid Call ID (Starting with CA/CF followed by 32 characters)",
    comment: ""
  };
  // Move the error string from the Messages into the visible object. This will dynamically be shown.
  @track errorString = {
    subject: false,
    auth: false,
    voiceCall: false,
    comment: false
  };
  // Init the Wire to get the subject
  @wire(getRecord, {
    recordId: "$recordId",
    fields: [SUBJECT]
  })
  wiredSubject({ data }) {
    if (data) {
      /**
      /* Prefix "Call" to Subject so it's obvious that this is a call
      /* when looking at the Activity History / Chatter feed
      */

      this.fields.subject = "Call: " + data.fields.Subject.value;
    }
  }

  // Get Authentication Options
  // The following recordTypeId is a "Master Record Picklist ID" and can be hardcoded for all orgs
  @wire(getPicklistValues, {
    recordTypeId: "012000000000000AAA",
    fieldApiName: AUTH_OPTIONS
  })
  wiredPicklist({ data }) {
    if (data) {
      const cleanedAuthOptions = data.values.map((object) => {
        return { label: object.label, value: object.value };
      });

      this.auth = cleanedAuthOptions;
    }
  }
  get authOptions() {
    return [{ label: "--None--", value: "--None--" }, ...this.auth];
  }

  connectedCallback() {
    this.fields.recordId = this.recordId;
  }

  // Used to keep the LWC small until the first interation
  get containerClass() {
    return this.showMore ? "container container-show" : "container";
  }

  // Used to trigger the expasion of the full LWC view.
  openLWC() {
    this.showMore = true;

    /**
     * This will add a finished class to the container so overflow is changed to visible. 6/09/2021
     * This is required so the Combo box options can overflow while allowing a slide-open animation.
     */
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    window.setTimeout(() => {
      this.template.querySelector(".container-show").classList.add("finished");
    }, 500);
  }

  // Handle Field changes as they occur on the LWC
  handleFieldChange(event) {
    try {
      const field = event.target.dataset.field;
      this.fields[field] = event.target.value;

      //Do instant Validation
      this.validateAndShowError(field);
    } catch (err) {
      handleErrorShowToast(
        this,
        "Field error",
        err,
        "You have not set the data-field on this element!"
      );
    }
  }

  // Validate if the Field and Values pass
  validate(field) {
    const regEx = new RegExp(this.fieldValidation[field]);
    return regEx.test(this.fields[field]);
  }

  // Validate and set the error to the object
  validateAndShowError(field) {
    if (!this.validate(field)) {
      this.errorString[field] = this.fieldErrorMessages[field];
      return false;
    }

    this.errorString[field] = false;
    return true;
  }

  // When the Save Button is pressed, handle it below
  // First check each field is validating OK, then run the createTask() function
  handleSaveTask() {
    this.isLoading = true;

    // Validate each field within the Regex Validation Object
    const isOK = Object.keys(this.fieldValidation).map((field) => {
      return this.validateAndShowError(field);
    });

    // if isOK contains 1 false, stop the function.
    if (isOK.includes(false)) {
      this.isLoading = false;
      return false;
    }

    // Create Task using the Field Object
    createTask({ fields: this.fields })
      .then(() => {
        // Refresh the View once task created
        /**
         * LWC does not support refreshing of the other
         * components on the page and this is the most
         * elegant solution without doing window.refresh()
         * which is much slower 02/09/2021
         */
        /* eslint-disable no-eval */
        eval("$A.get('e.force:refreshView').fire();");

        this.showToast();
        this.fields = {
          recordId: this.recordId,
          auth: "--None--",
          voiceCall: "",
          comment: "",
          subject: this.fields.subject
        };
      })
      .catch((error) => {
        var message;

        if (typeof error.body != "undefined") {
          message = error.body.message;
        } else {
          message = error;
        }

        const title = "Error";
        const variant = "error";

        const event = new ShowToastEvent({ title, message, variant });
        this.dispatchEvent(event);
      })
      .finally(() => {
        this.isLoading = false;
      });

    return true;
  }

  // showToast function to make ShowToastEvent.
  showToast() {
    let title = "Success";
    let message = "New call log has been created.";
    let variant = "success";

    const event = new ShowToastEvent({ title, message, variant });
    this.dispatchEvent(event);
  }
}
