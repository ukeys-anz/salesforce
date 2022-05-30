import Lead from "./Lead";
import RecordCreationForm from "pageObjects/recordCreationForm";
import LwcRecordCreationForm from "pageObjects/lwcRecordCreationForm";
import * as commonUtils from "utils/commonUtils";
import IChatter from "interfaces/IChatter";
import LeadNotesTab from "pageObjects/leadNotesTab";
import * as leadPageUtils from "utils/leadPageUtils";
import * as faker from "faker";
import RecordPage from "pageObjects/recordPage";

const generalComment = `Automation Test General Comment.`;
export default class ANZXLead extends Lead implements IChatter {
  async create(leadData?: any): Promise<void> {
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
    const firstName = leadData?.firstName
      ? leadData.firstName
      : faker.name.firstName();
    await firstNameInput.setText(firstName);

    const lastNameInput = await inputName.getLastNameInput();
    const lastName = leadData?.lastName
      ? leadData.lastName
      : faker.name.lastName();
    await lastNameInput.setText(lastName);

    const mobilePhoneField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [1, 2, 1]
    );
    const mobilePhoneInput = await mobilePhoneField.getInput();
    const mobile = leadData?.mobile
      ? leadData.mobile
      : faker.phone.phoneNumber("04########");
    await mobilePhoneInput.setText(mobile);

    const emailField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [1, 3, 1]
    );
    const emailInput = await emailField.getInput();
    const email = leadData?.email
      ? leadData.email
      : faker.internet.exampleEmail(firstName, lastName);
    await emailInput.setText(email);

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
      [1, 2, 2],
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

  async verifyDuplicate(hasDuplicates: boolean): Promise<void> {
    // load Lead flexi page
    const recordPageRoot = await utam.load(RecordPage);
    const leadRecordPage = await recordPageRoot.getLeadRecordPage();
    const mergeCandidatesPreviewCard =
      await leadRecordPage.getMergeCandidatesPreviewCard();

    const duplicateMessage =
      await mergeCandidatesPreviewCard.getDuplicateMessage();

    if (hasDuplicates) {
      expect(duplicateMessage).toEqual(
        "We found 1 potential duplicate of this Lead."
      );
    } else {
      expect(duplicateMessage).toEqual(
        "We found no potential duplicates of this Lead."
      );
    }
  }
}
