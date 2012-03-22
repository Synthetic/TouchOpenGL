#!/bin/sh

rm Source/*

SLOBGen Shaders/BlitTexture.fsh Shaders/Default.vsh --class CBlitProgram --output Source
SLOBGen Shaders/BlitTextureRectangle.fsh Shaders/Default.vsh --class CBlitRectangleProgram --output Source
SLOBGen Shaders/Blur.fsh Shaders/Default.vsh --class CBlurProgram --output Source
SLOBGen Shaders/CompositeTexture.fsh Shaders/Default.vsh --class CCompositeProgram --output Source
SLOBGen Shaders/ChannelLookup.fsh Shaders/Default.vsh --class CChannelLookupProgram --output Source
