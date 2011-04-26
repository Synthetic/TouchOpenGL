#!/usr/bin/env python

import argparse # argparse was added in Python 3.2 - for earlier Pythons just install it manually (easy_install argparse)
import collections
import glob
import hashlib
import logging
import numpy
import os
import biplist
import plistlib
import pprint
import re
import shlex
import shutil
import sys
import types
import os
import Image
import math

from itertools import izip_longest

########################################################################

logging.basicConfig(level = logging.DEBUG, format = '%(message)s', stream = sys.stderr)
logger = logging.getLogger()

########################################################################

def convert_image(inputPath, outputDirectory, dimension = 2048):

    theImage = Image.open(inputPath)

    theNewSize = int(min(2 ** math.ceil(math.log(max(theImage.size), 2)), dimension))
    theNewSize = (theNewSize, theNewSize)

    if theImage.mode != 'RGB':
        theImage = theImage.convert('RGBA')

    if theImage.size != theNewSize:
        theImage = theImage.resize(theNewSize, resample = Image.ANTIALIAS)

    theName, e = os.path.splitext(os.path.split(inputPath)[1])
    theName += '.png'
    f = os.path.join(outputDirectory, theName)
    theImage.save(f)
    return theName

########################################################################

def grouper(n, iterable, padvalue=None):
    "grouper(3, 'abcdefg', 'x') --> ('a','b','c'), ('d','e','f'), ('g','x','x')"
    return izip_longest(*[iter(iterable)]*n, fillvalue=padvalue)

def grouper_nopad(n, iterable):
    "grouper(3, 'abcdefg', 'x') --> ('a','b','c'), ('d','e','f'), ('g','x','x')"
    return izip_longest(*[iter(iterable)]*n)

def iter_flatten(iterable):
    it = iter(iterable)
    for e in it:
        if isinstance(e, (list, tuple)):
            for f in iter_flatten(e):
                yield f
        else:
            yield e

########################################################################
#### INPUT
########################################################################

class Material(object):
    def __init__(self, name = None):
        self.name = name
        self.ambientColor = None #(0.2, 0.2, 0.2)
        self.diffuseColor = None # (0.8, 0.8, 0.8)
        self.specularColor = None #(1.0, 1.0, 1.0)
        self.d = 1.0
        self.Ns = 0.0
        self.illum = 2
        self.map_Ka = None
        self.texture = None

    def __repr__(self):
        return('Material (%s)' % (self.name))

########################################################################

class Surface(object):
    pass

########################################################################

class Face(object):
    def __init__(self):
        self.material = None
        self.vertexIndices = [None, None, None]
        self.normalIndices = [None, None, None]
        self.texCoordIndices = [None, None]

    def __repr__(self):
        return('Face (%s, %s, %s, %s)' % (self.material, self.vertexIndices, self.normalIndices, self.texCoordIndices))

########################################################################

class MTLParser(object):
    def __init__(self, fp):
        theLines = fp.readlines()
        theLines = [theLine for theLine in theLines]
        theLines = [theLine.strip() for theLine in theLines]
        theLines = [theLine for theLine in theLines if len(theLine) > 0]
        theLines = [theLine for theLine in theLines if not re.match('^#.*$', theLine)]

        theCurrentMaterial = Material('default')

        theMaterials = dict()

        for theLine in theLines:
            theMatch = re.match('^([A-Za-z_]+)( +(.*))? *$', theLine)
            if not theMatch:
                logging.error('Error line: \"%s\"' % theLine)
                raise Exception('Parse error')
            theVerb, theParameters = theMatch.groups()[0], theMatch.groups()[2]
            if theVerb == 'newmtl':
                theCurrentMaterial = Material(theParameters)
                theMaterials[theCurrentMaterial.name] = theCurrentMaterial
            elif theVerb == 'Ka':
                theCurrentMaterial.ambientColor = [float(x) for x in re.split(' +', theParameters)]
            elif theVerb == 'Kd':
                theCurrentMaterial.diffuseColor = [float(x) for x in re.split(' +', theParameters)]
            elif theVerb == 'Ks':
                theCurrentMaterial.specularColor = [float(x) for x in re.split(' +', theParameters)]
            elif theVerb == 'd':
                theCurrentMaterial.d = float(theParameters)
            elif theVerb == 'Ns':
                theCurrentMaterial.d = float(theParameters)
            elif theVerb == 'illum':
                theCurrentMaterial.d = int(theParameters)
            elif theVerb == 'map_Ka':
                theCurrentMaterial.map_Ka = theParameters
            elif theVerb == 'map_Kd':
                theCurrentMaterial.texture = theParameters
            else:
                logging.warning('Unknown verb: %s' % theLine)

        self.materials = theMaterials

