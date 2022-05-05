"use strict";

var core = require("@utam/core");
var _Button = require("./../pageObjects/button");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Button__default = /*#__PURE__*/ _interopDefaultLegacy(_Button);

async function _utam_get_actionPanel(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-quick-action-panel`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_publishButton(driver, root) {
  let _element = await _utam_get_actionPanel(driver, root);
  const _locator = core.By.css(`lightning-button:nth-of-type(2)`);
  return _element.findElement(_locator);
}

class LwcPublishArticle extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getActionPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_actionPanel(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getPublishButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_publishButton(driver, root);
    element = new _Button__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async publish() {
    const _statement0 = await this.__getPublishButton();
    await _statement0.click();
  }
}

module.exports = LwcPublishArticle;
