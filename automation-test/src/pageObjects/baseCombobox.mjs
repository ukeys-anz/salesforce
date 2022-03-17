import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject,
  EditableUtamElement as _EditableUtamElement
} from "@utam/core";
import _BaseComboboxItem from "./../pageObjects/baseComboboxItem";

async function _utam_get_expandButton(driver, root) {
  let _element = root;
  const _locator = _By.css(`button`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_triggerInput(driver, root) {
  let _element = root;
  const _locator = _By.css(`input`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_groupss(driver, root) {
  let _element = root;
  const _locator = _By.css(`ul[role='group']`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElements(_locator);
}

async function _utam_get_itemsWrapper(driver, root) {
  let _element = root;
  const _locator = _By.css(`div.slds-dropdown_fluid`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_itemss(driver, root) {
  let _element = root;
  const _locator = _By.css(`lightning-base-combobox-item`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElements(_locator);
}

async function _utam_get_item(driver, root, indexStartingOne) {
  let _element = root;
  const _locator = _By.css(
    `lightning-base-combobox-item:nth-of-type(${indexStartingOne})`
  );
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_selectedItemInput(driver, root) {
  let _element = root;
  const _locator = _By.css(`input[type='text']`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class BaseCombobox extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = _createUtamMixinCtor(_EditableUtamElement);
    return new EditableUtamElement(driver, root);
  }

  async __getExpandButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_expandButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getTriggerInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_triggerInput(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getGroups() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let elements = await _utam_get_groupss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new BaseUtamElement(driver, element);
    });
    return elements;
  }

  async __getItemsWrapper() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_itemsWrapper(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getItems() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_itemss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _BaseComboboxItem(driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async getItem(indexStartingOne) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_item(driver, root, indexStartingOne);
    element = new _BaseComboboxItem(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getSelectedItemInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = _createUtamMixinCtor(_EditableUtamElement);
    let element = await _utam_get_selectedItemInput(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
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