########################################################################

class OBJParser(object):

    def parse(self, inputFile):
        self.inputFile = inputFile

        self.currentMaterialLibrary = None
        self.currentGroups = None
        self.currentMaterial = Material('default')

        self.positions = []
        self.texCoords = []
        self.normals = []

        self.faces = []

        theLines = [theLine for theLine in inputFile.readlines()]
        theLines = [theLine.strip() for theLine in theLines]
        theLines = [theLine for theLine in theLines if len(theLine) > 0]

        for theLine in theLines:
            self.parseLine(theLine)

        return self

    def parseLine(self, line):
        theMatch = re.match('^#.*$', line)
        if theMatch:
            return

        theMatch = re.match('^([A-Za-z_]+)( +(.*))? *$', line)
        if not theMatch:
            logging.error('Error line: \"%s\"' % line)
            raise Exception('Parse error')
        theVerb, theParameters = theMatch.groups()[0], theMatch.groups()[2]

        try:
            if theVerb == 'mtllib':
                thePath = os.path.join(os.path.split(self.inputFile.name)[0], theParameters)
                if not os.path.exists(thePath):
                    logging.warning('Warning: no MTL file')
                else:
                    theMaterialFile = file(thePath)
                    theParser = MTLParser(theMaterialFile)
                    self.currentMaterialLibrary = theParser.materials
            elif theVerb == 'usemtl':
                if self.currentMaterialLibrary:
                    self.currentMaterial = self.currentMaterialLibrary[theParameters]
            elif theVerb == 'v':
                self.positions.append(tuple([float(x) for x in re.split(' +', theParameters)]))
            elif theVerb == 'vt':
                self.texCoords.append(tuple([float(x) for x in re.split(' +', theParameters)]))
            elif theVerb == 'vn':
                self.normals.append(tuple([float(x) for x in re.split(' +', theParameters)]))
            elif theVerb == 'f':
                theVertices = []
                theVertexIndices = re.split(' +', theParameters)

                if len(theVertexIndices) == 4:

                    theVertices = self.parseVertices([theVertexIndices[0], theVertexIndices[1], theVertexIndices[2]])
                    theFace = self.makeFace(theVertices)
                    self.faces.append(theFace)

                    theVertices = self.parseVertices([theVertexIndices[1], theVertexIndices[2], theVertexIndices[3]])
                    theFace = self.makeFace(theVertices)
                    self.faces.append(theFace)


                elif len(theVertexIndices) == 3:
                    theVertices = self.parseVertices(theVertexIndices)
                    theFace = self.makeFace(theVertices)
                    self.faces.append(theFace)

                else:
                    raise Exception('Wrong number (%d) of faces: %s' % (len(theVertexIndices), line))
            else:
                logging.warning('Unknown verb: %s' % line)

        except:
            logging.error('Failed on line:')
            logging.error(line)
            raise

    def parseVertices(self, vertexIndices):
        theVertices = []
        for theVertex in vertexIndices:
            theIndices = theVertex.split('/')
            theIndices[len(theIndices):] = [None, None, None][:3 - len(theIndices)]
            thePositionsIndex, theTexCoordIndex, theNormalsIndex = theIndices
            thePositionsIndex = (int(thePositionsIndex) - 1) if thePositionsIndex else None
            theTexCoordIndex = (int(theTexCoordIndex) - 1) if theTexCoordIndex else None
            theNormalsIndex = (int(theNormalsIndex) - 1) if theNormalsIndex else None

            theIndices = (thePositionsIndex, theTexCoordIndex, theNormalsIndex)

            theVertices.append(theIndices)
        return theVertices

    def makeFace(self, vertices):
        theFace = Face()
        theFace.material = self.currentMaterial
        theFace.vertexIndices = [x[0] for x in vertices]
        theFace.texCoordIndices = [x[1] for x in vertices]
        theFace.normalIndices = [x[2] for x in vertices]

        theFace.positions = [self.positions[i] for i in theFace.vertexIndices]
        theFace.texCoords = [self.texCoords[i] for i in theFace.texCoordIndices if i]
        theFace.normals = [self.normals[i] for i in theFace.normalIndices if i]

        return theFace

########################################################################
#### OUTPUT
########################################################################

