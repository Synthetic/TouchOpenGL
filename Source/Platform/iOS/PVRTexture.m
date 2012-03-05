

#import "PVRTexture.h"

static char gPVRTexIdentifier[4] = "PVR!";

enum {
	kPVRTextureFlagTypePVRTC_2 = 24,
	kPVRTextureFlagTypePVRTC_4
};

typedef struct _PVRTexHeader {
	uint32_t headerLength;
	uint32_t height;
	uint32_t width;
	uint32_t numMipmaps;
	uint32_t flags;
	uint32_t dataLength;
	uint32_t bpp;
	uint32_t bitmaskRed;
	uint32_t bitmaskGreen;
	uint32_t bitmaskBlue;
	uint32_t bitmaskAlpha;
	uint32_t pvrTag;
	uint32_t numSurfs;
} PVRTexHeader;


#pragma mark -

@interface PVRTexture ()

@property (readwrite, nonatomic, assign) GLuint name;

+ (BOOL)unpackPVRData:(NSData *)inData LODData:(NSArray **)outLODData size:(SIntSize *)outSize internalFormat:(GLuint *)outInternalFormat hasAlpha:(BOOL *)outHasAlpha;
+ (BOOL)createGLTexture:(NSArray *)inLODData size:(SIntSize)inSize name:(GLuint *)outName internalFormat:(GLuint)inInternalFormat;

@end

#pragma mark -

@implementation PVRTexture

+ (id)textureWithContentsOfURL:(NSURL *)inURL error:(NSError **)outError
	{
	return([[self alloc] initWithContentsOfURL:inURL error:outError]);
	}

#pragma mark -

- (id)initWithContentsOfURL:(NSURL *)inURL error:(NSError **)outError
	{
	NSData *theData = [NSData dataWithContentsOfURL:inURL];
	if (theData == NULL)
		{
		self = NULL;
		return(self);
		}
		
//		_internalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
		
	NSArray *theLODData = NULL;
	SIntSize theSize;
	GLuint theInternalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
	BOOL theHasAlpha;
	[PVRTexture unpackPVRData:theData LODData:&theLODData size:&theSize internalFormat:&theInternalFormat hasAlpha:&theHasAlpha];
	
	
	GLuint theName;
	[PVRTexture createGLTexture:theLODData size:theSize name:&theName internalFormat:theInternalFormat];



	if ((self = [self initWithName:theName target:GL_TEXTURE_2D size:theSize owns:YES]) != NULL)
		{
		}	
	return(self);
	}

+ (BOOL)unpackPVRData:(NSData *)inData LODData:(NSArray **)outLODData size:(SIntSize *)outSize internalFormat:(GLuint *)outInternalFormat hasAlpha:(BOOL *)outHasAlpha
	{
	BOOL success = FALSE;
	PVRTexHeader *header = NULL;
	uint32_t flags, pvrTag;
	uint32_t dataLength = 0, dataOffset = 0, dataSize = 0;
	uint32_t blockSize = 0, widthBlocks = 0, heightBlocks = 0;
	uint32_t width = 0, height = 0, bpp = 4;
	uint8_t *bytes = NULL;
	uint32_t formatFlags;
	
	header = (PVRTexHeader *)[inData bytes];
	
	pvrTag = CFSwapInt32LittleToHost(header->pvrTag);

	if (gPVRTexIdentifier[0] != ((pvrTag >>  0) & 0xff) ||
		gPVRTexIdentifier[1] != ((pvrTag >>  8) & 0xff) ||
		gPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
		gPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xff))
	{
		return FALSE;
	}
	
	flags = CFSwapInt32LittleToHost(header->flags);
	formatFlags = flags & 0xFF;
	
	NSMutableArray *theLODData = [NSMutableArray array];
	
	if (formatFlags == kPVRTextureFlagTypePVRTC_4 || formatFlags == kPVRTextureFlagTypePVRTC_2)
	{
		if (formatFlags == kPVRTextureFlagTypePVRTC_4)
			*outInternalFormat = GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG;
		else if (formatFlags == kPVRTextureFlagTypePVRTC_2)
			*outInternalFormat = GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG;
	
	
	
		width = CFSwapInt32LittleToHost(header->width);
		height = CFSwapInt32LittleToHost(header->height);
		*outSize = (SIntSize){ width, height };
		
		if (CFSwapInt32LittleToHost(header->bitmaskAlpha))
			*outHasAlpha = TRUE;
		else
			*outHasAlpha = FALSE;
		
		dataLength = CFSwapInt32LittleToHost(header->dataLength);
		
		bytes = ((uint8_t *)[inData bytes]) + sizeof(PVRTexHeader);
		
		// Calculate the data size for each texture level and respect the minimum number of blocks
		while (dataOffset < dataLength)
		{
			if (formatFlags == kPVRTextureFlagTypePVRTC_4)
			{
				blockSize = 4 * 4; // Pixel by pixel block size for 4bpp
				widthBlocks = width / 4;
				heightBlocks = height / 4;
				bpp = 4;
			}
			else
			{
				blockSize = 8 * 4; // Pixel by pixel block size for 2bpp
				widthBlocks = width / 8;
				heightBlocks = height / 4;
				bpp = 2;
			}
			
			// Clamp to minimum number of blocks
			if (widthBlocks < 2)
				widthBlocks = 2;
			if (heightBlocks < 2)
				heightBlocks = 2;

			dataSize = widthBlocks * heightBlocks * ((blockSize  * bpp) / 8);
			
			[theLODData addObject:[NSData dataWithBytes:bytes+dataOffset length:dataSize]];
			
			dataOffset += dataSize;
			
			width = MAX(width >> 1, 1);
			height = MAX(height >> 1, 1);
		}
				  
		success = TRUE;
	}
	
	*outLODData = theLODData;
	
	return success;
}


+ (BOOL)createGLTexture:(NSArray *)inLODData size:(SIntSize)inSize name:(GLuint *)outName internalFormat:(GLuint)inInternalFormat
{
	int width = inSize.width;
	int height = inSize.height;
	NSData *data;
	GLenum err;
	
	if ([inLODData count] > 0)
		{
		GLuint theName;
		glGenTextures(1, &theName);
		glBindTexture(GL_TEXTURE_2D, theName);
		*outName = theName;
		}
	
	if ([inLODData count] > 1)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	else
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	
	for (int i=0; i < [inLODData count]; i++)
	{
		data = [inLODData objectAtIndex:i];
		glCompressedTexImage2D(GL_TEXTURE_2D, i, inInternalFormat, width, height, 0, [data length], [data bytes]);
		
		err = glGetError();
		if (err != GL_NO_ERROR)
		{
			NSLog(@"Error uploading compressed texture level: %d. glError: 0x%04X", i, err);
			return FALSE;
		}
		
		width = MAX(width >> 1, 1);
		height = MAX(height >> 1, 1);
	}
	
	
	return TRUE;
}


@end
