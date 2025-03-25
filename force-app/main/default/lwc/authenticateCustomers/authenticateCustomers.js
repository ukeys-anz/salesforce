import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import anzxViewCibaAuthorisationAal4 from "@salesforce/customPermission/ANZx_View_CIBA_Authorisation_AAL4";
import initiateAuthenticationRequest from "@salesforce/apex/AuthenticateCustomerController.initiateAuthenticationRequest";
import authenticationPollingResponse from "@salesforce/apex/AuthenticateCustomerController.authenticationPollingResponse";
import updateAuthenticationHistory from "@salesforce/apex/AuthenticateCustomerController.updateAuthenticationHistory";
import { notifyRecordUpdateAvailable } from "lightning/uiRecordApi";

import FIELD_ACCOUNT_ID from "@salesforce/schema/Interaction.AccountId";
import FIELD_ACCOUNT_FIRSTNAME from "@salesforce/schema/Interaction.Account.FirstName";
import FIELD_ACCOUNT_LASTNAME from "@salesforce/schema/Interaction.Account.LastName";
import FIELD_ACCOUNT_OCVID from "@salesforce/schema/Interaction.Account.OCV_ID__c";
import FIELD_ACCOUNT_KYCSTATUS from "@salesforce/schema/Interaction.Account.FinServ__KYCStatus__c";
import FIELD_ACCOUNT_KYCLEVEL from "@salesforce/schema/Interaction.Account.KYC_Verification_Level__c";

const STATUSMAP = {
  LOADING: "Loading",
  SHOWAUTHENTICATEBUTTON: "ShowAuthenticateButton",
  ERROR: "error",
  START_POLLING: "startPolling",
  POLLING: "Polling",
  VERIFIED: "verified",
  ACCESS_DENIED: "access_denied",
  TOKEN_VERIFICATION_FAILED: "Token Verification Failed",
  EXPIRED: "expired",
  KYCCHECK: "kycCheck",
  AUTHORIZATION_PENDING: "authorization_pending",
  SLOW_DOWN: "slow_down"
};

const ICONNAME = {
  APPROVAL: "action:approval",
  CLOSE: "action:close"
};

const ICONCLASS = {
  APPROVAL: "success-icon",
  CLOSE: "close-icon"
};

const MESSAGECLASS = {
  OPTIONSELECTION: "option-selecion",
  USERMESSAGE: "user-message"
};

const ACRVALUES = {
  PIN: "IAL4.AAL3.FAL1",
  SELFIE: "IAL4.AAL4.FAL1"
};

const ACRBUTTONNAME = {
  PIN: "AAL3 - Pin or Local Biometrics",
  SELFIE: "AAL4 - Selfie ID"
};

const REQUEST_EXPIRED = "Request Expired";
const CANCELLED = "Cancelled";

const USERMESSAGE = {
  LOADING_MESSAGE:
    "Use mutual authentication to securely authenticate the customer by pushing a verification tile in their app. Select the appropriate option below.",
  ERROR: "Something went wrong. Please try again",
  KYCERROR:
    "Authentication Request can only be raised for KYC Approved Customers."
};

export default class AuthenticateCustomers extends LightningElement {
  //customer info
  accountName;
  kycCustomer;
  ocvId;
  //auth info
  authrequestId;
  authHistoryId;

  buttonName;
  expirationMessage;
  enableAal4 = anzxViewCibaAuthorisationAal4;
  pollInstance;
  status = STATUSMAP.LOADING;

  @api recordId;