class VBO(object):
    def __init__(self, array):
        self.array = array
        self._buffer = None
        self._signature = None

    @property
    def buffer(self):
        if not self._buffer:
            self._buffer = numpy.getbuffer(self.array)
        return self._buffer

    @property
    def signature(self):
        if not self._signature:
            self._signature = hashlib.md5(self.buffer)
        return self._signature

    def write(self, path):
        f = file(os.path.join(path, '%s.vbo' % self.signature.hexdigest()), 'w')
        f.write(self.buffer)

class MeshWriter(object):

    def write(self, faces, input, outputDirectory):

        inputRoot = os.path.split(input.name)[0]

        ################################################################

        d = {
            'buffers': {},
            'geometries': [],
            'materials': {},
            }

        faces.sort(key = lambda X:X.material)

        logging.info('%d faces found' % len(faces))

        #### Group Faces by material ################################
        theFacesByMaterial = collections.defaultdict(list)
        for p in faces:
            theFacesByMaterial[p.material].append(p)

        #### Produce Bounding Box ######################################
        theMin = [None, None, None]
        theMax = [None, None, None]
        for theMaterial in theFacesByMaterial:
            theFaces = theFacesByMaterial[theMaterial]
            for p in theFaces:
                for v in p.positions:
                    for n in xrange(0,3):
                        if not theMin[n]:
                            theMin[n] = v[n]
                        else:
                            theMin[n] = min(theMin[n], v[n])

                        if not theMax[n]:
                            theMax[n] = v[n]
                        else:
                            theMax[n] = max(theMax[n], v[n])
            theCenter = [(theMin[N] + theMax[N]) * 0.5 for N in xrange(0, 3)]

#         theTransform = [
#             [1, 0, 0, 0],
#             [0, 1, 0, 0],
#             [0, 0, 1, 0],
#             [theCenter[0], theCenter[1], theCenter[2], 1],
#             ]
#         d['transform'] = theTransform

        d['center'] = theCenter
        d['boundingbox'] = [theMin, theMax]

        #### Process materials #########################################
        for theMaterial in theFacesByMaterial:
            m = dict()
            if theMaterial:
                if theMaterial.ambientColor:
                    m['ambientColor'] = theMaterial.ambientColor
                if theMaterial.diffuseColor:
                    m['diffuseColor'] = theMaterial.diffuseColor
                if theMaterial.specularColor:
                    m['specularColor'] = theMaterial.specularColor
                if theMaterial.d or theMaterial.Tr:
                    m['alpha'] = theMaterial.d if theMaterial.d else theMaterial.Tr
                if theMaterial.texture:

                    theInputPath = os.path.join(inputRoot, theMaterial.texture)
                    theOutputPath = os.path.join(outputDirectory, os.path.split(theMaterial.texture)[1])

                    if os.path.exists(theOutputPath):
                        logging.warning('Warning: file might exist already at path: %s' % theOutputPath)
                        theName = os.path.split(theOutputPath)[1]
                    else:
                        theName = convert_image(theInputPath, os.path.split(theOutputPath)[0])

                    m['texture'] = theName


                d['materials'][theMaterial.name] = m

        #### Process meshes ############################################
        for theMaterial, theFaces in theFacesByMaterial.items():

            theHasTextureFlag = True if theMaterial.texture else False

            for theSubFaces in grouper(10920, theFaces):
                theVertices = []

                theSubFaces = [theFace for theFace in theSubFaces if theFace]

                for theFace in theSubFaces:
                    # TODO assumes triangles`
                    for N in xrange(0, 3):
                        theVertexBuffer = []
                        theVertexBuffer.append(list(theFace.positions[N]))
                        theVertexBuffer.append(list(theFace.normals[N] if N < len(theFace.normals) else (0.0, 0.0, 0.0)))
                        if theHasTextureFlag:
                            theVertexBuffer.append(list(theFace.texCoords[N] if N < len(theFace.texCoords) else (0.0,0.0)))
                        theVertices.append(theVertexBuffer)

                theBuffer = list(iter_flatten(theVertices))
                theBuffer = numpy.array(theBuffer, dtype=numpy.float32)
                theBuffer = VBO(theBuffer)
                theBuffer.write(outputDirectory)

                d['buffers'][theBuffer.signature.hexdigest()] = dict(target = 'GL_ARRAY_BUFFER', usage = 'GL_STATIC_DRAW', href = '%s.vbo' % (theBuffer.signature.hexdigest()))

                theStride = 3 + 3
                if theHasTextureFlag:
                    theStride += 2

                theStride *= 4

                thePositions = dict(
                    buffer = theBuffer.signature.hexdigest(),
                    size = 3,
                    type = 'GL_FLOAT',
                    normalized = False,
                    offset = 0,
                    stride = theStride,
                    )

                theNormals = dict(
                    buffer = theBuffer.signature.hexdigest(),
                    size = 3,
                    type = 'GL_FLOAT',
                    normalized = False,
                    offset = 3 * 4, # TODO hack
                    stride = theStride
                    )

                if theHasTextureFlag:
                    theTexCoords = dict(
                        buffer = theBuffer.signature.hexdigest(),
                        size = 2,
                        type = 'GL_FLOAT',
                        normalized = False,
                        offset = 6 * 4, # TODO hack
                        stride = theStride
                        )

                #### Produce Indices buffer ############################

                theBuffer = numpy.array(xrange(0,len(theVertices)), dtype=numpy.uint16)
                theBuffer = VBO(theBuffer)
                theBuffer.write(outputDirectory)

                d['buffers'][theBuffer.signature.hexdigest()] = dict(target = 'GL_ELEMENT_ARRAY_BUFFER', usage = 'GL_STATIC_DRAW', href = '%s.vbo' % (theBuffer.signature.hexdigest()))

                theIndices = dict(
                    buffer = theBuffer.signature.hexdigest(),
                    size = 1,
                    type = 'GL_SHORT',
                    normalized = False,
                    )

                ########################################################

                theGeometry = dict(
                    indices = theIndices,
                    positions = thePositions,
                    normals = theNormals,
                    material = theMaterial.name,
                    triangle_count = len(theSubFaces) / 3,
                    shader = 'default',
                    )

                if theHasTextureFlag:
                    theGeometry['texCoords'] = theTexCoords

                d['geometries'].append(theGeometry)

        d['cullBackFaces'] = True
