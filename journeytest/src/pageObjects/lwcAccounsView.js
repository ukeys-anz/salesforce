"use strict";

var core = require("@utam/core");

async function _utam_get_selectAccountFiler(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button[title='Select a List View']`);
  return _element.findElement(_locator);
}

async function _utam_get_inputAccountName(driver, root) {
  let _element = root;
  const _locator = core.By.css(`div input[name='Account-search-input']`);
  return _element.findElement(_locator);
}

async function _utam_get_refreshAccount(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button[name='refreshButton']`);
  return _element.findElement(_locator);
}

async function _utam_get_selectElementss(driver, root) {
  let _element = root;
  const _locator = core.By.css(`ul[aria-label] li`);
  return _element.findElements(_locator);
}

async function _utam_get_listView(driver, root) {
  let _element = root;
  const _locator = core.By.css(`div[class='listContent']`);
  return _element.findElement(_locator);
}

async function _utam_get_accountItem(driver, root, accname) {
  let _element = root;
  const _locator = core.By.css(`table tbody tr th a[title='${accname}']`);
  return _element.findElement(_locator);
}

class LwcAccounsView extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
    super(driver, element, locator);
  }
  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getSelectAccountFiler() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_selectAccountFiler(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getInputAccountName() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    let element = await _utam_get_inputAccountName(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async getRefreshAccount() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_refreshAccount(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getSelectElements() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let elements = await _utam_get_selectElementss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ClickableUtamElement(driver, element);
    });
    return elements;
  }

  async getListView() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_listView(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getAccountItem(accname) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_accountItem(driver, root, accname);
    element = new ClickableUtamElement(driver, element);
    return element;
  }
}

module.exports = LwcAccounsView;
