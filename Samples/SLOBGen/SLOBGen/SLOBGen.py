#!/usr/bin/python

import plistlib
import genshi
import genshi.template

import os
import logging
import sys
import re
import glob

##########################################################################################

class MyString(str):
    @property
    def u(self):
        return self[0].upper() + self[1:]

##########################################################################################

def merge(inTemplate, inOriginal, inDelimiters):
    theComponents = []
    for theDelimiter in inDelimiters:
        ### Find delimited section in template
        theTemplateStart = inTemplate.find(theDelimiter[0])
        if not theTemplateStart:
            continue
        theTemplateStart += len(theDelimiter[0])
        theTemplateEnd = inTemplate.find(theDelimiter[1], theTemplateStart)
        if not theTemplateEnd:
            continue

        ### Find delimited section in original
        theOriginalStart = inOriginal.find(theDelimiter[0])
        if not theOriginalStart:
            continue
        theOriginalStart += len(theDelimiter[0])
        theOriginalEnd = inOriginal.find(theDelimiter[1], theOriginalStart)
        if not theOriginalEnd:
            continue

        inOriginal = inOriginal[:theOriginalStart] + inTemplate[theTemplateStart:theTemplateEnd] + inOriginal[theOriginalEnd:]

    return inOriginal

##########################################################################################

class Generator(object):

    def __init__(self):
        self.input = None
        self.template = None
        self.output = None
        self.classPrefix = 'C'
        self.classSuffix = 'Program'
        self.logger = logging.getLogger()

    def generate(self):
        # If we don't have an input file lets try and find one in the cwd
        if self.input == None:
            files = glob.glob('*.plist')
            if files:
                self.input = files[0]
        if self.input == None:
            raise Exception('Could not find any input files.')

        # If we still don't have an input file we need to bail.
        if not os.path.exists(self.input):
            raise Exception('Input file doesnt exist at %s' % self.input)

        self.input_type = os.path.splitext(self.input)[1][1:]
        if self.input_type not in ['plist']:
            raise Exception('Input file is not a .plist. Why are you trying to trick me?')

        # No? Ok, let's fall back to the cwd
        if self.template == None:
            self.template = 'templates'

#         self.logger.info('Using input file \'%s\'', self.input)
#         self.logger.info('Using output directory \'%s\'', self.output)
#         self.logger.info('Using template directory \'%s\'', self.template)

        # Start up genshi..
        theLoader = genshi.template.TemplateLoader(self.template)

        theTypeTable = {
            ('mat4',None): {
                'propertyType': 'Matrix4',
                'setter': 'glUniformMatrix4fv(${uniform.propertyName}Uniform, 1, NO, &${uniform.propertyName}.m[0][0]);',
                'initialValue': 'Matrix4Identity',
                'ownership': 'assign',
                },
            ('vec4',None): {
                'propertyType': 'Vector4',
                'setter': 'glUniform4fv(${uniform.propertyName}Uniform, 1, &${uniform.propertyName}.x);',
                'initialValue': '{}',
                'ownership': 'assign',
                },
            ('vec4','Color'): {
                'propertyType': 'Color4f',
                'setter': 'glUniform4fv(${uniform.propertyName}Uniform, 1, &${uniform.propertyName}.r);',
                'initialValue': '(Color4f){ 1.0, 1.0, 1.0, 1.0 }',
                'ownership': 'assign',
                },
            ('int',None): {
                'propertyType': 'int',
                'setter': 'glUniform1i(${uniform.propertyName}Uniform, ${uniform.propertyName});',
                'initialValue': '0',
                'ownership': 'assign',
                },
            ('sampler2D',None): {
                'propertyType': 'CTexture *',
                'setter': '[${uniform.propertyName} use:${uniform.propertyName}Uniform]',
                'initialValue': 'NULL',
                'ownership': 'strong',
                },
            }

        uniforms = []

        theProgramSpecification = plistlib.readPlist(self.input)

        theKlassName = self.classPrefix + theProgramSpecification['name'] + self.classSuffix

        for theUniform in theProgramSpecification['uniforms']:
            d = dict()
            theUniform['intent'] = theUniform['intent'] if 'intent' in theUniform else None
            d.update(theTypeTable[(theUniform['type'], theUniform['intent'])])
            d['GLSLName'] = theUniform['name']
            d['propertyName'] = MyString(theUniform['propertyName'])

            # this is a bit of a hack
            d['setter'] = d['setter'].replace('${uniform.propertyName}', theUniform['propertyName'])

            uniforms.append(d)

        attributes = []
        for theAttribute in theProgramSpecification['attributes']:
            d = dict()
            d['propertyName'] = MyString(theAttribute['propertyName'])

            attributes.append(d)

        theContext = {
            'klass': { 'name': theKlassName },
            'uniforms': uniforms,
            'attributes': attributes,
            }

        theTemplateNames = ['classname.h.genshi', 'classname.m.genshi']
        for theTemplateName in theTemplateNames:
            theTemplate = theLoader.load(theTemplateName, cls=genshi.template.NewTextTemplate)

            theTemplate = theLoader.load(theTemplateName, cls=genshi.template.NewTextTemplate)

            theStream = theTemplate.generate(**theContext)
            theNewContent = theStream.render()

            theFilename = theKlassName + '.' + re.match(r'.+\.(.+)\.genshi', theTemplateName).group(1)

            theOutputPath = os.path.join(self.output, theFilename)

            file(theOutputPath, 'w').write(theNewContent)

#             if os.path.exists(theOutputPath) == False:
#                 file(theOutputPath, 'w').write(theNewContent)
#             else:
#                 theCurrentContent = file(theOutputPath).read()
#                 theNewContent = merge(theNewContent, theCurrentContent, [
#                     ('#pragma mark begin emogenerator accessors', '#pragma mark end emogenerator accessors'),
#                     ('#pragma mark begin emogenerator forward declarations', '#pragma mark end emogenerator forward declarations'),
#                     ])
#                 if theNewContent != theCurrentContent:
#                     file(theOutputPath, 'w').write(theNewContent)

if __name__ == '__main__':
    g = Generator()
    g.input = '/Users/schwa/Development/Source/Git/github_touchcode_public/TouchOpenGL/Resources/Shaders/Flat.program.plist'
    g.output = '/Users/schwa/Desktop'
    g.template = '/Users/schwa/Development/Source/Git/github_touchcode_public/TouchOpenGL/Samples///templates'

    g.generate()
