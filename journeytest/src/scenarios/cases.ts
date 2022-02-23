import LwcCaseCreation from "../pageObjects/lwcCaseCreation";
import data from "../../testdata.json";
import { ScenarioUtil } from "../common/scenarioUtil";

export default class SfCases {
  createGenEnqCase = async (scenarioId: string) => {
    const casePageRoot = utam.load(LwcCaseCreation);

    //Navigation to new case form
    await this.navigateToNewCase();

    //Select the case type
    await this.selectCaseType("General Enquiry");

    let casesData: any = {};
    casesData = await ScenarioUtil.getCaseCreateDetails(scenarioId);

    const caseInputElement = await (await casePageRoot).getCustomerInput();
    const caseDropDown = await (await casePageRoot).getCustomerDropDown(
      data.accounts[0].case_creation.name
    );

    //Enter case creation fields
    await caseInputElement.setText(data.accounts[0].case_creation.name);
    await caseDropDown.click();

    //Channel Received
    await this.selectChannelReceived(casesData.channelReceived);

    //Issue Type
    await this.selectIssueType("New", casesData.issueType);

    //Subsequent Issue Type
    const issueSubType = await $(`//span[@title='${casesData.issueSubType}']`);
    await issueSubType.click();

    const moveChosenElement = await $(
      "//button[@title='Move selection to Chosen']"
    );
    await moveChosenElement.click();
    await browser.pause(1000);

    const saveCaseElement = await (await casePageRoot).getSaveCase();
    await saveCaseElement.click();
    await browser.pause(3000);

    return this.getCaseNumberCreated();
  };

  createAnzxComplaintCase = async (scenarioId: string) => {
    const casePageRoot = utam.load(LwcCaseCreation);

    await this.navigateToNewCase();
    await this.selectCaseType("ANZ Plus Complaint");

    // const casePageRoot = await utam.load(LwcCaseCreation);
    let casesData: any = {};
    casesData = await ScenarioUtil.getCaseCreateDetails(scenarioId);

    //Fill ANZ Plus Complaint form
    //Select Customer details
    const caseInputElement = await (await casePageRoot).getCustomerInput();
    const caseDropDown = await (await casePageRoot).getCustomerDropDown(
      data.accounts[0].case_creation.name
    );
    await caseInputElement.setText(data.accounts[0].case_creation.name);
    await caseDropDown.click();

    //Enter Case Information
    await this.selectIssueType("New", casesData.issueType);
    await this.selectIssueSubType("New", casesData.issueSubType);

    const producttxt = await $("(//input[@title='Search Products'])[1]");
    await producttxt.setValue(casesData.productOrService);
    const productDdValue = await $(
      `//a//div[@title='${casesData.productOrService}']`
    );
    await productDdValue.click();

    const desctxt = await $(
      "//label/span[text()='Description of Issue']/../following-sibling::textarea"
    );
    await desctxt.setValue(casesData.description);

    const outcometxt = await $(
      "//label/span[text()='Customer Desired Outcome']/../following-sibling::textarea"
    );
    await outcometxt.setValue(casesData.outcome);

    const writtenRespDd = await $(
      "//span[text()='Is a Written Response Requested?']/../following-sibling::div//a"
    );
    await writtenRespDd.click();
    await browser.pause(1000);
    await this.selectMenuOption(casesData.writtenResponse);

    //First Issue

    //Second Issue

    //Complaince Information

    //Submit
    await this.submitCase();

    return this.getCaseNumberCreated();
  };

  getCaseNumberCreated = async () => {
    const caseNumberElement = await $(
      "//p[@title='Case Number']/following-sibling::p"
    );
    const caseNumber = await caseNumberElement.getText();
    return caseNumber;
  };

  selectCaseType = async (caseType: string) => {
    const caseTypeRadioElement = await $(
      `//label/span[text()='${caseType}']/preceding-sibling::span`
    );
    await caseTypeRadioElement.click();
    const nextButton = await $("//button[text()='Next']");
    await nextButton.click();

    //In this case, xpath takes label text in the UI as arguements to dynamically select the radio button,
    //but in case of UTAM, it is only possible through name attribute, value of which is but different from label text of corresponding radio button
    // const casePageRoot = utam.load(LwcCaseCreation);
    // const caseTypeRadio = await (await casePageRoot).getAnzxComplaint()
    // await caseTypeRadio.click()
    // const caseNextButton = await (await casePageRoot).getNextButton()
    // await caseNextButton.click()
  };

  navigateToNewCase = async () => {
    const casePageRoot = await utam.load(LwcCaseCreation);
    const caseNewCaseElement = await casePageRoot.getNewCase();
    await caseNewCaseElement.click();
  };

  selectMenuOption = async (valueToSelect: string) => {
    const optionsElement = await $(
      `//div[@class='select-options']//li/a[text()='${valueToSelect}']`
    );
    await optionsElement.click();
  };

  selectLighteningMenuOption = async (valueToSelect: string) => {
    const optionsElement = await $(
      `//lightning-base-combobox-item//span[@title='${valueToSelect}']`
    );
    await optionsElement.click();
  };

