import { api, track } from "lwc";
import { handleErrors, SimpleToast } from "c/utils";
import LightningModal from "lightning/modal";
import updatePinStatus from "@salesforce/apex/AUFController.updatePinStatus";
import updateStatus from "@salesforce/apex/AUFController.updateStatus";
import resetPin from "@salesforce/apex/AUFController.resetPin";
import updateMobileNumber from "@salesforce/apex/AUFController.updateMobileNumber";
import updateOcvid from "@salesforce/apex/AUFController.updateOcvid";
import checkAccountsOpen from "@salesforce/apex/AUFController.checkAccountsOpen";
import archiveUser from "@salesforce/apex/AUFController.archiveUser";
import { NavigationMixin } from "lightning/navigation";
import { getFocusedTabInfo, refreshTab } from "lightning/platformWorkspaceApi";

const SUCCESS_MESSAGE = "Operation is completed successfully.";

const ARCHIVE_ACC_NOT_CLOSED =
  "Please ensure that all accounts are closed, before archiving the Aegis profile.";

export default class AssistedUserFunctions extends NavigationMixin(
  LightningModal
) {
  @api actionName; // Action sent by the Aura component
  @track mobileNumber = ""; // Stores the mobile number input
  @api recordId; // Record ID (if applicable)
  @track ocvId = "";
  @track newPin = "";
  @track confirmPin = "";
  @track showPinMisMatchError = false; // Error state for mobile validation
  pinMisMatchError = "Oops, that's not the PIN you chose. Try again.";
  invalidMobileError = "Invalid mobile number";
  showSpinner = false;

  toast = new SimpleToast(this);

  UPDATE_STATUS_MAP = {
    Suspend: "Suspended",
    Unsuspend: "Unsuspend",
    Unpadlock: "Active"
  };

  // Getter for Update PIN
  get isUpdatePin() {
    return this.actionName === "LockPIN" || this.actionName === "UnlockPIN";
  }

  // Get the correct PIN status for display
  get pinStatus() {
    return this.actionName === "LockPIN" ? "Locked" : "Active";
  }

  get isUpdateStatus() {
    return this.actionName in this.UPDATE_STATUS_MAP;
  }

  get status() {
    return this.UPDATE_STATUS_MAP[this.actionName];
  }

  get isResetPin() {
    return this.actionName === "ResetPIN";
  }

  get isUpdateMobile() {
    return this.actionName === "MobileNumber";
  }

  get isUpdateOcvId() {
    return this.actionName === "OCVNumber";
  }

  get isArchiveUser() {
    return this.actionName === "ArchiveUser";
  }

  // Handle input change for mobile number
  handleMobileInput(event) {
    this.mobileNumber = event.target.value;
    event.target.reportValidity();
  }

  handleNewPin(event) {
    this.newPin = event.target.value;
    this.showPinMisMatchError = false;
    event.target.reportValidity();
  }

  handleConfirmPin(event) {
    this.confirmPin = event.target.value;
    this.showPinMisMatchError = false;
    event.target.reportValidity();
  }

  handleOCVIdInput(event) {
    this.ocvId = event.target.value;
    event.target.reportValidity();
  }
  // Handle update PIN button click
  handleUpdatePinStatus() {
    this.showSpinner = true;
    let pinStatusValue = this.actionName === "LockPIN" ? "Locked" : "Active";
    updatePinStatus({ recordId: this.recordId, action: pinStatusValue })
      .then(() => {
        this.toast.success(SUCCESS_MESSAGE);
        this.performRefreshActions();
      })
      .catch((error) => {
        this.handleApiError(error);
      })
      .finally(() => {
        this.showSpinner = false;
      });
  }

  handleUpdateStatus() {
    this.showSpinner = true;
    let statusValue = this.actionName === "Suspend" ? "Suspended" : "active";
    updateStatus({ recordId: this.recordId, action: statusValue })
      .then(() => {
        this.toast.success(SUCCESS_MESSAGE);
        this.performRefreshActions();
      })
      .catch((error) => {
        this.handleApiError(error);
      })
      .finally(() => {
        this.showSpinner = false;
      });
  }

  handleResetPin() {
    if (
      !this.template.querySelector(".newPINCls").reportValidity() ||
      !this.template.querySelector(".confirmPINCls").reportValidity()
    ) {
      return;
    }
    if (this.newPin !== this.confirmPin) {
      this.showPinMisMatchError = true;
      return;
    }
    this.showSpinner = true;
    resetPin({ recordId: this.recordId, pin: this.newPin })
      .then(() => {
        this.toast.success(SUCCESS_MESSAGE);
        this.performRefreshActions();
      })
      .catch((error) => {
        this.handleApiError(error);
      })
      .finally(() => {
        this.showSpinner = false;
      });
  }

  get mobileNumberDisabled() {
    return !this.mobileNumber;
  }

  handleUpdateMobileNumber() {
    if (!this.template.querySelector(".mobileNumberCls").reportValidity()) {
      return;
    }
    this.showSpinner = true;
    updateMobileNumber({
      recordId: this.recordId,
      mobileNumber: this.mobileNumber
    })
      .then(() => {
        this.toast.success(SUCCESS_MESSAGE);
        this.performRefreshActions();
      })
      .catch((error) => {
        this.handleApiError(error);
      })
      .finally(() => {
        this.showSpinner = false;
      });
  }

  get ocvButtonDisabled() {
    return !this.ocvId;
  }

  get pinButtonDisabled() {
    return !this.newPIN && !this.confirmPin;
  }
  handleUpdateOcvid() {
    if (!this.template.querySelector(".ocvIdCls").reportValidity()) {
      return;
    }
    this.showSpinner = true;
    updateOcvid({ recordId: this.recordId, ocvId: this.ocvId })
      .then(() => {
        this.toast.success(SUCCESS_MESSAGE);
        this.performRefreshActions();
      })
      .catch((error) => {
        this.handleApiError(error);
      })
      .finally(() => {
        this.showSpinner = false;
      });
  }

  handleArchiveUser() {
    this.showSpinner = true;
    checkAccountsOpen({ recordId: this.recordId })
      .then((result) => {
        if (result) {
          this.toast.error(ARCHIVE_ACC_NOT_CLOSED);
          this.handleCloseModal();
          this.showSpinner = false;
          return;
        }
        this.callArchiveUserAPI();
      })
      .catch((error) => {
        this.handleApiError(error);
        this.showSpinner = false;
      });
  }

  callArchiveUserAPI() {
    this.showSpinner = true;
    archiveUser({ recordId: this.recordId, action: "archived" })
      .then(() => {
        this.toast.success(SUCCESS_MESSAGE);
        this.performRefreshActions();
      })
      .catch((error) => {
        this.handleApiError(error);
      })
      .finally(() => {
        this.showSpinner = false;
      });
  }
  handleApiError(error) {
    let msg = error.body.message ?? handleErrors(error);
    this.toast.error(msg);
  }

  performRefreshActions() {
    this.navigateToPersonIdentityPage();
    this.refreshTab();
    /* ANZX-179785 - The double refresh here is needed because of an issue where the criteria based Quick Actions on PersonDigitalIdentity were not getting rendedred
    correctly with a single sub-tab refresh. As a workaround, we are doing the secod refresh with a 5s timeout.
    */
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      this.refreshTab();
    }, 5000);
  }
  navigateToPersonIdentityPage() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        objectApiName: "PersonDigitalIdentity__x",
        actionName: "view",
        recordId: this.recordId
      }
    });
  }

  async refreshTab() {
    const { tabId } = await getFocusedTabInfo();
    await refreshTab(tabId, {
      includeAllSubtabs: true
    });
  }

  handleCloseModal() {
    const closeActionEvent = new CustomEvent("closeaction");
    this.dispatchEvent(closeActionEvent);
  }
}
