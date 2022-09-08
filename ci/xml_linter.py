"""
Iterates through the deploy directory to identify .xml files that require linting, if
there is an error parsing the document to sort then an XMLSyntaxError is flagged
Author: Rebecca Jan
Date: 2022-08
"""
#import packages
import os
from lxml import etree
# set root and tnp directory
rootdir = os.getcwd()
x = rootdir + '/tmp/deploy'
# initialise log lists
lintedLog = []
errorLog = []

def sort_xml(xml_doc):
    """
    Helper function to sort xml
    Args:
        xml_doc (elementTree): the unlinted version of the file
    Returns:
        xml_doc (elementTree): the linted version of the file
    """
    # handle known type error for .xml's containing '<!--'
    known_error = "'<' not supported between instances of 'cython_function_or_method' and 'str'"
    # get namespace from doc
    name_space = xml_doc.nsmap
    # split out namespace tag and fullName tag so position is retained
    for parent in xml_doc.xpath('//*[./*]'):
        to_sort = (e for e in parent if e.tag !=
                   '{'+name_space[None]+'}fullName')
        non_sort = (e for e in parent if e.tag ==
                    '{'+name_space[None]+'}fullName')
        while True:
            try:
                # sort rest of doc
                parent[:] = list(non_sort) + sorted(to_sort, key=lambda e: e.tag)
            # handle known type error
            except TypeError as type_error:
                if str(type_error) == known_error:
                    break
            break
    return etree.ElementTree(xml_doc)

def check_xml(linted_file, unlinted_file):
    """
    Helper function to check sorted xml against the original file
    Args:
        linted_file (elementTree): the linted version of the file
        unlinted_file (elementTree): the unlinted version of the file
    Returns:
        Boolean: True if a diff in the xml is found, False if not
    """
    # if file has been sorted return true, else false
    return bool(etree.tostring(linted_file) != etree.tostring(unlinted_file))


def print_log(lint_log, error_log):
    """
    Helper function that raises an exception if parameters aren't empty
    Args:
        lint_log (list): a list of files that require linting
        error_log (list): a list of XMLSyntaxError's identified
    """
    exception_log = ''
    if lint_log:
        exception_log = 'The following files require linting: ' + ", ".join(lint_log) + "\n"
    if error_log:
        exception_log += 'The following files have XMLSyntaxError(s): ' + ", ".join(error_log)
    if lint_log or error_log:
        raise Exception(exception_log)

for subdir, dirs, files in os.walk(x):
    for file in files:
        nameOfFile = subdir + os.sep + file
        if nameOfFile.endswith(".xml"):
            data = open(nameOfFile, 'rb').read()
            while True:
                try:
                    temp = etree.XML(data, etree.XMLParser(
                        remove_blank_text=True))
                    doc = etree.XML(data, etree.XMLParser(
                        remove_blank_text=True))
                    newDoc = sort_xml(doc)
                    if check_xml(newDoc, temp):
                        lintedLog.append(file)
                except etree.XMLSyntaxError as xmlError:
                    errorLog.append(file + ': ' + str(xmlError))
                break
print_log(lintedLog, errorLog)