  changeOwner = async (scenarioId: string) => {
    const ownerElement = await $("//button[@title='Change Owner']/..");
    await ownerElement.click();
    await browser.pause(1000);

    const ownerTypeSelect = await $("//a[contains(@aria-label,'new owner')]");
    await ownerTypeSelect.click();
    await browser.pause(2000);

    let casesData: any = {};
    casesData = await ScenarioUtil.getCaseEditDetails(scenarioId);
    const ownerType = await $(`//a[@title='${casesData.caseOwnerType}']`);
    await ownerType.click();
    const searchBox = await $(
      `//input[@title='Search ${casesData.caseOwnerType}']`
    );
    await searchBox.setValue(casesData.caseOwner);
    const queueValue = await $(`//a//div[@title='${casesData.caseOwner}']`);
    await queueValue.click();
    const changeOwnerbtn = await $("//button[@name='change owner']");
    await changeOwnerbtn.click();
    await browser.pause(3000);
  };

  editIssueType = async (scenarioId: string) => {
    let casesData: any = {};
    casesData = await ScenarioUtil.getCaseEditDetails(scenarioId);
    let caseType: any = {};
    caseType = await ScenarioUtil.getCaseCreateDetails(scenarioId);

    const editIssueType = await $("//button[@title='Edit Issue Type']");
    await editIssueType.click();
    await browser.pause(2000);

    //Issue Type
    await this.selectIssueType("Edit", casesData.issueType);

    //Issue Sub Type
    if (caseType.type == "General Enquiry") {
      const issueSubType = await $(
        `//span[@title='${casesData.issueSubType}']`
      );
      await issueSubType.click();

      const moveChosenElement = await $(
        "//button[@title='Move selection to Chosen']"
      );
      await moveChosenElement.click();
      await browser.pause(1000);
    } else {
      await this.selectIssueSubType("Edit", casesData.issueSubType);
    }

    const saveEdit = await $("//button[@name='SaveEdit']");
    await saveEdit.click();
    await browser.pause(2000);
  };

  selectIssueType = async (mode: string, value: string) => {
    //The Issue type drop down does not contain any unique way of CSS selector identification,
    //this object is selected using the sibling's label text via xpath - this is more resilient than css selector
    //this will change only when the DOM is changed due to any CRs in the future

    let issueTypeDd;
    if (mode == "Edit") {
      issueTypeDd = await $(
        "//label[text()='Issue Type']/following-sibling::div//button"
      );
      await issueTypeDd.click();
      await browser.pause(1000);
      await this.selectLighteningMenuOption(value);
    } else {
      issueTypeDd = await $(
        "//span[text()='Issue Type']/../following-sibling::div//a"
      );
      await issueTypeDd.click();
      await browser.pause(1000);
      await this.selectMenuOption(value);
    }
  };

  selectChannelReceived = async (value: string) => {
    const channelDd = await $(
      "//span[text()='Channel Received']/../following-sibling::div//a"
    );
    await channelDd.click();
    await browser.pause(1000);
    await this.selectMenuOption(value);
  };

  selectIssueSubType = async (mode: string, value: string) => {
    let issueSubTypeDd;
    if (mode == "Edit") {
      issueSubTypeDd = await $(
        "//label[text()='Subsequent Issue Type']/following-sibling::div//button"
      );
      await issueSubTypeDd.click();
      await browser.pause(1000);
      await this.selectLighteningMenuOption(value);
    } else {
      issueSubTypeDd = await $(
        "//span[text()='Subsequent Issue Type']/../following-sibling::div//a"
      );
      await issueSubTypeDd.click();
      await browser.pause(1000);
      await this.selectMenuOption(value);
    }
  };

  submitCase = async () => {
    //Submit
    const saveButton = await $("//button[@title='Save']");
    await saveButton.click();
    await browser.pause(3000);
  };

  closeCase = async (caseNumber: string) => {
    await this.openCase(caseNumber);
    const editStatusBtn = await $("//button[@title='Edit Status']");
    await editStatusBtn.click();

    const statusList = await $(
      "//label[text()='Status']/following-sibling::div//button"
    );
    await statusList.click();

    await this.selectLighteningMenuOption("Closed");
    const saveEdit = await $("//button[@name='SaveEdit']");
    await saveEdit.click();
    await browser.pause(2000);
    await this.verifyCaseStatus("Closed");
  };

  openCase = async (caseNumber: string) => {
    const caseInput = await $("//input[@name='Case-search-input']");
    await caseInput.setValue(caseNumber);

    const refreshBtn = await $("//button[@name='refreshButton']");
    await refreshBtn.click();

    const caseLink = await $(`//a[@title='${caseNumber}']`);
    await caseLink.click();
  };

  verifyCaseStatus = async (status: string) => {
    const caseStatuElement = await $(
      "//p[@title='Status']/following-sibling::p"
    );
    await expect(caseStatuElement).toHaveText(status);
  };

  shareCaseUpdate = async () => {
    const shareButton = await $(
      "//li/a[text()='Case Notes']/ancestor::lightning-tab-bar/following-sibling::slot//button[@title='Share an update...']"
    );
    await shareButton.scrollIntoView();
    await shareButton.click();
    await browser.pause(2000);

    const textArea = await $("//div[@data-placeholder='Share an update...']/p");
    await textArea.setValue("Case comments by automation script");

    const submitComment = await $(
      "//button[@title='Click, or press Ctrl+Enter']"
    );
    await submitComment.click();
    await browser.pause(2000);

    const postTxtElm = await $(
      "//li/a[text()='Case Notes']/ancestor::lightning-tab-bar/following-sibling::slot//article[@data-type='TextPost']//p"
    );
    await expect(await postTxtElm.getText()).toHaveText(
      "Case comments by automation script"
    );
  };
}
