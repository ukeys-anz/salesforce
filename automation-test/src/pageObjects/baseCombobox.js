"use strict";

var core = require("@utam/core");
var _BaseComboboxItem = require("./../pageObjects/baseComboboxItem");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _BaseComboboxItem__default =
  /*#__PURE__*/ _interopDefaultLegacy(_BaseComboboxItem);

async function _utam_get_searchBox(driver, root) {
  let _element = root;
  const _locator = core.By.css(`input[role='combobox']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_lookupResultsBox(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[role='listbox']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_firstSearchedResult(driver, root) {
  let _element = root;
  const _locator = core.By.css(`ul li lightning-base-combobox-item`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_expandButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_triggerInput(driver, root) {
  let _element = root;
  const _locator = core.By.css(`input`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_groupss(driver, root) {
  let _element = root;
  const _locator = core.By.css(`ul[role='group']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElements(_locator);
}

async function _utam_get_itemsWrapper(driver, root) {
  let _element = root;
  const _locator = core.By.css(`div.slds-dropdown_fluid`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_itemss(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-base-combobox-item`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElements(_locator);
}

async function _utam_get_item(driver, root, indexStartingOne) {
  let _element = root;
  const _locator = core.By.css(
    `lightning-base-combobox-item:nth-of-type(${indexStartingOne})`
  );
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_selectedItemInput(driver, root) {
  let _element = root;
  const _locator = core.By.css(`input[type='text']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class BaseCombobox extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    return new EditableUtamElement(driver, root);
  }

  async __getSearchBox() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableEditableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement,
      core.EditableUtamElement
    );
    let element = await _utam_get_searchBox(driver, root);
    element = new ClickableEditableUtamElement(driver, element);
    return element;
  }

  async __getLookupResultsBox() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_lookupResultsBox(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getFirstSearchedResult() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_firstSearchedResult(driver, root);
    element = new _BaseComboboxItem__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getExpandButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_expandButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getTriggerInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_triggerInput(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getGroups() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let elements = await _utam_get_groupss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new BaseUtamElement(driver, element);
    });
    return elements;
  }

  async __getItemsWrapper() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_itemsWrapper(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getItems() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_itemss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _BaseComboboxItem__default["default"](driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async getItem(indexStartingOne) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_item(driver, root, indexStartingOne);
    element = new _BaseComboboxItem__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getSelectedItemInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    let element = await _utam_get_selectedItemInput(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async searchLookupAndSelect(lookupText) {
    const _statement0 = await this.__getSearchBox();
    await _statement0.click();
    await _statement0.clearAndType(lookupText);
    const _statement2 = await this.getFirstSearchedResult();
    await _statement2.waitForVisible();
    await _statement2.clickItem();
  }

  async expand() {
    const _statement0 = await this.__getTriggerInput();
    await _statement0.click();
    const _statement1 = await this.__getItemsWrapper();
    await _statement1.waitForVisible();
  }

  async expandForDisabledInput() {
    const _statement0 = await this.__getExpandButton();
    await _statement0.click();
    const _statement1 = await this.__getItemsWrapper();
    await _statement1.waitForVisible();
  }

  async pickItem(indexStartingOne) {
    const _statement0 = await this.getItem(indexStartingOne);
    await _statement0.clickItem();
  }
}

module.exports = BaseCombobox;
