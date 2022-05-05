"use strict";

var core = require("@utam/core");

async function _utam_get_knowledgeMultiSelectTable(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.forceKnowledgeMultiSelectTable`);
  return _element.findElement(_locator);
}

async function _utam_get_tableBody(driver, root) {
  let _element = await _utam_get_knowledgeMultiSelectTable(driver, root);
  const _locator = core.By.css(`tbody`);
  return _element.findElement(_locator);
}

async function _utam_get_firstOption(driver, root) {
  let _element = await _utam_get_tableBody(driver, root);
  const _locator = core.By.css(`tr:nth-of-type(1)`);
  return _element.findElement(_locator);
}

async function _utam_get_firstOptionSelector(driver, root) {
  let _element = await _utam_get_firstOption(driver, root);
  const _locator = core.By.css(`input[type='checkbox']`);
  return _element.findElement(_locator);
}

async function _utam_get_modalFooter(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.slds-modal__footer`);
  return _element.findElement(_locator);
}

async function _utam_get_saveButton(driver, root) {
  let _element = await _utam_get_modalFooter(driver, root);
  const _locator = core.By.css(`button:nth-of-type(2)`);
  return _element.findElement(_locator);
}

class ArticleCategoriesEditorModal extends core.UtamBaseRootPageObject {
  constructor(driver, element, locator = core.By.css(`body`)) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getKnowledgeMultiSelectTable() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_knowledgeMultiSelectTable(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getTableBody() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_tableBody(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getFirstOption() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_firstOption(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getFirstOptionSelector() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_firstOptionSelector(driver, root);
    element = new ClickableUtamElement(driver, element);
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

  async __getSaveButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_saveButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async selectFirstCategory() {
    const _statement0 = await this.__getFirstOptionSelector();
    await _statement0.click();
    const _statement1 = await this.__getSaveButton();
    await _statement1.click();
  }
}

module.exports = ArticleCategoriesEditorModal;
