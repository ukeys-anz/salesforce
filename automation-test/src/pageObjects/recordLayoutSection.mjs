import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  ClickableUtamElement as _ClickableUtamElement,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _RecordLayoutRow from "./../pageObjects/recordLayoutRow";

async function _utam_get_rowss(driver, root) {
  let _element = root;
  const _locator = _By.css(`records-record-layout-row`);
  return _element.findElements(_locator);
}

async function _utam_get_row(driver, root, indexStartingOne) {
  let _element = root;
  const _locator = _By.css(
    `records-record-layout-row:nth-of-type(${indexStartingOne})`
  );
  return _element.findElement(_locator);
}

async function _utam_get_sectionTitleButton(driver, root) {
  let _element = root;
  const _locator = _By.css(`button.slds-button`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_sectionTitle(driver, root) {
  let _element = root;
  const _locator = _By.css(`.slds-section__title .slds-truncate`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_openSection(driver, root) {
  let _element = root;
  const _locator = _By.css(`div.slds-section.has-header.slds-is-open`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

export default class RecordLayoutSection extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getRows() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_rowss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _RecordLayoutRow(driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async getRow(indexStartingOne) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_row(driver, root, indexStartingOne);
    element = new _RecordLayoutRow(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async __getSectionTitleButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_sectionTitleButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getSectionTitle() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_sectionTitle(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getOpenSection() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_openSection(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async isOpen() {
    const _statement0 = await this.__getRoot();
    const _result0 = await _statement0.containsElement(
      _By.css(`div.slds-section.has-header.slds-is-open`),
      true
    );
    return _result0;
  }

  async hasTitle() {
    const _statement0 = await this.__getRoot();
    const _result0 = await _statement0.containsElement(
      _By.css(`.slds-section__title .slds-truncate`),
      true
    );
    return _result0;
  }

  async toggleSectionCollapse() {
    const _statement0 = await this.__getSectionTitleButton();
    await _statement0.click();
    const _statement1 = await this.__getRoot();
    const _result1 = await _statement1.waitFor(async () => {
      const _statement0 = await this.__getRoot();
      const _result0 = await _statement0.containsElement(
        _By.css(`div.slds-section.has-header.slds-is-open`),
        true
      );
      const _matcher0 = _result0 == false;
      return _matcher0;
    });
    return _result1;
  }
}
