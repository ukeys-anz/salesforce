"use strict";

var core = require("@utam/core");
var _CaseCreationFormPicklist = require("./../pageObjects/caseCreationFormPicklist");

function _interopDefaultLegacy(e) {
  return e && typeof e === "object" && "default" in e ? e : { default: e };
}

var _CaseCreationFormPicklist__default = /*#__PURE__*/ _interopDefaultLegacy(
  _CaseCreationFormPicklist
);

async function _utam_filter_caseRecordType(element, text) {
  const result = await element.getText();
  return result === text;
}

async function _utam_get_newCase(driver, root) {
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

async function _utam_get_lookupResult(driver, root, resultTile) {
  let _element = root;
  const _locator = core.By.css(
    `.listContent li a div[class*='primaryLabel'][title='${resultTile}']`
  );
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

async function _utam_get_picklist(
  driver,
  root,
  sectionIndex,
  sectionRowIndex,
  sectionRowItemIndex
) {
  let _element = await _utam_get_formSectionRowItem(
    driver,
    root,
    sectionIndex,
    sectionRowIndex,
    sectionRowItemIndex
  );
  const _locator = core.By.css(`a[role='button']`);
  return _element.findElement(_locator);
}

async function _utam_get_number(
  driver,
  root,
  sectionIndex,
  sectionRowIndex,
  sectionRowItemIndex
) {
  let _element = await _utam_get_formSectionRowItem(
    driver,
    root,
    sectionIndex,
    sectionRowIndex,
    sectionRowItemIndex
  );
  const _locator = core.By.css(`input[class*='uiInputSmartNumber']`);
  return _element.findElement(_locator);
}

async function _utam_get_text(
  driver,
  root,
  sectionIndex,
  sectionRowIndex,
  sectionRowItemIndex
) {
  let _element = await _utam_get_formSectionRowItem(
    driver,
    root,
    sectionIndex,
    sectionRowIndex,
    sectionRowItemIndex
  );
  const _locator = core.By.css(`input[type='text']`);
  return _element.findElement(_locator);
}

async function _utam_get_textarea(
  driver,
  root,
  sectionIndex,
  sectionRowIndex,
  sectionRowItemIndex
) {
  let _element = await _utam_get_formSectionRowItem(
    driver,
    root,
    sectionIndex,
    sectionRowIndex,
    sectionRowItemIndex
  );
  const _locator = core.By.css(`textarea[role='textbox']`);
  return _element.findElement(_locator);
}

async function _utam_get_lookup(
  driver,
  root,
  sectionIndex,
  sectionRowIndex,
  sectionRowItemIndex
) {
  let _element = await _utam_get_formSectionRowItem(
    driver,
    root,
    sectionIndex,
    sectionRowIndex,
    sectionRowItemIndex
  );
  const _locator = core.By.css(`input[role='combobox']`);
  return _element.findElement(_locator);
}

async function _utam_get_picklistItemsListss(driver, root) {
  let _element = root;
  const _locator = core.By.css(`.desktop > .select-options ul`);
  return _element.findElements(_locator);
}

async function _utam_get_saveCase(driver, root) {
  let _element = root;
  const _locator = core.By.css(`button[title='Save']`);
  return _element.findElement(_locator);
}

class CaseCreationForm extends core.UtamBaseRootPageObject {
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

  async getNewCase() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_newCase(driver, root);
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

  async __getLookupResult(resultTile) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_lookupResult(driver, root, resultTile);
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
    const BaseUtamElement = core.createUtamMixinCtor();
    let element = await _utam_get_formSectionRowItem(
      driver,
      root,
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async __getPicklist(sectionIndex, sectionRowIndex, sectionRowItemIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_picklist(
      driver,
      root,
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async __getNumber(sectionIndex, sectionRowIndex, sectionRowItemIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    let element = await _utam_get_number(
      driver,
      root,
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async __getText(sectionIndex, sectionRowIndex, sectionRowItemIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    let element = await _utam_get_text(
      driver,
      root,
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async __getTextarea(sectionIndex, sectionRowIndex, sectionRowItemIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const EditableUtamElement = core.createUtamMixinCtor(
      core.EditableUtamElement
    );
    let element = await _utam_get_textarea(
      driver,
      root,
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    element = new EditableUtamElement(driver, element);
    return element;
  }

  async __getLookup(sectionIndex, sectionRowIndex, sectionRowItemIndex) {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableEditableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement,
      core.EditableUtamElement
    );
    let element = await _utam_get_lookup(
      driver,
      root,
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    element = new ClickableEditableUtamElement(driver, element);
    return element;
  }

  async getPicklistItemsLists() {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_picklistItemsListss(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _CaseCreationFormPicklist__default["default"](driver, element);
    });
    await Promise.all(elements.map((el) => el.__beforeLoad__()));
    return elements;
  }

  async getSaveCase() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const ClickableUtamElement = core.createUtamMixinCtor(
      core.ClickableUtamElement
    );
    let element = await _utam_get_saveCase(driver, root);
    element = new ClickableUtamElement(driver, element);
    return element;
  }

  async selectCaseRecordType(text) {
    await this.waitFor(async () => {
      const _result0 = await this.getNewCase();
      const _matcher0 = _result0 !== null;
      return _matcher0;
    });
    const _statement1 = await this.getNewCase();
    if (_statement1 === null) {
      return null;
    }
    await _statement1.click();
    await this.waitFor(async () => {
      const _result0 = await this.getCaseRecordType(text);
      const _matcher0 = _result0 !== null;
      return _matcher0;
    });
    const _statement3 = await this.getCaseRecordType(text);
    if (_statement3 === null) {
      return null;
    }
    await _statement3.click();
    const _statement4 = await this.getNextButton();
    if (_statement4 === null) {
      return null;
    }
    await _statement4.click();
  }

  async selectPicklist(sectionIndex, sectionRowIndex, sectionRowItemIndex) {
    const _statement0 = await this.__getPicklist(
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    await _statement0.click();
  }

  async editNumber(
    sectionIndex,
    sectionRowIndex,
    sectionRowItemIndex,
    numberStr
  ) {
    const _statement0 = await this.__getNumber(
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    await _statement0.clearAndType(numberStr);
  }

  async editText(sectionIndex, sectionRowIndex, sectionRowItemIndex, text) {
    const _statement0 = await this.__getText(
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    await _statement0.clearAndType(text);
  }

  async editTextarea(sectionIndex, sectionRowIndex, sectionRowItemIndex, text) {
    const _statement0 = await this.__getTextarea(
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    await _statement0.clearAndType(text);
  }

  async searchAndSelectLookup(
    sectionIndex,
    sectionRowIndex,
    sectionRowItemIndex,
    searchTerm,
    resultTile
  ) {
    const _statement0 = await this.__getLookup(
      sectionIndex,
      sectionRowIndex,
      sectionRowItemIndex
    );
    await _statement0.clearAndType(searchTerm);
    await _statement0.click();
    await this.waitForVisible(async () => {
      const _result0 = await this.__getLookupResult(resultTile);
      const _matcher0 = _result0 !== null;
      return _matcher0;
    });
    const _statement3 = await this.__getLookupResult(resultTile);
    await _statement3.click();
  }

  async saveNew() {
    const _statement0 = await this.getSaveCase();
    await _statement0.click();
  }
}

module.exports = CaseCreationForm;
