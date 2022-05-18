import Lead from "./Lead";
import RecordCreationForm from "pageObjects/recordCreationForm";
import LwcRecordCreationForm from "pageObjects/lwcRecordCreationForm";
import * as commonUtils from "utils/commonUtils";
import IChatter from "interfaces/IChatter";
import LeadNotesTab from "pageObjects/leadNotesTab";
import * as leadPageUtils from "utils/leadPageUtils";
import * as faker from "faker";

const generalComment = `Automation Test General Comment.`;
export default class ANZXLead extends Lead implements IChatter {
  async create(): Promise<void> {
    const recordCreationFormRoot = await utam.load(RecordCreationForm);

    await recordCreationFormRoot.createNewLead();
    await browser.pause(2000);

    const lwcRecordCreationFormRoot = await utam.load(LwcRecordCreationForm);

    const baseRecordFrom =
      await lwcRecordCreationFormRoot.getModalBaseRecordForm();

    const recordLayout = await baseRecordFrom.getRecordLayout();

    // name field is a compound field
    const nameField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [1, 1, 1]
    );

    const recordLayoutInputName = await nameField.getInputName();
    const inputName = await recordLayoutInputName.getInputName();
    const firstNameInput = await inputName.getFirstNameInput();
    const randomFirstName = faker.name.firstName();
    await firstNameInput.setText(randomFirstName);

    const lastNameInput = await inputName.getLastNameInput();
    const randomLastName = faker.name.lastName();
    await lastNameInput.setText(randomLastName);

    const mobilePhoneField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [1, 2, 1]
    );
    const mobilePhoneInput = await mobilePhoneField.getInput();
    const randomMobileNumber = faker.phone.phoneNumber("04########");
    await mobilePhoneInput.setText(randomMobileNumber);

    const emailField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [1, 3, 1]
    );
    const emailInput = await emailField.getInput();
    const emailText = faker.internet.exampleEmail(
      randomFirstName,
      randomLastName
    );
    await emailInput.setText(emailText);

    // click save button
    const formFooter = await baseRecordFrom.getFooter();
    const actionRibbon = await formFooter.getActionsRibbon();
    const saveButton = await actionRibbon.getActionRendererWithTitle("Save");
    await saveButton.clickButton();
    await browser.pause(5000);
  }

  async verifyCannotManuallyConvert(): Promise<void> {
    const baseRecordForm = (await leadPageUtils.getRecordForm())!;
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Attempt to change Status to Converted
    const statusPicklist = await commonUtils.selectPicklistOnRecordLayout(
      recordLayout,
      [1, 1, 2],
      4
    );
    await baseRecordForm.clickFooterButton("Save");
    await browser.pause(3000);
    // Validation error should be thrown: Lead Status cannot be changed to Converted manually.
    await baseRecordForm.clickFooterButton("Cancel");
    await browser.pause(1000);
  }

  async postChatterComment(): Promise<void> {
    const leadNotesTab = await leadPageUtils.getTabContent("Lead Notes");
    if (leadNotesTab instanceof LeadNotesTab) {
      const chatterPanel = await leadNotesTab.getChatterPanel();
      await chatterPanel.clickShareButton();
      await browser.pause(2000);
      await chatterPanel.postComment(generalComment);
    }
  }

  async verifyChatterComment(): Promise<void> {
    const leadNotesTab = await leadPageUtils.getTabContent("Lead Notes");
    if (leadNotesTab instanceof LeadNotesTab) {
      const chatterPanel = await leadNotesTab.getChatterPanel();
      expect(
        await chatterPanel.latestPostContentEquals(generalComment)
      ).toEqual(true);
    }
  }
}
