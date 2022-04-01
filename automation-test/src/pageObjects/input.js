"use strict";

var core = require("@utam/core");
var _Datepicker = require("./../pageObjects/datepicker");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _Datepicker__default = /*#__PURE__*/ _interopDefaultLegacy(_Datepicker);

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

async function _utam_get_input(driver, root) {
  let _element = root;
  const _locator = core.By.css(`input`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_inputCheckbox(driver, root) {
  let _element = root;
  const _locator = core.By.css(`input[type='checkbox']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_inputRadio(driver, root) {
  let _element = root;
  const _locator = core.By.css(`input[type='radio']`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_error(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.slds-form-element__help`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_datepicker(driver, root) {
  let _element = root;
  const _locator = core.By.css(`lightning-datepicker`);
  _element = new core.ShadowRoot(driver, _element);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

class Input extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ActionableUtamElement = core.createUtamMixinCtor(
      core.ActionableUtamElement
    );
    return new ActionableUtamElement(driver, root);
  }

  async __getLabel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_label(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getRequired() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_required(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getInput() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ActionableClickableEditableUtamElement = core.createUtamMixinCtor(
      core.ActionableUtamElement,
      core.ClickableUtamElement,
      core.EditableUtamElement
    );
    let element = await _utam_get_input(driver, root);
    element = new ActionableClickableEditableUtamElement(driver, element);
    return element;
  }

  async __getInputCheckbox() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_inputCheckbox(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getInputRadio() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_inputRadio(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getError() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_error(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getDatepicker() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_datepicker(driver, root);
    if (!element) {
      return null;
    }
    element = new _Datepicker__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async hasLabel() {
    const _statement0 = await this.__getRoot();
    const _result0 = await _statement0.containsElement(
      core.By.css(`label`),
      true
    );
    return _result0;
  }

  async hasFocus() {
    const _statement0 = await this.__getInput();
    const _result0 = await _statement0.isFocused();
    return _result0;
  }

  async getLabelText() {
    const _statement0 = await this.__getLabel();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async getValueText() {
    const _statement0 = await this.__getInput();
    const _result0 = await _statement0.getValue();
    return _result0;
  }

  async setText(text) {
    const _statement0 = await this.__getInput();
    await _statement0.scrollToTop();
    await _statement0.click();
    await _statement0.clear();
    await _statement0.setText(text);
  }

  async toggleCheckbox() {
    const _statement0 = await this.__getInputCheckbox();
    await _statement0.click();
  }

  async getCheckedState() {
    const _statement0 = await this.__getInputCheckbox();
    const _result0 = await _statement0.getAttribute('"checked"');
    return _result0;
  }

  async selectRadio() {
    const _statement0 = await this.__getInputRadio();
    await _statement0.click();
  }

  async getErrorText() {
    const _statement0 = await this.getError();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async hasError() {
    const _statement0 = await this.getError();
    const _result0 = await _statement0.isPresent();
    return _result0;
  }

  async isReadonly() {
    const _statement0 = await this.__getInput();
    const _result0 = await _statement0.getAttribute('"readonly"');
    return _result0;
  }

  async isEnabled() {
    const _statement0 = await this.__getInput();
    const _result0 = await _statement0.isEnabled();
    return _result0;
  }

  async isSelectable() {
    const _statement0 = await this.__getInputCheckbox();
    const _result0 = await _statement0.isEnabled();
    return _result0;
  }

  async scrollToCenter() {
    const _statement0 = await this.__getRoot();
    await _statement0.scrollToCenter();
  }

  async hasDatetimepicker() {
    const _statement0 = await this.__getRoot();
    const _result0 = await _statement0.containsElement(
      core.By.css(`lightning-datetimepicker`),
      true
    );
    return _result0;
  }
}

module.exports = Input;
