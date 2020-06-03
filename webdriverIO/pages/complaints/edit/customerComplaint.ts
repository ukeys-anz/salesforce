import Base from "../../base";
/**
 * Handles the Customer Complaint record type fields on Complaints Mgt during edit
 */
class CustomerComplaint extends Base {
  /****** TEXT INPUTS ******/
  get customerNumber() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[1]/div/div/div[1]/div[1]/div/div/div/input"
    );
  }
  get nominatedThirdName() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[1]/div[1]/div/div/div/input"
    );
  }
  get nominatedThirdEmail() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[1]/div[2]/div/div/div/input"
    );
  }
  get nominatedThirdStreet() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[2]/div[1]/div/div/div/input"
    );
  }
  get nominatedThirdSuburb() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[2]/div[2]/div/div/div/input"
    );
  }
  get nominatedThirdPostcode() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[3]/div[1]/div/div/div/input"
    );
  }
  get nominatedThirdMobile() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[4]/div[2]/div/div/div/input"
    );
  }
  get nominatedThirdPhone() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[5]/div[1]/div/div/div/input"
    );
  }
  get subject() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[8]/div/div/div/div/input"
    );
  }
  get description() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[9]/div/div/div/div/textarea"
    );
  }
  get desiredOutcome() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[10]/div/div/div/div/textarea"
    );
  }
  get descriptionOfOutcome() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[4]/div/div/div[3]/div/div/div/div/textarea"
    );
  }

  /****** DROPDOWNS ******/
  get complainantType() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[1]/div/div/div[1]/div[2]/div/div/div/div"
    );
  }
  get descent() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[1]/div/div/div[2]/div[1]/div/div/div/div"
    );
  }
  get nominatedThirdCountry() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[3]/div[2]/div/div/div/div"
    );
  }
  get nominatedThirdState() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[2]/div/div/div[4]/div[1]/div/div/div/div"
    );
  }
  get status() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[2]/div[2]/div/div/div/div"
    );
  }
  get escalatedReason() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[6]/div[2]/div/div/div/div"
    );
  }
  get escalatedTo() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[3]/div/div/div[7]/div[1]/div/div/div/div"
    );
  }
  get complaintOutcome() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[4]/div/div/div[1]/div[1]/div/div/div/div"
    );
  }
  get complaintRemedy() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[4]/div/div/div[1]/div[2]/div/div/div/div"
    );
  }
  get financialCompensation() {
    return $(
      "/html/body/div[4]/div[2]/div[1]/div[2]/div/div[2]/div/article/div[3]/div/div[4]/div/div/div[2]/div[1]/div/div/div/div"
    );
  }

  /****** BUTTONS ******/
  get save() {
    return $("/html/body/div[4]/div[2]/div[1]/div[2]/div/div[3]/div/button[3]");
  }
}

export default new CustomerComplaint();
