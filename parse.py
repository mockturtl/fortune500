#!/usr/bin/python
"""Multiline sed is tricky! It's easier to look at character sequences.

"""

import sys
import re

def main():
    """Parse the files to remove newline and tab characters."""
    
    sourcefiles = sys.argv[1]
    localDirectory = sys.argv[2] + "/"
    
    # construct a list of files to parse
    file = open(sourcefiles, "r")
    lines = file.readlines()
    webpages = []
    for i, line in enumerate(lines):
        line = line.strip()
        webpages.append(localDirectory + line)
    file.close()
    
    for filename in webpages:
        #print "Parsing file " + filename
        file = open(filename, "r")
        text = file.read()
        file.close()
        # whitespace in the HTML, value is indented
        text = re.sub(r'\<td class=\"cnncol4\"\>\s+', '<td class=\"cnncol4\">', text)
        text = text.replace("<td class=\"cnncol4\">\n\t\t\t\t\t\t", "<td class=\"cnncol4\">")
        # closing tag is indented
        text = text.replace("\n\t\t\t\t\t\t\n\t\t\t\t\t\t</td>", "</td>")
        file = open(filename, "w")
        file.write(text)
        file.close()
    
    
if __name__ == "__main__":
    main()
