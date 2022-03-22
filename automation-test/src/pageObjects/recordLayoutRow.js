"use strict";

var core = require("@utam/core");
var _RecordLayoutItem = require("./../pageObjects/recordLayoutItem");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _RecordLayoutItem__default =
  /*#__PURE__*/ _interopDefaultLegacy(_RecordLayoutItem);

async function _utam_get_itemss(driver, root) {
  let _element = root;
  const _locator = core.By.css(`records-record-layout-item`);
  return _element.findElements(_locator);
}

async function _utam_get_item(driver, root, indexStartingOne) {
  let _element = root;
  const _locator = core.By.css(
    `records-record-layout-item:nth-of-type(${indexStartingOne})`
  );
  return _element.findElement(_locator);
}

class RecordLayoutRow extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getItems() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_itemss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _RecordLayoutItem__default["default"](driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async getItem(indexStartingOne) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_item(driver, root, indexStartingOne);
    element = new _RecordLayoutItem__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = RecordLayoutRow;
