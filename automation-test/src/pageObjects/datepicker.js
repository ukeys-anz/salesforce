"use strict";

var core = require("@utam/core");

async function _utam_get_label(driver, root) {
  let _element = root;
  const _locator = core.By.css(`label`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_required(driver, root) {
  let _element = await _utam_get_label(driver, root);
  const _locator = core.By.css(`.slds-required`);
  return _element.findElement(_locator);
}

async function _utam_get_dateInput(driver, root) {
  let _element = root;
  const _locator = core.By.css(`input`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class Datepicker extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getLabel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_label(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getRequired() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_required(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getDateInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    let element = await _utam_get_dateInput(driver, root);
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async getLabelText() {
    const _statement0 = await this.__getLabel();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async isRequired() {
    const _statement0 = await this.__getRequired();
    const _result0 = await _statement0.isPresent();
    return _result0;
  }

  async setDateText(text) {
    const _statement0 = await this.__getDateInput();
    await _statement0.setText(text);
  }

  async getDateText() {
    const _statement0 = await this.__getDateInput();
    const _result0 = await _statement0.getValue();
    return _result0;
  }

  async clearDateText() {
    const _statement0 = await this.__getDateInput();
    await _statement0.clear();
  }
}

module.exports = Datepicker;
