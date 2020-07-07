import Base from "../../base";
/**
 * Handles the General Inquiry record type fields on Coaches Workbench during create
 */
class GeneralInquiry extends Base {
  /****** TEXT INPUTS ******/
  get subject() {
    return $("//div/div[1]/div/div/div[1]/div/div/div/div/input");
  }
  get description() {
    return $("//div/div[1]/div/div/div[2]/div/div/div/div/textarea");
  }
  get originalCaseNumber() {
    return $("//div/div[2]/div/div/div[1]/div[1]/div/div/div/input");
  }

  /****** LOOKUPS ******/
  get accountName() {
    return $(
      "//div/div[2]/div/div/div[2]/div[1]/div/div/div/div/div/div[1]/div/input"
    );
  }
  get parentCase() {
    return $(
      "//div/div[2]/div/div/div[5]/div[1]/div/div/div/div/div/div[1]/div/input"
    );
  }
  get financialAccount() {
    return $(
      "//div/div[2]/div/div/div[8]/div[1]/div/div/div/div/div/div[1]/div/input"
    );
  }

  /****** DROPDOWNS ******/
  get status() {
    return $(
      "//article/div[3]/div/div[2]/div/div/div[2]/div[2]/div/div/div/div"
    );
  }
  get type() {
    return $("//div/div[2]/div/div/div[3]/div[1]/div/div/div/div");
  }
  get channelReceived() {
    return $("//div/div[2]/div/div/div[4]/div[2]/div/div/div/div");
  }
  get caseReason() {
    return $("//div/div[2]/div/div/div[5]/div[2]/div/div/div/div");
  }
  get priority() {
    return $("//div/div[2]/div/div/div[6]/div[1]/div/div/div/div");
  }

  /****** BUTTONS ******/
  get subTypeAdd() {
    return $(
      "//div/div[3]/div[2]/div/div/lightning-picklist/lightning-dual-listbox/div/div[2]/div/div[4]/lightning-button-icon[1]/button"
    );
  }
  get additionalTypeAdd() {
    return $(
      "//div/div[4]/div[1]/div/div/lightning-picklist/lightning-dual-listbox/div/div[2]/div/div[4]/lightning-button-icon[1]/button"
    );
  }
  get save() {
    return $("//div/div[2]/button[3]");
  }
}

export default new GeneralInquiry();
