import RecordPage from "pageObjects/recordPage";
import RecordCreationForm from "pageObjects/recordCreationForm";
import BodyTextEditorContainer from "pageObjects/bodyTextEditorContainer";
import ArticleCategoriesEditorModal from "pageObjects/articleCategoriesEditorModal";
import ContentWorkbenchHomePage from "pageObjects/contentWorkbenchHomePage";
import BodyTextEditor from "pageObjects/bodyTextEditor";
import KnowledgeModal from "pageObjects/knowledgeModal";
import * as creationFormUtils from "../utils/creationFormUtils";
import { navigateToAppAndTab } from "../utils/navigationUtils";
import * as faker from "faker";
import { Queue, SObject, SObjectAPIName } from "../constants/enums";
import { App, AppTab } from "../constants/appsDefinition";
import { FieldDefinition } from "../types/field";
import KnowledgeEditAsDraftModal from "pageObjects/knowledgeEditAsDraftModal";

export default class Knowledge {
  static knowledgeCreationFormFieldIndexMap = new Map<string, number>();
  private readonly artitleTitle: string;
  public sobject: SObject;
  public sobjectAPIName: SObjectAPIName;

  constructor() {
    this.sobject = SObject.Knowledge;
    this.sobjectAPIName = SObjectAPIName.Knowledge;

    // date format: yyyy-mm-dd
    const todayDateStr = new Date().toISOString().slice(0, 10);
    const randomIndex = faker.datatype.number({ min: 1, max: 1000 });

    // build a default article title and body content
    this.artitleTitle = `Automation Testing Article ${randomIndex} at ${todayDateStr}`;
  }

  async create(): Promise<void> {
    const recordCreationFormRoot = await utam.load(RecordCreationForm);
    await recordCreationFormRoot.clickNew();
    await browser.pause(2000);

    const fieldsToFill: FieldDefinition[] = [
      {
        label: "Title",
        options: {
          textContent: this.artitleTitle
        }
      }
    ];

    Knowledge.knowledgeCreationFormFieldIndexMap =
      await creationFormUtils.fillInFields(
        this.sobject,
        Knowledge.knowledgeCreationFormFieldIndexMap,
        fieldsToFill
      );

    // URL Name
    // press Tab key to auto populate URL Name
    await browser.keys("Tab");
    await browser.pause(1000);

    const fields = await recordCreationFormRoot.getAllFields();

    if (!fields || fields.length === 0) {
      return;
    }

    const bodyField = await creationFormUtils.getFieldByLabel(fields, "Body");
    await bodyField!.editBody();
    await browser.pause(2000);

    const bodyIframe = await bodyField!.getBodyIframe();
    await browser.pause(2000);

    const creationFormDocument = utam.getCurrentDocument();

    // enter editor container iframe and load its root
    await bodyIframe?.enterBodyTextEditorContainerIframe();
    await browser.pause(2000);

    const bodyTextEditorContainerRoot = await utam.load(
      BodyTextEditorContainer
    );

    const containerDocument = utam.getCurrentDocument();

    // enter editor iframe and load its root
    await bodyTextEditorContainerRoot.enterBodyTextEditorIframe();
    const bodyTextEditorRoot = await utam.load(BodyTextEditor);

    await bodyTextEditorRoot.editBody(this.artitleTitle);

    await containerDocument.exitFrame();
    await creationFormDocument.exitFrame();

    await browser.pause(1000);
    await recordCreationFormRoot.saveNew();
    await browser.pause(5000);
  }

  async submit(): Promise<void> {
    const recordPageRoot = await utam.load(RecordPage);
    const knowledgeRecordPage = await recordPageRoot.getKnowledgeRecordPage();

    // verify Publication Status is Draft
    const status = await knowledgeRecordPage.getFieldOutputText(1, 3, 2);
    expect(status).toEqual("Draft");

    // add a category
    await knowledgeRecordPage.openCategoriesEditor();
    await browser.pause(3000);

    const categoriesEditor = await utam.load(ArticleCategoriesEditorModal);
    await categoriesEditor.selectFirstCategory();
    await browser.pause(3000);

    // click submit for approval button
    await knowledgeRecordPage.clickHeaderButtonByTitle("Submit for Approval");
    await browser.pause(1000);

    // click submit button on modal
    const knowledgeModalRoot = await utam.load(KnowledgeModal);
    await knowledgeModalRoot.submit();
    await browser.pause(3000);
  }

