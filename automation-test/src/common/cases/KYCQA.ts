import CaseCreationForm from "pageObjects/coachesWorkbenchCaseCreationForm";
import CaseRecordHomeFlexipage from "pageObjects/coachesWorkbenchCaseRecordHomeFlexipage";
import { CaseType } from "constants/enums";
import Case from "./Case";
import caseData from "data/caseData";
import * as CommonUtils from "utils/commonUtils";
import * as faker from "faker";

export default class KYCQA extends Case {
  async createRecord(): Promise<void> {
    const caseCreationFormRoot = await utam.load(CaseCreationForm);
    await caseCreationFormRoot.selectCaseRecordType(CaseType.KYC_QA);

    // search and select first account
    await caseCreationFormRoot.searchAndSelectLookup(
      1,
      4,
      1,
      caseData.accountName,
      1
    );

    // click save button
    await caseCreationFormRoot.saveNew();

    await browser.pause(5000);
  }

  async assignNewOwner(): Promise<void> {
    const consoleRecordFlexipageRoot = await utam.load(CaseRecordHomeFlexipage);
  }

  async updateRecord(): Promise<void> {
    // Coaches Workbench Case Record Page
    const CaseRecordHomeFlexipageRoot = await utam.load(
      CaseRecordHomeFlexipage
    );

    // get record layout
    const detailPanel = await CaseRecordHomeFlexipageRoot.getMainRegionActiveTabDetailPanel();
    const baseRecordForm = await detailPanel.getBaseRecordForm();
    const recordLayout = await baseRecordForm.getRecordLayout();

    // Chat Topic ID
    const chatTopicField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      1,
      3,
      2
    );

    const chatTopicId = `CH${faker.datatype.string(32)}`;
    await CommonUtils.inputText(chatTopicField, chatTopicId);

    // click save button
    await baseRecordForm.clickFooterButton("Save");
  }

  async closeRecord(): Promise<void> {
    // Coaches Workbench Case Record Page
    const CaseRecordHomeFlexipageRoot = await utam.load(
      CaseRecordHomeFlexipage
    );

    // get record layout
    const detailPanel = await CaseRecordHomeFlexipageRoot.getMainRegionActiveTabDetailPanel();
    const baseRecordForm = await detailPanel.getBaseRecordForm();
    const recordLayout = await baseRecordForm.getRecordLayout();

    // select Yes for all below fields to close KYC QA Case
    // KYC Information is a Match & Complete
    const kycInfoField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      2,
      1,
      1
    );
    await CommonUtils.selectPicklist(kycInfoField, 2);
    await baseRecordForm.clickFooterButton("Save");

    // Identity Document is Legible
    const identifyField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      2,
      1,
      2
    );
    await CommonUtils.selectPicklist(identifyField, 2);
    await baseRecordForm.clickFooterButton("Save");

    // Middle Name Missing
    const mNameMissField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      2,
      2,
      1
    );
    await CommonUtils.selectPicklist(mNameMissField, 2);
    await baseRecordForm.clickFooterButton("Save");

    // Image is not a Picture of ID Document
    const imageField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      2,
      2,
      2
    );
    await CommonUtils.selectPicklist(imageField, 2);
    await baseRecordForm.clickFooterButton("Save");

    // Middle Name Initial
    const mNameInitField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      2,
      3,
      1
    );
    await CommonUtils.selectPicklist(mNameInitField, 2);
    await baseRecordForm.clickFooterButton("Save");

    // Customer's Photo is Not Modified
    const photoField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      2,
      3,
      2
    );
    await CommonUtils.selectPicklist(photoField, 2);
    await baseRecordForm.clickFooterButton("Save");

    // Selfie Comparison Match
    const selfieField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      2,
      4,
      1
    );
    await CommonUtils.selectPicklist(selfieField, 2);
    await baseRecordForm.clickFooterButton("Save");

    // Security Features Visible
    const securityField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      2,
      4,
      2
    );
    await CommonUtils.selectPicklist(securityField, 2);
    await baseRecordForm.clickFooterButton("Save");

    // Residential Address is Not a PO Box
    const addNotPOField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      2,
      5,
      1
    );
    await CommonUtils.selectPicklist(addNotPOField, 2);
    await baseRecordForm.clickFooterButton("Save");

    // Residential address is valid
    const addValidField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      2,
      6,
      1
    );
    await CommonUtils.selectPicklist(addValidField, 2);
    await baseRecordForm.clickFooterButton("Save");

    // Restraint Status
    // select N/A
    const restraintField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      2,
      7,
      1
    );
    await CommonUtils.selectPicklist(restraintField, 2);
    await baseRecordForm.clickFooterButton("Save");

    // Have All Defects Been Rectified
    // select Not Applicab;e
    const defectsField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      3,
      1,
      1
    );
    await CommonUtils.selectPicklist(defectsField, 3);
    await baseRecordForm.clickFooterButton("Save");

    // Status
    // select Closed status
    const statusField = await CommonUtils.getFieldFromLayout(
      recordLayout,
      1,
      4,
      2
    );
    await CommonUtils.selectPicklist(statusField, 3);
    await baseRecordForm.clickFooterButton("Save");

    await browser.pause(3000);
  }
}