  @wire(getRecord, {
    recordId: "$recordId",
    fields: [
      FIELD_ACCOUNT_ID,
      FIELD_ACCOUNT_FIRSTNAME,
      FIELD_ACCOUNT_LASTNAME,
      FIELD_ACCOUNT_OCVID,
      FIELD_ACCOUNT_KYCSTATUS,
      FIELD_ACCOUNT_KYCLEVEL
    ]
  })
  wiredRecord({ data, error }) {
    if (error) {
      this.status = STATUSMAP.ERROR;
    }
    if (!data) {
      return;
    }
    if (!getFieldValue(data, FIELD_ACCOUNT_ID)) {
      return;
    }
    this.ocvId = getFieldValue(data, FIELD_ACCOUNT_OCVID);
    this.accountName =
      getFieldValue(data, FIELD_ACCOUNT_FIRSTNAME) ||
      getFieldValue(data, FIELD_ACCOUNT_LASTNAME);
    this.kycCustomer =
      getFieldValue(data, FIELD_ACCOUNT_KYCSTATUS) === "CO" &&
      getFieldValue(data, FIELD_ACCOUNT_KYCLEVEL) === "VE";
    if (this.status === STATUSMAP.LOADING) {
      this.status = STATUSMAP.SHOWAUTHENTICATEBUTTON;
    }
  }

  get IconName() {
    return this.status === STATUSMAP.VERIFIED
      ? ICONNAME.APPROVAL
      : ICONNAME.CLOSE;
  }

  get showAuthenticateButton() {
    return this.status === STATUSMAP.SHOWAUTHENTICATEBUTTON;
  }

  get userMessage() {
    const pollingMsg = `${this.accountName} has been asked to accept ${this.buttonName} verification request.`;
    return (
      {
        [STATUSMAP.SHOWAUTHENTICATEBUTTON]: USERMESSAGE.LOADING_MESSAGE,
        [STATUSMAP.LOADING]: USERMESSAGE.LOADING_MESSAGE,
        [STATUSMAP.TOKEN_VERIFICATION_FAILED]: USERMESSAGE.ERROR,
        [STATUSMAP.ERROR]: USERMESSAGE.ERROR,
        [STATUSMAP.KYCCHECK]: USERMESSAGE.KYCERROR,
        [STATUSMAP.VERIFIED]: `${this.accountName} has successfully completed the ${this.buttonName} verification request.`,
        [STATUSMAP.ACCESS_DENIED]: `${this.accountName} has declined the ${this.buttonName} verification request.`,
        [STATUSMAP.EXPIRED]: `The ${this.buttonName} verification request has expired.`,
        [STATUSMAP.START_POLLING]: pollingMsg,
        [STATUSMAP.POLLING]: pollingMsg
      }[this.status] ?? ""
    );
  }

  get showSpinner() {
    return [
      STATUSMAP.LOADING,
      STATUSMAP.START_POLLING,
      STATUSMAP.POLLING
    ].includes(this.status);
  }

  get showTimer() {
    return this.status === STATUSMAP.POLLING ? this.expirationMessage : null;
  }

  get showAuthenticateAgainButton() {
    return [
      STATUSMAP.POLLING,
      STATUSMAP.VERIFIED,
      STATUSMAP.ACCESS_DENIED,
      STATUSMAP.EXPIRED,
      STATUSMAP.ERROR,
      STATUSMAP.KYCCHECK,
      STATUSMAP.TOKEN_VERIFICATION_FAILED
    ].includes(this.status);
  }

  get showIcon() {
    return [
      STATUSMAP.VERIFIED,
      STATUSMAP.ACCESS_DENIED,
      STATUSMAP.EXPIRED,
      STATUSMAP.ERROR,
      STATUSMAP.KYCCHECK,
      STATUSMAP.TOKEN_VERIFICATION_FAILED
    ].includes(this.status);
  }

  get iconClass() {
    return this.status === STATUSMAP.VERIFIED
      ? ICONCLASS.APPROVAL
      : ICONCLASS.CLOSE;
  }

  get userMessageStyle() {
    return this.status === STATUSMAP.SHOWAUTHENTICATEBUTTON ||
      this.status === STATUSMAP.LOADING
      ? MESSAGECLASS.OPTIONSELECTION
      : MESSAGECLASS.USERMESSAGE;
  }

