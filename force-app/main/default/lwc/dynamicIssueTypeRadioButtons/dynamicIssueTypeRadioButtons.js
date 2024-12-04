import { LightningElement, api, track, wire } from "lwc";
import { OmniscriptBaseMixin } from "omnistudio/omniscriptBaseMixin";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import ISSUETYPE_FIELD from "@salesforce/schema/Case.IDR_Issue_Type_2__c";
import SUBISSUE_FIELD from "@salesforce/schema/Case.IDR_Subsequent_Issue__c";

const CHOOSEPATHWAY = "ChoosePathway";
const BEGINCALL = "BeginPhoneCall";
const SIMILAR_PATHWAYS = {
  "Branch queues / wait time": "Trading hours/location/closures",
  "Statement Issue": "Statement features/accessibility"
};
export default class DynamicIssueTypeRadioButtons extends OmniscriptBaseMixin(
  LightningElement
) {
  @api userSelection;
  @api recTypeId;
  @track issueTypeButtons = [];
  _pageName;
  error;
  isChoosePathway;
  issueTypePicklistArr = [];
  subIssueTypePicklistArr = [];

  // conditionally display readonly / selectable buttons for different screens
  @api set pageName(value) {
    this.isChoosePathway = value === CHOOSEPATHWAY ? true : false;
    this._pageName = value;
  }
  get pageName() {
    return this._pageName;
  }

  @wire(getPicklistValues, {
    recordTypeId: "$recTypeId",
    fieldApiName: ISSUETYPE_FIELD
  })
  issueTypePicklistValues({ error, data }) {
    if (data) {
      this.issueTypePicklistArr = [...data.values];
      this.error = undefined;
      this.createButtonList();
    } else if (error) {
      this.error = error;
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$recTypeId",
    fieldApiName: SUBISSUE_FIELD
  })
  subIssuePicklistValues({ error, data }) {
    if (data) {
      this.subIssueTypePicklistArr = [...data.values];
      this.error = undefined;
      this.createButtonList();
    } else if (error) {
      this.error = error;
    }
  }

  // We have numeric values in picklist value api names so we need to find the label for these selected api names.
  // createButtonList() runs after both wire issueTypePicklistValues and subIssuePicklistValues have resolved, this creates the buttons dynamically on UI
  createButtonList() {
    let tempButtonList = [];
    let uniqueLabels = new Set();

    if (
      !this.issueTypePicklistArr.length ||
      !this.subIssueTypePicklistArr.length
    )
      return;

    let order = 1;
    let subIssue1 = this.findPicklistLabel(
      this.omniJsonData?.SubIssue,
      this.subIssueTypePicklistArr
    ).label;
    let button1 = {
      label: subIssue1,
      sublabel: this.findPicklistLabel(
        this.omniJsonData.Type,
        this.issueTypePicklistArr
      ).label,
      order: order++
    };
    if (this._pageName === CHOOSEPATHWAY && this.checkType(subIssue1)) {
      tempButtonList.push(button1);
      uniqueLabels.add(button1.label);
    } else if (this._pageName === BEGINCALL) {
      tempButtonList.push(button1);
    }

    let subIssue2 = this.omniJsonData?.SubIssue2
      ? this.findPicklistLabel(
          this.omniJsonData?.SubIssue2,
          this.subIssueTypePicklistArr
        ).label
      : "";
    let button2;
    if (subIssue2) {
      button2 = {
        label: subIssue2,
        sublabel: this.findPicklistLabel(
          this.omniJsonData.IssueType2,
          this.issueTypePicklistArr
        ).label,
        order: order++
      };

      if (
        this._pageName === CHOOSEPATHWAY &&
        this.checkType(subIssue2) &&
        !uniqueLabels.has(button2.label)
      ) {
        tempButtonList.push(button2);
        uniqueLabels.add(button2.label);
      } else if (this._pageName === BEGINCALL) {
        tempButtonList.push(button2);
      }
    }

    let subIssue3 = this.omniJsonData?.SubIssue3
      ? this.findPicklistLabel(
          this.omniJsonData?.SubIssue3,
          this.subIssueTypePicklistArr
        ).label
      : "";
    if (subIssue3) {
      let button3 = {
        label: subIssue3,
        sublabel: this.findPicklistLabel(
          this.omniJsonData.IssueType3,
          this.issueTypePicklistArr
        ).label,
        order: order++
      };

      if (
        this._pageName === CHOOSEPATHWAY &&
        this.checkType(subIssue3) &&
        !uniqueLabels.has(button3.label)
      ) {
        tempButtonList.push(button3);
        uniqueLabels.add(button3.label);
      } else if (this._pageName === BEGINCALL) {
        tempButtonList.push(button3);
      }
    }

    if (this._pageName === CHOOSEPATHWAY) {
      let button4 = {
        label: "Consider additional issues",
        sublabel: "",
        order: order
      };
      tempButtonList.push(button4);
    }

    this.issueTypeButtons =
      this._pageName === CHOOSEPATHWAY
        ? this.filterFinalIssueTypes(tempButtonList)
        : tempButtonList;
  }

  filterFinalIssueTypes(tempButtonList) {
    let toRemove = new Set();
    tempButtonList.forEach((button) => {
      if (button.label==='Branch queues / wait time') {
        toRemove.add(SIMILAR_PATHWAYS[button.label]);
        button.label = 'Branch Availability';
        button.sublabel = '';
      }
      else if (button.label==='Statement Issue') {
        toRemove.add(SIMILAR_PATHWAYS[button.label]);
        button.label = 'Statements';
        button.sublabel = '';
      }
    });
    return tempButtonList.filter((button) => !toRemove.has(button.label));
  }

  renderedCallback() {
    if (this.isChoosePathway && this.userSelection) {
      let defaultButton = this.template.querySelector(
        `input[name="customRadioGroup"][value="${this.userSelection}"]`
      );
      if (!defaultButton) return;
      defaultButton.checked = true;
    }
  }

  // Checks if the SubIssue type has active Resolution pathway
  checkType(key) {
    return this.omniJsonData.ResolutionPathwaysMdt.some((str) =>
      str.Label.includes(key)
    );
  }

  // Finds the label for the selected picklist api name
  findPicklistLabel(apiName, arr) {
    return arr.find((ele) => ele.value === apiName);
  }

  handleChange(event) {
    let selectedButton = event.target.value;
    let issueType = {
      selectedButtonName: selectedButton
    };
    // update data json with selected button name
    this.omniApplyCallResp({ issueType: selectedButton });
    this.omniUpdateDataJson(issueType);
  }
}
