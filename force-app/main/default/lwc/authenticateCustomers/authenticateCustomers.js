import { LightningElement, api, wire } from "lwc";
import getAccountName from "@salesforce/apex/AuthenticateCustomerController.getAccountName";
import getUserRole from "@salesforce/apex/AuthenticateCustomerController.getUserRole";
import initiateAuthenticationRequest from "@salesforce/apex/AuthenticateCustomerController.initiateAuthenticationRequest";
import authenticationPollingResponse from "@salesforce/apex/AuthenticateCustomerController.authenticationPollingResponse";
import updateAuthenticationHistory from "@salesforce/apex/AuthenticateCustomerController.updateAuthenticationHistory";
import { updateRecord } from "lightning/uiRecordApi";

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
  accountId;
  accountNameMessage;
  authrequestId;
  authHistoryId;
  buttonName;
  expirationMessage;
  fraudAgentRole = true;
  kycCustomer;
  ocvId;
  receivedPollingResponse = false;
  authenticateAgainClicked = false;

  _status = STATUSMAP.LOADING;

  @api recordId;

  //This method get the role of the logged in user
  @wire(getUserRole)
  wiredUserRole({ data, error }) {
    if (data) {
      this._status = STATUSMAP.SHOWAUTHENTICATEBUTTON;
      this.fraudAgentRole = data === "FraudX_Agent" ? true : false;
    } else if (error) {
      this._status = STATUSMAP.ERROR;
    }
  }

  //This method get the Account Details based on the interaction recordnId.
  @wire(getAccountName, { interactionId: "$recordId" })
  wiredAccountName({ data, error }) {
    if (data) {
      this.accountNameMessage =
        data.Account.FirstName !== undefined
          ? data.Account.FirstName
          : data.Account.LastName;
      this.accountId = data.AccountId;
      this.ocvId = data.Account.OCV_ID__c;
      //Hold value for KYCed customer in kycCustomer variable
      this.kycCustomer =
        data.Account.FinServ__KYCStatus__c === "CO" &&
        data.Account.KYC_Verification_Level__c === "VE";
    } else if (error) {
      this._status = STATUSMAP.ERROR;
    }
  }

  get IconName() {
    return this._status === STATUSMAP.VERIFIED
      ? ICONNAME.APPROVAL
      : ICONNAME.CLOSE;
  }

  get showAuthenticateButton() {
    return this._status === STATUSMAP.SHOWAUTHENTICATEBUTTON ? true : false;
  }

  get userMessage() {
    if (
      this._status === STATUSMAP.SHOWAUTHENTICATEBUTTON ||
      this._status === STATUSMAP.LOADING
    ) {
      return USERMESSAGE.LOADING_MESSAGE;
    } else if (this._status === STATUSMAP.VERIFIED) {
      return `${this.accountNameMessage} has successfully completed the ${this.buttonName} verification request.`;
    } else if (this._status === STATUSMAP.ACCESS_DENIED) {
      return `${this.accountNameMessage} has declined the ${this.buttonName} verification request.`;
    } else if (this._status === STATUSMAP.EXPIRED) {
      return `The ${this.buttonName} verification request has expired.`;
    } else if (
      this._status === STATUSMAP.ERROR ||
      this._status === STATUSMAP.TOKEN_VERIFICATION_FAILED
    ) {
      return USERMESSAGE.ERROR;
    } else if (
      this._status === STATUSMAP.START_POLLING ||
      this._status === STATUSMAP.POLLING
    ) {
      return `${this.accountNameMessage} been asked to accept ${this.buttonName} verification request.`;
    } else if (this._status === STATUSMAP.KYCCHECK) {
      return USERMESSAGE.KYCERROR;
    }
    return "";
  }

  get showSpinner() {
    return this._status === STATUSMAP.LOADING ||
      this._status === STATUSMAP.POLLING ||
      this._status === STATUSMAP.START_POLLING
      ? true
      : false;
  }

  get showTimer() {
    return this._status === STATUSMAP.POLLING ? this.expirationMessage : null;
  }

  get showAuthenticateAgainButton() {
    return this._status === STATUSMAP.POLLING ||
      this._status === STATUSMAP.VERIFIED ||
      this._status === STATUSMAP.ACCESS_DENIED ||
      this._status === STATUSMAP.EXPIRED ||
      this._status === STATUSMAP.ERROR ||
      this._status === STATUSMAP.KYCCHECK ||
      this._status === STATUSMAP.TOKEN_VERIFICATION_FAILED
      ? true
      : false;
  }

  get showIcon() {
    return this._status === STATUSMAP.VERIFIED ||
      this._status === STATUSMAP.ACCESS_DENIED ||
      this._status === STATUSMAP.EXPIRED ||
      this._status === STATUSMAP.ERROR ||
      this._status === STATUSMAP.KYCCHECK ||
      this._status === STATUSMAP.TOKEN_VERIFICATION_FAILED
      ? true
      : false;
  }

  get iconClass() {
    return this._status === STATUSMAP.VERIFIED
      ? ICONCLASS.APPROVAL
      : ICONCLASS.CLOSE;
  }

  get userMessageStyle() {
    return this._status === STATUSMAP.SHOWAUTHENTICATEBUTTON ||
      this._status === STATUSMAP.LOADING
      ? MESSAGECLASS.OPTIONSELECTION
      : MESSAGECLASS.USERMESSAGE;
  }
  //This Method initiates the authentication request.
  handleAuthentication(event) {
    this._status = STATUSMAP.START_POLLING;
    this.authenticateAgainClicked = false;
    this.buttonName = event.target.dataset.id;
    //This method assists in determining whether the customer record is linked to an interaction record and whether the client is a KYC customer.
    let verifyCustomer = this.validateCustomerKYC(
      this.accountId,
      this.kycCustomer
    );

    //This Method initiates the authentication request when the button is clicked and the customer is KYC customer.
    // Account Id associated to interaction and the name of the button (AAL3 - Pin or Local Biometrics OR  AAL4 - Selfie ID) are passed to initiateAuthenticationRequest apex method.
    if (verifyCustomer) {
      let buttonApiName =
        this.buttonName === ACRBUTTONNAME.PIN
          ? ACRVALUES.PIN
          : ACRVALUES.SELFIE;
      initiateAuthenticationRequest({
        ocvId: this.ocvId,
        acrValue: buttonApiName,
        interactionId: this.recordId
      })
        .then((result) => {
          if (result && result.auth_req_id) {
            this.authrequestId = result.auth_req_id;
            this.authHistoryId = result.authHistoryId;
            this._status = STATUSMAP.START_POLLING;

            // This method calculates the request time out in hh:mm am/pm format. The request will display user expiration time after polling will start.
            this.calculateExpirationTime(result.expires_in);

            // This is apex call after receiving authorisationzation id . This method helps in getting status of the authorization request.
            this.handlePolling(
              this.authrequestId,
              result.expires_in,
              result.interval
            );
          } else {
            // If the user will not get the authorisation id then user will see the error message
            this._status = STATUSMAP.ERROR;
          }
        })
        .catch(() => {
          this._status = STATUSMAP.ERROR;
        });
    }
    // This will help in showing the user messsage when the user is not a KYCed customer.
    else {
      this._status = STATUSMAP.KYCCHECK;
    }
  }

  // This is a Polling method . It will run till expireIn seconds and call the apex method in every interval seconds . If the user will receive the response then loop will end.
  // If the user will not receive the response within that time then error message will dispaly.
  handlePolling(authrequestId, expireIn, interval) {
    const startTime = Date.now();

    const poll = () => {
      if (
        Date.now() - startTime < expireIn * 1000 &&
        this.receivedPollingResponse === false &&
        this.authenticateAgainClicked === false
      ) {
        this._status = STATUSMAP.POLLING;
        authenticationPollingResponse({
          authrequestId,
          authHistoryId: this.authHistoryId,
          ocvId: this.ocvId
        })
          .then((authresult) => {
            if (
              authresult &&
              authresult !== STATUSMAP.AUTHORIZATION_PENDING &&
              authresult !== STATUSMAP.SLOW_DOWN &&
              this.authenticateAgainClicked === false
            ) {
              this.receivedPollingResponse = true;
              this._status = authresult;
              if (
                authresult === STATUSMAP.VERIFIED ||
                authresult === STATUSMAP.ACCESS_DENIED
              ) {
                // Refresh Interaction Detail Page
                updateRecord({ fields: { Id: this.recordId } });
              }
            } else {
              // eslint-disable-next-line @lwc/lwc/no-async-operation
              setTimeout(poll, interval * 1000);
            }
          })
          .catch(() => {
            this._status = STATUSMAP.EXPIRED;
            this.updateAuthenticationHistoryStatus(REQUEST_EXPIRED);
          });
      } else {
        this.receivedPollingResponse = false;
        this._status =
          this.authenticateAgainClicked === true
            ? STATUSMAP.SHOWAUTHENTICATEBUTTON
            : STATUSMAP.EXPIRED;

        if (this._status === STATUSMAP.EXPIRED) {
          this.updateAuthenticationHistoryStatus(REQUEST_EXPIRED);
        }
      }
    };
    poll();
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
    if (this.authHistoryId && this._status === STATUSMAP.POLLING) {
      this.updateAuthenticationHistoryStatus(CANCELLED);
    }
    this._status = STATUSMAP.SHOWAUTHENTICATEBUTTON;
    this.receivedPollingResponse = false;
    this.authenticateAgainClicked = true;
  }

  updateAuthenticationHistoryStatus(status) {
    updateAuthenticationHistory({
      authHistoryId: this.authHistoryId,
      status: status
    });
  }

  //This method assists in determining whether the customer record is linked to an interaction record and whether the client is a KYC customer.
  validateCustomerKYC(accountId, KYCcustomer) {
    return accountId && KYCcustomer ? true : false;
  }
}
