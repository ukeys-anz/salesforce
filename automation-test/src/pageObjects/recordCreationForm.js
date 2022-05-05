"use strict";

var core = require("@utam/core");
var _RecordCreationFormField = require("./../pageObjects/recordCreationFormField");
var _RecordCreationFormPicklist = require("./../pageObjects/recordCreationFormPicklist");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _RecordCreationFormField__default = /*#__PURE__*/ _interopDefaultLegacy(
  _RecordCreationFormField
);
var _RecordCreationFormPicklist__default = /*#__PURE__*/ _interopDefaultLegacy(
  _RecordCreationFormPicklist
);

async function _utam_filter_caseRecordType(element, text) {
  const result = await element.getText();
  return result === text;
}

async function _utam_filter_fieldByLabel(element, label) {
  const result = await element.getLabel();
  return result === label;
}

async function _utam_get_newButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`a div[title='New']`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

async function _utam_get_caseRecordTypes(driver, root) {
  let _element = root;
  const _locator = core.By.css(`article[class*='cNewCaseAuraWrapper'] span`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElements(_locator);
}

async function _utam_get_nextButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`footer button:nth-of-type(2)`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElement(_locator);
}

async function _utam_get_formSection(driver, root, sectionIndex) {
  let _element = root;
  const _locator = core.By.css(
    `.forcePageBlockSection:nth-of-type(${sectionIndex})`
  );
  return _element.findElement(_locator);
}

async function _utam_get_formSectionRow(
  driver,
  root,
  sectionIndex,
  sectionRowIndex
) {
  let _element = await _utam_get_formSection(driver, root, sectionIndex);
  const _locator = core.By.css(
    `.forcePageBlockSectionRow:nth-of-type(${sectionRowIndex})`
  );
  return _element.findElement(_locator);
}

async function _utam_get_formSectionRowItem(
  driver,
  root,
  sectionIndex,
  sectionRowIndex,
  sectionRowItemIndex
) {
  let _element = await _utam_get_formSectionRow(
    driver,
    root,
    sectionIndex,
    sectionRowIndex
  );
  const _locator = core.By.css(
    `.forcePageBlockItem:nth-of-type(${sectionRowItemIndex})`
  );
  return _element.findElement(_locator);
}

async function _utam_get_fieldByLabels(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.forcePageBlockItem`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElements(_locator);
}

async function _utam_get_allFieldss(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.forcePageBlockItem`);
  const hasElement = await _element.containsElement(_locator);
  if (!hasElement) {
    return null;
  }
  return _element.findElements(_locator);
}

async function _utam_get_picklistss(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.desktop > .select-options ul`);
  return _element.findElements(_locator);
}

async function _utam_get_saveButton(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button[title='Save']`);
  return _element.findElement(_locator);
}

class RecordCreationForm extends core.UtamBaseRootPageObject {
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

  async getNewButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_newButton(driver, root);
    if (!element) {
      return null;
    }
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async getCaseRecordType(text) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let elements = await _utam_get_caseRecordTypes(driver, root);
    if (!elements) {
      return null;
    }
    elements = elements.map(function _createElement(element) {
      return new ClickableUtamElement(driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_caseRecordType(el, text))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    return elements;
  }

  async getNextButton() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_nextButton(driver, root);
    if (!element) {
      return null;
    }
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getFormSection(sectionIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_formSection(driver, root, sectionIndex);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getFormSectionRow(sectionIndex, sectionRowIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_formSectionRow(
      driver,
      root,
      sectionIndex,
      sectionRowIndex
    );
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getFormSectionRowItem(
    sectionIndex,
    sectionRowIndex,
    sectionRowItemIndex
  ) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let element = await _utam_get_formSectionRowItem(
      driver,
      root,
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    element = new _RecordCreationFormField__default["default"](driver, element);
    await element.__beforeLoad__();
    return element;
  }

  async getFieldByLabel(label) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_fieldByLabels(driver, root);
    if (!elements) {
      return null;
    }
    elements = elements.map(function _createElement(element) {
      return new _RecordCreationFormField__default["default"](driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_fieldByLabel(el, label))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    if (elements) {
      await elements.__beforeLoad__();
    }
    return elements;
  }

  async getAllFields() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_allFieldss(driver, root);
    if (!elements) {
      return null;
    }
    elements = elements.map(function _createElement(element) {
      return new _RecordCreationFormField__default["default"](driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async getPicklists() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_picklistss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _RecordCreationFormPicklist__default[
        "default"
      ](driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
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

  async selectCaseRecordType(text) {
    await this.clickNew();
    await this.waitFor(async () => {
      const _result0 = await this.getCaseRecordType(text);
      const _matcher0 = _result0 !== null;
      return _matcher0;
    });
    const _statement2 = await this.getCaseRecordType(text);
    if (_statement2 === null) {
      return null;
    }
    await _statement2.click();
    const _statement3 = await this.getNextButton();
    if (_statement3 === null) {
      return null;
    }
    await _statement3.click();
  }

  async clickNew() {
    await this.waitFor(async () => {
      const _result0 = await this.getNewButton();
      const _matcher0 = _result0 !== null;
      return _matcher0;
    });
    const _statement1 = await this.getNewButton();
    if (_statement1 === null) {
      return null;
    }
    await _statement1.click();
  }

  async saveNew() {
    const _statement0 = await this.getSaveButton();
    await _statement0.click();
  }
}

module.exports = RecordCreationForm;
