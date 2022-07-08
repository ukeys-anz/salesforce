import { App, AppTab } from "src/constants/appsDefinition";
import { UserRole } from "../constants/enums";
import AppLauncher from "pageObjects/appLauncher";
import { searchRecordInGlobalSearchAndRedirect } from "../utils/commonUtils";
import RecordPage from "pageObjects/recordPage";
import {
  navigateToAppAndTab,
  openTabHomeInCurrentApp
} from "../utils/navigationUtils";
import ObjectHome from "pageObjects/objectHome";
import ReportObjectHome from "pageObjects/reportHomePage";
import { TransactionType, Access } from "../constants/enums";
import * as commonUtils from "../utils/commonUtils";
import * as casePageUtils from "../utils/casePageUtils";
import CoachesWorkbenchHomePage from "pageObjects/coachesWorkbenchHomePage";
import { searchInAppLauncher } from "../utils/navigationUtils";
import MenuItem from "@salesforce-pageobjects/lightning/pageObjects/menuItem";
import AnalyticsContainer from "pageObjects/analyticsContainer";
import Dispute from "../common/Dispute";

type AccessLevel = Access.Read_Only | Access.Edit;
export type ReportAction = "Run" | "Edit" | "Export" | "Delete";
export type HasReportActionAccess = boolean;

export default class UAM {
  public readonly userRole: UserRole;

  constructor(userRole: UserRole) {
    this.userRole = userRole;
  }

  async verifyAppAccess(hasAccess: boolean, appName: App): Promise<void> {
    const appLauncherRoot = await utam.load(AppLauncher);
    await searchInAppLauncher(appName);

    if (hasAccess) {
      // verify user get one search result to verify has access
      const appResult = await appLauncherRoot.getAppResult();
      expect(await appResult!.isVisible()).toBeTruthy();
    } else {
      // verify user get No results as search message to verify has no access
      const noAppResultsMessage =
        await appLauncherRoot.getNoAppResultsMessage();
      expect(noAppResultsMessage).toEqual("No results");
    }

    // refresh page to close app launcher
    await browser.refresh();
    await browser.pause(4000);
  }

  async verifyItemAccess(hasAccess: boolean, itemName: string): Promise<void> {
    const appLauncherRoot = await utam.load(AppLauncher);
    await searchInAppLauncher(itemName);

    if (hasAccess) {
      // verify user get one search result to verify has access
      const itemResult = await appLauncherRoot.getItemResult();
      expect(await itemResult!.isVisible()).toBeTruthy();
    } else {
      // verify user get No results as search message to verify has no access
      const noItemResultsMessage =
        await appLauncherRoot.getNoItemResultsMessage();
      expect(noItemResultsMessage).toEqual("No results");
    }

    // refresh page to close app launcher
    await browser.refresh();
    await browser.pause(4000);
  }

  /**
   * @description check if user has record access by checking if the Edit button present
   * @param accountOcvId
   * @param accessLevel
   */
  async verifyAccountAccess(
    accessLevel: AccessLevel,
    accountOcvId: string
  ): Promise<void> {
    await searchRecordInGlobalSearchAndRedirect(accountOcvId);

    // load Account flexi page
    const recordPageRoot = await utam.load(RecordPage);
    const accountRecordPage = await recordPageRoot.getAccountRecordPage();

    const highlightsPanel = await accountRecordPage.getHighlightsPanel();
    const actionsRibbon = await highlightsPanel.getActions();

    // verify there's no Edit button on Highlights Panel
    const hasEditButton = await actionsRibbon.containsElement(
      utam.By.css("runtime_platform_actions-action-renderer[title='Edit']")
    );

    if (accessLevel === Access.Read_Only) {
      expect(hasEditButton).toBeFalsy();
    } else if (accessLevel === Access.Edit) {
      expect(hasEditButton).toBeTruthy();
    }
  }

  /**
   * @description check if user has record access by checking if the Edit button present
   * @param financialAccountNumber
   * @param accessLevel
   */
  async verifyFinancialAccountAccess(
    accessLevel: AccessLevel,
    financialAccountNumber: string
  ): Promise<void> {
    await searchRecordInGlobalSearchAndRedirect(financialAccountNumber);

    // load Financial Account flexi page
    const recordPageRoot = await utam.load(RecordPage);
    const financialAccountRecordPage =
      await recordPageRoot.getFinancialAccountRecordPage();
    const highlightsPanel =
      await financialAccountRecordPage.getHighlightsPanel();
    const actionsRibbon = await highlightsPanel.getActions();

    // verify there's no action button (Edit / Delete / Clone etc) on Highlights Panel
    const hasEditButton = await actionsRibbon.containsElement(
      utam.By.css("runtime_platform_actions-action-renderer[title='Edit']")
    );

    if (accessLevel === Access.Read_Only) {
      expect(hasEditButton).toBeFalsy();
    } else if (accessLevel === Access.Edit) {
      expect(hasEditButton).toBeTruthy();
    }
  }