  /**
   * This method initiates the authentication request based on the button clicked by the user.
   * If the authentication request is successful, it sets the authentication request ID and history ID,
   * calculates the expiration time, and starts polling for the authentication status.
   * If the request fails or the response does not contain an authorization ID, it sets the status to error.
   */
  async handleAuthentication(event) {
    if (!this.kycCustomer) {
      this.status = STATUSMAP.KYCCHECK;
      return;
    }
    this.buttonName = event.target.dataset.id;
    let buttonApiName =
      this.buttonName === ACRBUTTONNAME.PIN ? ACRVALUES.PIN : ACRVALUES.SELFIE;

    this.status = STATUSMAP.START_POLLING;
    const startTime = Date.now();
    let result;
    try {
      result = await initiateAuthenticationRequest({
        ocvId: this.ocvId,
        acrValue: buttonApiName,
        interactionId: this.recordId
      });
    } catch {
      this.status = STATUSMAP.ERROR;
      return;
    }
    // If the user will not get the authorisation id then user will see the error message
    if (!result?.auth_req_id) {
      this.status = STATUSMAP.ERROR;
      return;
    }
    this.authrequestId = result.auth_req_id;
    this.authHistoryId = result.authHistoryId;
    this.calculateExpirationTime(result.expires_in);
    this.handlePolling(
      this.authrequestId,
      result.expires_in,
      result.interval,
      startTime
    );
  }

  /**
   * This method will run immediately to check status of an auth request.
   * If the customer hasn't responded to the request then it will poll the status of the request.
   * If the user does not receive the response within given time then error message will dispaly.
   */
  async handlePolling(authrequestId, expireIn, interval, startTime) {
    if (Date.now() - startTime >= expireIn * 1000) {
      this.status = STATUSMAP.EXPIRED;
      this.updateAuthenticationHistoryStatus(REQUEST_EXPIRED);
      return;
    }
    this.status = STATUSMAP.POLLING;
    let authresult;
    try {
      authresult = await authenticationPollingResponse({
        authrequestId,
        authHistoryId: this.authHistoryId,
        ocvId: this.ocvId
      });
    } catch (error) {
      this.status = STATUSMAP.ERROR;
      return;
    }
    if (
      !authresult ||
      authresult === STATUSMAP.AUTHORIZATION_PENDING ||
      authresult === STATUSMAP.SLOW_DOWN
    ) {
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      this.pollInstance = setTimeout(() => {
        this.handlePolling(authrequestId, expireIn, interval, startTime);
      }, interval * 1000);
      return;
    }
    if (
      authresult === STATUSMAP.VERIFIED ||
      authresult === STATUSMAP.ACCESS_DENIED
    ) {
      notifyRecordUpdateAvailable([this.recordId]);
    }
    this.status = authresult;
  }

  // This method calculates the request time out in hh:mm am/pm format. The request will display user expiration time after polling will start.
  calculateExpirationTime(expireIn) {
    const currentTime = new Date();
    const expirationTime = new Date(currentTime.getTime() + expireIn * 1000);
    const formattedExpirationTime = expirationTime.toLocaleString("en-US", {
      hour: "numeric",
      minute: "numeric",
      hour12: true
    });
    this.expirationMessage =
      "The request will expire at " + formattedExpirationTime;
  }

  authenticateAgain() {
    if (this.authHistoryId && this.status === STATUSMAP.POLLING) {
      this.updateAuthenticationHistoryStatus(CANCELLED);
    }
    if (this.pollInstance) {
      clearTimeout(this.pollInstance);
    }
    this.status = STATUSMAP.SHOWAUTHENTICATEBUTTON;
    this.expirationMessage = null;
    this.authHistoryId = null;
    this.authrequestId = null;
  }

  updateAuthenticationHistoryStatus(status) {
    updateAuthenticationHistory({
      authHistoryId: this.authHistoryId,
      status: status
    });
  }
}
