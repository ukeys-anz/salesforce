"use strict";

var core = require("@utam/core");
var _ListViewHeader = require("./../pageObjects/listViewHeader");
var _ListViewRow = require("./../pageObjects/listViewRow");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _ListViewHeader__default =
  /*#__PURE__*/ _interopDefaultLegacy(_ListViewHeader);
var _ListViewRow__default = /*#__PURE__*/ _interopDefaultLegacy(_ListViewRow);

async function _utam_get_newButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`a[title='New']`);
  return _element.findElement(_locator);
}

async function _utam_get_title(driver, root) {
  let _element = root;
  const _locator = core.By.css(`h2`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewContent(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.listViewContent`);
  return _element.findElement(_locator);
}

async function _utam_get_tableHeader(driver, root) {
  let _element = await _utam_get_listViewContent(driver, root);
  const _locator = core.By.css(`table.uiVirtualDataTable thead`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewHeaderByTitle(driver, root, headerTitle) {
  let _element = await _utam_get_tableHeader(driver, root);
  const _locator = core.By.css(`th[title='${headerTitle}']`);
  return _element.findElement(_locator);
}

async function _utam_get_tableBody(driver, root) {
  let _element = await _utam_get_listViewContent(driver, root);
  const _locator = core.By.css(`table.uiVirtualDataTable tbody`);
  return _element.findElement(_locator);
}

async function _utam_get_listViewRowByIndex(driver, root, rowIndex) {
  let _element = await _utam_get_tableBody(driver, root);
  const _locator = core.By.css(`tr:nth-of-type(${rowIndex})`);
  return _element.findElement(_locator);
}

class HomePageListView extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getNewButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_newButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getTitle() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_title(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getListViewContent() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_listViewContent(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getTableHeader() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
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
    element = new _ListViewHeader__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getTableBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_tableBody(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getListViewRowByIndex(rowIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_listViewRowByIndex(driver, root, rowIndex);
    element = new _ListViewRow__default["default"](driver, element);
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

module.exports = HomePageListView;
