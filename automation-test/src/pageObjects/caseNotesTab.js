"use strict";

var core = require("@utam/core");
var _ChatterPanel = require("./../pageObjects/chatterPanel");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _ChatterPanel__default = /*#__PURE__*/ _interopDefaultLegacy(_ChatterPanel);

async function _utam_get_chatterWrapper(driver, root) {
  let _element = root;
  const _locator = core.By.css(`flexipage-aura-wrapper`);
  return _element.findElement(_locator);
}

async function _utam_get_chatterPanel(driver, root) {
  let _element = await _utam_get_chatterWrapper(driver, root);
  const _locator = core.By.css(`.supportCompactRecordFeedContainerDesktop`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class CaseNotesTab extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getChatterWrapper() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_chatterWrapper(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getChatterPanel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_chatterPanel(driver, root);
    element = new _ChatterPanel__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = CaseNotesTab;
