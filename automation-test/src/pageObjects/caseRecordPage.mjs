import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _LwcHighlightsPanel from "./../pageObjects/lwcHighlightsPanel";
import _Tabset2 from "./../pageObjects/tabset2";

async function _utam_get_highlights(driver, root) {
  let _element = root;
  const _locator = _By.css(`records-lwc-highlights-panel`);
  return _element.findElement(_locator);
}

async function _utam_get_detailsTabset(driver, root) {
  let _element = root;
  const _locator = _By.css(
    `.region-main flexipage-component2:nth-of-type(1) flexipage-tabset2`
  );
  return _element.findElement(_locator);
}

async function _utam_get_caseNotesTabset(driver, root) {
  let _element = root;
  const _locator = _By.css(
    `.region-main flexipage-component2:nth-of-type(2) flexipage-tabset2`
  );
  return _element.findElement(_locator);
}

async function _utam_get_chatsTabset(driver, root) {
  let _element = root;
  const _locator = _By.css(
    `.region-sidebar-right flexipage-component2:nth-of-type(1) flexipage-tabset2`
  );
  return _element.findElement(_locator);
}

async function _utam_get_knowledgeTabset(driver, root) {
  let _element = root;
  const _locator = _By.css(
    `.region-sidebar-right flexipage-component2:nth-of-type(2) flexipage-tabset2`
  );
  return _element.findElement(_locator);
}

export default class CaseRecordPage extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getHighlights() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_highlights(driver, root);
    element = new _LwcHighlightsPanel(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getDetailsTabset() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_detailsTabset(driver, root);
    element = new _Tabset2(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getCaseNotesTabset() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_caseNotesTabset(driver, root);
    element = new _Tabset2(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getChatsTabset() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_chatsTabset(driver, root);
    element = new _Tabset2(driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getKnowledgeTabset() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_knowledgeTabset(driver, root);
    element = new _Tabset2(driver, element);
    await element.__beforeLoad__();
    return element;
  }
}
