import { LightningElement, api, track, wire } from "lwc";
import { getRecord } from "lightning/uiRecordApi";
import { CloseActionScreenEvent } from "lightning/actions";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

const FINANCIAL_ACCOUNT_FIELD = "Case.FinServ__FinancialAccount__c";
const FIELDS = [FINANCIAL_ACCOUNT_FIELD];
const CHANGE_TO_NUMBER_OF_SIGN = new Map([
  ["1", "2"],
  ["2", "1"]
]);

export default class UpdateSigningAuthorityWrapper extends OmniscriptBaseMixin(
  LightningElement
) {
  @api recordId;
  renderFlex = false;
  @track records;
  loaded = true;
  financialAccountId;

  @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
  wiredCase({ error, data }) {
    if (data) {
      this.financialAccountId = data.fields.FinServ__FinancialAccount__c.value;
      this.callIPWithFinancialAccountId();
    } else if (error) {
      this.dispatchEvent(new CloseActionScreenEvent());
    }
  }

  callIPWithFinancialAccountId() {
    const inputsForIP = {
      recordId: this.financialAccountId
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
          numberOfSign: CHANGE_TO_NUMBER_OF_SIGN.get(
            response.result.IPResult.numberOfSign
          ),
          oldNumberOfSign: response.result.IPResult.oldNumberOfSign,
          finAccountNumber: response.result.IPResult.finAccountNumber,
          ocvId: response.result.IPResult.ocvId,
          customerId: response.result.IPResult.customerId,
          finAccountId: response.result.IPResult.finAccountId,
          caseRecordId: this.recordId
        };
        this.renderFlex = true;
        this.loaded = false;
      })
      .catch(() => {
        this.dispatchEvent(new CloseActionScreenEvent());
      });
  }
  connectedCallback() {
    window.addEventListener("cancelEvent", this.handleCancel.bind(this));
  }

  handleCancel() {
    this.dispatchEvent(new CloseActionScreenEvent());
  }
}
