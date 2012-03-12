#!/bin/sh

rm Source/*

SLOBGen Shaders/BlitTexture.fsh Shaders/Default.vsh --class CBlitProgram --output Source
SLOBGen Shaders/BlitTextureRectangle.fsh Shaders/Default.vsh --class CBlitProgramRectangle --output Source
SLOBGen Shaders/Blur.fsh Shaders/Default.vsh --class CBlurProgram --output Source
