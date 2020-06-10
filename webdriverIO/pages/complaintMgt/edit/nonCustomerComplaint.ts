import Base from "../../base";
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
    return $("//div/div[3]/div/div/div[2]/div[1]/div/div/div/input");
  }
  get nominatedThirdSuburb() {
    return $("//div/div[3]/div/div/div[2]/div[2]/div/div/div/input");
  }
  get nominatedThirdPostcode() {
    return $("//div/div[3]/div/div/div[3]/div[1]/div/div/div/input");
  }
  get nominatedThirdMobile() {
    return $("//div/div[3]/div/div/div[4]/div[2]/div/div/div/input");
  }
  get nominatedThirdPhone() {
    return $("//div/div[3]/div/div/div[5]/div[1]/div/div/div/input");
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
  get descent() {
    return $("//div/div[2]/div/div/div[4]/div[2]/div/div/div/div");
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

  /****** BUTTONS ******/
  get save() {
    return $("//div[3]/div/button[3]");
  }
}

export default new NonCustomerComplaint();
