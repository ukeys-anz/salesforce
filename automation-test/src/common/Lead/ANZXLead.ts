import Lead from "./Lead";
import RecordCreationForm from "pageObjects/recordCreationForm";
import LwcRecordCreationForm from "pageObjects/lwcRecordCreationForm";
import IChatter from "interfaces/IChatter";
import LeadNotesTab from "pageObjects/leadNotesTab";
import RecordPage from "pageObjects/recordPage";
import * as commonUtils from "utils/commonUtils";
import * as leadPageUtils from "utils/leadPageUtils";
import { loginJSForce } from "utils/apiUtils";
import { gotoRecordPageById } from "utils/navigationUtils";

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

    // Set Name - field is a compound field
    const nameField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [1, 1, 1]
    );
    const recordLayoutInputName = await nameField.getInputName();
    const inputName = await recordLayoutInputName.getInputName();

    const firstNameInput = await inputName.getFirstNameInput();
    const firstName = leadData?.firstName ? leadData.firstName : this.firstName;
    await firstNameInput.setText(firstName);

    const lastNameInput = await inputName.getLastNameInput();
    const lastName = leadData?.lastName ? leadData.lastName : this.lastName;
    await lastNameInput.setText(lastName);

    // Set Mobiile
    const mobilePhoneField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [1, 2, 1]
    );
    const mobilePhoneInput = await mobilePhoneField.getInput();
    const mobile = leadData?.mobile ? leadData.mobile : this.mobile;
    await mobilePhoneInput.setText(mobile);

    // Set email
    const emailField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [1, 3, 1]
    );
    const emailInput = await emailField.getInput();
    const email = leadData?.email ? leadData.email : this.email;
    await emailInput.setText(email);

    // Set Lead Source
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [1, 3, 2], 4);

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
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [1, 2, 2], 4);
    await baseRecordForm.clickFooterButton("Save");
    await browser.pause(3000);
    // Validation error should be thrown: Lead Status cannot be changed to Converted manually.
    await baseRecordForm.clickFooterButton("Cancel");
    await browser.pause(1000);

    // Assert Status field is still New
    const statusPicklistAfterAttemptedConvert =
      await commonUtils.getFieldFromRecordLayout(recordLayout, [1, 2, 2]);
    expect(
      await commonUtils.getFormattedTextValue(
        statusPicklistAfterAttemptedConvert!
      )
    ).toEqual("New");
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

  async receiveLeadViaQualtricsIntegration(): Promise<string | void> {
    let apiResult = "";

    // Log in as Qualtrics Integration User
    const conn = await loginJSForce(
      process.env.QUALTRICS_AUTOMATION_USERNAME!,
      process.env.QUALTRICS_AUTOMATION_PASSWORD!
    );

    if (conn) {
      // Construct lead payload
      const qualtricsPayload = {
        FirstName: this.firstName,
        LastName: this.lastName,
        MobilePhone: this.mobile,
        Email: this.email,
        Marketing_Consent__c: true,
        Privacy_Consent__c: true,
        LeadSource: "Marketing",
        RecordTypeId: process.env.ANZX_LEADS_RECORD_TYPE_ID
      };

      const optionHeader = { headers: { "SForce-Auto-Assign": "FALSE" } };

      const sr = await conn
        .sobject("Lead")
        .create(qualtricsPayload, optionHeader);

      expect(sr.success);

      apiResult = await sr.id!;
      return apiResult;
    }
  }

  async openById(leadId: string) {
    await browser.pause(1000);
    await gotoRecordPageById(leadId);
    await browser.pause(1000);
  }

  async verifyQualtricsLead() {
    const baseRecordForm = (await leadPageUtils.getRecordForm())!;
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Assert Status field is New
    const statusPicklist = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [1, 2, 2]
    );
    expect(await commonUtils.getFormattedTextValue(statusPicklist!)).toEqual(
      "New"
    );

    async verifyLeadFieldsAreReadOnly(): Promise<void> {
    const baseRecordForm = (await leadPageUtils.getRecordForm())!;
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Mobile Phone Field
    await commonUtils.editButtonIsNotVisible(recordLayout, [1, 2, 1]);
    // Status Picklist
    await commonUtils.editButtonIsNotVisible(recordLayout, [1, 2, 2]);
    // Email Field
    await commonUtils.editButtonIsNotVisible(recordLayout, [1, 2, 2]);
  }
}
