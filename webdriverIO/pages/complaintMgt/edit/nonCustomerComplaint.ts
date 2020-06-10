import Base from "../../base";
/**
 * Handles the Non Customer Complaint record type fields on Complaints Mgt during edit
 */
class NonCustomerComplaint extends Base {
  /****** TEXT INPUTS ******/
  get businessName() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[1]/div[2]/div/div/div/input"
    );
  }
  get firstName() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[2]/div[1]/div/div/div/input"
    );
  }
  get middleName() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[2]/div[2]/div/div/div/input"
    );
  }
  get lastName() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[3]/div[1]/div/div/div/input"
    );
  }
  get email() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[5]/div[1]/div/div/div/input"
    );
  }
  get mobile() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[5]/div[2]/div/div/div/input"
    );
  }
  get phone() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[6]/div[1]/div/div/div/input"
    );
  }
  get street() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[6]/div[2]/div/div/div/input"
    );
  }
  get suburb() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[7]/div[1]/div/div/div/input"
    );
  }
  get postcode() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[7]/div[2]/div/div/div/input"
    );
  }
  get description() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[4]/div/div/div[8]/div/div/div/div/textarea"
    );
  }
  get desiredOutcome() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[4]/div/div/div[9]/div/div/div/div/textarea"
    );
  }
  get nominatedThirdName() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[1]/div[1]/div/div/div/input"
    );
  }
  get nominatedThirdEmail() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[1]/div[2]/div/div/div/input"
    );
  }
  get nominatedThirdStreet() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[2]/div[1]/div/div/div/input"
    );
  }
  get nominatedThirdSuburb() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[2]/div[2]/div/div/div/input"
    );
  }
  get nominatedThirdPostcode() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[3]/div[1]/div/div/div/input"
    );
  }
  get nominatedThirdMobile() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[4]/div[2]/div/div/div/input"
    );
  }
  get nominatedThirdPhone() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[5]/div[1]/div/div/div/input"
    );
  }

  /****** DROPDOWNS ******/
  get complainantType() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[1]/div[1]/div/div/div/div"
    );
  }
  get age() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[3]/div[2]/div/div/div/div"
    );
  }
  get gender() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[4]/div[1]/div/div/div/div"
    );
  }
  get descent() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[4]/div[2]/div/div/div/div"
    );
  }
  get country() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[8]/div[2]/div/div/div/div"
    );
  }
  get state() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[8]/div[1]/div/div/div/div"
    );
  }
  get priority() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[4]/div/div/div[3]/div[2]/div/div/div/div"
    );
  }
  get caseType() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[4]/div/div/div[4]/div[1]/div/div/div/div"
    );
  }
  get nominatedThirdCountry() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[3]/div[2]/div/div/div/div"
    );
  }
  get nominatedThirdState() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[4]/div[1]/div/div/div/div"
    );
  }
  get writtenResponseRequested() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[7]/div/div/div[3]/div[1]/div/div/div/div"
    );
  }
  get writtenResponseRequired() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[7]/div/div/div[3]/div[2]/div/div/div/div"
    );
  }

  /****** BUTTONS ******/
  get save() {
    return $("/html/body/div[4]/div[2]/div[1]/div[2]/div/div[3]/div/button[3]");
  }
}

export default new NonCustomerComplaint();
