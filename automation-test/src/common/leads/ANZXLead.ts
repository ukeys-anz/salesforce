import Lead from "./Lead";
import RecordCreationForm from "pageObjects/recordCreationForm";
import LwcRecordCreationForm from "pageObjects/lwcRecordCreationForm";
import * as commonUtils from "../../utils/commonUtils";
import IChatter from "../../interfaces/IChatter";
import LeadNotesTab from "pageObjects/leadNotesTab";
import * as leadPageUtils from "../../utils/leadPageUtils";
import RecordPage from "pageObjects/recordPage";
import {
  navigateToAppAndTab,
  openRecordPageById
} from "../../utils/navigationUtils";
import { App, AppTab } from "../../constants/appsDefinition";
import ObjectHome from "pageObjects/objectHome";
import UAM from "../../common/UAM";
import { UserRole, Access } from "../../constants/enums";

const generalComment = `Automation Test General Comment.`;

export default class ANZXLead extends Lead implements IChatter {
  async create(leadData?: any): Promise<void> {
    const recordCreationFormRoot = await utam.load(RecordCreationForm);

    await recordCreationFormRoot.createNewLead();
    await browser.pause(5000);

    const lwcRecordCreationFormRoot = await utam.load(LwcRecordCreationForm);

    const baseRecordForm =
      await lwcRecordCreationFormRoot.getModalBaseRecordForm();

    const recordLayout = await baseRecordForm.getRecordLayout();

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

    // Set Mobile
    const mobilePhoneField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [1, 2, 1]
    );
    const mobilePhoneInput = await mobilePhoneField.getInput();
    const mobile = leadData?.mobile ? leadData.mobile : this.mobile;
    await mobilePhoneInput!.setText(mobile);

    // Set email
    const emailField = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [1, 3, 1]
    );
    const emailInput = await emailField.getInput();
    const email = leadData?.email ? leadData.email : this.email;
    await emailInput!.setText(email);

    // Set Lead Source
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [1, 3, 2], 4);

    await commonUtils.clickFormFooterButtonByTitle("Save", baseRecordForm);
  }

  async verifyCannotManuallyConvert(): Promise<void> {
    const baseRecordForm = await leadPageUtils.getRecordForm();
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

    // Assert Status field is still New
    const statusPicklistAfterAttemptedConvert =
      await commonUtils.getFieldFromRecordLayout(recordLayout, [1, 2, 2]);

    const status = await (
      await statusPicklistAfterAttemptedConvert.getFormattedText()
    ).getInnerText();

    expect(status).toEqual("New");
  }

  async postChatterComment(): Promise<void> {
    const leadNotesTab = await leadPageUtils.getTabContent("Lead Notes");
    const chatterPanel = await (leadNotesTab as LeadNotesTab).getChatterPanel();
    await chatterPanel.clickShareButton();
    await browser.pause(2000);
    await chatterPanel.postComment(generalComment);
  }

  async verifyChatterComment(): Promise<void> {
    const leadNotesTab = await leadPageUtils.getTabContent("Lead Notes");
    const chatterPanel = await (leadNotesTab as LeadNotesTab).getChatterPanel();
    expect(await chatterPanel.latestPostContentEquals(generalComment)).toEqual(
      true
    );
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

  async verifyVisibleInListView(
    listViewTile: string,
    visible: boolean
  ): Promise<void> {
    await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Leads);

    const objectHomeRoot = await utam.load(ObjectHome);
    await objectHomeRoot.selectListViewByTitle(listViewTile);
    await browser.pause(5000);

    // check if current list view has any lead records
    const hasLeads = await objectHomeRoot.containsElement(
      utam.By.css("tbody tr th span a")
    );

    // if no lead records in current list view, and visible is false, pass.
    // otherwise it's a failure
    if (!hasLeads) {
      expect(visible).toBeFalsy();
    }
    // if has lead records, check if can find specific lead by title
    else if (hasLeads) {
      // Added a sorting logic to sort by CreatedDate
      const record = await objectHomeRoot.getRecordLinkByTitle(
        `${this.firstName} ${this.lastName}`
      );
      expect(!!(await record?.isVisible())).toBe(visible);
    }
  }

  async openConvertedAccount(): Promise<void> {
    await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Accounts);
    await openRecordPageById(this.accountId!);

    const recordPageRoot = await utam.load(RecordPage);
    const accountRecordPage = await recordPageRoot.getAccountRecordPage();
    expect(await accountRecordPage.isVisible()).toBeTruthy();
  }

  async verifyChatterOnAccount(): Promise<void> {
    const recordPageRoot = await utam.load(RecordPage);
    const accountRecordPage = await recordPageRoot.getAccountRecordPage();

    const chatterPanel = await accountRecordPage.getChatterPanel();
    const allPosts = await chatterPanel.getPosts();

    // there should be 1 posts, contains convert message
    expect(allPosts.length).toBe(1);

    const containsConvertMessage = await chatterPanel.latestPostHeaderContains(
      "converted a lead to this account."
    );
    expect(containsConvertMessage).toBeTruthy();
  }

  async verifyLeadFieldsAreReadOnly(): Promise<void> {
    const qualityAnalystUAM = new UAM(UserRole.Quality_Analyst);
    qualityAnalystUAM.verifyLeadAccess(Access.Read_Only);
  }

  async verifyQualtricsLead() {
    const baseRecordForm = await leadPageUtils.getRecordForm();
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Assert Status field is New
    const statusPicklist = await commonUtils.getFieldFromRecordLayout(
      recordLayout,
      [1, 2, 2]
    );
    const status = await (
      await statusPicklist.getFormattedText()
    ).getInnerText();

    expect(status).toEqual("New");
  }
}
