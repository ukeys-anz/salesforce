import {
  By as _By,
  createUtamMixinCtor as _createUtamMixinCtor,
  UtamBasePageObject as _UtamBasePageObject
} from "@utam/core";
import _CompletedQARelatedListItem from "./../pageObjects/completedQARelatedListItem";

async function _utam_filter_qualityAssessmentByNumber(element, qaNumber) {
  const result = await element.getNumber();
  return result.includes(qaNumber);
}

async function _utam_get_qaList(driver, root) {
  let _element = root;
  const _locator = _By.css(`.uiAbstractList .listContent ul`);
  return _element.findElement(_locator);
}

async function _utam_get_qualityAssessmentByNumbers(driver, root) {
  let _element = await _utam_get_qaList(driver, root);
  const _locator = _By.css(`.forceListRecord`);
  return _element.findElements(_locator);
}

export default class CompletedQARelatedList extends _UtamBasePageObject {
  constructor(driver, element, locator) {
    super(driver, element, locator);
  }

  async __getRoot() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    return new BaseUtamElement(driver, root);
  }

  async __getQaList() {
    const driver = this.driver;
    const root = await this.getRootElement();
    const BaseUtamElement = _createUtamMixinCtor();
    let element = await _utam_get_qaList(driver, root);
    element = new BaseUtamElement(driver, element);
    return element;
  }

  async getQualityAssessmentByNumber(qaNumber) {
    const driver = this.driver;
    const root = await this.getRootElement();
    let elements = await _utam_get_qualityAssessmentByNumbers(driver, root);
    elements = elements.map(function _createElement(element) {
      return new _CompletedQARelatedListItem(driver, element);
    });
    const appliedFilter = await Promise.all(
      elements.map((el) => _utam_filter_qualityAssessmentByNumber(el, qaNumber))
    );
    elements = elements.find((_, i) => appliedFilter[i]);
    if (elements) {
      await elements.__beforeLoad__();
    }
    return elements;
  }
}
