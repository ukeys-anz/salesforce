import LwcCaseCreation from "../pageObjects/lwcCaseCreation";
import data from "../../testdata.json";

export default class SfCases {
  createCase = async () => {
    const casePageRoot = await utam.load(LwcCaseCreation);

    const caseNewCaseElement = await casePageRoot.getNewCase();
    await caseNewCaseElement.click();

    const caseGenEnqChk = await casePageRoot.getGeneralEnquiryChk();
    //Select case Type - at the moment it is general enquiry
    await caseGenEnqChk.click();

    const caseNextButton = await casePageRoot.getNextButton();
    //Click next button
    await caseNextButton.click();

    const caseInputElement = await casePageRoot.getCustomerInput();
    const caseDropDown = await casePageRoot.getCustomerDropDown(
      data.accounts[1].case_creation.name
    );

    //Enter case creation fields
    await caseInputElement.setText(data.accounts[1].case_creation.name);
    await caseDropDown.click();

    const selectElement = await casePageRoot.getSelectElements();

    await selectElement[0].click();
    await browser.pause(1000);

    const dropdownElement = await casePageRoot.getValueDropDown("Chat");
    await dropdownElement.click();
    await browser.pause(3000);
    await selectElement[1].click();
    await browser.pause(2000);

    // const IssuedropdownElement = await casePageRoot.getValueDropDown(
    //   "Deceased Estate"
    // );

    const IssuedropdownElement = await casePageRoot.getValueDropDown("Cards");
    await IssuedropdownElement.click();
    await browser.pause(2000);
    // const issueSubType = await $("//span[@title='Lost or stolen card']");
   /* const issueSubType = await casePageRoot.getDualListLeft(
      "Lost or stolen card"
    );
    await issueSubType.click();

    // const moveChosenElement = await casePageRoot.getMoveChosen();
    const moveChosenElement = await $(
      "//button[@title='Move selection to Chosen']"
    );
    await moveChosenElement.click();*/
    await browser.pause(3000);

    const saveCaseElement = await casePageRoot.getSaveCase();
    await saveCaseElement.click();
    await browser.pause(3000);
  };
}