  async verifyApprovalHistory(): Promise<void> {
    const recordPageRoot = await utam.load(RecordPage);
    const knowledgeRecordPage = await recordPageRoot.getKnowledgeRecordPage();

    // verify Approval History
    await knowledgeRecordPage.openApprovalHistoryTab();
    await browser.pause(2000);

    const approvalHistories = await knowledgeRecordPage.getHistories();
    // there should have 2 records
    expect(approvalHistories.length).toEqual(2);

    // first record is Peer Review
    const peerReview = approvalHistories[0];
    expect(await peerReview.getStepName()).toEqual("Peer Review");

    // first record Assigned to Content Writers Queue
    expect(await peerReview.getAssignedTo()).toEqual(
      Queue.Content_Writers_Queue
    );

    // second record is Approval Request Submitted
    const requestSubmitted = approvalHistories[1];
    expect(await requestSubmitted.getStepName()).toEqual(
      "Approval Request Submitted"
    );
  }

  async approve(): Promise<void> {
    await navigateToAppAndTab(App.Content_Workbench, AppTab.Home);

    const contentWorkbenchHomePageRoot = await utam.load(
      ContentWorkbenchHomePage
    );
    const listView = await contentWorkbenchHomePageRoot.getListViewByTitle(
      "Articles Submitted for Approval"
    );

    // make list view sorted by Modified Date, descending
    const modifiedDate = await listView!.getListViewHeaderByTitle(
      "Modified Date"
    );
    await modifiedDate.sort();
    await browser.pause(2000);

    const sortingDirection = await modifiedDate.getSortingDirection();

    // if ascending, click again to force to descending
    if (sortingDirection === "Sorted Ascending") {
      await modifiedDate.sort();
      await browser.pause(2000);
    }

    const firstRecord = await listView!.getListViewRowByIndex(1);

    // Article Title is the th element in Articles Submitted for Approval list view
    const articleTitle = await firstRecord.getRowHeaderContent();
    expect(articleTitle).toEqual(this.artitleTitle);

    // open and redirect to this article
    await firstRecord.clickRowHeader();
    await browser.pause(2000);

    const domDocument = utam.getCurrentDocument();
    await domDocument.waitFor(async () =>
      (await domDocument.getUrl()).includes(SObjectAPIName.Knowledge)
    );

    const recordPageRoot = await utam.load(RecordPage);
    const knowledgeRecordPage = await recordPageRoot.getKnowledgeRecordPage();

    // click approval
    await knowledgeRecordPage.openApprovalHistoryTab();
    await browser.pause(2000);
    await knowledgeRecordPage.clickApproveButton();
    await browser.pause(1000);

    const knowledgeModalRoot = await utam.load(KnowledgeModal);
    await knowledgeModalRoot.approve();
    await browser.pause(2000);
  }

  async publish(): Promise<void> {
    const recordPageRoot = await utam.load(RecordPage);
    const knowledgeRecordPage = await recordPageRoot.getKnowledgeRecordPage();
    await knowledgeRecordPage.openDetailTab();

    // click publish article button to open Publish Article lwc modal
    await knowledgeRecordPage.clickHeaderButtonByTitle("Publish Article");
    await browser.pause(2000);

    // click publish button in Publish Article lwc modal
    const knowledgeModalRoot = await utam.load(KnowledgeModal);
    await knowledgeModalRoot.publish();
    await browser.pause(2000);

    // verify Publication Status is Published
    const status = await knowledgeRecordPage.getFieldOutputText(1, 3, 2);
    expect(status).toEqual("Published");
  }

  async editDraft(): Promise<void> {
    // refresh page to get updated status
    await browser.refresh();
    await browser.pause(5000);

    const recordPageRoot = await utam.load(RecordPage);
    const knowledgeRecordPage = await recordPageRoot.getKnowledgeRecordPage();

    // click Edit as Draft button on header
    await knowledgeRecordPage.clickHeaderButtonByTitle("Edit as Draft");
    await browser.pause(2000);

    // click Edit as Draft button in modal
    const knowledgeModalRoot = await utam.load(KnowledgeModal);
    await knowledgeModalRoot.editAsDraft();
    await browser.pause(2000);

    // page refreshed? and a new modal
    const editAsDraftModalRoot = await utam.load(KnowledgeEditAsDraftModal);
    await editAsDraftModalRoot.editReasonForChangeEdit("New Edit");
    await editAsDraftModalRoot.saveDraft();
    await browser.pause(2000);
  }
}
