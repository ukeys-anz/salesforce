import RecordCreationForm from "pageObjects/recordCreationForm";
import CaseType from "../../constants/case/caseType";
import { OwnerType } from "../../constants/enums";
import Case from "./Case";
import * as commonUtils from "../../utils/commonUtils";
import * as creationFormUtils from "../../utils/creationFormUtils";
import * as casePageUtils from "../../utils/casePageUtils";
import { FieldDefinition } from "../../types/field";
import { FieldSectionIndex } from "../../types/layout";
import CaseFields from "../../constants/case/caseFields";
import IAssignNewOwner from "../../interfaces/IAssignNewOwner";

export default class KYCQA extends Case implements IAssignNewOwner {
  static creationFormFieldIndexMap = new Map<string, number>();

  async create(caseData: any): Promise<void> {
    const recordCreationFormRoot = await utam.load(RecordCreationForm);
    await recordCreationFormRoot.selectCaseRecordType(CaseType.KYC_QA);
    await browser.pause(2000);

    const fieldsToFill: FieldDefinition[] = [
      {
        label: CaseFields.Account_Name,
        options: {
          firstFieldIndex: 6,
          lookupText: caseData.accountName
        }
      }
    ];

    KYCQA.creationFormFieldIndexMap = await creationFormUtils.fillInFields(
      this.sobject,
      KYCQA.creationFormFieldIndexMap,
      fieldsToFill
    );

    // click save button
    await recordCreationFormRoot.saveNew();
    await browser.pause(5000);
  }

  async assignNewOwner(
    newOwnerType: OwnerType,
    newOwnerName: string
  ): Promise<void> {
    // Owner field index on layout
    const ownerFieldIndex: FieldSectionIndex = [1, 3, 1];

    await commonUtils.assignNewOwner(
      this.sobject,
      ownerFieldIndex,
      newOwnerType,
      newOwnerName
    );
  }

  async update(): Promise<void> {
    const baseRecordForm = await casePageUtils.getRecordForm();
    const recordLayout = await baseRecordForm.getRecordLayout();

    // select Yes for all below fields to close KYC QA Case
    // KYC Information is a Match & Complete
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [2, 1, 1], 2);

    // Identity Document is Legible
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [2, 1, 2], 2);

    // Middle Name Missing
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [2, 2, 1], 2);

    // Image is not a Picture of ID Document
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [2, 2, 2], 2);

    // Middle Name Initial
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [2, 3, 1], 2);

    // Customer's Photo is Not Modified
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [2, 3, 2], 2);

    // Selfie Comparison Match
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [2, 4, 1], 2);

    // Security Features Visible
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [2, 4, 2], 2);

    // Residential Address is Not a PO Box
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [2, 5, 1], 2);

    // Residential address is valid
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [2, 6, 1], 2);

    // Restraint Status
    // select N/A
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [2, 7, 1], 2);

    // Have All Defects Been Rectified
    // select Not Applicable
    await commonUtils.selectPicklistOnRecordLayout(recordLayout, [3, 1, 1], 3);

    // click save button
    await commonUtils.clickFormFooterButtonByTitle("Save", baseRecordForm);
  }

  async close(): Promise<void> {
    // Status
    // select Closed status
    const statusFieldIndex: FieldSectionIndex = [1, 4, 2];
    const closedOptionIndex = 3;
    await casePageUtils.closeCase(statusFieldIndex, closedOptionIndex);
  }
}
