import {
  By as _By,
  ShadowRoot as _ShadowRoot,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject,
  ClickableUtamElement as _ClickableUtamElement
} from "@utam/core";
import _RecordLayoutBaseInput from "./../pageObjects/recordLayoutBaseInput";
import _RecordLayoutLookup from "./../pageObjects/recordLayoutLookup";
import _ChangeOwner from "./../pageObjects/changeOwner";
import _RecordPicklist from "./../pageObjects/recordPicklist";
import _InputStageName from "./../pageObjects/inputStageName";
import _Input from "./../pageObjects/input";

async function _utam_get_inputField(driver, root) {
  let _element = root;
  const _locator = _By.css(`[slot='inputField']`);
  return _element.findElement(_locator);
}

async function _utam_get_outputField(driver, root) {
  let _element = root;
  const _locator = _By.css(`[slot='outputField']`);
  return _element.findElement(_locator);
}

async function _utam_get_label(driver, root) {
  let _element = root;
  const _locator = _By.css(`.test-id__field-label`);
  _element = new _ShadowRoot(driver, _element);
  return _element.findElement(_locator);
}

async function _utam_get_inlineEditButton(driver, root) {
  let _element = root;
  const _locator = _By.css(`button.inline-edit-trigger`);
  _element = new _ShadowRoot(driver, _element);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

export default class RecordLayoutItem extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
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
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_label(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getInlineEditButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = _createUtamMixinCtor(_ClickableUtamElement);
    let element = await _utam_get_inlineEditButton(driver, root);
    if (!element) {
      return null;
    }
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
      _By.css(`.test-id__field-label`),
      true
    );
    return _result0;
  }

  async edit() {
    const _statement0 = await this.getInlineEditButton();
    if (_statement0 === null) {
      return null;
    }
    await _statement0.click();
    const _result1 = await this.waitFor(async () => {
      const _statement0 = await this.getRoot();
      const _result0 = await _statement0.containsElement(
        _By.css(`slot[slot='inputField']`)
      );
      return _result0;
    });
    return _result1;
  }

  async getTextInput() {
    const _statement0 = await this.getInputField(_RecordLayoutBaseInput);
    const _result1 = await _statement0.getInput();
    return _result1;
  }

  async getLookup() {
    const _statement0 = await this.getInputField(_RecordLayoutLookup);
    const _result1 = await _statement0.getLookup();
    return _result1;
  }

  async clickChangeOwnerButton() {
    const _statement0 = await this.getOutputField(_ChangeOwner);
    await _statement0.clickButton();
  }

  async getPicklist() {
    const _statement0 = await this.getInputField(_RecordPicklist);
    const _result1 = await _statement0.getBasePicklist();
    return _result1;
  }

  async getStageNamePicklist() {
    const _statement0 = await this.getInputField(_InputStageName);
    const _statement1 = await _statement0.getRecordPicklist();
    const _result2 = await _statement1.getBasePicklist();
    return _result2;
  }

  async getDatepicker() {
    const _statement0 = await this.getInputField(_Input);
    const _result1 = await _statement0.getDatepicker();
    return _result1;
  }

  async waitForOutputField() {
    const _result0 = await this.waitFor(async () => {
      const _statement0 = await this.getRoot();
      const _result0 = await _statement0.containsElement(
        _By.css(`[slot='outputField']`)
      );
      return _result0;
    });
    return _result0;
  }
}
