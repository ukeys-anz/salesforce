# Table of Contents
- [APEX  Classes](#Apex-Classes)
  - [Rules for Naming](#Rules-for-Naming)
  - [Sequence](#an-apex-class-should-be-organized-in-a-sequence-as-shown-below)
  - [Class Headers](#Class-Headers)
  - [Method Headers](#Method-Headers)
  - [Exceptions](#Exceptions)
  - [Demonstrative Example](#Demonstrative-Example)
  
- [APEX Methods](#APEX-Methods)
  - [Rules for Naming](#Rules-for-Naming-1)
  - [Exceptions](#Exceptions-1)
  - [Demonstrative Example](#Demonstrative-Example-1)
  
- [APEX Variables](#APEX-Variables)
  - [Rules for Naming](#Rules-for-Naming-2)
  - [Demonstrative Example](#Demonstrative-Example-2)
  
- [APEX Constants](#APEX-Constants)
  - [Rules for Naming](#Rules-for-Naming-3)
  - [Demonstrative Example](#Demonstrative-Example-3)
<br>

# **APEX  Classes**

## Rules for Naming

 - Class names should be unique.

 - The words should be concatenated (should use Pascal Case).

 - Whole words should be used and use of acronyms and abbreviations
   should be limited (except for prefix and suffix).

 - Apex classes that are test classes should be suffixed with _TEST

 - Apex classes that are batch classes should be suffixed with _BATCH


## An Apex class should be organized in a sequence as shown below: ##

- instance variables
- private static variables (using static)
- private constants (using static final)
- unit header
- public class <class_name>
- public instance methods
	- getters / setters
	- instance methods
- protected instance methods
	- getters / setters
	- instance methods
- private instance methods
	- getters / setters
	- instance methods
- static methods
 

## Class Headers

Class headers should start with comments recognized by JavaDocs , similar to the format given below.
```javascript
/**
* ANZ Application Logger
* @author
* @date 2019
* @group Utilities
* @description Application Logger for Apex Code
*/
```
## Method Headers

Method headers should start with comments recognized by JavaDocs , similar to the format given below.
``` javascript
/**
*  Description of the purpose of the class the method.
*  @name <method-name>
*  @param <parameter-name> <description>
*  @return <parameter> - <Description about the return parameter>
*  @throws exception-<exception description>
*/
```

## Exceptions

- Widely used acronyms and abbreviations can be used instead of the long form. For example HTTP or URL or ACMA.


## Demonstrative Example

:thumbsdown: The following are examples of Apex class naming that should **`not`** be used

| Class Name  | Reason |
------------- | -------------
| `FHACustomer`  | Using acronyms should be avoided as they are not mnemonic |
| `GrtBgClass`  | Whole words should be used in place of shortened versions GreatBigClass |
| `addresshandler` | Class does not begin with an uppercase letter |
| `Address_Handler` | Underscores should be avoided |

<br>

:thumbsup: The following are examples of the naming convention that will be used

| Class Name | Reason |
------------- | -------------
| `Customer` | Full word used to describe the class and starts with uppercase |
| `AddressHandler` | Multiple words concatenated with subsequent words capitalised |

----------
<br>

# **APEX Methods**

## Rules for Naming

 - Methods should be verbs, in mixed case with the first letter lowercase, with the first letter of each internal word capitalized (Camel Case).

 - Whole words should be used and use of acronyms and abbreviations should be limited.

 - Methods should have a try-catch-finally block to handle possible exceptions. The try-catch block should appear at logical places where you are sure of an exception’s nature and its handling.

## Exceptions

- Widely used acronyms and abbreviations can be used instead of the long form. For example HTTP or URL or ACMA.


## Demonstrative Example

:thumbsdown: The following are examples of Apex method naming that should **`not`** be used

| Method Name  | Reason |
------------- | -------------
| `handleCalculation()`  | What is being handled?! |
| `performServices()`  | Perform what services? |
| `dealWithInput()`  | How exactly is the input being dealt with? |
| `NTInQ1()`  | Cannot determine from the name what the function does |

<br>

:thumbsup: The following are examples of the naming convention that will be used

| Method Name | Reason |
------------- | -------------
| `ammortisationCalculation()` | Describes what calculation is performed |
| `repaginateDocument()`  | Describes the service being performed |
| `getEmployeeDetail()`  | Describes what is being done |
| `numberOfTransactionsInQ1()`  | Longer names are better if they are needed for clarity |


----------
<br>

# **APEX Variables**

## Rules for Naming

 - Variables should be in mixed case with a lowercase first letter. Internal words start with capital letters (Camel Case). Variable names should be short yet meaningful.

 - The choice of a variable name should be mnemonic— that is, designed to indicate to the casual observer the intent of its use.

 - One-character variable names should be avoided except for temporary “throwaway” variables. Common names for temporary variables are i, j, k,m, and n for integers; c, d, and e for characters.


## Demonstrative Example

:thumbsdown: The following are examples of Apex variable naming that should **`not`** be used

| Variable Name  | Reason |
------------- | -------------
| `x = x – y`  | Variable names are ambiguous |

<br>

:thumbsup: The following are examples of the naming convention that will be used

| Variable Name | Reason |
------------- | -------------
| `currentBalance = lastBalance - LastPayment` | Unambiguous names that have a clear meaning |


----------
<br>

# **APEX Constants**

## Rules for Naming

 - The names of variables declared class constants should be all uppercase with words separated by underscores (“_”).


## Demonstrative Example

:thumbsdown: The following are examples of Apex constants naming that should **`not`** be used

| Variable Name  | Reason |
------------- | -------------
| `maxCharacters`  | Indistinguishable from a variable name |

<br>

:thumbsup: The following are examples of the naming convention that will be used

| Variable Name | Reason |
------------- | -------------
| `MAX_CHARACTERS` | Uppercase letters help the reviewer determine that it is a constant |