  /**
   * @description check if user has record access by checking if the New button present in object home page
   * @param canCreate
   */
  async verifyKnowledgeCreateAccess(canCreate: boolean): Promise<void> {
    await openTabHomeInCurrentApp(AppTab.Knowledge);

    const objectHomeRoot = await utam.load(ObjectHome);
    const headerActionBar = await objectHomeRoot.getHeaderActionBar();

    // if has New button on header action bar, then user can create Knowledge
    const hasNewButton = await headerActionBar.containsElement(
      utam.By.css("a[title='New']")
    );
    expect(hasNewButton).toEqual(canCreate);
  }

  /**
   * @description check if user has record access by checking if the Edit and Edit as Draft button present in record page
   * @param accessLevel
   */
  async verifyKnowledgeAccess(accessLevel: AccessLevel): Promise<void> {
    await openTabHomeInCurrentApp(AppTab.Knowledge);

    const objectHomeRoot = await utam.load(ObjectHome);
    const firstRecord = await objectHomeRoot.getFirstRow();
    await firstRecord!.click();
    await browser.pause(3000);

    const recordPageRoot = await utam.load(RecordPage);
    const knowledgeRecordPage = await recordPageRoot.getKnowledgeRecordPage();

    const editButton = await knowledgeRecordPage.getActionByTitle(Access.Edit);
    const editDraftButton = await knowledgeRecordPage.getActionByTitle(
      "Edit as Draft"
    );

    if (accessLevel === Access.Read_Only) {
      expect(editButton).toBeNull();
      expect(editDraftButton).toBeNull();
    } else if (accessLevel === Access.Edit) {
      expect(await editButton!.isVisible()).toBeTruthy();
      expect(await editDraftButton!.isVisible()).toBeTruthy();
    }
  }

  async verifyReportAccess(accessLevel: AccessLevel): Promise<void> {
    const [, itemResult] = await searchInAppLauncher(AppTab.Reports);

    if (itemResult !== "No results") {
      await itemResult.click();
      await browser.pause(4000);
    }

    const reportObjectHomeRoot = await utam.load(ReportObjectHome);
    const platformActions = await reportObjectHomeRoot.getPlatformActions();
    const hasNewReportButton = await platformActions.containsElement(
      utam.By.css("a[title='New Report']")
    );

    if (accessLevel === Access.Read_Only) {
      expect(hasNewReportButton).toBeFalsy();
    } else if (accessLevel === Access.Edit) {
      expect(hasNewReportButton).toBeTruthy();
    }
  }

  async verifyReportActionsAccess(
    actionsToCheck: Map<ReportAction, HasReportActionAccess>
  ): Promise<void> {
    // if no action to check
    if (!actionsToCheck || actionsToCheck.size == 0) {
      return;
    }

    const [, itemResult] = await searchInAppLauncher(AppTab.Reports);

    if (itemResult !== "No results") {
      await itemResult.click();
      await browser.pause(4000);
    }

    let reportObjectHomeRoot: ReportObjectHome;

    reportObjectHomeRoot = await utam.load(ReportObjectHome);
    await reportObjectHomeRoot.openAllReports();
    await browser.pause(4000);

    reportObjectHomeRoot = await utam.load(ReportObjectHome);
    const reportList = await reportObjectHomeRoot.getReportsList();
    const rowActions = await reportList.getRowAction(1);
    await rowActions.clickButton();
    await browser.pause(4000);

    const allMenuItems = await rowActions.getAllMenuItems();

    const allAvailableActions = await Promise.all(
      allMenuItems.map(async (item: MenuItem) => await item.getItemText())
    );

    for (const [action, hasAccess] of actionsToCheck) {
      if (hasAccess) {
        expect(allAvailableActions.includes(action)).toBeTruthy();
      } else {
        expect(allAvailableActions.includes(action)).toBeFalsy();
      }
    }
  }

  async verifyRaiseDispute(
    canRaise: boolean,
    financialAccountNumber: string,
    transactionType: TransactionType
  ): Promise<void> {
    await openTabHomeInCurrentApp(AppTab.Home);

    // search financial account in global search and redirect
    await searchRecordInGlobalSearchAndRedirect(financialAccountNumber);

    const dispute = new Dispute(this.userRole, transactionType);
    const transactionHistoryRecord =
      await dispute.getTransactionHistoryRecordByType(transactionType);

    const recordRoot = await transactionHistoryRecord!.getRoot();
    await recordRoot.scrollToCenter();
    await transactionHistoryRecord!.clickDropdown();

    // get Raise Dispute button and verify enabled for clicking
    const raiseDisputeButton =
      await transactionHistoryRecord!.getRaiseDisputeButton();

    const validRaiseButton = await raiseDisputeButton.containsElement(
      utam.By.css(`a[aria-disabled=${!canRaise}]`),
      true
    );

    expect(validRaiseButton).toBeTruthy();
  }

