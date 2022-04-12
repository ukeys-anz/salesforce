"use strict";

var core = require("@utam/core");
var _ActionButton = require("./../pageObjects/actionButton");
var _ActionLink = require("./../pageObjects/actionLink");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _ActionButton__default = /*#__PURE__*/ _interopDefaultLegacy(_ActionButton);
var _ActionLink__default = /*#__PURE__*/ _interopDefaultLegacy(_ActionLink);

async function _utam_filter_actionButton(element, text) {
  const result = await element.getLabel();
  return result === text;
}

async function _utam_filter_actionLink(element, text) {
  const result = await element.getLabel();
  return result === text;
}

async function _utam_get_actionButtons(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.forceActionButton`);
  return _element.findElements(_locator);
}

async function _utam_get_actionLinks(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.forceActionLink`);
  return _element.findElements(_locator);
}

class ActionsContainer extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getActionButton(text) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_actionButtons(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _ActionButton__default["default"](driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_actionButton(el, text))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    if (elements) {
      await elements.__beforeLoad__();
    }
    return elements;
  }

  async getActionLink(text) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_actionLinks(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _ActionLink__default["default"](driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_actionLink(el, text))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    if (elements) {
      await elements.__beforeLoad__();
    }
    return elements;
  }
}

module.exports = ActionsContainer;
