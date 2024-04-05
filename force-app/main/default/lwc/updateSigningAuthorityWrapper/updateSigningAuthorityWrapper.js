import { LightningElement, api, track } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

export default class UpdateSigningAuthorityWrapper extends OmniscriptBaseMixin(
  LightningElement
) {
  _recordId;
  renderFlex = false;
  @track records;
  loaded = true;

  @api set recordId(value) {
    this._recordId = value;
    const inputsForIP = {
      recordId: this._recordId
    };
    const params = {
      input: JSON.stringify(inputsForIP),
      sClassName: "omnistudio.IntegrationProcedureService",
      sMethodName: "FinancialAccount_GetDetails",
      options: {}
    };
    this.omniRemoteCall(params, true)
      .then((response) => {
        this.records = {
          numberOfSign: response.result.IPResult.numberOfSign,
          oldNumberOfSign: response.result.IPResult.oldNumberOfSign,
          finAccountNumber: response.result.IPResult.finAccountNumber,
          ocvId: response.result.IPResult.ocvId,
          customerId: response.result.IPResult.customerId,
          finAccountId: response.result.IPResult.finAccountId,
          isPendingRecordPresent:
            response.result.IPResult.isPendingRecordPresent
        };
        this.renderFlex = true;
        this.loaded = false;
      })
      .catch(() => {
        this.dispatchEvent(new CloseActionScreenEvent());
      });
  }

  get recordId() {
    return this._recordId;
  }

  connectedCallback() {
    window.addEventListener("cancelEvent", this.handleCancel.bind(this));
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}
