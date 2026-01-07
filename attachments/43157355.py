'''
Created on 29/06/2011

@author: Michael
'''

class LogStripper(object):
    '''
    classdocs
    '''


    def __init__(selfparams):
        '''
        Constructor
        '''
        
    directoryPath = "C:\Atlantis\\"
    inputFileName = "log.txt"
    outputFileName = "log_stripped.txt"
    outputFileNameB = "log_stripped_B.txt"
    
    outputArray = []
    outputArrayB = []
    
    with open(directoryPath + inputFileName, 'r') as inputFile:
        for inputLine in inputFile:
            if "sn-" in inputLine:
                outputArray.append(inputLine)
            if "of virgin biomass" in inputLine:
                outputArrayB.append(inputLine)

    with open(directoryPath + outputFileName, 'w') as outputFile:
        for outputLine in outputArray:
            outputFile.write(outputLine)
            
    with open(directoryPath + outputFileNameB, 'w') as outputFileB:
        for outputLine in outputArrayB:
            outputFileB.write(outputLine)
            
    print "finished!"
        
        
