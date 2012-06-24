#!/bin/sh

rm -rf Source/*

SLOBGen Shaders/BlitTexture.GL.fsh Shaders/Default.GL.vsh --class CBlitProgram --output Source
SLOBGen Shaders/BlitTextureRectangle.GL.fsh Shaders/Default.GL.vsh --class CBlitRectangleProgram --output Source
#SLOBGen Shaders/Blur.fsh Shaders/Default.GL.vsh --class CBlurProgram --output Source
#SLOBGen Shaders/CompositeTexture.GL.fsh Shaders/Default.GL.vsh --class CCompositeProgram --output Source

#SLOBGen Shaders/ChannelLookup.GL.fsh Shaders/Default.GL.vsh --class CChannelLookupProgram --output Source/OSX
# SLOBGen Shaders/ChannelLookup.GLES.fsh Shaders/Default.GLES.vsh --class CChannelLookupProgram --output Source/iOS

# SLOBGen Shaders/HSLAdjustment.GL.fsh Shaders/Default.GL.vsh --class CHSLAdjustmentProgram --output Source
# SLOBGen Shaders/Diff.GL.fsh Shaders/Default.GL.vsh --class CDiffProgram --output Source
