import Base from "../../base";
/**
 * Handles the General Inquiry record type fields on Coaches Workbench during edit
 */
class GeneralInquiry extends Base {
  /****** TEXT INPUTS ******/
  get subject() {
    return $(
      "/html/body/div[4]/div[2]/div/div[2]/div/div[2]/div/article/div[3]/div/div[1]/div/div/div[1]/div/div/div/div/input"
    );
  }
  get description() {
    return $(
      "/html/body/div[4]/div[2]/div/div[2]/div/div[2]/div/article/div[3]/div/div[1]/div/div/div[2]/div/div/div/div/textarea"
    );
  }

  /****** LOOKUPS ******/
  get accountName() {
    return $(
      "/html/body/div[4]/div[2]/div/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[2]/div[1]/div/div/div/div/div/div[1]/div/input"
    );
  }
  get parentCase() {
    return $(
      "/html/body/div[4]/div[2]/div/div[2]/div/div[2]/div/div/div[1]/div/article/div[3]/div/div[2]/div/div/div[5]/div[1]/div/div/div/div/div/div[1]/div/input"
    );
  }
  get financialAccount() {
    return $(
      "/html/body/div[4]/div[2]/div/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[8]/div[1]/div/div/div/div/div/div[1]/div/input"
    );
  }

  /****** DROPDOWNS ******/
  get status() {
    return $(
      "/html/body/div[4]/div[2]/div/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[2]/div[2]/div/div/div/div"
    );
  }
  get type() {
    return $(
      "/html/body/div[4]/div[2]/div/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[3]/div[1]/div/div/div/div"
    );
  }
  get channelReceived() {
    return $(
      "/html/body/div[4]/div[2]/div/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[4]/div[2]/div/div/div/div"
    );
  }
  get caseReason() {
    return $(
      "/html/body/div[4]/div[2]/div/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[5]/div[2]/div/div/div/div"
    );
  }
  get priority() {
    return $(
      "/html/body/div[4]/div[2]/div/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[6]/div[1]/div/div/div/div"
    );
  }

  /****** BUTTONS ******/
  get subTypeAdd() {
    return $(
      "/html/body/div[4]/div[2]/div/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[3]/div[2]/div/div/lightning-picklist/lightning-dual-listbox/div/div[2]/div/div[4]/lightning-button-icon[1]/button"
    );
  }
  get additionalTypeAdd() {
    return $(
      "/html/body/div[4]/div[2]/div/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[4]/div[1]/div/div/lightning-picklist/lightning-dual-listbox/div/div[2]/div/div[4]/lightning-button-icon[1]/button"
    );
  }
  get save() {
    return $("/html/body/div[4]/div[2]/div/div[2]/div/div[3]/div/button[3]");
  }
}

export default new GeneralInquiry();
