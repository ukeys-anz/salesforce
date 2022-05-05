import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ActionsRibbon from "./../pageObjects/actionsRibbon";
import _ListViewRow from "./../pageObjects/listViewRow";
import _LstTemplateListItemFactory from "./../pageObjects/lstTemplateListItemFactory";

async function _utam_get_lafProgressiveContainer(driver, root) {
  let _element = root;
  const _locator = _By.css(`laf-progressive-container`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lstRelatedListSingleAppBuilderMapper(driver, root) {
  let _element = await _utam_get_lafProgressiveContainer(driver, root);
  const _locator = _By.css(`lst-related-list-single-app-builder-mapper`);
  return _element.findElement(_locator);
}

async function _utam_get_lstRelatedListViewManager(driver, root) {
  let _element = await _utam_get_lstRelatedListSingleAppBuilderMapper(
    driver,
    root
  );
  const _locator = _By.css(`lst-related-list-view-manager`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lstCommonListInternal(driver, root) {
  let _element = await _utam_get_lstRelatedListViewManager(driver, root);
  const _locator = _By.css(`lst-common-list-internal`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lstListViewManagerHeader(driver, root) {
  let _element = await _utam_get_lstCommonListInternal(driver, root);
  const _locator = _By.css(`lst-list-view-manager-header`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_actionsRibbon(driver, root) {
  let _element = await _utam_get_lstListViewManagerHeader(driver, root);
  const _locator = _By.css(`runtime_platform_actions-actions-ribbon`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lstPrimaryDisplayManager(driver, root) {
  let _element = await _utam_get_lstCommonListInternal(driver, root);
  const _locator = _By.css(`lst-primary-display-manager`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lstPrimaryDisplay(driver, root) {
  let _element = await _utam_get_lstPrimaryDisplayManager(driver, root);
  const _locator = _By.css(`lst-primary-display`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lstPrimaryDisplayGrid(driver, root) {
  let _element = await _utam_get_lstPrimaryDisplay(driver, root);
  const _locator = _By.css(`lst-primary-display-grid`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lstCustomizedDatatable(driver, root) {
  let _element = await _utam_get_lstPrimaryDisplayGrid(driver, root);
  const _locator = _By.css(`lst-customized-datatable`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_listViewTableBody(driver, root) {
  let _element = await _utam_get_lstCustomizedDatatable(driver, root);
  const _locator = _By.css(`tbody`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_listViewRowByIndex(driver, root, rowIndex) {
  let _element = await _utam_get_listViewTableBody(driver, root);
  const _locator = _By.css(`tr:nth-of-type(${rowIndex})`);
  return _element.findElement(_locator);
}

async function _utam_get_lstPrimaryDisplayCard(driver, root) {
  let _element = await _utam_get_lstPrimaryDisplay(driver, root);
  const _locator = _By.css(`lst-primary-display-card`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lstCustomizedTemplateList(driver, root) {
  let _element = await _utam_get_lstPrimaryDisplayCard(driver, root);
  const _locator = _By.css(`lst-customized-template-list`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_itemByIndex(driver, root, itemInde) {
  let _element = await _utam_get_lstCustomizedTemplateList(driver, root);
  const _locator = _By.css(
    `lst-template-list-item-factory:nth-of-type(${itemInde})`
  );
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class LstRelatedListSingleContainer extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getLafProgressiveContainer() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lafProgressiveContainer(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getLstRelatedListSingleAppBuilderMapper() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lstRelatedListSingleAppBuilderMapper(
      driver,
      root
    );
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getLstRelatedListViewManager() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lstRelatedListViewManager(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getLstCommonListInternal() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lstCommonListInternal(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getLstListViewManagerHeader() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lstListViewManagerHeader(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getActionsRibbon() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_actionsRibbon(driver, root);
    element = new _ActionsRibbon(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getLstPrimaryDisplayManager() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lstPrimaryDisplayManager(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getLstPrimaryDisplay() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lstPrimaryDisplay(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getLstPrimaryDisplayGrid() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lstPrimaryDisplayGrid(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getLstCustomizedDatatable() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lstCustomizedDatatable(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getListViewTableBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_listViewTableBody(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getListViewRowByIndex(rowIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_listViewRowByIndex(driver, root, rowIndex);
    element = new _ListViewRow(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getLstPrimaryDisplayCard() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lstPrimaryDisplayCard(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getLstCustomizedTemplateList() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_lstCustomizedTemplateList(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getItemByIndex(itemInde) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_itemByIndex(driver, root, itemInde);
    element = new _LstTemplateListItemFactory(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async clickButtonByTitle(titleString) {
    const _statement0 = await this.__getActionsRibbon();
    const _statement1 = await _statement0.getActionRendererWithTitle(
      titleString
    );
    await _statement1.clickButton();
  }

  async clickDropdownButtonByTitle(buttonTitle) {
    const _statement0 = await this.__getActionsRibbon();
    const _statement1 = await _statement0.expandDropdown();
    const _statement2 = await this.__getActionsRibbon();
    const _statement3 = await _statement2.getActionRendererWithTitle(
      buttonTitle
    );
    await _statement3.clickItemByText(buttonTitle);
  }
}
