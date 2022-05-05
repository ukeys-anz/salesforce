"use strict";

var core = require("@utam/core");

async function _utam_filter_searchResult(element, username) {
  const result = await element.getText();
  return result.includes(username);
}

async function _utam_get_modalBody(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.modal-body`);
  return _element.findElement(_locator);
}

async function _utam_get_searchBox(driver, root) {
  let _element = await _utam_get_modalBody(driver, root);
  const _locator = core.By.css(`input[title*='Search']`);
  return _element.findElement(_locator);
}

async function _utam_get_modalFooter(driver, root) {
  let _element = await _utam_get_modalBody(driver, root);
  const _locator = core.By.css(`.modal-footer`);
  return _element.findElement(_locator);
}

async function _utam_get_saveButton(driver, root) {
  let _element = await _utam_get_modalFooter(driver, root);
  const _locator = core.By.css(`button:nth-of-type(2)`);
  return _element.findElement(_locator);
}

async function _utam_get_searchResults(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.listContent li a`);
  return _element.findElements(_locator);
}

class QualityAssessmentSharingModal extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
    super(driver, element, locator);
  }

  async __beforeLoad__() {
    const _result0 = await this.waitFor(async () => {
      const _statement0 = await this.__getRoot();
      const _result0 = await _statement0.isVisible();
      return _result0;
    });
    return _result0;
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getModalBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_modalBody(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
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

  async __getModalFooter() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_modalFooter(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getSaveButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_saveButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getSearchResult(username) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let elements = await _utam_get_searchResults(driver, root);
    elements = elements.map(function _createElement(element) {
      return new ClickableUtamElement(driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_searchResult(el, username))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    return elements;
  }

  async search(searchTerm) {
    const _statement0 = await this.__getSearchBox();
    await _statement0.clearAndType(searchTerm);
  }

  async clickSearchBox() {
    const _statement0 = await this.__getSearchBox();
    await _statement0.click();
  }

  async clickResult(username) {
    const _statement0 = await this.__getSearchResult(username);
    await _statement0.click();
  }

  async save() {
    const _statement0 = await this.getSaveButton();
    await _statement0.click();
  }
}

module.exports = QualityAssessmentSharingModal;
