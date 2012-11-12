#!/usr/bin/python
"""Add numbers from a data file, one per line.

"""
import os

def main():
    """Sum the numerical amounts from properly-reformatted HTML."""
    
    file = open("profit.txt","r")
    profits = file.readlines()
    file = open("revenue.txt","r")
    revenues = file.readlines()
    file.close()
    
    totalProfits = 0
    for i in range(len(profits)):
        totalProfits += float(profits[i])
    
    print "Total Fortune 500 profits, " + os.environ['YEAR'] + ": $" + str(totalProfits) + "M"
    
    totalRevenues = 0
    for j in range(len(revenues)):
        totalRevenues += float(revenues[i])
    
    print "Total Fortune 500 revenues, " + os.environ['YEAR'] + ": $" + str(totalRevenues) + "M"

if __name__ == "__main__":
    main()
