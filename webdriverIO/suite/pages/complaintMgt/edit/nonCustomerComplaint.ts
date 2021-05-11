import Base from "../../base";
import helpers from "../../../utilities/helpers";
import * as faker from "faker";

/**
 * Handles the Non Customer Complaint record type fields on Complaints Mgt during edit
 */
class NonCustomerComplaint extends Base {
  /****** TEXT INPUTS ******/
  get businessName() {
    return $("//div/div[2]/div/div/div[1]/div[2]/div/div/div/input");
  }
  get firstName() {
    return $("//div/div[2]/div/div/div[2]/div[1]/div/div/div/input");
  }
  get middleName() {
    return $("//div/div[2]/div/div/div[2]/div[2]/div/div/div/input");
  }
  get lastName() {
    return $("//div/div[2]/div/div/div[3]/div[1]/div/div/div/input");
  }
  get email() {
    return $("//div/div[2]/div/div/div[5]/div[1]/div/div/div/input");
  }
  get mobile() {
    return $("//div/div[2]/div/div/div[5]/div[2]/div/div/div/input");
  }
  get phone() {
    return $("//div/div[2]/div/div/div[6]/div[1]/div/div/div/input");
  }
  get street() {
    return $("//div/div[2]/div/div/div[6]/div[2]/div/div/div/input");
  }
  get suburb() {
    return $("//div/div[2]/div/div/div[7]/div[1]/div/div/div/input");
  }
  get postcode() {
    return $("//div/div[2]/div/div/div[7]/div[2]/div/div/div/input");
  }
  get description() {
    return $("//div/div[4]/div/div/div[8]/div/div/div/div/textarea");
  }
  get desiredOutcome() {
    return $("//div/div[4]/div/div/div[9]/div/div/div/div/textarea");
  }
  get nominatedThirdName() {
    return $("//div/div[3]/div/div/div[1]/div[1]/div/div/div/input");
  }
  get nominatedThirdEmail() {
    return $("//div/div[3]/div/div/div[1]/div[2]/div/div/div/input");
  }
  get nominatedThirdStreet() {
    return $("//div/div[3]/div/div/div[3]/div[1]/div/div/div/input");
  }
  get nominatedThirdSuburb() {
    return $("//div/div[3]/div/div/div[2]/div[2]/div/div/div/input");
  }
  get nominatedThirdPostcode() {
    return $("//div/div[3]/div/div/div[4]/div[1]/div/div/div/input");
  }
  get nominatedThirdMobile() {
    return $("//div/div[3]/div/div/div[4]/div[2]/div/div/div/input");
  }
  get nominatedThirdPhone() {
    return $("//div/div[3]/div/div/div[6]/div[1]/div/div/div/input");
  }
  get productNameSearch() {
    return $('input[title="Search Products"]');
  }

  /****** DROPDOWNS ******/
  get complainantType() {
    return $("//div/div[2]/div/div/div[1]/div[1]/div/div/div/div");
  }
  get age() {
    return $("//div/div[2]/div/div/div[3]/div[2]/div/div/div/div");
  }
  get gender() {
    return $("//div/div[2]/div/div/div[4]/div[1]/div/div/div/div");
  }
  get country() {
    return $("//div/div[2]/div/div/div[8]/div[2]/div/div/div/div");
  }
  get state() {
    return $("//div/div[2]/div/div/div[8]/div[1]/div/div/div/div");
  }
  get priority() {
    return $("//div/div[4]/div/div/div[3]/div[2]/div/div/div/div");
  }
  get caseType() {
    return $("//div/div[4]/div/div/div[4]/div[1]/div/div/div/div");
  }
  get nominatedThirdCountry() {
    return $("//div/div[3]/div/div/div[3]/div[2]/div/div/div/div");
  }
  get nominatedThirdState() {
    return $("//div/div[3]/div/div/div[4]/div[1]/div/div/div/div");
  }
  get writtenResponseRequested() {
    return $("//div/div[7]/div/div/div[3]/div[1]/div/div/div/div");
  }
  get writtenResponseRequired() {
    return $("//div/div[7]/div/div/div[3]/div[2]/div/div/div/div");
  }

  get searchTxt() {
    return $("//input[@placeholder='Search this list...']");
  }

  /****** BUTTONS ******/
  get save() {
    return $("//div/div[3]/button[3]");
  }

  get editBtn() {
    return $(
      "//runtime_platform_actions-page-reference-action[1]/slot[1]/slot[1]/lightning-button[1]/button[1]"
    );
  }

  get refreshBtn() {
    return $("//button[@name='refreshButton']");
  }

  /****LINKS*****/

  get caseLink() {
    return $("//tr[1]//th[1]//span[1]//a[1]");
  }

  /****PAGE ACTIONS *******/

  enterCaseInSearch(value: string) {
    helpers.enterText(this.searchTxt, value);
  }

  clickEdit() {
    helpers.doClick(this.editBtn);
  }

  waitForCaseToDisplay(valueToClick: string) {
    helpers.waitAndRetry(this.refreshBtn, this.caseLink, valueToClick);
  }

  selectSubIssueType() {
    const pageElement = $("=Disputed debt");
    helpers.doJSClick(pageElement);
  }

  selectProdType() {
    const pageElement = $("mark=Netwealth");
    helpers.doJSClick(pageElement);
  }

  selectWrittenResponseRequestedAsYes() {
    this.writtenResponseRequested.click();
    const pageElement = $("=Yes");
    helpers.doClick(pageElement);
  }

  selectWrittenResponseRequiredAsNo() {
    this.writtenResponseRequired.click();
    const pageElement = $("=No");
    helpers.doClick(pageElement);
  }

  fillNonComplaintEditDetails() {
    helpers.enterText(this.phone, faker.phone.phoneNumber("04########"));
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
    this.selectSubIssueType();
    helpers.enterText(this.productNameSearch, "Netwealth");
    this.selectProdType();
    this.selectWrittenResponseRequestedAsYes();
    this.selectWrittenResponseRequiredAsNo();
  }
}

export default new NonCustomerComplaint();
