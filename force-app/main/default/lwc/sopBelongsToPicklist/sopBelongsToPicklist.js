/**
 * @description this lwc overrides the belongs to picklist on debt form
 * @author @fangl6
 */
import OmniscriptSelect from "omnistudio/omniscriptSelect";
import { OmniscriptActionCommonUtil } from "omnistudio/omniscriptActionUtils";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";

const DebtType = {
  UNSPECIFIED: "LIABILITY_TYPE_UNSPECIFIED",
  CREDIT_CARD: "LIABILITY_TYPE_CREDIT_CARD",
  HOME_LOAN: "LIABILITY_TYPE_HOME_LOAN",
  LEASE_HIRE_PURCHASE: "LIABILITY_TYPE_LEASE_HIRE_PURCHASE",
  PERSONAL_LOAN: "LIABILITY_TYPE_PERSONAL_LOAN",
  STUDENT_LOAN: "LIABILITY_TYPE_STUDENT_LOAN",
  VEHICLE_LOAN: "LIABILITY_TYPE_VEHICLE_LOAN",
  LINE_OF_CREDIT: "LIABILITY_TYPE_LINE_OF_CREDIT",
  OVERDRAFT: "LIABILITY_TYPE_OVERDRAFT",
  MARGIN_LOAN: "LIABILITY_TYPE_MARGIN_LOAN",
  BPL_FACILITY: "LIABILITY_TYPE_BPL_FACILITY",
  OTHER_LIABILITY: "LIABILITY_TYPE_OTHER_LIABILITY",

  // Catch-all for other loan types. These can be pre-populated from bureau or manually added
  OTHER_LOAN: "LIABILITY_TYPE_OTHER_LOAN",
  // property loan excluding home loan
  PROPERTY_LOAN: "LIABILITY_TYPE_PROPERTY_LOAN",

  //BNPL used as term loan
  BPL_LOAN: "LIABILITY_TYPE_BPL_LOAN"
};

const SOMEONE_ELSE = " & someone else";
const singleDebtTypes = [
  DebtType.STUDENT_LOAN,
  DebtType.BPL_FACILITY,
  DebtType.BPL_LOAN
];

export default class SOPBelongsToPicklist extends OmniscriptBaseMixin(
  OmniscriptSelect
) {
  isPageLoading;
  _actionUtilClass;
  _firstUserPartyId;
  _firstUser;
  _secondUserPartyId;
  _secondUser;
  _debtTypeSelection;
  _joint;
  _isEdit;
  _ownership = [];
  connectedCallback() {
    super.connectedCallback();
    this.isPageLoading = true;

    let parsedJSONData = JSON.parse(this.jsonDataStr); //Omniscript JSON data should be available in jsonDataStr
    let selectOptions = {};

    this.init(parsedJSONData);
    selectOptions = this.getOptions();

    const options = {
      chainable: true, //Use chainable when an Integration Procedure exceeds the Salesforce CPU Governor limit.
      useFuture: false
    };
    const params = {
      input: JSON.stringify(selectOptions),
      sClassName: "ResidentialLoanApplicationController",
      sMethodName: "getBelongsToOptions", //this will need to match the VIP -> type_subtype
      options: JSON.stringify(options)
    };

    this._actionUtilClass = new OmniscriptActionCommonUtil();
    this._actionUtilClass
      .executeAction(params, null, this, null, null)
      .then((resp) => {
        this.isPageLoading = false;
        if (!resp.error && resp.result.error && resp.result.error === "OK") {
          this._realtimeOptions = resp.result.options;
        }
      })
      .catch((error) => {
        this.isPageLoading = false;
        window.console.log(error, "failed to load belongs to");
      });
  }

  init(parsedJSONData) {
    if (parsedJSONData != null) {
      this._isEdit = parsedJSONData?.isEdit;
      this._ownership = parsedJSONData?.debt?.ownership;
      this._firstUserPartyId = parsedJSONData.firstUserPartyId;
      this._firstUser = parsedJSONData.firstUser;
      this._secondUserPartyId = parsedJSONData.secondUserPartyId;
      this._secondUser = parsedJSONData.secondUser;
      this._debtTypeSelection = parsedJSONData.debtTypeValue;
      this._joint = this._secondUserPartyId === null ? false : true;
    }
  }

  getOptions() {
    let options = {};
    options[this._firstUser] = JSON.stringify(
      this.getOwnership(this._firstUserPartyId, "100", null, null)
    );
    if (this._joint) {
      options[this._secondUser] = JSON.stringify(
        this.getOwnership(null, null, this._secondUserPartyId, "100")
      );
    }

    if (!singleDebtTypes.includes(this._debtTypeSelection)) {
      //single applicant
      options[this._firstUser + SOMEONE_ELSE] = JSON.stringify(
        this.getOwnership(this._firstUserPartyId, "50", null, null)
      );
      if (this._joint) {
        //two applicants
        options[this._secondUser + SOMEONE_ELSE] = JSON.stringify(
          this.getOwnership(null, null, this._secondUserPartyId, "50")
        );
        options.Joint = JSON.stringify(
          this.getOwnership(
            this._firstUserPartyId,
            "50",
            this._secondUserPartyId,
            "50"
          )
        );
      }
    }
    if (this._isEdit) {
      this.setElementValue(options[this.getDefaultValue()]);
      this.raiseOmniApplyResponse(options[this.getDefaultValue()]);
    }
    return options;
  }

  getOwnership(partyId1, proportionValue1, partyId2, proportionValue2) {
    return {
      partyIdOne: partyId1,
      proportionValueOne: proportionValue1,
      partyIdTwo: partyId2,
      proportionValueTwo: proportionValue2
    };
  }

  getDefaultValue() {
    if (this._ownership[1]) {
      return "Joint";
    }
    let defaultLabel =
      this._ownership[0]?.partyId === this._firstUserPartyId
        ? this._firstUser
        : this._secondUser;

    if (this._ownership[0]?.proportion?.value === "100") {
      return defaultLabel;
    }
    defaultLabel += SOMEONE_ELSE;
    return defaultLabel;
  }

  handleChange(event) {
    super.handleChange(event);
    this.raiseOmniApplyResponse(event.target.value);
  }

  raiseOmniApplyResponse(value) {
    const data = {
      editDebtsForm: {
        debtDetails: {
          belongsToValue: value
        }
      }
    };
    this.omniApplyCallResp(data);
  }
}
