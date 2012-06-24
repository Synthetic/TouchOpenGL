#!/usr/bin/env python

import logging
import argparse
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

    theVersion = '0.1.12dev'

    ####################################################################

    theDefaultTemplateDirectory = pkg_resources.resource_filename('SLOBGen', 'templates')
    theRecipeFilePath = pkg_resources.resource_filename('SLOBGen', 'recipe.yaml')

    parser = argparse.ArgumentParser()

    parser.add_argument('shaders', metavar='SHADERS', type=str, nargs='+')

    parser.add_argument('-c', '--class', action='store', dest='klass', type=str, metavar='CLASS')
    parser.add_argument('-o', '--output', action='store', dest='output', type=str, metavar='OUTPUT_DIR')
    parser.add_argument('-t', '--template', action='store', dest='template', type=str, default = theDefaultTemplateDirectory, metavar='TEMPLATE',
        help='Directory containing templates (default: \'%s\'' % theDefaultTemplateDirectory)
    parser.add_argument('-r', '--recipe', action='store', dest='recipe', type=str, default = theRecipeFilePath, metavar='RECIPE',
        help='TODO (default: \'%s\'' % theDefaultTemplateDirectory)
    parser.add_argument('-v', '--verbose', action='store_const', dest='loglevel', const=logging.INFO, default=logging.WARNING,
        help='set the log level to INFO')

    theArguments = parser.parse_args(args)

    for theHandler in logger.handlers:
        logger.removeHandler(theHandler)

    logger.setLevel(theArguments.loglevel)
    logger.addHandler(theHandler)

    ####################################################################

    g = Generator()
    g.klass = theArguments.klass
    g.shaders = theArguments.shaders
    g.output = theArguments.output
    g.template = theArguments.template
    g.recipe = theArguments.recipe
    g.logger = logger
    g.generate()


if __name__ == '__main__':
    main('SLOBGen ../Test/BlitTexture.fsh ../Test/Default.vsh --class CTestProgram -o ../Test'.split(' ')[1:])
