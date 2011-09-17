#!/usr/bin/python

import plistlib
import genshi
import genshi.template

class MyString(str):
    @property
    def u(self):
        return self[0].upper() + self[1:]
        
theTypeTable = {
    'mat4': {
        'propertyType': 'Matrix4',
        'setter': 'glUniformMatrix4fv(${uniform.propertyName}Uniform, 1, NO, &${uniform.propertyName}.m[0][0]);',
        'initialValue': 'Matrix4Identity'
        },
    }



theTemplateDirectoryPath = '/Users/schwa/Development/Source/Git/github_touchcode_public/TouchOpenGL/Samples/ProgramGenerator/templates'

theProgramSpecificationPath = '/Users/schwa/Development/Source/Git/github_touchcode_public/TouchOpenGL/Resources/Shaders/Flat.program.plist'

theProgramSpecification = plistlib.readPlist(theProgramSpecificationPath)

uniforms = []

for theUniform in theProgramSpecification['uniforms']:
    d = dict()
    d.update(theTypeTable[theUniform['type']])
    d['GLSLName'] = theUniform['name']
    d['propertyName'] = MyString(theUniform['propertyName'])

    # this is a bit of a hack
    d['setter'] = d['setter'].replace('${uniform.propertyName}', theUniform['propertyName'])

    uniforms.append(d)
    
    
    

theLoader = genshi.template.TemplateLoader(theTemplateDirectoryPath)

attributes = [
    {'propertyName': MyString('positions')},
    {'propertyName': MyString('colors')},
    ]

for theTemplateName in ['ProgramTemplate.m.genshi']:
    
    theTemplate = theLoader.load(theTemplateName, cls=genshi.template.NewTextTemplate)

    theContext = {
        'klass': { 'name': 'Flat' },
        'uniforms': uniforms,
        'attributes': attributes,
        }
    theStream = theTemplate.generate(**theContext)
    theNewContent = theStream.render()



    print theNewContent