  /**
   * @description check if user's access level of a case by searching and open existing case from a list view
   * @param listViewName
   * @param accessLevel
   */
  async verifyCaseAccess(
    accessLevel: AccessLevel,
    listViewName: string
  ): Promise<void> {
    await openTabHomeInCurrentApp(AppTab.Cases);

    // Go to list view
    await commonUtils.searchAndOpenListViewByName(listViewName);

    // Open first case and click to open it
    await commonUtils.openFirstRecordInListView();

    const highlightsPanel = await casePageUtils.getHighlightsPanel();
    const actionsRibbon = await highlightsPanel.getActions();

    // if access level is edit, verify Edit button is visible on record highlight panel
    const hasEditButton = await actionsRibbon.containsElement(
      utam.By.css("runtime_platform_actions-action-renderer[title='Edit']"),
      true
    );

    if (accessLevel === Access.Read_Only) {
      expect(hasEditButton).toBeFalsy();
    } else if (accessLevel === Access.Edit) {
      expect(hasEditButton).toBeTruthy();
    }
  }

  async verifyCanOpenReleaseNotes(): Promise<void> {
    await navigateToAppAndTab(App.Coaches_Workbench, AppTab.Home);

    const coachesWorkbenchHomePageRoot = await utam.load(
      CoachesWorkbenchHomePage
    );

    const releaseNoteLink =
      await coachesWorkbenchHomePageRoot.getReleaseLogLink();
    await releaseNoteLink.open();
    await browser.pause(1000);

    // wait for page fully loaded
    const domDocument = utam.getCurrentDocument();

    await domDocument.waitFor(async () =>
      (await domDocument.getUrl()).includes("Release_Notes")
    );

    expect((await domDocument.getUrl()).includes("Release_Notes")).toBeTruthy();
  }

  async verifyAnalyticsAppsAndReportsAccess(
    appsToCheck: string[],
    reportsToCheck: string[]
  ): Promise<void> {
    const [, itemResult] = await searchInAppLauncher(AppTab.Analytics);

    if (itemResult !== "No results") {
      await itemResult.click();
      await browser.pause(4000);
    }

    const RecordPageRoot = await utam.load(RecordPage);
    const recordPageDocument = utam.getCurrentDocument();

    await RecordPageRoot.enterAnalyticsIframe();
    await browser.pause(3000);

    let AnalyticsContainerRoot: AnalyticsContainer;

    AnalyticsContainerRoot = await utam.load(AnalyticsContainer);
    await AnalyticsContainerRoot.clickMenuItemByTitle("All Items");
    await browser.pause(3000);

    if (appsToCheck && appsToCheck.length > 0) {
      await AnalyticsContainerRoot.clickNavItemByTitle("APPS");
      await browser.pause(3000);

      AnalyticsContainerRoot = await utam.load(AnalyticsContainer);

      for (let i = 0; i < appsToCheck.length; i++) {
        const row = await AnalyticsContainerRoot.getRowByTitle(appsToCheck[i]);
        expect(await row?.isVisible()).toBeTruthy();
      }
    }

    if (reportsToCheck && reportsToCheck.length > 0) {
      await AnalyticsContainerRoot.clickNavItemByTitle("DASHBOARDS");
      await browser.pause(3000);

      AnalyticsContainerRoot = await utam.load(AnalyticsContainer);

      for (let i = 0; i < reportsToCheck.length; i++) {
        const row = await AnalyticsContainerRoot.getRowByTitle(
          reportsToCheck[i]
        );
        expect(await row?.isVisible()).toBeTruthy();
      }
    }

    await recordPageDocument.exitFrame();
  }

  /**
   * @description check if user has record access by checking if the Edit button present
   * @param accessLevel
   */
  async verifyLeadAccess(accessLevel: AccessLevel): Promise<void> {
    // load Lead flexi page
    const recordPageRoot = await utam.load(RecordPage);
    const leadRecordPage = await recordPageRoot.getLeadRecordPage();

    const highlightsPanel = await leadRecordPage.getHighlightsPanel();
    const actionsRibbon = await highlightsPanel.getActions();

    // verify there's no Edit button on Highlights Panel
    const hasEditButton = await actionsRibbon.containsElement(
      utam.By.css("runtime_platform_actions-action-renderer[title='Edit']")
    );

    if (accessLevel === Access.Read_Only) {
      expect(hasEditButton).toBeFalsy();
    } else if (accessLevel === Access.Edit) {
      expect(hasEditButton).toBeTruthy();
    }
  }
}
