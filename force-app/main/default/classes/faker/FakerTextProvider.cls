/**
 * @author Igor Matkovic
 * @since 09/07/2018
 * @group Faker
 * @description Class having various text output methods
 */
public with sharing virtual class FakerTextProvider extends FakerBase {
  public String text;

  public List<String> sentences;

  /**
   * @description Init method
   */
  public void init() {
    this.sentences = this.text.split('\\.\\s');

    for (Integer i = 0; i < this.sentences.size(); i++) {
      String sentence = this.sentences.get(i);
      this.sentences.set(
        i,
        sentence.trim().replace('\n', '').replace('\r', '')
      );
    }
  }

  /**
   * @description Method which returns a list of real words
   * @param wordInt Integer representing the number of words
   * @return `List<String>` List of real words
   */
  public List<String> realWords(Integer wordInt) {
    List<String> words = new List<String>();

    while (words.size() < wordInt) {
      String sentence = this.randomElement(this.sentences);
      List<String> sentences = sentence.split('\\s');
      String word = this.randomElement(sentences);
      words.add(word.replaceAll('[^a-zA-Z0-9]', ''));
    }

    return words;
  }

  /**
   * @description Method which returns a sentence with real words
   * @param minLength Integer representing minimum length
   * @param maxLength Integer representing maximum length
   * @return `String` Sentence with real words
   */
  public String realText(Integer minLength, Integer maxLength) {
    if (maxLength > 500) {
      maxLength = 500;
    }
    String finalText = '';

    // Not to always max out... put in a random size
    maxLength = this.randomIntegerBetween(minLength, maxLength);
    while (finalText.length() < maxLength) {
      String sentence = this.randomElement(this.sentences);
      finalText += sentence + '. ';
      finalText = finalText.replace('  ', ' ');
    }

    // Crop it if its to large
    if (finalText.length() >= maxLength) {
      finalText = finalText.substring(0, maxLength - 1);
    }

    //Make sure we are ending the sentence correctly. And not splitting a word.
    while (
      finalText.length() > minLength &&
      finalText.substring(finalText.length() - 1, finalText.length()) != ' '
    ) {
      finalText = finalText.substring(0, finalText.length() - 1);
    }
    return finalText;
  }
}