#        d['programName'] = ''

        theName = os.path.splitext(os.path.split(input.name)[1])[0]

        biplist.writePlist(d, os.path.join(outputDirectory, theName + '.model.plist'))


########################################################################
#### COMMAND LINE TOOL
########################################################################

class Tool(object):
    @property
    def argparser(self):
        if not hasattr(self, '_argparser'):
            argparser = argparse.ArgumentParser()
            argparser.add_argument('-i', '--input', action='store', dest='input', type=argparse.FileType(), default = None, metavar='INPUT',
                help='The input file (type is inferred by file extension).')
            argparser.add_argument('-o', '--output', action='store', dest='output', type=unicode, default = None, metavar='OUTPUT',
                help='Output directory for generated files.')
#             argparser.add_argument('--output-type', action='store', dest='output_type', type=str, metavar='INPUT_TYPE',
#                 help='The output file type (overides file extension if any).')

            argparser.add_argument('-v', '--verbose', action='store_const', dest='loglevel', const=logging.INFO, default=logging.WARNING,
                help='set the log level to INFO')
            argparser.add_argument('--loglevel', action='store', dest='loglevel', type=int,
                help='set the log level, 0 = no log, 10+ = level of logging')
            argparser.add_argument('--logfile', dest='logstream', type = argparse.FileType('w'), default = sys.stderr, action="store", metavar='LOG_FILE',
                help='File to log messages to. If - or not provided then stdout is used.')

            argparser.add_argument('args', nargs='*')
            self._argparser = argparser
        return self._argparser

    def parse(self):
        pass

    def main(self, args):

        self.options = self.argparser.parse_args(args = args)

        for theHandler in logger.handlers:
            logger.removeHandler(theHandler)

        logger.setLevel(logging.DEBUG)

        theHandler = logging.StreamHandler(self.options.logstream)
        logger.addHandler(theHandler)

        theParser = OBJParser()
        theParser.parse(self.options.input)

        theMeshWriter = MeshWriter()
        theMeshWriter.write(theParser.faces, self.options.input, self.options.output)

def main(args):
    Tool().main(args)

if __name__ == '__main__':

    theRootDir = os.path.split(sys.argv[0])[0]
    if theRootDir:
        os.chdir(theRootDir)

#   Tool().main(shlex.split('tool --input Input/Skull.obj --output Output/Skull.model.plist'))
    Tool().main(shlex.split('tool --input /Users/schwa/Dropbox/Projects/OpenGL/Samples/OBJ\\ Files/Untested/Liberty/Liberty.obj --output /Users/schwa/.Trash/Test.model.plist'))
