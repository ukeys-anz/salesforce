"use strict";

var core = require("@utam/core");
var _ArticleCategoriesEditorModal = require("./../pageObjects/articleCategoriesEditorModal");
var _KnowledgeApprovalHistory = require("./../pageObjects/knowledgeApprovalHistory");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _ArticleCategoriesEditorModal__default =
  /*#__PURE__*/ _interopDefaultLegacy(_ArticleCategoriesEditorModal);
var _KnowledgeApprovalHistory__default = /*#__PURE__*/ _interopDefaultLegacy(
  _KnowledgeApprovalHistory
);

async function _utam_filter_actionByTitle(element, title) {
  const result = await element.getTitle();
  return result.includes(title);
}

async function _utam_get_header(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.region-header`);
  return _element.findElement(_locator);
}

async function _utam_get_actionBar(driver, root) {
  let _element = await _utam_get_header(driver, root);
  const _locator = core.By.css(`.actionsContainer`);
  return _element.findElement(_locator);
}

async function _utam_get_actionRibbon(driver, root) {
  let _element = await _utam_get_actionBar(driver, root);
  const _locator = core.By.css(`.oneActionsRibbon`);
  return _element.findElement(_locator);
}

async function _utam_get_actionByTitles(driver, root) {
  let _element = await _utam_get_actionRibbon(driver, root);
  const _locator = core.By.css(`li a`);
  return _element.findElements(_locator);
}

async function _utam_get_main(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.row-main`);
  return _element.findElement(_locator);
}

async function _utam_get_formSection(driver, root, sectionIndex) {
  let _element = await _utam_get_main(driver, root);
  const _locator = core.By.css(
    `.forcePageBlockSection:nth-of-type(${sectionIndex})`
  );
  return _element.findElement(_locator);
}

async function _utam_get_formSectionRow(
  driver,
  root,
  sectionIndex,
  sectionRowIndex
) {
  let _element = await _utam_get_formSection(driver, root, sectionIndex);
  const _locator = core.By.css(
    `.forcePageBlockSectionRow:nth-of-type(${sectionRowIndex})`
  );
  return _element.findElement(_locator);
}

async function _utam_get_formSectionRowItem(
  driver,
  root,
  sectionIndex,
  sectionRowIndex,
  sectionRowItemIndex
) {
  let _element = await _utam_get_formSectionRow(
    driver,
    root,
    sectionIndex,
    sectionRowIndex
  );
  const _locator = core.By.css(
    `.forcePageBlockItem:nth-of-type(${sectionRowItemIndex})`
  );
  return _element.findElement(_locator);
}

async function _utam_get_displayText(
  driver,
  root,
  sectionIndex,
  sectionRowIndex,
  sectionRowItemIndex
) {
  let _element = await _utam_get_formSectionRowItem(
    driver,
    root,
    sectionIndex,
    sectionRowIndex,
    sectionRowItemIndex
  );
  const _locator = core.By.css(`.is-read-only span`);
  return _element.findElement(_locator);
}

async function _utam_get_rightSidebar(driver, root) {
  let _element = await _utam_get_main(driver, root);
  const _locator = core.By.css(`.region-sidebar-right`);
  return _element.findElement(_locator);
}

async function _utam_get_categoryViewer(driver, root) {
  let _element = await _utam_get_rightSidebar(driver, root);
  const _locator = core.By.css(`.flexipageComponent:nth-of-type(1)`);
  return _element.findElement(_locator);
}

async function _utam_get_categoryMenuButton(driver, root) {
  let _element = await _utam_get_categoryViewer(driver, root);
  const _locator = core.By.css(`a[role='button']`);
  return _element.findElement(_locator);
}

async function _utam_get_categoryEditButton(driver, root) {
  let _element = await _utam_get_categoryViewer(driver, root);
  const _locator = core.By.css(`a[title='Edit']`);
  return _element.findElement(_locator);
}

async function _utam_get_approvalHistory(driver, root) {
  let _element = await _utam_get_rightSidebar(driver, root);
  const _locator = core.By.css(`.flexipageComponent:nth-of-type(2)`);
  return _element.findElement(_locator);
}

async function _utam_get_approvalHistoryDropDown(driver, root) {
  let _element = await _utam_get_approvalHistory(driver, root);
  const _locator = core.By.css(`.forceDeferredDropDownAction`);
  return _element.findElement(_locator);
}

async function _utam_get_hisotryList(driver, root) {
  let _element = await _utam_get_approvalHistory(driver, root);
  const _locator = core.By.css(`.uiAbstractList`);
  return _element.findElement(_locator);
}

async function _utam_get_historiess(driver, root) {
  let _element = await _utam_get_hisotryList(driver, root);
  const _locator = core.By.css(`li.forceRecordLayout`);
  return _element.findElements(_locator);
}

async function _utam_get_articleCategoriesEditorModal(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.forceKnowledgeArticleDataCategoryChooser`);
  return _element.findElement(_locator);
}

class KnowledgeRecordPage extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getHeader() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_header(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getActionBar() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_actionBar(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getActionRibbon() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_actionRibbon(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getActionByTitle(title) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let elements = await _utam_get_actionByTitles(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ClickableUtamElement(driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_actionByTitle(el, title))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    return elements;
  }

  async __getMain() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_main(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getFormSection(sectionIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_formSection(driver, root, sectionIndex);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getFormSectionRow(sectionIndex, sectionRowIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_formSectionRow(
      driver,
      root,
      sectionIndex,
      sectionRowIndex
    );
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getFormSectionRowItem(
    sectionIndex,
    sectionRowIndex,
    sectionRowItemIndex
  ) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_formSectionRowItem(
      driver,
      root,
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getDisplayText(sectionIndex, sectionRowIndex, sectionRowItemIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_displayText(
      driver,
      root,
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getRightSidebar() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_rightSidebar(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getCategoryViewer() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_categoryViewer(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getCategoryMenuButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_categoryMenuButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getCategoryEditButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_categoryEditButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getApprovalHistory() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_approvalHistory(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getApprovalHistoryDropDown() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_approvalHistoryDropDown(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getHisotryList() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_hisotryList(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getHistories() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_historiess(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _KnowledgeApprovalHistory__default["default"](driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async __getArticleCategoriesEditorModal() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_articleCategoriesEditorModal(driver, root);
    element = new _ArticleCategoriesEditorModal__default["default"](
      driver,
      element
    );
    await element.__beforeLoad__();
    return element;
  }

  async clickHeaderButtonByTitle(title) {
    const _statement0 = await this.__getActionByTitle(title);
    await _statement0.click();
  }

  async getFieldOutputText(sectionIndex, sectionRowIndex, sectionRowItemIndex) {
    const _statement0 = await this.__getDisplayText(
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async openCategoriesEditor() {
    const _statement0 = await this.__getCategoryMenuButton();
    await _statement0.click();
    const _statement1 = await this.__getCategoryEditButton();
    await _statement1.waitForVisible();
    await _statement1.click();
  }

  async expandApprovalHistoryDropDown() {
    const _statement0 = await this.__getApprovalHistoryDropDown();
    await _statement0.click();
  }
}

module.exports = KnowledgeRecordPage;
