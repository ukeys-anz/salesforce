import Base from "../../base";
import helpers from "../../../utilities/helpers";
import * as faker from "faker";

/**
 * Handles the Customer Complaint record type fields on Complaints Mgt during edit
 */
class CustomerComplaint extends Base {
  /****** TEXT INPUTS ******/
  get customerNumber() {
    return $("//div/div[1]/div/div/div[1]/div[1]/div/div/div/input");
  }
  get nominatedThirdName() {
    return $("//div/div[2]/div/div/div[1]/div[1]/div/div/div/input");
  }
  get nominatedThirdEmail() {
    return $("//div/div[2]/div/div/div[1]/div[2]/div/div/div/input");
  }
  get nominatedThirdStreet() {
    return $("//div/div[2]/div/div/div[3]/div[1]/div/div/div/input");
  }
  get nominatedThirdSuburb() {
    return $("//div/div[2]/div/div/div[2]/div[2]/div/div/div/input");
  }
  get nominatedThirdPostcode() {
    return $("//div/div[2]/div/div/div[3]/div[1]/div/div/div/input");
  }
  get nominatedThirdMobile() {
    return $("//div/div[2]/div/div/div[4]/div[2]/div/div/div/input");
  }
  get nominatedThirdPhone() {
    return $("//div/div[2]/div/div/div[6]/div[1]/div/div/div/input");
  }
  get subject() {
    return $("//div/div[3]/div/div/div[8]/div/div/div/div/input");
  }
  get description() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[7]/lightning-textarea/div[1]/textarea"
    );
  }
  get desiredOutcome() {
    return $(
      "//lightning-accordion-section[2]/section/div[2]/slot/div/div[8]/lightning-input-field/lightning-textarea/div[1]/textarea"
    );
  }
  get descriptionOfOutcome() {
    return $("//div/div[4]/div/div/div[3]/div/div/div/div/textarea");
  }

  get searchTxt() {
    return $("//input[@placeholder='Search this list...']");
  }

  get productNameSearch() {
    return $(
      "//article/div[3]/div/div[3]/div/div/div[5]/div[1]/div/div/div/div/div/div[1]/div/input"
    );
  }

  /****** DROPDOWNS ******/
  get complainantType() {
    return $("//div/div[1]/div/div/div[1]/div[2]/div/div/div/div");
  }
  get descent() {
    return $("//div/div[1]/div/div/div[2]/div[1]/div/div/div/div");
  }
  get nominatedThirdCountry() {
    return $("//div/div[2]/div/div/div[3]/div[2]/div/div/div/div");
  }
  get nominatedThirdState() {
    return $("//div/div[2]/div/div/div[4]/div[1]/div/div/div/div");
  }
  get status() {
    return $("//div/div[3]/div/div/div[2]/div[2]/div/div/div/div");
  }
  get escalatedReason() {
    return $(
      "//article/div[3]/div/div[3]/div/div/div[6]/div[2]/div/div/div/div/div/div/div/a"
    );
  }
  get escalatedTo() {
    return $(
      "//div/div[3]/div/div/div[6]/div[1]/div/div/div/div/div[1]/div/div/a"
    );
  }

  get complaintOutcome() {
    return $(
      "//article/div[3]/div/div[4]/div/div/div[1]/div[1]/div/div/div/div"
    );
  }
  get complaintRemedy() {
    return $(
      "//article/div[3]/div/div[4]/div/div/div[1]/div[2]/div/div/div/div"
    );
  }
  get financialCompensation() {
    return $(
      "//div//div//div//div//div//div//div[4]//div[1]//div[1]//div[2]//div[1]//div[1]//div[1]//div[1]//input[1]"
    );
  }

  get issueType() {
    return $(
      "//article/div[3]/div/div[3]/div/div/div[4]/div[1]/div/div/div/div/div/div/div/a"
    );
  }

  get subIssueType() {
    return $(
      "//article/div[3]/div/div[3]/div/div/div[4]/div[2]/div/div/div/div/div[1]/div/div/a"
    );
  }

  /****** BUTTONS ******/
  get save() {
    //return $("//div/div[2]/button[3]");
    return $("//div/div[2]/div/div/div[3]/button[3]");
  }

  get refreshBtn() {
    return $("//button[@name='refreshButton']");
  }

  get editBtn() {
    return $(
      "//runtime_platform_actions-page-reference-action[1]/slot[1]/slot[1]/lightning-button[1]/button[1]"
    );
  }

  //**LINKS ***/

  get caseLink() {
    return $("//tr[1]//th[1]//span[1]//a[1]");
  }

  ///***PAGE ACTIONS ***/\

  enterCaseInSearch(value: string) {
    helpers.enterText(this.searchTxt, value);
  }

  waitForCaseToDisplay(valueToClick: string) {
    helpers.waitAndRetry(this.refreshBtn, this.caseLink, valueToClick);
  }

  clickEdit() {
    helpers.doJSClick(this.editBtn);
  }

  selectIssueType() {
    helpers.doJSClick(this.issueType);
    const pageElement = $('a[role="menuitemradio"]=Collections');
    helpers.doClick(pageElement);
  }

  selectSubIssueType() {
    helpers.doJSClick(this.subIssueType);
    const pageElement = $('a[role="menuitemradio"]=Disputed debt');
    helpers.doClick(pageElement);
  }

  selectEscalateStatus() {
    helpers.doClick(this.status);
    const pageElement = $('a[role="menuitemradio"]=Escalated');
    helpers.doJSClick(pageElement);
  }

  selectResolveStatus() {
    helpers.doClick(this.status);
    const pageElement = $('a[role="menuitemradio"]=Resolved');
    helpers.doJSClick(pageElement);
  }

  selectProdType() {
    const pageElement = $("mark=Netwealth");
    helpers.doJSClick(pageElement);
  }

  selectEscalatedReason() {
    helpers.doClick(this.escalatedReason);
    const pageElement = $("=Above Banker Discretion");
    helpers.doJSClick(pageElement);
  }

  selectEscalatedTo() {
    helpers.doClick(this.escalatedTo);
    const pageElement = $("=Customer Resolution Portfolio");
    helpers.doJSClick(pageElement);
  }

  selectComplaintOutcome() {
    helpers.doClick(this.complaintOutcome);
    const pageElement = $("=In favour of customer in full");
    helpers.doJSClick(pageElement);
  }

  selectComplaintRemedy() {
    helpers.doClick(this.complaintRemedy);
    const pageElement = $("=Financial remedy");
    helpers.doJSClick(pageElement);
  }

  fillComplaintEditDetails() {
    helpers.enterText(
      this.nominatedThirdName,
      faker.name.firstName() + " " + faker.name.lastName()
    );
    helpers.enterText(this.nominatedThirdEmail, faker.internet.email());
    helpers.enterText(this.nominatedThirdStreet, faker.address.streetName());
    helpers.enterText(this.nominatedThirdSuburb, faker.address.city());
    helpers.enterText(
      this.nominatedThirdPostcode,
      faker.address.zipCode("####")
    );
    helpers.enterText(
      this.nominatedThirdMobile,
      faker.phone.phoneNumber("04########")
    );
    helpers.enterText(
      this.nominatedThirdPhone,
      faker.phone.phoneNumber("97######")
    );
    this.selectIssueType();
    this.selectSubIssueType();
    helpers.enterText(this.productNameSearch, "Netwealth");
    this.selectProdType();
    //helpers.enterText(this.description, faker.lorem.text());
    //helpers.enterText(this.desiredOutcome, faker.lorem.text());
  }

  fillComplaintEscalateDetails() {
    this.status.scrollIntoView();
    this.selectEscalateStatus();
    this.selectIssueType();
    this.selectSubIssueType();
    helpers.enterText(this.productNameSearch, "Netwealth");
    this.selectProdType();
    this.selectEscalatedReason();
    this.selectEscalatedTo();
  }

  fillComplaintResolveDetails() {
    this.status.scrollIntoView();
    this.selectResolveStatus();
    this.selectIssueType();
    this.selectSubIssueType();
    helpers.enterText(this.productNameSearch, "Netwealth");
    this.selectProdType();
    this.selectComplaintOutcome();
    this.selectComplaintRemedy();
    helpers.enterText(this.financialCompensation, "123.22");
    helpers.enterText(
      this.descriptionOfOutcome,
      "Financial compensation awarded"
    );
  }
}

export default new CustomerComplaint();
