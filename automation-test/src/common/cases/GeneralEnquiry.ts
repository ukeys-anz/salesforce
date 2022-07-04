import RecordCreationForm from "pageObjects/recordCreationForm";
import CaseCallsTab from "pageObjects/caseCallsTab";
import CaseNotesTab from "pageObjects/caseNotesTab";
import CaseType from "../../constants/case/caseType";
import { OwnerType } from "../../constants/enums";
import Case from "./Case";
import IChatter from "../../interfaces/IChatter";
import * as commonUtils from "../../utils/commonUtils";
import * as creationFormUtils from "../../utils/creationFormUtils";
import * as casePageUtils from "../../utils/casePageUtils";
import * as faker from "faker";
import { FieldDefinition } from "../../types/field";
import { FieldSectionIndex } from "../../types/layout";
import CaseFields from "../../constants/case/caseFields";
import IAssignNewOwner from "../../interfaces/IAssignNewOwner";

const generalComment = `Automation Test @ ${new Date().toLocaleString()}.`;

export default class GeneralEnquiry
  extends Case
  implements IChatter, IAssignNewOwner
{
  static creationFormFieldIndexMap = new Map<string, number>();

  async create(caseData: any): Promise<void> {
    const recordCreationFormRoot = await utam.load(RecordCreationForm);
    await recordCreationFormRoot.selectCaseRecordType(CaseType.GENERAL_ENQUIRY);
    await browser.pause(2000);

    const fieldsToFill: FieldDefinition[] = [
      {
        label: CaseFields.Account_Name,
        options: {
          lookupText: caseData.accountName
        }
      },
      {
        label: CaseFields.Channel_Received,
        options: {
          picklistDOMIndex: 0,
          picklistOptionIndexRange: [2, 8]
        }
      },
      {
        label: CaseFields.Issue_Type,
        options: {
          picklistDOMIndex: 1,
          picklistOptionIndexRange: [2, 10]
        }
      }
    ];

    GeneralEnquiry.creationFormFieldIndexMap =
      await creationFormUtils.fillInFields(
        this.sobject,
        GeneralEnquiry.creationFormFieldIndexMap,
        fieldsToFill
      );

    // click save button
    await recordCreationFormRoot.saveNew();
    await browser.pause(5000);

    this.caseNumber = await casePageUtils.getCaseNumber();
  }

  async assignNewOwner(
    newOwnerType: OwnerType,
    newOwnerName: string
  ): Promise<void> {
    // Owner field index on layout
    const ownerFieldIndex: FieldSectionIndex = [2, 1, 1];

    await commonUtils.assignNewOwner(
      this.sobject,
      ownerFieldIndex,
      newOwnerType,
      newOwnerName
    );
  }

  async update(): Promise<void> {
    const baseRecordForm = (await casePageUtils.getRecordForm())!;
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Priority
    await commonUtils.selectPicklistOnRecordLayout(
      recordLayout,
      [2, 4, 2],
      [2, 5]
    );
    await commonUtils.clickFormFooterButtonByTitle("Save", baseRecordForm);
  }

  async updateCallDetails(): Promise<void> {
    const callsTab = await casePageUtils.getTabContent("Calls");

    if (callsTab instanceof CaseCallsTab) {
      const randomCallSID = `CA${faker.finance.account(32)}`;
      const randomAuthMethodIndex = faker.datatype.number({ min: 2, max: 4 });

      const caseLogACall = await callsTab.getCaseLogACall();
      await caseLogACall.logACall(randomCallSID, randomAuthMethodIndex);
      await browser.pause(2000);
    }
  }

  async postChatterComment(): Promise<void> {
    const caseNotesTab = await casePageUtils.getTabContent("Case Notes");

    if (caseNotesTab instanceof CaseNotesTab) {
      const chatterPanel = await caseNotesTab.getChatterPanel();
      await chatterPanel.clickShareButton();
      await browser.pause(2000);
      await chatterPanel.postComment(generalComment);
    }
  }

  async verifyChatterComment(): Promise<void> {
    const caseNotesTab = await casePageUtils.getTabContent("Case Notes");

    if (caseNotesTab instanceof CaseNotesTab) {
      const chatterPanel = await caseNotesTab.getChatterPanel();
      expect(
        await chatterPanel.latestPostContentEquals(generalComment)
      ).toEqual(true);
    }
  }

  async close(): Promise<void> {
    // Status
    // select Closed status
    const statusFieldIndex: FieldSectionIndex = [2, 3, 2];
    const closedOptionIndex = 6;
    await casePageUtils.closeCase(statusFieldIndex, closedOptionIndex);
  }
}
