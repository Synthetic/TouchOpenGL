#!/usr/bin/python

import genshi
import genshi.template

import os
import logging
import sys
import re
import glob
import pprint
import yaml

import scanner

################################################################################

class MyString(str):
    @property
    def u(self):
        return self[0].upper() + self[1:]

################################################################################

class Generator(object):

    def __init__(self):
        self.input = None
        self.template = None
        self.output = None
        self.classPrefix = 'C'
        self.classSuffix = 'Program'
        self.logger = logging.getLogger()

    def generate(self):

        self.definitions = []

        for theShader in self.shaders:

            theString = file(theShader).read()
            theScanner = scanner.scanner(theString)

            theDefinitions = []
            while theScanner.more:
                theScanner.scan_upto_string('//')
                if theScanner.scan_string('//@'):
                    theDefinitions.append(theScanner.current_line)
                    theScanner.scan_upto_string('\n')
                elif theScanner.scan_string('//'):
                    pass

            thePattern = re.compile('^(?P<glsl_storage>uniform|attribute|in|out) (?P<glsl_type>.+) (?P<glsl_name>.+); //@ (?P<meta>.+)')

            for theDefinition in theDefinitions:
                theDefinition = thePattern.match(theDefinition).groupdict()
                theDefinition.update(dict([x.strip().split(':') for x in theDefinition['meta'].split(',')]))
                del theDefinition['meta']
                self.definitions.append(theDefinition)

        ########################################################################

        self.uniforms = {}
        self.attributes = {}

        for theDefinition in self.definitions:
            theName = theDefinition['glsl_name']
            if theDefinition['glsl_storage'] == 'uniform':
                if theName in self.uniforms:
                    raise Exception('Already a uniform with that name!')
                self.uniforms[theName] = theDefinition
            elif theDefinition['glsl_storage'] in ('attribute', 'in', 'out'):
                if theName in self.attributes:
                    raise Exception('Already an attribute with that name!')
                self.attributes[theName] = theDefinition

        ########################################################################

        if self.template == None:
            self.template = 'templates'

        # Start up genshi..
        theLoader = genshi.template.TemplateLoader(self.template)

        ########################################################################

        if self.recipe == None:
            self.recipe = 'recipe.yaml'
        theTypeTable = yaml.load(file(self.recipe, 'r').read())

        ########################################################################

        theKlassName = self.klass

        theTextureUnitIndex = 0

        uniforms = []
        for theUniform in self.uniforms.values():
            d = dict()
            theKey = theUniform['glsl_type']
            if 'usage' in theUniform:
                theKey = '%s/%s' % (theKey, theUniform['usage'])
            d.update(theTypeTable[theKey])

            if 'usesTextureUnit' in d:
                d['textureUnitIndex'] = theTextureUnitIndex
                theTextureUnitIndex += 1
            else:
                d['usesTextureUnit'] = False


            d['GLSLName'] = theUniform['glsl_name']
            d['propertyName'] = MyString(theUniform['name'])
            d['ivarName'] = '_' + theUniform['name']

            # this is a bit of a hack
            d['setter'] = d['setter'].replace('${uniform.propertyName}', theUniform['name'])

            uniforms.append(d)

        attributes = []
        for theAttribute in self.attributes.values():
            d = dict()
            d['GLSLName'] = theAttribute['glsl_name']
            d['propertyName'] = MyString(theAttribute['name'])
            d['index'] = self.attributes.values().index(theAttribute)

            attributes.append(d)

        theContext = {
            'klass': { 'name': self.klass },
            'shaders': [os.path.split(p)[1] for p in self.shaders],
            'uniforms': uniforms,
            'attributes': attributes,
            }

        ########################################################################

        theTemplateNames = ['classname.h.genshi', 'classname.m.genshi']
        for theTemplateName in theTemplateNames:
            theTemplate = theLoader.load(theTemplateName, cls=genshi.template.NewTextTemplate)
            theStream = theTemplate.generate(**theContext)
            theNewContent = theStream.render()

            theFilename = theKlassName + '.' + re.match(r'.+\.(.+)\.genshi', theTemplateName).group(1)

            if not os.path.exists(self.output):
                os.makedirs(self.output)


            theOutputPath = os.path.join(self.output, theFilename)

            file(theOutputPath, 'w').write(theNewContent)


if __name__ == '__main__':
    g = Generator()
    g.klass = 'CBlitProgram'
    g.shaders = ['../Test/BlitTexture.fsh', '../Test/Default.vsh']
    g.output = '../Test'
    g.template = None
    g.recipe = None
    g.generate()
