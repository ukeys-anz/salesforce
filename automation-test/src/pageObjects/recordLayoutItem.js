"use strict";

var core = require("@utam/core");
var _RecordLayoutBaseInput = require("./../pageObjects/recordLayoutBaseInput");
var _RecordLayoutLookup = require("./../pageObjects/recordLayoutLookup");
var _ChangeOwner = require("./../pageObjects/changeOwner");
var _RecordPicklist = require("./../pageObjects/recordPicklist");
var _InputStageName = require("./../pageObjects/inputStageName");
var _Input = require("./../pageObjects/input");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _RecordLayoutBaseInput__default = /*#__PURE__*/ _interopDefaultLegacy(
  _RecordLayoutBaseInput
);
var _RecordLayoutLookup__default =
  /*#__PURE__*/ _interopDefaultLegacy(_RecordLayoutLookup);
var _ChangeOwner__default = /*#__PURE__*/ _interopDefaultLegacy(_ChangeOwner);
var _RecordPicklist__default =
  /*#__PURE__*/ _interopDefaultLegacy(_RecordPicklist);
var _InputStageName__default =
  /*#__PURE__*/ _interopDefaultLegacy(_InputStageName);
var _Input__default = /*#__PURE__*/ _interopDefaultLegacy(_Input);

async function _utam_get_inputField(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[slot='inputField']`);
  return _element.findElement(_locator);
}

async function _utam_get_outputField(driver, root) {
  let _element = root;
  const _locator = core.By.css(`[slot='outputField']`);
  return _element.findElement(_locator);
}

async function _utam_get_label(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.test-id__field-label`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_inlineEditButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button.inline-edit-trigger`);
  _element = new core.ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

class RecordLayoutItem extends core.UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async getInputField(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_inputField(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async getOutputField(ContainerCtor) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_outputField(driver, root);
    element = new ContainerCtor(driver, element);
    return element;
  }

  async getLabel() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_label(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getInlineEditButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_inlineEditButton(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getLabelText() {
    const _statement0 = await this.getLabel();
    const _result0 = await _statement0.getText();
    return _result0;
  }

  async hasLabelText() {
    const _statement0 = await this.getRoot();
    const _result0 = await _statement0.containsElement(
      core.By.css(`.test-id__field-label`),
      true
    );
    return _result0;
  }

  async edit() {
    const _statement0 = await this.getInlineEditButton();
    await _statement0.click();
    const _result1 = await this.waitFor(async () => {
      const _statement0 = await this.getRoot();
      const _result0 = await _statement0.containsElement(
        core.By.css(`slot[slot='inputField']`)
      );
      return _result0;
    });
    return _result1;
  }

  async getTextInput() {
    const _statement0 = await this.getInputField(
      _RecordLayoutBaseInput__default["default"]
    );
    const _result1 = await _statement0.getInput();
    return _result1;
  }

  async getLookup() {
    const _statement0 = await this.getInputField(
      _RecordLayoutLookup__default["default"]
    );
    const _result1 = await _statement0.getLookup();
    return _result1;
  }

  async clickChangeOwnerButton() {
    const _statement0 = await this.getOutputField(
      _ChangeOwner__default["default"]
    );
    const _statement1 = await _statement0.getChangeOwnerButton();
    await _statement1.click();
  }

  async getPicklist() {
    const _statement0 = await this.getInputField(
      _RecordPicklist__default["default"]
    );
    const _result1 = await _statement0.getBasePicklist();
    return _result1;
  }

  async getStageNamePicklist() {
    const _statement0 = await this.getInputField(
      _InputStageName__default["default"]
    );
    const _statement1 = await _statement0.getRecordPicklist();
    const _result2 = await _statement1.getBasePicklist();
    return _result2;
  }

  async getDatepicker() {
    const _statement0 = await this.getInputField(_Input__default["default"]);
    const _result1 = await _statement0.getDatepicker();
    return _result1;
  }

  async waitForOutputField() {
    const _result0 = await this.waitFor(async () => {
      const _statement0 = await this.getRoot();
      const _result0 = await _statement0.containsElement(
        core.By.css(`[slot='outputField']`)
      );
      return _result0;
    });
    return _result0;
  }
}

module.exports = RecordLayoutItem;
