import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _ListViewHeader from "./../pageObjects/listViewHeader";
import _ListViewRow from "./../pageObjects/listViewRow";

async function _utam_get_newButton(driver, root) {
  let _element = root;
  const _locator = _By.css(`a[title='New']`);
  return _element.findElement(_locator);
}

async function _utam_get_title(driver, root) {
  let _element = root;
  const _locator = _By.css(`h2`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewContent(driver, root) {
  let _element = root;
  const _locator = _By.css(`.listViewContent`);
  return _element.findElement(_locator);
}

async function _utam_get_tableHeader(driver, root) {
  let _element = await _utam_get_listViewContent(driver, root);
  const _locator = _By.css(`table.uiVirtualDataTable thead`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewHeaderByTitle(driver, root, headerTitle) {
  let _element = await _utam_get_tableHeader(driver, root);
  const _locator = _By.css(`th[title='${headerTitle}']`);
  return _element.findElement(_locator);
}

async function _utam_get_tableBody(driver, root) {
  let _element = await _utam_get_listViewContent(driver, root);
  const _locator = _By.css(`table.uiVirtualDataTable tbody`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewRowByIndex(driver, root, rowIndex) {
  let _element = await _utam_get_tableBody(driver, root);
  const _locator = _By.css(`tr:nth-of-type(${rowIndex})`);
  return _element.findElement(_locator);
}

export default class HomePageListView extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getNewButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_newButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getTitle() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_title(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getListViewContent() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_listViewContent(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getTableHeader() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_tableHeader(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getListViewHeaderByTitle(headerTitle) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_listViewHeaderByTitle(
      driver,
      root,
      headerTitle
    );
    element = new _ListViewHeader(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getTableBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_tableBody(driver, root);
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

  async getListViewTitle() {
    const _statement0 = await this.__getTitle();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async clickNew() {
    const _statement0 = await this.__getNewButton();
    await _statement0.click();
  }
}
