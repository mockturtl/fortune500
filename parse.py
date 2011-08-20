#!/usr/bin/python
"""Multiline sed is tricky! It's easier to look at character sequences.

"""

def main():
    """Parse the files to remove newline and tab characters."""
    
    dir = "html/"
    suffix = ".html"
    filenames=["1_100", "101_200", "201_300", "301_400", "401_500"]
    
    for i, filename in enumerate(filenames):
        filenames[i] = dir + filename + suffix
    
    for filename in filenames:
        #print "Parsing file " + filename
        file = open(filename, "r")
        text = file.read()
        file.close()
        # whitespace in the HTML, value is indented
        text = text.replace("<td class=\"cnncol4\">\n\t\t\t\t\t\t", "<td class=\"cnncol4\">")
        # closing tag is indented
        text = text.replace("\n\t\t\t\t\t\t\n\t\t\t\t\t\t</td>", "</td>")
        file = open(filename, "w")
        file.write(text)
        file.close()
    
    
if __name__ == "__main__":
    main()
