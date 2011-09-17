#!/usr/bin/env python

import logging
import optparse
import os
import pkg_resources
import sys
import tempfile

from SLOBGen import Generator

logging.basicConfig(level = logging.DEBUG, format = '%(message)s', stream = sys.stderr)
logger = logging.getLogger()

def main(args):
    def store_open_file(option, opt_str, value, parser, *args, **kwargs):
        if value == '-':
            theFile = option.default
        else:
            theFile = file(value, kwargs['mode'])
        setattr(parser.values, option.dest, theFile)

    theUsage = '''%prog [options] [INPUT]'''
    theVersion = '%prog 0.1.12dev'

    ####################################################################

    theDefaultTemplateDirectory = pkg_resources.resource_filename('SLOBGen', 'templates')

    parser = optparse.OptionParser(usage=theUsage, version=theVersion)
    parser.add_option('-i', '--input', action='store', dest='input', type='string', metavar='INPUT',
        help='TODO.')
    parser.add_option('-o', '--output', action='store', dest='output', type='string', default = '', metavar='OUTPUT',
        help='Output directory for generated files.')
    parser.add_option('-t', '--template', action='store', dest='template', type='string', default = theDefaultTemplateDirectory, metavar='TEMPLATE',
        help='Directory containing templates (default: \'%s\'' % theDefaultTemplateDirectory)
#   parser.add_option('-c', '--config', action='store', dest='config', type='string', metavar='CONFIG',
#       help='Path to config plist file (values will be passed to template engine as a dictionary)')
    parser.add_option('-v', '--verbose', action='store_const', dest='loglevel', const=logging.INFO, default=logging.WARNING,
        help='set the log level to INFO')
    parser.add_option('', '--loglevel', action='store', dest='loglevel', type='int',
        help='set the log level, 0 = no log, 10+ = level of logging')
    parser.add_option('', '--logfile', action='callback', dest='logstream', type='string', default = sys.stderr, callback=store_open_file, callback_kwargs = {'mode':'w'}, metavar='LOG_FILE',
        help='File to log messages to. If - or not provided then stdout is used.')

    (theOptions, theArguments) = parser.parse_args(args = args[1:])

    for theHandler in logger.handlers:
        logger.removeHandler(theHandler)

    logger.setLevel(theOptions.loglevel)
    theHandler = logging.StreamHandler(theOptions.logstream)
    logger.addHandler(theHandler)

    ####################################################################

    logger.debug(theOptions)
    logger.debug(theArguments)

    if theOptions.input == None and len(theArguments) > 0:
        theOptions.input = theArguments.pop(0)

    g = Generator()
    g.input = theOptions.input
    g.output = theOptions.output
    g.template = theOptions.template
    g.logger = logger
    
    
    g.generate()    
    

if __name__ == '__main__':
    main(['emogenerator', '-v'])
