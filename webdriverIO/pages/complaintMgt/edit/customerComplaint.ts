import Base from "../../base";
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
    return $("//div/div[2]/div/div/div[2]/div[1]/div/div/div/input");
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
    return $("//div/div[2]/div/div/div[5]/div[1]/div/div/div/input");
  }
  get subject() {
    return $("//div/div[3]/div/div/div[8]/div/div/div/div/input");
  }
  get description() {
    return $("//div/div[3]/div/div/div[9]/div/div/div/div/textarea");
  }
  get desiredOutcome() {
    return $("//div/div[3]/div/div/div[10]/div/div/div/div/textarea");
  }
  get descriptionOfOutcome() {
    return $("//div/div[4]/div/div/div[3]/div/div/div/div/textarea");
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
    return $("//div/div[3]/div/div/div[6]/div[1]/div/div/div/div");
  }
  get escalatedTo() {
    return $("//div/div[3]/div/div/div[5]/div[2]/div/div/div/div");
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
    return $("//div/div[4]/div/div/div[2]/div[1]/div/div/div/div");
  }

  /****** BUTTONS ******/
  get save() {
    return $("//div/div[3]/div/button[3]");
  }
}

export default new CustomerComplaint();
