import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _RecordLayoutItem from "./../pageObjects/recordLayoutItem";

async function _utam_get_itemss(driver, root) {
  let _element = root;
  const _locator = _By.css(`records-record-layout-item`);
  return _element.findElements(_locator);
}

async function _utam_get_item(driver, root, indexStartingOne) {
  let _element = root;
  const _locator = _By.css(
    `records-record-layout-item:nth-of-type(${indexStartingOne})`
  );
  return _element.findElement(_locator);
}

export default class RecordLayoutRow extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getItems() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_itemss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _RecordLayoutItem(driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async getItem(indexStartingOne) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_item(driver, root, indexStartingOne);
    element = new _RecordLayoutItem(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
