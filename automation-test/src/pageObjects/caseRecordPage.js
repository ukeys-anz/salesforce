"use strict";

var core = require("@utam/core");
var _LwcHighlightsPanel = require("./../pageObjects/lwcHighlightsPanel");
var _Tabset2 = require("./../pageObjects/tabset2");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _LwcHighlightsPanel__default =
  /*#__PURE__*/ _interopDefaultLegacy(_LwcHighlightsPanel);
var _Tabset2__default = /*#__PURE__*/ _interopDefaultLegacy(_Tabset2);

async function _utam_get_highlights(driver, root) {
  let _element = root;
  const _locator = core.By.css(`records-lwc-highlights-panel`);
  return _element.findElement(_locator);
}

async function _utam_get_detailsTabset(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `.region-main flexipage-component2:nth-of-type(1) flexipage-tabset2`
  );
  return _element.findElement(_locator);
}

async function _utam_get_caseNotesTabset(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `.region-main flexipage-component2:nth-of-type(2) flexipage-tabset2`
  );
  return _element.findElement(_locator);
}

async function _utam_get_chatsTabset(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `.region-sidebar-right flexipage-component2:nth-of-type(1) flexipage-tabset2`
  );
  return _element.findElement(_locator);
}

async function _utam_get_knowledgeTabset(driver, root) {
  let _element = root;
  const _locator = core.By.css(
    `.region-sidebar-right flexipage-component2:nth-of-type(2) flexipage-tabset2`
  );
  return _element.findElement(_locator);
}

class CaseRecordPage extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getHighlights() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_highlights(driver, root);
    element = new _LwcHighlightsPanel__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getDetailsTabset() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_detailsTabset(driver, root);
    element = new _Tabset2__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getCaseNotesTabset() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_caseNotesTabset(driver, root);
    element = new _Tabset2__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getChatsTabset() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_chatsTabset(driver, root);
    element = new _Tabset2__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getKnowledgeTabset() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_knowledgeTabset(driver, root);
    element = new _Tabset2__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }
}

module.exports = CaseRecordPage;
