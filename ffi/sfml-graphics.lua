--=================================--
-- 
-- LuaJIT/FFI wrapper for SFML 2.x
-- Author: Nathan Cousins
-- 
-- 
-- Released under the zlib/libpng license:
-- 
-- Copyright (c) 2014 Nathan Cousins
-- 
-- This software is provided 'as-is', without any express or implied warranty. In
-- no event will the authors be held liable for any damages arising from the use
-- of this software.
-- 
-- Permission is granted to anyone to use this software for any purpose, including
-- commercial applications, and to alter it and redistribute it freely, subject to
-- the following restrictions:
-- 
-- 1. The origin of this software must not be misrepresented; you must not claim 
--    that you wrote the original software. If you use this software in a product,
--    an acknowledgment in the product documentation would be appreciated but is
--    not required.
--
-- 2. Altered source versions must be plainly marked as such, and must not be
--    misrepresented as being the original software.
-- 
-- 3. This notice may not be removed or altered from any source distribution.
-- 
--=================================--

local ffi = require 'ffi';

local setmetatable = setmetatable;
local rawget = rawget;
local require = require;
local type = type;
--local tonumber = tonumber;

module 'sf';
require 'ffi/sfml-system';
require 'ffi/sfml-window';


local function newObj(cl, obj)
	local gc = rawget(cl, '__gc');
	if gc ~= nil then
		ffi.gc(obj, gc);
	end
	return obj;
end


local function bool(b)
	-- Convert sfBool to Lua boolean.
	return b ~= ffi.C.sfFalse;
end


ffi.cdef [[
typedef struct sfCircleShape sfCircleShape;
typedef struct sfConvexShape sfConvexShape;
typedef struct sfFont sfFont;
typedef struct sfImage sfImage;
typedef struct sfRectangleShape sfRectangleShape;
typedef struct sfRenderTexture sfRenderTexture;
typedef struct sfRenderWindow sfRenderWindow;
typedef struct sfShader sfShader;
typedef struct sfShape sfShape;
typedef struct sfSprite sfSprite;
typedef struct sfText sfText;
typedef struct sfTexture sfTexture;
typedef struct sfTransformable sfTransformable;
typedef struct sfVertexArray sfVertexArray;
typedef struct sfView sfView;

typedef enum 
{
    sfBlendAlpha,    ///< Pixel = Src * a + Dest * (1 - a)
    sfBlendAdd,      ///< Pixel = Src + Dest
    sfBlendMultiply, ///< Pixel = Src * Dest
    sfBlendNone      ///< No blending
} sfBlendMode;

typedef enum 
{
    sfPoints,         ///< List of individual points
    sfLines,          ///< List of individual lines
    sfLinesStrip,     ///< List of connected lines, a point uses the previous point to form a line
    sfTriangles,      ///< List of individual triangles
    sfTrianglesStrip, ///< List of connected triangles, a point uses the two previous points to form a triangle
    sfTrianglesFan,   ///< List of connected triangles, a point uses the common center and the previous point to form a triangle
    sfQuads           ///< List of individual quads
} sfPrimitiveType;

typedef enum
{
    sfTextRegular    = 0,      ///< Regular characters, no style
    sfTextBold       = 1 << 0, ///< Characters are bold
    sfTextItalic     = 1 << 1, ///< Characters are in italic
    sfTextUnderlined = 1 << 2  ///< Characters are underlined
} sfTextStyle;

typedef struct
{
    sfUint8 r;
    sfUint8 g;
    sfUint8 b;
    sfUint8 a;
} sfColor;

sfColor sfBlack;       ///< Black predefined color
sfColor sfWhite;       ///< White predefined color
sfColor sfRed;         ///< Red predefined color
sfColor sfGreen;       ///< Green predefined color
sfColor sfBlue;        ///< Blue predefined color
sfColor sfYellow;      ///< Yellow predefined color
sfColor sfMagenta;     ///< Magenta predefined color
sfColor sfCyan;        ///< Cyan predefined color
sfColor sfTransparent; ///< Transparent (black) predefined color

typedef struct
{
    float left;
    float top;
    float width;
    float height;
} sfFloatRect;

typedef struct
{
    int left;
    int top;
    int width;
    int height;
} sfIntRect;

typedef struct
{
    sfVector2f position;  ///< Position of the vertex
    sfColor    color;     ///< Color of the vertex
    sfVector2f texCoords; ///< Coordinates of the texture's pixel to map to the vertex
} sfVertex;

typedef struct
{
    float matrix[9];
} sfTransform;

const sfTransform sfTransform_Identity;

typedef struct
{
    int       advance;     ///< Offset to move horizontically to the next character
    sfIntRect bounds;      ///< Bounding rectangle of the glyph, in coordinates relative to the baseline
    sfIntRect textureRect; ///< Texture coordinates of the glyph inside the font's image
} sfGlyph;

typedef struct
{
    sfBlendMode      blendMode; ///< Blending mode
    sfTransform      transform; ///< Transform
    const sfTexture* texture;   ///< Texture
    const sfShader*  shader;    ///< Shader
} sfRenderStates;

sfColor sfColor_fromRGB(sfUint8 red, sfUint8 green, sfUint8 blue);
sfColor sfColor_fromRGBA(sfUint8 red, sfUint8 green, sfUint8 blue, sfUint8 alpha);
sfColor sfColor_add(sfColor color1, sfColor color2);
sfColor sfColor_modulate(sfColor color1, sfColor color2);

sfBool sfFloatRect_contains(const sfFloatRect* rect, float x, float y);
sfBool sfFloatRect_intersects(const sfFloatRect* rect1, const sfFloatRect* rect2, sfFloatRect* intersection);
sfBool sfIntRect_contains(const sfIntRect* rect, int x, int y);
sfBool sfIntRect_intersects(const sfIntRect* rect1, const sfIntRect* rect2, sfIntRect* intersection);

sfTransform sfTransform_fromMatrix(float a00, float a01, float a02, float a10, float a11, float a12, float a20, float a21, float a22);
void        sfTransform_getMatrix(const sfTransform* transform, float* matrix);
sfTransform sfTransform_getInverse(const sfTransform* transform);
sfVector2f  sfTransform_transformPoint(const sfTransform* transform, sfVector2f point);
sfFloatRect sfTransform_transformRect(const sfTransform* transform, sfFloatRect rectangle);
void        sfTransform_combine(sfTransform* transform, const sfTransform* other);
void        sfTransform_translate(sfTransform* transform, float x, float y);
void        sfTransform_rotate(sfTransform* transform, float angle);
void        sfTransform_rotateWithCenter(sfTransform* transform, float angle, float centerX, float centerY);
void        sfTransform_scale(sfTransform* transform, float scaleX, float scaleY);
void        sfTransform_scaleWithCenter(sfTransform* transform, float scaleX, float scaleY, float centerX, float centerY);

sfCircleShape*   sfCircleShape_create(void);
sfCircleShape*   sfCircleShape_copy(const sfCircleShape* shape);
void             sfCircleShape_destroy(sfCircleShape* shape);
void             sfCircleShape_setPosition(sfCircleShape* shape, sfVector2f position);
void             sfCircleShape_setRotation(sfCircleShape* shape, float angle);
void             sfCircleShape_setScale(sfCircleShape* shape, sfVector2f scale);
void             sfCircleShape_setOrigin(sfCircleShape* shape, sfVector2f origin);
sfVector2f       sfCircleShape_getPosition(const sfCircleShape* shape);
float            sfCircleShape_getRotation(const sfCircleShape* shape);
sfVector2f       sfCircleShape_getScale(const sfCircleShape* shape);
sfVector2f       sfCircleShape_getOrigin(const sfCircleShape* shape);
void             sfCircleShape_move(sfCircleShape* shape, sfVector2f offset);
void             sfCircleShape_rotate(sfCircleShape* shape, float angle);
void             sfCircleShape_scale(sfCircleShape* shape, sfVector2f factors);
sfTransform      sfCircleShape_getTransform(const sfCircleShape* shape);
sfTransform      sfCircleShape_getInverseTransform(const sfCircleShape* shape);
void             sfCircleShape_setTexture(sfCircleShape* shape, const sfTexture* texture, sfBool resetRect);
void             sfCircleShape_setTextureRect(sfCircleShape* shape, sfIntRect rect);
void             sfCircleShape_setFillColor(sfCircleShape* shape, sfColor color);
void             sfCircleShape_setOutlineColor(sfCircleShape* shape, sfColor color);
void             sfCircleShape_setOutlineThickness(sfCircleShape* shape, float thickness);
const sfTexture* sfCircleShape_getTexture(const sfCircleShape* shape);
sfIntRect        sfCircleShape_getTextureRect(const sfCircleShape* shape);
sfColor          sfCircleShape_getFillColor(const sfCircleShape* shape);
sfColor          sfCircleShape_getOutlineColor(const sfCircleShape* shape);
float            sfCircleShape_getOutlineThickness(const sfCircleShape* shape);
unsigned int     sfCircleShape_getPointCount(const sfCircleShape* shape);
sfVector2f       sfCircleShape_getPoint(const sfCircleShape* shape, unsigned int index);
void             sfCircleShape_setRadius(sfCircleShape* shape, float radius);
float            sfCircleShape_getRadius(const sfCircleShape* shape);
void             sfCircleShape_setPointCount(sfCircleShape* shape, unsigned int count);
sfFloatRect      sfCircleShape_getLocalBounds(const sfCircleShape* shape);
sfFloatRect      sfCircleShape_getGlobalBounds(const sfCircleShape* shape);

sfConvexShape*   sfConvexShape_create(void);
sfConvexShape*   sfConvexShape_copy(const sfConvexShape* shape);
void             sfConvexShape_destroy(sfConvexShape* shape);
void             sfConvexShape_setPosition(sfConvexShape* shape, sfVector2f position);
void             sfConvexShape_setRotation(sfConvexShape* shape, float angle);
void             sfConvexShape_setScale(sfConvexShape* shape, sfVector2f scale);
void             sfConvexShape_setOrigin(sfConvexShape* shape, sfVector2f origin);
sfVector2f       sfConvexShape_getPosition(const sfConvexShape* shape);
float            sfConvexShape_getRotation(const sfConvexShape* shape);
sfVector2f       sfConvexShape_getScale(const sfConvexShape* shape);
sfVector2f       sfConvexShape_getOrigin(const sfConvexShape* shape);
void             sfConvexShape_move(sfConvexShape* shape, sfVector2f offset);
void             sfConvexShape_rotate(sfConvexShape* shape, float angle);
void             sfConvexShape_scale(sfConvexShape* shape, sfVector2f factors);
sfTransform      sfConvexShape_getTransform(const sfConvexShape* shape);
sfTransform      sfConvexShape_getInverseTransform(const sfConvexShape* shape);
void             sfConvexShape_setTexture(sfConvexShape* shape, const sfTexture* texture, sfBool resetRect);
void             sfConvexShape_setTextureRect(sfConvexShape* shape, sfIntRect rect);
void             sfConvexShape_setFillColor(sfConvexShape* shape, sfColor color);
void             sfConvexShape_setOutlineColor(sfConvexShape* shape, sfColor color);
void             sfConvexShape_setOutlineThickness(sfConvexShape* shape, float thickness);
const sfTexture* sfConvexShape_getTexture(const sfConvexShape* shape);
sfIntRect        sfConvexShape_getTextureRect(const sfConvexShape* shape);
sfColor          sfConvexShape_getFillColor(const sfConvexShape* shape);
sfColor          sfConvexShape_getOutlineColor(const sfConvexShape* shape);
float            sfConvexShape_getOutlineThickness(const sfConvexShape* shape);
unsigned int     sfConvexShape_getPointCount(const sfConvexShape* shape);
sfVector2f       sfConvexShape_getPoint(const sfConvexShape* shape, unsigned int index);
void             sfConvexShape_setPointCount(sfConvexShape* shape, unsigned int count);
void             sfConvexShape_setPoint(sfConvexShape* shape, unsigned int index, sfVector2f point);
sfFloatRect      sfConvexShape_getLocalBounds(const sfConvexShape* shape);
sfFloatRect      sfConvexShape_getGlobalBounds(const sfConvexShape* shape);

sfFont* sfFont_createFromFile(const char* filename);
sfFont* sfFont_createFromMemory(const void* data, size_t sizeInBytes);
sfFont* sfFont_createFromStream(sfInputStream* stream);
sfFont* sfFont_copy(const sfFont* font);
void    sfFont_destroy(sfFont* font);
sfGlyph sfFont_getGlyph(sfFont* font, sfUint32 codePoint, unsigned int characterSize, sfBool bold);
int     sfFont_getKerning(sfFont* font, sfUint32 first, sfUint32 second, unsigned int characterSize);
int     sfFont_getLineSpacing(sfFont* font, unsigned int characterSize);
const   sfTexture* sfFont_getTexture(sfFont* font, unsigned int characterSize);

sfImage*       sfImage_create(unsigned int width, unsigned int height);
sfImage*       sfImage_createFromColor(unsigned int width, unsigned int height, sfColor color);
sfImage*       sfImage_createFromPixels(unsigned int width, unsigned int height, const sfUint8* pixels);
sfImage*       sfImage_createFromFile(const char* filename);
sfImage*       sfImage_createFromMemory(const void* data, size_t size);
sfImage*       sfImage_createFromStream(sfInputStream* stream);
sfImage*       sfImage_copy(const sfImage* image);
void           sfImage_destroy(sfImage* image);
sfBool         sfImage_saveToFile(const sfImage* image, const char* filename);
sfVector2u     sfImage_getSize(const sfImage* image);
void           sfImage_createMaskFromColor(sfImage* image, sfColor color, sfUint8 alpha);
void           sfImage_copyImage(sfImage* image, const sfImage* source, unsigned int destX, unsigned int destY, sfIntRect sourceRect, sfBool applyAlpha);
void           sfImage_setPixel(sfImage* image, unsigned int x, unsigned int y, sfColor color);
sfColor        sfImage_getPixel(const sfImage* image, unsigned int x, unsigned int y);
const sfUint8* sfImage_getPixelsPtr(const sfImage* image);
void           sfImage_flipHorizontally(sfImage* image);
void           sfImage_flipVertically(sfImage* image);

sfRectangleShape* sfRectangleShape_create(void);
sfRectangleShape* sfRectangleShape_copy(const sfRectangleShape* shape);
void              sfRectangleShape_destroy(sfRectangleShape* shape);
void              sfRectangleShape_setPosition(sfRectangleShape* shape, sfVector2f position);
void              sfRectangleShape_setRotation(sfRectangleShape* shape, float angle);
void              sfRectangleShape_setScale(sfRectangleShape* shape, sfVector2f scale);
void              sfRectangleShape_setOrigin(sfRectangleShape* shape, sfVector2f origin);
sfVector2f        sfRectangleShape_getPosition(const sfRectangleShape* shape);
float             sfRectangleShape_getRotation(const sfRectangleShape* shape);
sfVector2f        sfRectangleShape_getScale(const sfRectangleShape* shape);
sfVector2f        sfRectangleShape_getOrigin(const sfRectangleShape* shape);
void              sfRectangleShape_move(sfRectangleShape* shape, sfVector2f offset);
void              sfRectangleShape_rotate(sfRectangleShape* shape, float angle);
void              sfRectangleShape_scale(sfRectangleShape* shape, sfVector2f factors);
sfTransform       sfRectangleShape_getTransform(const sfRectangleShape* shape);
sfTransform       sfRectangleShape_getInverseTransform(const sfRectangleShape* shape);
void              sfRectangleShape_setTexture(sfRectangleShape* shape, const sfTexture* texture, sfBool resetRect);
void              sfRectangleShape_setTextureRect(sfRectangleShape* shape, sfIntRect rect);
void              sfRectangleShape_setFillColor(sfRectangleShape* shape, sfColor color);
void              sfRectangleShape_setOutlineColor(sfRectangleShape* shape, sfColor color);
void              sfRectangleShape_setOutlineThickness(sfRectangleShape* shape, float thickness);
const sfTexture*  sfRectangleShape_getTexture(const sfRectangleShape* shape);
sfIntRect         sfRectangleShape_getTextureRect(const sfRectangleShape* shape);
sfColor           sfRectangleShape_getFillColor(const sfRectangleShape* shape);
sfColor           sfRectangleShape_getOutlineColor(const sfRectangleShape* shape);
float             sfRectangleShape_getOutlineThickness(const sfRectangleShape* shape);
unsigned int      sfRectangleShape_getPointCount(const sfRectangleShape* shape);
sfVector2f        sfRectangleShape_getPoint(const sfRectangleShape* shape, unsigned int index);
void              sfRectangleShape_setSize(sfRectangleShape* shape, sfVector2f size);
sfVector2f        sfRectangleShape_getSize(const sfRectangleShape* shape);
sfFloatRect       sfRectangleShape_getLocalBounds(const sfRectangleShape* shape);
sfFloatRect       sfRectangleShape_getGlobalBounds(const sfRectangleShape* shape);

sfRenderTexture* sfRenderTexture_create(unsigned int width, unsigned int height, sfBool depthBuffer);
void             sfRenderTexture_destroy(sfRenderTexture* renderTexture);
sfVector2u       sfRenderTexture_getSize(const sfRenderTexture* renderTexture);
sfBool           sfRenderTexture_setActive(sfRenderTexture* renderTexture, sfBool active);
void             sfRenderTexture_display(sfRenderTexture* renderTexture);
void             sfRenderTexture_clear(sfRenderTexture* renderTexture, sfColor color);
void             sfRenderTexture_setView(sfRenderTexture* renderTexture, const sfView* view);
const sfView*    sfRenderTexture_getView(const sfRenderTexture* renderTexture);
const sfView*    sfRenderTexture_getDefaultView(const sfRenderTexture* renderTexture);
sfIntRect        sfRenderTexture_getViewport(const sfRenderTexture* renderTexture, const sfView* view);
sfVector2f       sfRenderTexture_mapPixelToCoords(const sfRenderTexture* renderTexture, sfVector2i point, const sfView* view);
sfVector2i       sfRenderTexture_mapCoordsToPixel(const sfRenderTexture* renderTexture, sfVector2f point, const sfView* view);
void             sfRenderTexture_drawSprite(sfRenderTexture* renderTexture, const sfSprite* object, const sfRenderStates* states);
void             sfRenderTexture_drawText(sfRenderTexture* renderTexture, const sfText* object, const sfRenderStates* states);
void             sfRenderTexture_drawShape(sfRenderTexture* renderTexture, const sfShape* object, const sfRenderStates* states);
void             sfRenderTexture_drawCircleShape(sfRenderTexture* renderTexture, const sfCircleShape* object, const sfRenderStates* states);
void             sfRenderTexture_drawConvexShape(sfRenderTexture* renderTexture, const sfConvexShape* object, const sfRenderStates* states);
void             sfRenderTexture_drawRectangleShape(sfRenderTexture* renderTexture, const sfRectangleShape* object, const sfRenderStates* states);
void             sfRenderTexture_drawVertexArray(sfRenderTexture* renderTexture, const sfVertexArray* object, const sfRenderStates* states);
void             sfRenderTexture_drawPrimitives(sfRenderTexture* renderTexture, const sfVertex* vertices, unsigned int vertexCount, sfPrimitiveType type, const sfRenderStates* states);
void             sfRenderTexture_pushGLStates(sfRenderTexture* renderTexture);
void             sfRenderTexture_popGLStates(sfRenderTexture* renderTexture);
void             sfRenderTexture_resetGLStates(sfRenderTexture* renderTexture);
const sfTexture* sfRenderTexture_getTexture(const sfRenderTexture* renderTexture);
void             sfRenderTexture_setSmooth(sfRenderTexture* renderTexture, sfBool smooth);
sfBool           sfRenderTexture_isSmooth(const sfRenderTexture* renderTexture);
void             sfRenderTexture_setRepeated(sfRenderTexture* renderTexture, sfBool repeated);
sfBool           sfRenderTexture_isRepeated(const sfRenderTexture* renderTexture);

sfRenderWindow*   sfRenderWindow_create(sfVideoMode mode, const char* title, sfUint32 style, const sfContextSettings* settings);
sfRenderWindow*   sfRenderWindow_createUnicode(sfVideoMode mode, const sfUint32* title, sfUint32 style, const sfContextSettings* settings);
sfRenderWindow*   sfRenderWindow_createFromHandle(sfWindowHandle handle, const sfContextSettings* settings);
void              sfRenderWindow_destroy(sfRenderWindow* renderWindow);
void              sfRenderWindow_close(sfRenderWindow* renderWindow);
sfBool            sfRenderWindow_isOpen(const sfRenderWindow* renderWindow);
sfContextSettings sfRenderWindow_getSettings(const sfRenderWindow* renderWindow);
sfBool            sfRenderWindow_pollEvent(sfRenderWindow* renderWindow, sfEvent* event);
sfBool            sfRenderWindow_waitEvent(sfRenderWindow* renderWindow, sfEvent* event);
sfVector2i        sfRenderWindow_getPosition(const sfRenderWindow* renderWindow);
void              sfRenderWindow_setPosition(sfRenderWindow* renderWindow, sfVector2i position);
sfVector2u        sfRenderWindow_getSize(const sfRenderWindow* renderWindow);
void              sfRenderWindow_setSize(sfRenderWindow* renderWindow, sfVector2u size);
void              sfRenderWindow_setTitle(sfRenderWindow* renderWindow, const char* title);
void              sfRenderWindow_setUnicodeTitle(sfRenderWindow* renderWindow, const sfUint32* title);
void              sfRenderWindow_setIcon(sfRenderWindow* renderWindow, unsigned int width, unsigned int height, const sfUint8* pixels);
void              sfRenderWindow_setVisible(sfRenderWindow* renderWindow, sfBool visible);
void              sfRenderWindow_setMouseCursorVisible(sfRenderWindow* renderWindow, sfBool show);
void              sfRenderWindow_setVerticalSyncEnabled(sfRenderWindow* renderWindow, sfBool enabled);
void              sfRenderWindow_setKeyRepeatEnabled(sfRenderWindow* renderWindow, sfBool enabled);
sfBool            sfRenderWindow_setActive(sfRenderWindow* renderWindow, sfBool active);
void              sfRenderWindow_display(sfRenderWindow* renderWindow);
void              sfRenderWindow_setFramerateLimit(sfRenderWindow* renderWindow, unsigned int limit);
void              sfRenderWindow_setJoystickThreshold(sfRenderWindow* renderWindow, float threshold);
sfWindowHandle    sfRenderWindow_getSystemHandle(const sfRenderWindow* renderWindow);
void              sfRenderWindow_clear(sfRenderWindow* renderWindow, sfColor color);
void              sfRenderWindow_setView(sfRenderWindow* renderWindow, const sfView* view);
const sfView*     sfRenderWindow_getView(const sfRenderWindow* renderWindow);
const sfView*     sfRenderWindow_getDefaultView(const sfRenderWindow* renderWindow);
sfIntRect         sfRenderWindow_getViewport(const sfRenderWindow* renderWindow, const sfView* view);
sfVector2f        sfRenderWindow_mapPixelToCoords(const sfRenderWindow* renderWindow, sfVector2i point, const sfView* view);
sfVector2i        sfRenderWindow_mapCoordsToPixel(const sfRenderWindow* renderWindow, sfVector2f point, const sfView* view);
void              sfRenderWindow_drawSprite(sfRenderWindow* renderWindow, const sfSprite* object, const sfRenderStates* states);
void              sfRenderWindow_drawText(sfRenderWindow* renderWindow, const sfText* object, const sfRenderStates* states);
void              sfRenderWindow_drawShape(sfRenderWindow* renderWindow, const sfShape* object, const sfRenderStates* states);
void              sfRenderWindow_drawCircleShape(sfRenderWindow* renderWindow, const sfCircleShape* object, const sfRenderStates* states);
void              sfRenderWindow_drawConvexShape(sfRenderWindow* renderWindow, const sfConvexShape* object, const sfRenderStates* states);
void              sfRenderWindow_drawRectangleShape(sfRenderWindow* renderWindow, const sfRectangleShape* object, const sfRenderStates* states);
void              sfRenderWindow_drawVertexArray(sfRenderWindow* renderWindow, const sfVertexArray* object, const sfRenderStates* states);
void              sfRenderWindow_drawPrimitives(sfRenderWindow* renderWindow, const sfVertex* vertices, unsigned int vertexCount, sfPrimitiveType type, const sfRenderStates* states);
void              sfRenderWindow_pushGLStates(sfRenderWindow* renderWindow);
void              sfRenderWindow_popGLStates(sfRenderWindow* renderWindow);
void              sfRenderWindow_resetGLStates(sfRenderWindow* renderWindow);
sfImage*          sfRenderWindow_capture(const sfRenderWindow* renderWindow);

sfVector2i        sfMouse_getPositionRenderWindow(const sfRenderWindow* relativeTo);
void              sfMouse_setPositionRenderWindow(sfVector2i position, const sfRenderWindow* relativeTo);

sfShader* sfShader_createFromFile(const char* vertexShaderFilename, const char* fragmentShaderFilename);
sfShader* sfShader_createFromMemory(const char* vertexShader, const char* fragmentShader);
sfShader* sfShader_createFromStream(sfInputStream* vertexShaderStream, sfInputStream* fragmentShaderStream);
void      sfShader_destroy(sfShader* shader);
void      sfShader_setFloatParameter(sfShader* shader, const char* name, float x);
void      sfShader_setFloat2Parameter(sfShader* shader, const char* name, float x, float y);
void      sfShader_setFloat3Parameter(sfShader* shader, const char* name, float x, float y, float z);
void      sfShader_setFloat4Parameter(sfShader* shader, const char* name, float x, float y, float z, float w);
void      sfShader_setVector2Parameter(sfShader* shader, const char* name, sfVector2f vector);
void      sfShader_setVector3Parameter(sfShader* shader, const char* name, sfVector3f vector);
void      sfShader_setColorParameter(sfShader* shader, const char* name, sfColor color);
void      sfShader_setTransformParameter(sfShader* shader, const char* name, sfTransform transform);
void      sfShader_setTextureParameter(sfShader* shader, const char* name, const sfTexture* texture);
void      sfShader_setCurrentTextureParameter(sfShader* shader, const char* name);
void      sfShader_bind(const sfShader* shader);
sfBool    sfShader_isAvailable(void);

typedef unsigned int (*sfShapeGetPointCountCallback)(void*);        ///< Type of the callback used to get the number of points in a shape
typedef sfVector2f (*sfShapeGetPointCallback)(unsigned int, void*); ///< Type of the callback used to get a point of a shape

sfShape*         sfShape_create(sfShapeGetPointCountCallback getPointCount, sfShapeGetPointCallback getPoint, void* userData);
void             sfShape_destroy(sfShape* shape);
void             sfShape_setPosition(sfShape* shape, sfVector2f position);
void             sfShape_setRotation(sfShape* shape, float angle);
void             sfShape_setScale(sfShape* shape, sfVector2f scale);
void             sfShape_setOrigin(sfShape* shape, sfVector2f origin);
sfVector2f       sfShape_getPosition(const sfShape* shape);
float            sfShape_getRotation(const sfShape* shape);
sfVector2f       sfShape_getScale(const sfShape* shape);
sfVector2f       sfShape_getOrigin(const sfShape* shape);
void             sfShape_move(sfShape* shape, sfVector2f offset);
void             sfShape_rotate(sfShape* shape, float angle);
void             sfShape_scale(sfShape* shape, sfVector2f factors);
sfTransform      sfShape_getTransform(const sfShape* shape);
sfTransform      sfShape_getInverseTransform(const sfShape* shape);
void             sfShape_setTexture(sfShape* shape, const sfTexture* texture, sfBool resetRect);
void             sfShape_setTextureRect(sfShape* shape, sfIntRect rect);
void             sfShape_setFillColor(sfShape* shape, sfColor color);
void             sfShape_setOutlineColor(sfShape* shape, sfColor color);
void             sfShape_setOutlineThickness(sfShape* shape, float thickness);
const sfTexture* sfShape_getTexture(const sfShape* shape);
sfIntRect        sfShape_getTextureRect(const sfShape* shape);
sfColor          sfShape_getFillColor(const sfShape* shape);
sfColor          sfShape_getOutlineColor(const sfShape* shape);
float            sfShape_getOutlineThickness(const sfShape* shape);
unsigned int     sfShape_getPointCount(const sfShape* shape);
sfVector2f       sfShape_getPoint(const sfShape* shape, unsigned int index);
sfFloatRect      sfShape_getLocalBounds(const sfShape* shape);
sfFloatRect      sfShape_getGlobalBounds(const sfShape* shape);
void             sfShape_update(sfShape* shape);

sfSprite*        sfSprite_create(void);
sfSprite*        sfSprite_copy(const sfSprite* sprite);
void             sfSprite_destroy(sfSprite* sprite);
void             sfSprite_setPosition(sfSprite* sprite, sfVector2f position);
void             sfSprite_setRotation(sfSprite* sprite, float angle);
void             sfSprite_setScale(sfSprite* sprite, sfVector2f scale);
void             sfSprite_setOrigin(sfSprite* sprite, sfVector2f origin);
sfVector2f       sfSprite_getPosition(const sfSprite* sprite);
float            sfSprite_getRotation(const sfSprite* sprite);
sfVector2f       sfSprite_getScale(const sfSprite* sprite);
sfVector2f       sfSprite_getOrigin(const sfSprite* sprite);
void             sfSprite_move(sfSprite* sprite, sfVector2f offset);
void             sfSprite_rotate(sfSprite* sprite, float angle);
void             sfSprite_scale(sfSprite* sprite, sfVector2f factors);
sfTransform      sfSprite_getTransform(const sfSprite* sprite);
sfTransform      sfSprite_getInverseTransform(const sfSprite* sprite);
void             sfSprite_setTexture(sfSprite* sprite, const sfTexture* texture, sfBool resetRect);
void             sfSprite_setTextureRect(sfSprite* sprite, sfIntRect rectangle);
void             sfSprite_setColor(sfSprite* sprite, sfColor color);
const sfTexture* sfSprite_getTexture(const sfSprite* sprite);
sfIntRect        sfSprite_getTextureRect(const sfSprite* sprite);
sfColor          sfSprite_getColor(const sfSprite* sprite);
sfFloatRect      sfSprite_getLocalBounds(const sfSprite* sprite);
sfFloatRect      sfSprite_getGlobalBounds(const sfSprite* sprite);

sfText*         sfText_create(void);
sfText*         sfText_copy(const sfText* text);
void            sfText_destroy(sfText* text);
void            sfText_setPosition(sfText* text, sfVector2f position);
void            sfText_setRotation(sfText* text, float angle);
void            sfText_setScale(sfText* text, sfVector2f scale);
void            sfText_setOrigin(sfText* text, sfVector2f origin);
sfVector2f      sfText_getPosition(const sfText* text);
float           sfText_getRotation(const sfText* text);
sfVector2f      sfText_getScale(const sfText* text);
sfVector2f      sfText_getOrigin(const sfText* text);
void            sfText_move(sfText* text, sfVector2f offset);
void            sfText_rotate(sfText* text, float angle);
void            sfText_scale(sfText* text, sfVector2f factors);
sfTransform     sfText_getTransform(const sfText* text);
sfTransform     sfText_getInverseTransform(const sfText* text);
void            sfText_setString(sfText* text, const char* string);
void            sfText_setUnicodeString(sfText* text, const sfUint32* string);
void            sfText_setFont(sfText* text, const sfFont* font);
void            sfText_setCharacterSize(sfText* text, unsigned int size);
void            sfText_setStyle(sfText* text, sfUint32 style);
void            sfText_setColor(sfText* text, sfColor color);
const char*     sfText_getString(const sfText* text);
const sfUint32* sfText_getUnicodeString(const sfText* text);
const sfFont*   sfText_getFont(const sfText* text);
unsigned int    sfText_getCharacterSize(const sfText* text);
sfUint32        sfText_getStyle(const sfText* text);
sfColor         sfText_getColor(const sfText* text);
sfVector2f      sfText_findCharacterPos(const sfText* text, size_t index);
sfFloatRect     sfText_getLocalBounds(const sfText* text);
sfFloatRect     sfText_getGlobalBounds(const sfText* text);

sfTexture*   sfTexture_create(unsigned int width, unsigned int height);
sfTexture*   sfTexture_createFromFile(const char* filename, const sfIntRect* area);
sfTexture*   sfTexture_createFromMemory(const void* data, size_t sizeInBytes, const sfIntRect* area);
sfTexture*   sfTexture_createFromStream(sfInputStream* stream, const sfIntRect* area);
sfTexture*   sfTexture_createFromImage(const sfImage* image, const sfIntRect* area);
sfTexture*   sfTexture_copy(const sfTexture* texture);
void         sfTexture_destroy(sfTexture* texture);
sfVector2u   sfTexture_getSize(const sfTexture* texture);
sfImage*     sfTexture_copyToImage(const sfTexture* texture);
void         sfTexture_updateFromPixels(sfTexture* texture, const sfUint8* pixels, unsigned int width, unsigned int height, unsigned int x, unsigned int y);
void         sfTexture_updateFromImage(sfTexture* texture, const sfImage* image, unsigned int x, unsigned int y);
void         sfTexture_updateFromWindow(sfTexture* texture, const sfWindow* window, unsigned int x, unsigned int y);
void         sfTexture_updateFromRenderWindow(sfTexture* texture, const sfRenderWindow* renderWindow, unsigned int x, unsigned int y);
void         sfTexture_setSmooth(sfTexture* texture, sfBool smooth);
sfBool       sfTexture_isSmooth(const sfTexture* texture);
void         sfTexture_setRepeated(sfTexture* texture, sfBool repeated);
sfBool       sfTexture_isRepeated(const sfTexture* texture);
void         sfTexture_bind(const sfTexture* texture);
unsigned int sfTexture_getMaximumSize();

sfTransformable* sfTransformable_create(void);
sfTransformable* sfTransformable_copy(const sfTransformable* transformable);
void             sfTransformable_destroy(sfTransformable* transformable);
void             sfTransformable_setPosition(sfTransformable* transformable, sfVector2f position);
void             sfTransformable_setRotation(sfTransformable* transformable, float angle);
void             sfTransformable_setScale(sfTransformable* transformable, sfVector2f scale);
void             sfTransformable_setOrigin(sfTransformable* transformable, sfVector2f origin);
sfVector2f       sfTransformable_getPosition(const sfTransformable* transformable);
float            sfTransformable_getRotation(const sfTransformable* transformable);
sfVector2f       sfTransformable_getScale(const sfTransformable* transformable);
sfVector2f       sfTransformable_getOrigin(const sfTransformable* transformable);
void             sfTransformable_move(sfTransformable* transformable, sfVector2f offset);
void             sfTransformable_rotate(sfTransformable* transformable, float angle);
void             sfTransformable_scale(sfTransformable* transformable, sfVector2f factors);
sfTransform      sfTransformable_getTransform(const sfTransformable* transformable);
sfTransform      sfTransformable_getInverseTransform(const sfTransformable* transformable);

sfVertexArray*  sfVertexArray_create(void);
sfVertexArray*  sfVertexArray_copy(const sfVertexArray* vertexArray);
void            sfVertexArray_destroy(sfVertexArray* vertexArray);
unsigned int    sfVertexArray_getVertexCount(const sfVertexArray* vertexArray);
sfVertex*       sfVertexArray_getVertex(sfVertexArray* vertexArray, unsigned int index);
void            sfVertexArray_clear(sfVertexArray* vertexArray);
void            sfVertexArray_resize(sfVertexArray* vertexArray, unsigned int vertexCount);
void            sfVertexArray_append(sfVertexArray* vertexArray, sfVertex vertex);
void            sfVertexArray_setPrimitiveType(sfVertexArray* vertexArray, sfPrimitiveType type);
sfPrimitiveType sfVertexArray_getPrimitiveType(sfVertexArray* vertexArray);
sfFloatRect     sfVertexArray_getBounds(sfVertexArray* vertexArray);

sfView*     sfView_create(void);
sfView*     sfView_createFromRect(sfFloatRect rectangle);
sfView*     sfView_copy(const sfView* view);
void        sfView_destroy(sfView* view);
void        sfView_setCenter(sfView* view, sfVector2f center);
void        sfView_setSize(sfView* view, sfVector2f size);
void        sfView_setRotation(sfView* view, float angle);
void        sfView_setViewport(sfView* view, sfFloatRect viewport);
void        sfView_reset(sfView* view, sfFloatRect rectangle);
sfVector2f  sfView_getCenter(const sfView* view);
sfVector2f  sfView_getSize(const sfView* view);
float       sfView_getRotation(const sfView* view);
sfFloatRect sfView_getViewport(const sfView* view);
void        sfView_move(sfView* view, sfVector2f offset);
void        sfView_rotate(sfView* view, float angle);
void        sfView_zoom(sfView* view, float factor);
]];


local sfGraphics = ffi.load('csfml-graphics-2');
if sfGraphics then

BlendMode = {};      BlendMode.__index = BlendMode;
CircleShape = {};    CircleShape.__index = CircleShape;
Color = {};          Color.__index = Color;
ConvexShape = {};    ConvexShape.__index = ConvexShape;
FloatRect = {};      FloatRect.__index = FloatRect;
Font = {};           Font.__index = Font;
Glyph = {};          Glyph.__index = Glyph;
Image = {};          Image.__index = Image;
IntRect = {};        IntRect.__index = IntRect;
PrimitiveType = {};  PrimitiveType.__index = PrimitiveType;
RectangleShape = {}; RectangleShape.__index = RectangleShape;
RenderStates = {};   RenderStates.__index = RenderStates;
RenderTexture = {};  RenderTexture.__index = RenderTexture;
RenderWindow = {};   RenderWindow.__index = RenderWindow;
Shader = {};         Shader.__index = Shader;
Shape = {};          Shape.__index = Shape;
Sprite = {};         Sprite.__index = Sprite;
Text = {};           Text.__index = Text;
Text.Style = {};     Text.Style.__index = Text.Style;
Texture = {};        Texture.__index = Texture;
Transform = {};      Transform.__index = Transform;
Transformable = {};  Transformable.__index = Transformable;
Vertex = {}          Vertex.__index = Vertex;
VertexArray = {};    VertexArray.__index = VertexArray;
View = {};           View.__index = View;


--[=[
Enum 'BlendMode'
[
BlendMode.Alpha
BlendMode.Add
BlendMode.Multiply
BlendMode.None
]
]=]
BlendMode.Alpha = sfGraphics.sfBlendAlpha;
BlendMode.Add = sfGraphics.sfBlendAdd;
BlendMode.Multiply = sfGraphics.sfBlendMultiply;
BlendMode.None = sfGraphics.sfBlendNone;


--[=[
CircleShape()
CircleShape(CircleShape copy)
CircleShape(number radius, number pointCount = 30)
CircleShape CircleShape:copy()
nil         CircleShape:setPosition(Vector2f position)
nil         CircleShape:setPosition(number x, number y)
nil         CircleShape:setRotation(number angle)
nil         CircleShape:setScale(Vector2f scale)
nil         CircleShape:setScale(number x, number y)
nil         CircleShape:setOrigin(Vector2f origin)
nil         CircleShape:setOrigin(number x, number y)
Vector2f    CircleShape:getPosition()
number      CircleShape:getRotation()
Vector2f    CircleShape:getScale()
Vector2f    CircleShape:getOrigin()
nil         CircleShape:move(Vector2f offset)
nil         CircleShape:move(number x, number y)
nil         CircleShape:rotate(number angle)
nil         CircleShape:scale(Vector2f factors)
nil         CircleShape:scale(number x, number y)
Transform   CircleShape:getTransform()
Transform   CircleShape:getInverseTransform()
nil         CircleShape:setTexture(Texture texture, bool resetRect = false)
nil         CircleShape:setTextureRect(IntRect rect)
nil         CircleShape:setFillColor(Color color)
nil         CircleShape:setOutlineColor(Color color)
nil         CircleShape:setOutlineThickness(Color color)
Texture     CircleShape:getTexture()
IntRect     CircleShape:getTextureRect()
Color       CircleShape:getFillColor()
Color       CircleShape:getOutlineColor()
number      CircleShape:getOutlineThickness()
number      CircleShape:getPointCount()
Vector2f    CircleShape:getPoint(number index)
nil         CircleShape:setRadius(number radius)
number      CircleShape:getRadius()
nil         CircleShape:setPointCount(number count)
FloatRect   CircleShape:getLocalBounds()
FloatRect   CircleShape:getGlobalBounds()
]=]

setmetatable(CircleShape, { __call = function(cl, copy_radius, pointCount)
	if ffi.istype('sfCircleShape', copy_radius) then
		return newObj(CircleShape, sfGraphics.sfCircleShape_copy(copy_radius));
	else
		local obj = newObj(CircleShape, sfGraphics.sfCircleShape_create());
		if copy_radius ~= nil then
			sfGraphics.sfCircleShape_setRadius(obj, copy_radius);
			if pointCount ~= nil then
				sfGraphics.sfCircleShape_setPointCount(obj, pointCount);
			end
		end
		return obj;
	end
end });
function CircleShape:__gc()
	sfGraphics.sfCircleShape_destroy(self);
end
function CircleShape:copy()
	return newObj(CircleShape, sfGraphics.sfCircleShape_copy(self));
end
function CircleShape:setPosition(position_x, y)
	if ffi.istype('sfVector2f', position_x) then
		sfGraphics.sfCircleShape_setPosition(self, position);
	else
		sfGraphics.sfCircleShape_setPosition(self, newObj(Vector2f, ffi.new('sfVector2f', {position_x, y})));
	end
end
function CircleShape:setRotation(angle)
	sfGraphics.sfCircleShape_setRotation(self, angle);
end
function CircleShape:setScale(scale_x, y)
	if ffi.istype('sfVector2f', scale_x) then
		sfGraphics.sfCircleShape_setScale(self, scale_x);
	else
		sfGraphics.sfCircleShape_setScale(self, newObj(Vector2f, ffi.new('sfVector2f', {scale_x, y})));
	end
end
function CircleShape:setOrigin(origin_x, y)
	if ffi.istype('sfVector2f', origin_x) then
		sfGraphics.sfCircleShape_setOrigin(self, origin_x);
	else
		sfGraphics.sfCircleShape_setOrigin(self, newObj(Vector2f, ffi.new('sfVector2f', {origin_x, y})));
	end
end
function CircleShape:getPosition()
	return sfGraphics.sfCircleShape_getPosition(self);
end
function CircleShape:getRotation()
	return sfGraphics.sfCircleShape_getRotation(self);
end
function CircleShape:getScale()
	return sfGraphics.sfCircleShape_getScale(self);
end
function CircleShape:getOrigin()
	return sfGraphics.sfCircleShape_getOrigin(self);
end
function CircleShape:move(offset_x, y)
	if ffi.istype('sfVector2f', offset_x) then
		sfGraphics.sfCircleShape_move(self, offset_x);
	else
		sfGraphics.sfCircleShape_move(self, newObj(Vector2f, ffi.new('sfVector2f', {offset_x, y})));
	end
end
function CircleShape:rotate(angle)
	sfGraphics.sfCircleShape_rotate(self, angle);
end
function CircleShape:scale(factors_x, y)
	if ffi.istype('sfVector2f', factors_x) then
		sfGraphics.sfCircleShape_scale(self, factors_x);
	else
		sfGraphics.sfCircleShape_scale(self, newObj(Vector2f, ffi.new('sfVector2f', {factors_x, y})));
	end
end
function CircleShape:getTransform()
	return sfGraphics.sfCircleShape_getTransform(self);
end
function CircleShape:getInverseTransform()
	return sfGraphics.sfCircleShape_getInverseTransform(self);
end
function CircleShape:setTexture(texture, resetRect)
	if resetRect == nil then resetRect = false; end
	sfGraphics.sfCircleShape_setTexture(self, texture, resetRect);
end
function CircleShape:setTextureRect(rect)
	sfGraphics.sfCircleShape_setTextureRect(self, rect);
end
function CircleShape:setFillColor(color)
	sfGraphics.sfCircleShape_setFillColor(self, color);
end
function CircleShape:setOutlineColor(color)
	sfGraphics.sfCircleShape_setOutlineColor(self, color);
end
function CircleShape:setOutlineThickness(thickness)
	sfGraphics.sfCircleShape_setOutlineThickness(self, thickness);
end
function CircleShape:getTexture()
	return sfGraphics.sfCircleShape_getTexture(self);
end
function CircleShape:getTextureRect()
	return sfGraphics.sfCircleShape_getTextureRect(self);
end
function CircleShape:getFillColor()
	return sfGraphics.sfCircleShape_getFillColor(self);
end
function CircleShape:getOutlineColor()
	return sfGraphics.sfCircleShape_getOutlineColor(self);
end
function CircleShape:getOutlineThickness()
	return sfGraphics.sfCircleShape_getOutlineThickness(self);
end
function CircleShape:getPointCount()
	return sfGraphics.sfCircleShape_getPointCount(self);
end
function CircleShape:getPoint(index)
	return sfGraphics.sfCircleShape_getPoint(self, index);
end
function CircleShape:setRadius(radius)
	return sfGraphics.sfCircleShape_setRadius(self, radius);
end
function CircleShape:getRadius()
	return sfGraphics.sfCircleShape_getRadius(self);
end
function CircleShape:setPointCount(count)
	sfGraphics.sfCircleShape_setPointCount(self, count);
end
function CircleShape:getLocalBounds()
	return sfGraphics.sfCircleShape_getLocalBounds(self);
end
function CircleShape:getGlobalBounds()
	return sfGraphics.sfCircleShape_getGlobalBounds(self);
end
ffi.metatype('sfCircleShape', CircleShape);


--[=[
Color.Black       = Color(0, 0, 0, 255)
Color.White       = Color(255, 255, 255, 255)
Color.Red         = Color(255, 0, 0, 255)
Color.Green       = Color(0, 255, 0, 255)
Color.Blue        = Color(0, 0, 255, 255)
Color.Yellow      = Color(255, 255, 0, 255)
Color.Magenta     = Color(255, 0, 255, 255)
Color.Cyan        = Color(0, 255, 255, 255)
Color.Transparent = Color(0, 0, 0, 0)

Color()
Color(Color copy)
Color(number red, number green, number blue, number alpha = 255)
Color  Color:add()
Color  Color:operator +  (Color rhs)
Color  Color:operator *  (Color rhs)
Color  Color:operator == (Color rhs)
Color  Color:operator ~= (Color rhs)
number Color.r
number Color.g
number Color.b
number Color.a
]=]

Color.Black       = sfGraphics.sfBlack;
Color.White       = sfGraphics.sfWhite;
Color.Red         = sfGraphics.sfRed;
Color.Green       = sfGraphics.sfGreen;
Color.Blue        = sfGraphics.sfBlue;
Color.Yellow      = sfGraphics.sfYellow;
Color.Magenta     = sfGraphics.sfMagenta;
Color.Cyan        = sfGraphics.sfCyan;
Color.Transparent = sfGraphics.sfTransparent;
setmetatable(Color, { __call = function(cl, copy_red, green, blue, alpha)
	if ffi.istype('sfColor', copy_red) then
		return newObj(Color, sfGraphics.sfColor_fromRGBA(copy_red.r, copy_red.g, copy_red.b, copy_red.a));
	else
		if copy_red == nil then
			return newObj(Color, sfGraphics.sfColor_fromRGB(0, 0, 0));
		else
			if alpha == nil then
				return newObj(Color, sfGraphics.sfColor_fromRGB(copy_red, green, blue));
			else
				return newObj(Color, sfGraphics.sfColor_fromRGBA(copy_red, green, blue, alpha));
			end
		end
	end
end });
function Color:__add(rhs)
	return newObj(Color, sfGraphics.sfColor_add(self, rhs));
end
function Color:__mul(rhs)
	return newObj(Color, sfGraphics.sfColor_modulate(self, rhs));
end
function Color:__eq(rhs)
	return (self.r == rhs.r) and (self.g == rhs.g) and (self.b == rhs.b) and (self.a == rhs.a);
end
ffi.metatype('sfColor', Color);


--[=[
ConvexShape()
ConvexShape(ConvexShape copy)
ConvexShape(number pointCount)
ConvexShape ConvexShape:copy()
nil         ConvexShape:setPosition(Vector2f position)
nil         ConvexShape:setPosition(number x, number y)
nil         ConvexShape:setRotation(number angle)
nil         ConvexShape:setScale(Vector2f scale)
nil         ConvexShape:setScale(number x, number y)
nil         ConvexShape:setOrigin(Vector2f origin)
nil         ConvexShape:setOrigin(number x, number y)
Vector2f    ConvexShape:getPosition()
number      ConvexShape:getRotation()
Vector2f    ConvexShape:getScale()
Vector2f    ConvexShape:getOrigin()
nil         ConvexShape:move(Vector2f offset)
nil         ConvexShape:move(number x, number y)
nil         ConvexShape:rotate(number angle)
nil         ConvexShape:scale(Vector2f factors)
nil         ConvexShape:scale(number x, number y)
Transform   ConvexShape:getTransform()
Transform   ConvexShape:getInverseTransform()
nil         ConvexShape:setTexture(Texture texture, bool resetRect = false)
nil         ConvexShape:setTextureRect(IntRect rect)
nil         ConvexShape:setFillColor(Color color)
nil         ConvexShape:setOutlineColor(Color color)
nil         ConvexShape:setOutlineThickness(Color color)
Texture     ConvexShape:getTexture()
IntRect     ConvexShape:getTextureRect()
Color       ConvexShape:getFillColor()
Color       ConvexShape:getOutlineColor()
number      ConvexShape:getOutlineThickness()
number      ConvexShape:getPointCount()
Vector2f    ConvexShape:getPoint(number index)
nil         ConvexShape:setPointCount(number count)
nil         ConvexShape:setPoint(number index, Vector2f point)
FloatRect   ConvexShape:getLocalBounds()
FloatRect   ConvexShape:getGlobalBounds()
]=]

setmetatable(ConvexShape, { __call = function(cl, copy_pointCount)
	if ffi.istype('sfConvexShape', copy_pointCount) then
		return newObj(ConvexShape, sfGraphics.sfConvexShape_copy(copy_pointCount));
	else
		local obj = newObj(ConvexShape, sfGraphics.sfConvexShape_create());
		if copy_pointCount ~= nil then sfGraphics.sfConvexShape_setPointCount(obj, copy_pointCount) end
		return obj;
	end
end });
function ConvexShape:__gc()
	sfGraphics.sfConvexShape_destroy(self);
end
function ConvexShape:copy()
	return newObj(ConvexShape, sfGraphics.sfConvexShape_copy(self));
end
function ConvexShape:setPosition(position_x, y)
	if ffi.istype('sfVector2f', position_x) then
		sfGraphics.sfConvexShape_setPosition(self, position_x);
	else
		sfGraphics.sfConvexShape_setPosition(self, newObj(Vector2f, ffi.new('sfVector2f', {position_x, y})));
	end
end
function ConvexShape:setRotation(angle)
	sfGraphics.sfConvexShape_setRotation(self, angle);
end
function ConvexShape:setScale(scale_x, y)
	if ffi.istype('sfVector2f', scale_x) then
		sfGraphics.sfConvexShape_setScale(self, scale_x);
	else
		sfGraphics.sfConvexShape_setScale(self, newObj(Vector2f, ffi.new('sfVector2f', {scale_x, y})));
	end
end
function ConvexShape:setOrigin(origin_x, y)
	if ffi.istype('sfVector2f', origin_x) then
		sfGraphics.sfConvexShape_setOrigin(self, origin_x);
	else
		sfGraphics.sfConvexShape_setOrigin(self, newObj(Vector2f, ffi.new('sfVector2f', {origin_x, y})));
	end
end
function ConvexShape:getPosition()
	return sfGraphics.sfConvexShape_getPosition(self);
end
function ConvexShape:getRotation()
	return sfGraphics.sfConvexShape_getRotation(self);
end
function ConvexShape:getScale()
	return sfGraphics.sfConvexShape_getScale(self);
end
function ConvexShape:getOrigin()
	return sfGraphics.sfConvexShape_getOrigin(self);
end
function ConvexShape:move(offset_x, y)
	if ffi.istype('sfVector2f', offset_x) then
		sfGraphics.sfConvexShape_move(self, offset_x);
	else
		sfGraphics.sfConvexShape_move(self, newObj(Vector2f, ffi.new('sfVector2f', {offset_x, y})));
	end
end
function ConvexShape:rotate(angle)
	sfGraphics.sfConvexShape_rotate(self, angle);
end
function ConvexShape:scale(factors_x, y)
	if ffi.istype('sfVector2f', factors_x) then
		sfGraphics.sfConvexShape_scale(self, factors_x);
	else
		sfGraphics.sfConvexShape_scale(self, newObj(Vector2f, ffi.new('sfVector2f', {factors_x, y})));
	end
end
function ConvexShape:getTransform()
	return sfGraphics.sfConvexShape_getTransform(self);
end
function ConvexShape:getInverseTransform()
	return sfGraphics.sfConvexShape_getInverseTransform(self);
end
function ConvexShape:setTexture(texture, resetRect)
	if resetRect == nil then resetRect = false; end
	sfGraphics.sfConvexShape_setTexture(self, texture, resetRect);
end
function ConvexShape:setTextureRect(rect)
	sfGraphics.sfConvexShape_setTextureRect(self, rect);
end
function ConvexShape:setFillColor(color)
	sfGraphics.sfConvexShape_setFillColor(self, color);
end
function ConvexShape:setOutlineColor(color)
	sfGraphics.sfConvexShape_setOutlineColor(self, color);
end
function ConvexShape:setOutlineThickness(thickness)
	sfGraphics.sfConvexShape_setOutlineThickness(self, thickness);
end
function ConvexShape:getTexture()
	return sfGraphics.sfConvexShape_getTexture(self);
end
function ConvexShape:getTextureRect()
	return sfGraphics.sfConvexShape_getTextureRect(self);
end
function ConvexShape:getFillColor()
	return sfGraphics.sfConvexShape_getFillColor(self);
end
function ConvexShape:getOutlineColor()
	return sfGraphics.sfConvexShape_getOutlineColor(self);
end
function ConvexShape:getOutlineThickness()
	return sfGraphics.sfConvexShape_getOutlineThickness(self);
end
function ConvexShape:getPointCount()
	return sfGraphics.sfConvexShapee_getPointCount(self);
end
function ConvexShape:getPoint(index)
	return sfGraphics.sfConvexShape_getPoint(self, index);
end
function ConvexShape:setPointCount(count)
	sfGraphics.sfConvexShape_setPointCount(self, count);
end
function ConvexShape:setPoint(index, point)
	return sfGraphics.sfConvexShape_setPoint(self, index, point);
end
function ConvexShape:getLocalBounds()
	return sfGraphics.sfConvexShape_getLocalBounds(self);
end
function ConvexShape:getGlobalBounds()
	return sfGraphics.sfConvexShape_getGlobalBounds(self);
end
ffi.metatype('sfConvexShape', ConvexShape);


--[=[
FloatRect()
FloatRect(IntRect copy)
FloatRect(FloatRect copy)
FloatRect(number rectLeft, number rectTop, number rectWidth, number rectHeight)
FloatRect(Vector2f position, Vector2f size)
bool   FloatRect:contains(Vector2f point)
bool   FloatRect:contains(number x, number y)
bool   FloatRect:intersects(FloatRect rect2, OUT FloatRect intersection = nil)
number FloatRect.left
number FloatRect.top
number FloatRect.width
number FloatRect.height
]=]

setmetatable(FloatRect, { __call = function(cl, copy_rectLeft_position, rectTop_size, rectWidth, rectHeight)
	if copy_rectLeft_position == nil then
		return newObj(FloatRect, ffi.new('sfFloatRect'));
	else
		if ffi.istype('sfVector2f', copy_rectLeft_position) then
			return newObj(FloatRect, ffi.new('sfFloatRect', {copy_rectLeft_position.x, copy_rectLeft_position.y, rectTop_size.x, rectTop_size.y}));
		elseif ffi.istype('sfIntRect', copy_rectLeft_position) then
			return newObj(IntRect, ffi.new('sfFloatRect', {copy_rectLeft_position.left, copy_rectLeft_position.top, copy_rectLeft_position.width, copy_rectLeft_position.height}));
		elseif ffi.istype('sfFloatRect', copy_rectLeft_position) then
			return newObj(IntRect, ffi.new('sfFloatRect', {copy_rectLeft_position.left, copy_rectLeft_position.top, copy_rectLeft_position.width, copy_rectLeft_position.height}));
		else
			return newObj(FloatRect, ffi.new('sfFloatRect', {copy_rectLeft_position, rectTop_size, rectWidth, rectHeight}));
		end
	end
end });
function FloatRect:contains(point_x, y)
	if ffi.istype('sfVector2f', point_x) then
		return bool(sfGraphics.sfFloatRect_contains(self, point_x.x, point_x.y));
	else
		return bool(sfGraphics.sfFloatRect_contains(self, x, y));
	end
end
function FloatRect:intersects(rect2, intersection)
	return bool(sfGraphics.sfFloatRect_intersects(self, rect2, intersection));
end
ffi.metatype('sfFloatRect', FloatRect);


--[=[
Font(Font copy)
Font(string filename)
Font(cdata<void*> data, number sizeInBytes)
Font(InputStream stream)
Font    Font:copy()
Glyph   Font:getGlyph(number codePoint, number characterSize, bool bold)
number  Font:getKerning(number first, number second, number characterSize)
number  Font:getLineSpacing(number characterSize)
Texture Font:getTexture(number characterSize)
]=]

setmetatable(Font, { __call = function(cl, copy_filename_data_stream, sizeInBytes)
	if type(copy_filename_data_stream) == 'cdata' then
		if ffi.istype('sfFont', copy_filename_data_stream) then
			return newObj(Font, sfGraphics.sfFont_copy(copy_filename_data_stream));
		elseif ffi.istype('sfInputStream', copy_filename_data_stream) then
			return newObj(Font, sfGraphics.sfFont_createFromStream(copy_filename_data_stream));
		else
			return newObj(Font, sfGraphics.sfFont_createFromMemory(copy_filename_data_stream, sizeInBytes));
		end
	else
		return newObj(Font, sfGraphics.sfFont_createFromFile(copy_filename_data_stream));
	end
end });
function Font:__gc()
	sfGraphics.sfFont_destroy(self);
end
function Font:copy()
	return newObj(Font, sfGraphics.sfFont_copy(self));
end
function Font:getGlyph(codePoint, characterSize, bold)
	return sfGraphics.sfFont_getGlyph(self, codePoint, characterSize, bold);
end
function Font:getKerning(first, second, characterSize)
	return sfGraphics.sfFont_getKerning(self, first, second, characterSize);
end
function Font:getLineSpacing(characterSize)
	return sfGraphics.sfFont_getLineSpacing(self, characterSize);
end
function Font:getTexture(characterSize)
	return sfGraphics.sfFont_getTexture(self, characterSize);
end
ffi.metatype('sfFont', Font);


--[=[
Glyph()
number  Glyph.advance
IntRect Glyph.bounds
IntRect Glyph.textureRect
]=]

setmetatable(Glyph, { __call = function(cl)
	return newObj(Glyph, ffi.new('Glyph'));
end });
ffi.metatype('sfGlyph', Glyph);


--[=[
Image(Image copy)
Image(unsigned int width, unsigned int height)
Image(unsigned int width, unsigned int height, sfColor color)
Image(unsigned int width, unsigned int height, const sfUint8* pixels)
Image(const char* filename)
Image(const void* data, size_t size)
Image(sfInputStream* stream)
Image          Image:copy()
bool           Image:saveToFile(string filename)
Vector2u       Image:getSize()
nil            Image:createMaskFromColor(Color color, number alpha)
nil            Image:copyImage(Image source, number destX, number destY, IntRect sourceRect, bool applyAlpha)
nil            Image:setPixel(number x, number y, Color color)
Color          Image:getPixel(number x, number y)
cdata<number*> Image:getPixelsPtr()
nil            Image:flipHorizontally()
nil            Image:flipVertically()
]=]
setmetatable(Image, { __call = function(cl, copy_width_filename_data_stream, height_sizeInBytes, color_pixels)
	local t = type(copy_width_filename_data_stream);
	if t == 'cdata' then
		if ffi.istype('sfImage', copy_width_filename_data_stream) then
			return newObj(Image, sfGraphics.sfImage_copy(copy_width_filename_data_stream));
		elseif ffi.istype('sfInputStream', copy_width_filename_data_stream) then
			return newObj(Image, sfGraphics.sfImage_createFromStream(copy_width_filename_data_stream));
		else
			return newObj(Image, sfGraphics.sfImage_createFromMemory(copy_width_filename_data_stream, height_sizeInBytes));
		end
	elseif t == 'number' then
		if color_pixels == nil then
			return newObj(Image, sfGraphics.sfImage_create(copy_width_filename_data_stream, height_sizeInBytes));
		else
			if ffi.istype('sfColor', color_pixels) then
				return newObj(Image, sfGraphics.sfImage_createFromColor(copy_width_filename_data_stream, height_sizeInBytes, color_pixels));
			else
				return newObj(Image, sfGraphics.sfImage_createFromPixels(copy_width_filename_data_stream, height_sizeInBytes, color_pixels));
			end
		end
	else
		return newObj(Image, sfGraphics.sfImage_createFromFile(copy_width_filename_data_stream));
	end
end });
function Image:__gc()
	sfGraphics.sfImage_destroy(self);
end
function Image:copy()
	return newObj(Image, sfGraphics.sfImage_copy(self));
end
function Image:saveToFile(filename)
	return bool(sfGraphics.sfImage_saveToFile(self, filename));
end
function Image:getSize()
	return sfGraphics.sfImage_getSize(self);
end
function Image:createMaskFromColor(color, alpha)
	sfGraphics.sfImage_createMaskFromColor(self, color, alpha);
end
function Image:copyImage(source, destX, destY, sourceRect, applyAlpha)
	sfGraphics.sfImage_copyImage(self, source, destX, destY, sourceRect, applyAlpha);
end
function Image:setPixel(x, y, color)
	sfGraphics.sfImage_setPixel(self, x, y, color);
end
function Image:getPixel(x, y)
	return sfGraphics.sfImage_getPixel(self, x, y);
end
function Image:getPixelsPtr()
	return sfGraphics.sfImage_getPixelsPtr(self);
end
function Image:flipHorizontally()
	sfGraphics.sfImage_flipHorizontally(self);
end
function Image:flipVertically()
	sfGraphics.sfImage_flipVertically(self);
end
ffi.metatype('sfImage', Image);


--[=[
IntRect()
IntRect(IntRect copy)
IntRect(FloatRect copy)
IntRect(number rectLeft, number rectTop, number rectWidth, number rectHeight)
IntRect(Vector2i position, Vector2i size)
bool   IntRect:contains(Vector2i point)
bool   IntRect:contains(number x, number y)
bool   IntRect:intersects(IntRect rect2, OUT IntRect intersection = nil)
number IntRect.left
number IntRect.top
number IntRect.width
number IntRect.height
]=]

setmetatable(IntRect, { __call = function(cl, copy_rectLeft_position, rectTop_size, rectWidth, rectHeight)
	if copy_rectLeft_position == nil then
		return newObj(IntRect, ffi.new('sfIntRect'));
	else
		if ffi.istype('sfVector2i', copy_rectLeft_position) then
			return newObj(IntRect, ffi.new('sfIntRect', {copy_rectLeft_position.x, copy_rectLeft_position.y, rectTop_size.x, rectTop_size.y}));
		elseif ffi.istype('sfIntRect', copy_rectLeft_position) then
			return newObj(IntRect, ffi.new('sfIntRect', {copy_rectLeft_position.left, copy_rectLeft_position.top, copy_rectLeft_position.width, copy_rectLeft_position.height}));
		elseif ffi.istype('sfFloatRect', copy_rectLeft_position) then
			return newObj(IntRect, ffi.new('sfIntRect', {copy_rectLeft_position.left, copy_rectLeft_position.top, copy_rectLeft_position.width, copy_rectLeft_position.height}));
		else
			return newObj(IntRect, ffi.new('sfIntRect', {copy_rectLeft_position, rectTop_size, rectWidth, rectHeight}));
		end
	end
end });
function FloatRect:contains(point_x, y)
	if ffi.istype('sfVector2i', point_x) then
		return bool(sfGraphics.sfIntRect_contains(self, point_x.x, point_x.y));
	else
		return bool(sfGraphics.sfIntRect_contains(self, x, y));
	end
end
function FloatRect:intersects(rect2, intersection)
	return bool(sfGraphics.sfIntRect_intersects(self, rect2, intersection));
end
ffi.metatype('sfIntRect', IntRect);


--[=[
Enum 'PrimitiveType'
[
PrimitiveType.Points
PrimitiveType.Lines
PrimitiveType.LinesStrip
PrimitiveType.Triangles
PrimitiveType.TrianglesStrip
PrimitiveType.TrianglesFan
PrimitiveType.Quads
]
]=]

PrimitiveType.Points         = sfGraphics.sfPoints
PrimitiveType.Lines          = sfGraphics.sfLines
PrimitiveType.LinesStrip     = sfGraphics.sfLinesStrip
PrimitiveType.Triangles      = sfGraphics.sfTriangles
PrimitiveType.TrianglesStrip = sfGraphics.sfTrianglesStrip
PrimitiveType.TrianglesFan   = sfGraphics.sfTrianglesFan
PrimitiveType.Quads          = sfGraphics.sfQuads


--[=[
RectangleShape()
RectangleShape(RectangleShape copy)
RectangleShape(Vector2f size)
RectangleShape RectangleShape:copy()
nil            RectangleShape:setPosition(Vector2f position)
nil            RectangleShape:setPosition(number x, number y)
nil            RectangleShape:setRotation(number angle)
nil            RectangleShape:setScale(Vector2f scale)
nil            RectangleShape:setScale(number x, number y)
nil            RectangleShape:setOrigin(Vector2f origin)
nil            RectangleShape:setOrigin(number x, number y)
Vector2f       RectangleShape:getPosition()
number         RectangleShape:getRotation()
Vector2f       RectangleShape:getScale()
Vector2f       RectangleShape:getOrigin()
nil            RectangleShape:move(Vector2f offset)
nil            RectangleShape:move(number x, number y)
nil            RectangleShape:rotate(number angle)
nil            RectangleShape:scale(Vector2f factors)
nil            RectangleShape:scale(number x, number y)
Transform      RectangleShape:getTransform()
Transform      RectangleShape:getInverseTransform()
nil            RectangleShape:setTexture(Texture texture, bool resetRect = false)
nil            RectangleShape:setTextureRect(IntRect rect)
nil            RectangleShape:setFillColor(Color color)
nil            RectangleShape:setOutlineColor(Color color)
nil            RectangleShape:setOutlineThickness(Color color)
Texture        RectangleShape:getTexture()
IntRect        RectangleShape:getTextureRect()
Color          RectangleShape:getFillColor()
Color          RectangleShape:getOutlineColor()
number         RectangleShape:getOutlineThickness()
number         RectangleShape:getPointCount()
Vector2f       RectangleShape:getPoint(number index)
nil            RectangleShape:setSize(Vector2f size)
Vector2f       RectangleShape:getSize()
FloatRect      RectangleShape:getLocalBounds()
FloatRect      RectangleShape:getGlobalBounds()
]=]

setmetatable(RectangleShape, { __call = function(cl, copy_size)
	if ffi.istype('sfRectangleShape', copy_size) then
		return newObj(RectangleShape, sfGraphics.sfRectangleShape_copy(copy_size));
	else
		local obj = newObj(RectangleShape, sfGraphics.sfRectangleShape_create());
		if ffi.istype('sfVector2f', copy_size) then
			sfGraphics.sfRectangleShape_setSize(obj, copy_size);
		end
		return obj;
	end
end });
function RectangleShape:__gc()
	sfGraphics.sfRectangleShape_destroy(self);
end
function RectangleShape:copy()
	return newObj(RectangleShape, sfGraphics.sfRectangleShape_copy(self));
end
function RectangleShape:setPosition(position_x, y)
	if ffi.istype('sfVector2f', position_x) then
		sfGraphics.sfRectangleShape_setPosition(self, position_x);
	else
		sfGraphics.sfRectangleShape_setPosition(self, newObj(Vector2f, ffi.new('sfVector2f', {position_x, y})));
	end
end
function RectangleShape:setRotation(angle)
	sfGraphics.sfRectangleShape_setRotation(self, angle);
end
function RectangleShape:setScale(scale_x, y)
	if ffi.istype('sfVector2f', scale_x) then
		sfGraphics.sfRectangleShape_setScale(self, scale_x);
	else
		sfGraphics.sfRectangleShape_setScale(self, newObj(Vector2f, ffi.new('sfVector2f', {scale_x, y})));
	end
end
function RectangleShape:setOrigin(origin_x, y)
	if ffi.istype('sfVector2f', origin_x) then
		sfGraphics.sfRectangleShape_setOrigin(self, origin_x);
	else
		sfGraphics.sfRectangleShape_setOrigin(self, newObj(Vector2f, ffi.new('sfVector2f', {origin_x, y})));
	end
end
function RectangleShape:getPosition()
	return sfGraphics.sfRectangleShape_getPosition(self);
end
function RectangleShape:getRotation()
	return sfGraphics.sfRectangleShape_getRotation(self);
end
function RectangleShape:getScale()
	return sfGraphics.sfRectangleShape_getScale(self);
end
function RectangleShape:getOrigin()
	return sfGraphics.sfRectangleShape_getOrigin(self);
end
function RectangleShape:move(offset_x, y)
	if ffi.istype('sfVector2f', offset_x) then
		sfGraphics.sfRectangleShape_move(self, offset_x);
	else
		sfGraphics.sfRectangleShape_move(self, newObj(Vector2f, ffi.new('sfVector2f', {offset_x, y})));
	end
end
function RectangleShape:rotate(angle)
	sfGraphics.sfRectangleShape_rotate(self, angle);
end
function RectangleShape:scale(factors_x, y)
	if ffi.istype('sfVector2f', factors_x) then
		sfGraphics.sfRectangleShape_scale(self, factors_x);
	else
		sfGraphics.sfRectangleShape_scale(self, newObj(Vector2f, ffi.new('sfVector2f', {factors_x, y})));
	end
end
function RectangleShape:getTransform()
	return sfGraphics.sfRectangleShape_getTransform(self);
end
function RectangleShape:getInverseTransform()
	return sfGraphics.sfRectangleShape_getInverseTransform(self);
end
function RectangleShape:setTexture(texture, resetRect)
	if resetRect == nil then resetRect = false; end
	sfGraphics.sfRectangleShape_setTexture(self, texture, resetRect);
end
function RectangleShape:setTextureRect(rect)
	sfGraphics.sfRectangleShape_setTextureRect(self, rect);
end
function RectangleShape:setFillColor(color)
	sfGraphics.sfRectangleShape_setFillColor(self, color);
end
function RectangleShape:setOutlineColor(color)
	sfGraphics.sfRectangleShape_setOutlineColor(self, color);
end
function RectangleShape:setOutlineThickness(thickness)
	sfGraphics.sfRectangleShape_setOutlineThickness(self, thickness);
end
function RectangleShape:getTexture()
	return sfGraphics.sfRectangleShape_getTexture(self);
end
function RectangleShape:getTextureRect()
	return sfGraphics.sfRectangleShape_getTextureRect(self);
end
function RectangleShape:getFillColor()
	return sfGraphics.sfRectangleShape_getFillColor(self);
end
function RectangleShape:getOutlineColor()
	return sfGraphics.sfRectangleShape_getOutlineColor(self);
end
function RectangleShape:getOutlineThickness()
	return sfGraphics.sfRectangleShape_getOutlineThickness(self);
end
function RectangleShape:getPointCount()
	return sfGraphics.sfRectangleShape_getPointCount(self);
end
function RectangleShape:getPoint(index)
	return sfGraphics.sfRectangleShape_getPoint(self, index);
end
function RectangleShape:setSize(size)
	return sfGraphics.sfRectangleShape_setSize(self, size);
end
function RectangleShape:getSize()
	return sfGraphics.sfRectangleShape_getSize(self);
end
function RectangleShape:getLocalBounds()
	return sfGraphics.sfRectangleShape_getLocalBounds(self);
end
function RectangleShape:getGlobalBounds()
	return sfGraphics.sfRectangleShape_getGlobalBounds(self);
end
ffi.metatype('sfRectangleShape', RectangleShape);


--[=[
RenderStates.Default = RenderStates(BlendMode.Alpha, Transform.Identity)
RenderStates()
RenderStates(RenderStates copy)
RenderStates(BlendMode theBlendMode)
RenderStates(Transform theTransform)
RenderStates(Texture theTexture)
RenderStates(Shader theShader)
RenderStates(BlendMode theBlendMode, Transform theTransform, Texture theTexture = nil, Shader theShader = nil)
BlendMode RenderStates.blendMode
Transform RenderStates.transform
Texture   RenderStates.texture
Shader    RenderStates.shader
]=]

-- RenderStates.Default defined at end
setmetatable(RenderStates, { __call = function(cl, copy_theBlendMode_theTransform_theTexture_theShader, theTransform, theTexture, theShader)
	if copy_theBlendMode_theTransform_theTexture_theShader == nil then
		return newObj(RenderStates, ffi.new('sfRenderStates', {BlendMode.Alpha, Transform.Identity}));
	else
		if theTransform == nil then
			if ffi.istype('sfBlendMode', copy_theBlendMode_theTransform_theTexture_theShader) then
				return newObj(RenderStates, ffi.new('sfRenderStates', {copy_theBlendMode_theTransform_theTexture_theShader, Transform.Identity}));
			elseif ffi.istype('sfTransform', copy_theBlendMode_theTransform_theTexture_theShader) then
				return newObj(RenderStates, ffi.new('sfRenderStates', {BlendMode.Alpha, copy_theBlendMode_theTransform_theTexture_theShader}));
			elseif ffi.istype('sfTexture', copy_theBlendMode_theTransform_theTexture_theShader) then
				return newObj(RenderStates, ffi.new('sfRenderStates', {BlendMode.Alpha, Transform.Identity, copy_theBlendMode_theTransform_theTexture_theShader}));
			elseif ffi.istype('sfShader', copy_theBlendMode_theTransform_theTexture_theShader) then
				return newObj(RenderStates, ffi.new('sfRenderStates', {BlendMode.Alpha, Transform.Identity, nil, copy_theBlendMode_theTransform_theTexture_theShader}));
			elseif ffi.istype('sfRenderStates', copy_theBlendMode_theTransform_theTexture_theShader) then
				return newObj(RenderStates, ffi.new('sfRenderStates', {copy_theBlendMode_theTransform_theTexture_theShader.blendMode, copy_theBlendMode_theTransform_theTexture_theShader.transform, copy_theBlendMode_theTransform_theTexture_theShader.texture, copy_theBlendMode_theTransform_theTexture_theShader.shader}));
			end
		else
			return newObj(RenderStates, ffi.new('sfRenderStates', {copy_theBlendMode_theTransform_theTexture_theShader, theTransform, theTexture, theShader}));
		end
	end
end });
ffi.metatype('sfRenderStates', RenderStates);


--[=[
RenderTexture(number width, number height, bool depthBuffer = false)
Vector2u RenderTexture:getSize()
bool     RenderTexture:setActive(bool active = true)
nil      RenderTexture:display()
nil      RenderTexture:clear(Color color = Color.Black)
nil      RenderTexture:setView(View view)
View     RenderTexture:getView()
View     RenderTexture:getDefaultView()
IntRect  RenderTexture:getViewport(View view)
Vector2f RenderTexture:mapPixelToCoords(Vector2i point, View view)
Vector2i RenderTexture:mapCoordsToPixel(Vector2f point, View view)
nil      RenderTexture:draw(Sprite object, RenderStates states = nil)
nil      RenderTexture:draw(Text object, RenderStates states = nil)
nil      RenderTexture:draw(Shape object, RenderStates states = nil)
nil      RenderTexture:draw(CircleShape object, RenderStates states = nil)
nil      RenderTexture:draw(ConvexShape object, RenderStates states = nil)
nil      RenderTexture:draw(RectangleShape object, RenderStates states = nil)
nil      RenderTexture:draw(VertexArray object, RenderStates states = nil)
nil      RenderTexture:draw(cdata<Vertex*> vertices, number vertexCount, PrimitiveType type, RenderStates states = nil)
nil      RenderTexture:pushGLStates()
nil      RenderTexture:popGLStates()
nil      RenderTexture:resetGLStates()
Texture  RenderTexture:getTexture()
nil      RenderTexture:setSmooth(bool smooth)
bool     RenderTexture:isSmooth()
nil      RenderTexture:setRepeated(bool repeated)
bool     RenderTexture:isRepeated()
]=]

setmetatable(RenderTexture, { __call = function(cl, width, height, depthBuffer)
	return newObj(RenderTexture, sfGraphics.sfRenderTexture_create(width, height, depthBuffer or false));
end });
function RenderTexture:__gc()
	sfGraphics.sfRenderTexture_destroy(self);
end
function RenderTexture:getSize()
	return sfGraphics.sfRenderTexture_getSize(self);
end
function RenderTexture:setActive(active)
	if active == nil then active = true; end
	return bool(sfGraphics.sfRenderTexture_setActive(self, active));
end
function RenderTexture:display()
	sfGraphics.sfRenderTexture_display(self);
end
function RenderTexture:clear(color)
	sfGraphics.sfRenderTexture_clear(self, color or Color.Black);
end
function RenderTexture:setView(view)
	sfGraphics.sfRenderTexture_setView(self, view);
end
function RenderTexture:getView()
	return sfGraphics.sfRenderTexture_getView(self);
end
function RenderTexture:getDefaultView()
	return sfGraphics.sfRenderTexture_getDefaultView(self);
end
function RenderTexture:getViewport(view)
	return sfGraphics.sfRenderTexture_getViewport(self, view);
end
function RenderTexture:mapPixelToCoords(point, view)
	return sfGraphics.sfRenderTexture_mapPixelToCoords(self, point, view);
end
function RenderTexture:mapCoordsToPixel(point, view)
	return sfGraphics.sfRenderTexture_mapCoordsToPixel(self, point, view);
end
function RenderTexture:draw(object_vertices, states_vertexCount, type, states)
	if ffi.istype('sfSprite', object_vertices) then
		sfGraphics.sfRenderTexture_drawSprite(self, object_vertices, states_vertexCount);
	elseif ffi.istype('sfText', object_vertices) then
		sfGraphics.sfRenderTexture_drawText(self, object_vertices, states_vertexCount);
	elseif ffi.istype('sfShape', object_vertices) then
		sfGraphics.sfRenderTexture_drawShape(self, object_vertices, states_vertexCount);
	elseif ffi.istype('sfCircleShape', object_vertices) then
		sfGraphics.sfRenderTexture_drawCircleShape(self, object_vertices, states_vertexCount);
	elseif ffi.istype('sfConvexShape', object_vertices) then
		sfGraphics.sfRenderTexture_drawConvexShape(self, object_vertices, states_vertexCount);
	elseif ffi.istype('sfRectangleShape', object_vertices) then
		sfGraphics.sfRenderTexture_drawRectangleShape(self, object_vertices, states_vertexCount);
	elseif ffi.istype('sfVertexArray', object_vertices) then
		sfGraphics.sfRenderTexture_drawVertexArray(self, object_vertices, states_vertexCount);
	else
		sfGraphics.sfRenderTexture_drawPrimitives(object_vertices, states_vertexCount, type, states);
	end
end
function RenderTexture:pushGLStates()
	sfGraphics.sfRenderTexture_pushGLStates(self);
end
function RenderTexture:popGLStates()
	sfGraphics.sfRenderTexture_popGLStates(self);
end
function RenderTexture:resetGLStates()
	sfGraphics.sfRenderTexture_resetGLStates(self);
end
function RenderTexture:getTexture()
	return sfGraphics.sfRenderTexture_getTexture(self);
end
function RenderTexture:setSmooth(smooth)
	return sfGraphics.sfRenderTexture_setSmooth(self, smooth);
end
function RenderTexture:isSmooth()
	return bool(sfGraphics.sfRenderTexture_isSmooth(self));
end
function RenderTexture:setRepeated(repeated)
	return sfGraphics.sfRenderTexture_setRepeated(self, repeated);
end
function RenderTexture:isRepeated()
	return bool(sfGraphics.sfRenderTexture_isRepeated(self));
end
ffi.metatype('sfRenderTexture', RenderTexture);


--[=[
RenderWindow(WindowHandle handle, ContextSettings settings)
RenderWindow(VideoMode mode, string title, Style style = Style.Default, ContextSettings settings = ContextSettings())
nil             RenderWindow:close()
bool            RenderWindow:isOpen()
ContextSettings RenderWindow:getSettings()
bool            RenderWindow:pollEvent(OUT Event event)
bool            RenderWindow:waitEvent(OUT Event event)
Vector2i        RenderWindow:getPosition()
nil             RenderWindow:setPosition(Vector2i position)
Vector2i        RenderWindow:getSize()
nil             RenderWindow:setSize(Vector2u size)
void            RenderWindow:setTitle(string title)
void            RenderWindow:setIcon(number width, number height, cdata<number*> pixels)
void            RenderWindow:setVisible(bool visible)
void            RenderWindow:setMouseCursorVisible(bool visible)
void            RenderWindow:setVerticalSyncEnabled(bool enabled)
void            RenderWindow:setKeyRepeatEnabled(bool enabled)
bool            RenderWindow:setActive(bool active = true)
nil             RenderWindow:display()
void            RenderWindow:setFramerateLimit(number limit)
void            RenderWindow:setJoystickThreshold(number threshold)
WindowHandle    RenderWindow:getSystemHandle()
nil             RenderWindow:clear(Color color = Color.Black)
nil             RenderWindow:setView(View view)
View            RenderWindow:getView()
View            RenderWindow:getDefaultView()
IntRect         RenderWindow:getViewport(View view)
Vector2f        RenderWindow:mapPixelToCoords(Vector2i point, View view)
Vector2i        RenderWindow:mapCoordsToPixel(Vector2f point, View view)
nil             RenderWindow:draw(Sprite object, RenderStates states = nil)
nil             RenderWindow:draw(Text object, RenderStates states = nil)
nil             RenderWindow:draw(Shape object, RenderStates states = nil)
nil             RenderWindow:draw(CircleShape object, RenderStates states = nil)
nil             RenderWindow:draw(ConvexShape object, RenderStates states = nil)
nil             RenderWindow:draw(RectangleShape object, RenderStates states = nil)
nil             RenderWindow:draw(VertexArray object, RenderStates states = nil)
nil             RenderWindow:draw(cdata<Vertex*> vertices, number vertexCount, PrimitiveType type, RenderStates states = nil)
nil             RenderWindow:pushGLStates()
nil             RenderWindow:popGLStates()
nil             RenderWindow:resetGLStates()
Image           RenderWindow:capture()
]=]

setmetatable(RenderWindow, { __call = function(cl, mode_handle, title_settings, style, settings)
	if ffi.istype('sfWindowHandle', mode_handle) then
		return newObj(RenderWindow, sfGraphics.sfRenderWindow_createFromHandle(mode_handle, title_settings));
	end
	return newObj(RenderWindow, sfGraphics.sfRenderWindow_create(mode_handle, title_settings, style or Style.Default, settings or ContextSettings()));
end });
function RenderWindow:__gc()
	sfGraphics.sfRenderWindow_destroy(self);
end
function RenderWindow:close()
	sfGraphics.sfRenderWindow_close(self);
end
function RenderWindow:isOpen()
	return bool(sfGraphics.sfRenderWindow_isOpen(self));
end
function RenderWindow:getSettings()
	return sfGraphics.sfRenderWindow_getSettings(self);
end
function RenderWindow:pollEvent(event)
	return bool(sfGraphics.sfRenderWindow_pollEvent(self, event));
end
function RenderWindow:waitEvent(event)
	return bool(sfGraphics.sfRenderWindow_waitEvent(self, event));
end
function RenderWindow:getPosition()
	return sfGraphics.sfRenderWindow_getPosition(self);
end
function RenderWindow:setPosition(position)
	sfGraphics.sfRenderWindow_setPosition(self, position);
end
function RenderWindow:getSize()
	return sfGraphics.sfRenderWindow_getSize(self);
end
function RenderWindow:setSize(size)
	sfGraphics.sfRenderWindow_setSize(self, position);
end
function RenderWindow:setTitle(title)
	sfGraphics.sfRenderWindow_setTitle(self, title);
end
function RenderWindow:setIcon(width, height, pixels)
	sfGraphics.sfRenderWindow_setIcon(self, width, height, pixels);
end
function RenderWindow:setVisible(visible)
	sfGraphics.sfRenderWindow_setVisible(self, visible);
end
function RenderWindow:setMouseCursorVisible(visible)
	sfGraphics.sfRenderWindow_setMouseCursorVisible(self, visible);
end
function RenderWindow:setVerticalSyncEnabled(enabled)
	sfGraphics.sfRenderWindow_setVerticalSyncEnabled(self, enabled);
end
function RenderWindow:setKeyRepeatEnabled(enabled)
	sfGraphics.sfRenderWindow_setKeyRepeatEnabled(self, enabled);
end
function RenderWindow:setActive(active)
	if active == nil then active = true; end
	return bool(sfGraphics.sfRenderWindow_setActive(self, active));
end
function RenderWindow:display()
	sfGraphics.sfRenderWindow_display(self);
end
function RenderWindow:setFramerateLimit(limit)
	sfGraphics.sfRenderWindow_setFramerateLimit(self, limit);
end
function RenderWindow:setJoystickThreshold(threshold)
	sfGraphics.sfRenderWindow_setJoystickThreshold(self, threshold);
end
function RenderWindow:getSystemHandle()
	return sfGraphics.sfRenderWindow_getSystemHandle(self);
end
function RenderWindow:clear(color)
	sfGraphics.sfRenderWindow_clear(self, color or Color.Black);
end
function RenderWindow:setView(view)
	sfGraphics.sfRenderWindow_setView(self, view);
end
function RenderWindow:getView()
	return sfGraphics.sfRenderWindow_getView(self);
end
function RenderWindow:getDefaultView()
	return sfGraphics.sfRenderWindow_getDefaultView(self);
end
function RenderWindow:getViewport(view)
	return sfGraphics.sfRenderWindow_getViewport(self, view);
end
function RenderWindow:mapPixelToCoords(point, view)
	return sfGraphics.sfRenderWindow_mapPixelToCoords(self, point, view);
end
function RenderWindow:mapCoordsToPixel(point, view)
	return sfGraphics.sfRenderWindow_mapCoordsToPixel(self, point, view);
end
function RenderWindow:draw(object_vertices, states_vertexCount, type, states)
	if ffi.istype('sfSprite', object_vertices) then
		sfGraphics.sfRenderWindow_drawSprite(self, object_vertices, states_vertexCount);
	elseif ffi.istype('sfText', object_vertices) then
		sfGraphics.sfRenderWindow_drawText(self, object_vertices, states_vertexCount);
	elseif ffi.istype('sfShape', object_vertices) then
		sfGraphics.sfRenderWindow_drawShape(self, object_vertices, states_vertexCount);
	elseif ffi.istype('sfCircleShape', object_vertices) then
		sfGraphics.sfRenderWindow_drawCircleShape(self, object_vertices, states_vertexCount);
	elseif ffi.istype('sfConvexShape', object_vertices) then
		sfGraphics.sfRenderWindow_drawConvexShape(self, object_vertices, states_vertexCount);
	elseif ffi.istype('sfRectangleShape', object_vertices) then
		sfGraphics.sfRenderWindow_drawRectangleShape(self, object_vertices, states_vertexCount);
	elseif ffi.istype('sfVertexArray', object_vertices) then
		sfGraphics.sfRenderWindow_drawVertexArray(self, object_vertices, states_vertexCount);
	else
		sfGraphics.sfRenderWindow_drawPrimitives(object_vertices, states_vertexCount, type, states);
	end
end
function RenderWindow:pushGLStates()
	sfGraphics.sfRenderWindow_pushGLStates(self);
end
function RenderWindow:popGLStates()
	sfGraphics.sfRenderWindow_popGLStates(self);
end
function RenderWindow:resetGLStates()
	sfGraphics.sfRenderWindow_resetGLStates(self);
end
function RenderWindow:capture()
	return newObj(Image, sfGraphics.sfRenderWindow_capture(self));
end
ffi.metatype('sfRenderWindow', RenderWindow);


--[=[
Vector2i Mouse.getPosition(RenderWindow relativeTo)
nil      Mouse.setPosition(Vector2i position, RenderWindow relativeTo)
]=]

local Window_Mouse_getPosition = Mouse.getPosition;
local Window_Mouse_setPosition = Mouse.setPosition;
Mouse.getPosition = function(relativeTo)
	if ffi.istype('sfRenderWindow', relativeTo) then
		return sfGraphics.sfMouse_getPositionRenderWindow(relativeTo);
	else
		return Window_Mouse_getPosition(relativeTo);
	end
end
Mouse.setPosition = function(position, relativeTo)
	if ffi.istype('sfRenderWindow', relativeTo) then
		sfGraphics.sfMouse_setPositionRenderWindow(position, relativeTo);
	else
		Window_Mouse_setPosition(position, relativeTo);
	end
end


--[=[
bool Shader.isAvailable()
Shader(InputStream vertexShaderStream, InputStream fragmentShaderStream)
Shader(bool useFilenames, string vertexShader, string fragmentShader) ///< Set useFilenames to true if vertexShader and fragmentShader are filenames. Otherwise, vertexShader and fragmentShader are strings of GLSL code.
nil Shader:setParameter(string name, number x)
nil Shader:setParameter(string name, number x, number y)
nil Shader:setParameter(string name, number x, number y, number z)
nil Shader:setParameter(string name, number x, number y, number z, number w)
nil Shader:setParameter(string name, Vector2f vector)
nil Shader:setParameter(string name, Vector3f vector)
nil Shader:setParameter(string name, Color color)
nil Shader:setParameter(string name, Transform transform)
nil Shader:setParameter(string name, Texture texture = nil) ///< If nil, use the `CurrentTexture'
]=]

Shader.isAvailable = function()
	return bool(sfGraphics.sfShader_isAvailable());
end

setmetatable(Shader, { __call = function(cl, vertexShaderStream_useFilenames, fragmentShaderStream_vertexShader, fragmentShader)
	if ffi.istype('sfInputStream', vertexShaderStream_useFilenames) then
		return newObj(Shader, sfGraphics.sfShader_createFromStream(vertexShaderStream_useFilenames, fragmentShaderStream_vertexShader));
	else
		if vertexShaderStream_useFilenames then
			return newObj(Shader, sfGraphics.sfShader_createFromFile(fragmentShaderStream_vertexShader, fragmentShader));
		else
			return newObj(Shader, sfGraphics.sfShader_createFromMemory(fragmentShaderStream_vertexShader, fragmentShader));
		end
	end
end });
function Shader:__gc()
	sfGraphics.sfShader_destroy(self);
end
function Shader:setParameter(name, x_vector_color_transform_texture, y, z, w)
	if x_vector_color_transform_texture == nil then
		sfGraphics.sfShader_setCurrentTextureParameter(self, name, x_vector_color_transform_texture);
	elseif type(x_vector_color_transform_texture) == 'cdata' then
		if ffi.istype('sfVector2f', x_vector_color_transform_texture) then
			sfGraphics.sfShader_setVector2Parameter(self, name, x_vector_color_transform_texture);
		elseif ffi.istype('sfVector3f', x_vector_color_transform_texture) then
			sfGraphics.sfShader_setVector3Parameter(self, name, x_vector_color_transform_texture);
		elseif ffi.istype('sfColor', x_vector_color_transform_texture) then
			sfGraphics.sfShader_setColorParameter(self, name, x_vector_color_transform_texture);
		elseif ffi.istype('sfTransform', x_vector_color_transform_texture) then
			sfGraphics.sfShader_setTransformParameter(self, name, x_vector_color_transform_texture);
		elseif ffi.istype('sfTexture', x_vector_color_transform_texture) then
			sfGraphics.sfShader_setTextureParameter(self, name, x_vector_color_transform_texture);
		end
	else
		if y == nil then
			sfGraphics.sfShader_setFloatParameter(self, name, x_vector_color_transform_texture);
		elseif z == nil then
			sfGraphics.sfShader_setFloat2Parameter(self, name, x_vector_color_transform_texture, y);
		elseif w == nil then
			sfGraphics.sfShader_setFloat3Parameter(self, name, x_vector_color_transform_texture, y, z);
		else
			sfGraphics.sfShader_setFloat4Parameter(self, name, x_vector_color_transform_texture, y, z, w);
		end
	end
end
function Shader:bind()
	sfGraphics.sfShader_bind(self);
end
ffi.metatype('sfShader', Shader);


--[=[
Shape(function getPointCount => function(cdata<void*> userData), function getPoint => function(number index, cdata<void*> userData), cdata<void*> userData = nil)
nil       Shape:setPosition(Vector2f position)
nil       Shape:setPosition(number x, number y)
nil       Shape:setRotation(number angle)
nil       Shape:setScale(Vector2f scale)
nil       Shape:setScale(number x, number y)
nil       Shape:setOrigin(Vector2f origin)
nil       Shape:setOrigin(number x, number y)
Vector2f  Shape:getPosition()
number    Shape:getRotation()
Vector2f  Shape:getScale()
Vector2f  Shape:getOrigin()
nil       Shape:move(Vector2f offset)
nil       Shape:move(number x, number y)
nil       Shape:rotate(number angle)
nil       Shape:scale(Vector2f factors)
nil       Shape:scale(number x, number y)
Transform Shape:getTransform()
Transform Shape:getInverseTransform()
nil       Shape:setTexture(Texture texture, bool resetRect = false)
nil       Shape:setTextureRect(IntRect rect)
nil       Shape:setFillColor(Color color)
nil       Shape:setOutlineColor(Color color)
nil       Shape:setOutlineThickness(Color color)
Texture   Shape:getTexture()
IntRect   Shape:getTextureRect()
Color     Shape:getFillColor()
Color     Shape:getOutlineColor()
number    Shape:getOutlineThickness()
number    Shape:getPointCount()
Vector2f  Shape:getPoint(number index)
FloatRect Shape:getLocalBounds()
FloatRect Shape:getGlobalBounds()
void      Shape:update()
]=]

setmetatable(Shape, { __call = function(cl, getPointCount, getPoint, userData)
	return newObj(Shape, sfGraphics.sfShape_create(getPointCount, getPoint, userData));
end });
function Shape:__gc()
	sfGraphics.sfShape_destroy(self);
end
function Shape:setPosition(position_x, y)
	if ffi.istype('sfVector2f', position_x) then
		sfGraphics.sfShape_setPosition(self, position_x);
	else
		sfGraphics.sfShape_setPosition(self, newObj(Vector2f, ffi.new('sfVector2f', {position_x, y})));
	end
end
function Shape:setRotation(angle)
	sfGraphics.sfShape_setRotation(self, angle);
end
function Shape:setScale(scale_x, y)
	if ffi.istype('sfVector2f', scale_x) then
		sfGraphics.sfShape_setScale(self, scale_x);
	else
		sfGraphics.sfShape_setScale(self, newObj(Vector2f, ffi.new('sfVector2f', {scale_x, y})));
	end
end
function Shape:setOrigin(origin_x, y)
	if ffi.istype('sfVector2f', origin_x) then
		sfGraphics.sfShape_setOrigin(self, origin_x);
	else
		sfGraphics.sfShape_setOrigin(self, newObj(Vector2f, ffi.new('sfVector2f', {origin_x, y})));
	end
end
function Shape:getPosition()
	return sfGraphics.sfShape_getPosition(self);
end
function Shape:getRotation()
	return sfGraphics.sfShape_getRotation(self);
end
function Shape:getScale()
	return sfGraphics.sfShape_getScale(self);
end
function Shape:getOrigin()
	return sfGraphics.sfShape_getOrigin(self);
end
function Shape:move(offset_x, y)
	if ffi.istype('sfVector2f', offset_x) then
		sfGraphics.sfShape_move(self, offset_x);
	else
		sfGraphics.sfShape_move(self, newObj(Vector2f, ffi.new('sfVector2f', {offset_x, y})));
	end
end
function Shape:rotate(angle)
	sfGraphics.sfShape_rotate(self, angle);
end
function Shape:scale(factors_x, y)
	if ffi.istype('sfVector2f', factors_x) then
		sfGraphics.sfShape_scale(self, factors_x);
	else
		sfGraphics.sfShape_scale(self, newObj(Vector2f, ffi.new('sfVector2f', {factors_x, y})));
	end
end
function Shape:getTransform()
	return sfGraphics.sfShape_getTransform(self);
end
function Shape:getInverseTransform()
	return sfGraphics.sfShape_getInverseTransform(self);
end
function Shape:setTexture(texture, resetRect)
	if resetRect == nil then resetRect = false; end
	sfGraphics.sfShape_setTexture(self, texture, resetRect);
end
function Shape:setTextureRect(rect)
	sfGraphics.sfShape_setTextureRect(self, rect);
end
function Shape:setFillColor(color)
	sfGraphics.sfShape_setFillColor(self, color);
end
function Shape:setOutlineColor(color)
	sfGraphics.sfShape_setOutlineColor(self, color);
end
function Shape:setOutlineThickness(thickness)
	sfGraphics.sfShape_setOutlineThickness(self, thickness);
end
function Shape:getTexture()
	return sfGraphics.sfShape_getTexture(self);
end
function Shape:getTextureRect()
	return sfGraphics.sfShape_getTextureRect(self);
end
function Shape:getFillColor()
	return sfGraphics.sfShape_getFillColor(self);
end
function Shape:getOutlineColor()
	return sfGraphics.sfShape_getOutlineColor(self);
end
function Shape:getOutlineThickness()
	return sfGraphics.sfShape_getOutlineThickness(self);
end
function Shape:getPointCount()
	return sfGraphics.sfShape_getPointCount(self);
end
function Shape:getPoint(index)
	return sfGraphics.sfShape_getPoint(self, index);
end
function Shape:getLocalBounds()
	return sfGraphics.sfShape_getLocalBounds(self);
end
function Shape:getGlobalBounds()
	return sfGraphics.sfShape_getGlobalBounds(self);
end
function Shape:update()
	return sfGraphics.sfShape_update(self);
end
ffi.metatype('sfShape', Shape);


--[=[
Sprite()
Sprite(Sprite copy)
Sprite(Texture texture)
Sprite(Texture texture, IntRect rectangle)
Sprite    Sprite:copy()
nil       Sprite:setPosition(Vector2f position)
nil       Sprite:setPosition(number x, number y)
nil       Sprite:setRotation(number angle)
nil       Sprite:setScale(Vector2f scale)
nil       Sprite:setScale(number x, number y)
nil       Sprite:setOrigin(Vector2f origin)
nil       Sprite:setOrigin(number x, number y)
Vector2f  Sprite:getPosition()
number    Sprite:getRotation()
Vector2f  Sprite:getScale()
Vector2f  Sprite:getOrigin()
nil       Sprite:move(Vector2f offset)
nil       Sprite:move(number x, number y)
nil       Sprite:rotate(number angle)
nil       Sprite:scale(Vector2f factors)
nil       Sprite:scale(number x, number y)
Transform Sprite:getTransform()
Transform Sprite:getInverseTransform()
nil       Sprite:setTexture(Texture texture, bool resetRect = false)
nil       Sprite:setTextureRect(IntRect rect)
nil       Sprite:setColor(Color color)
Texture   Sprite:getTexture()
IntRect   Sprite:getTextureRect()
Color     Sprite:getColor()
FloatRect Sprite:getLocalBounds()
FloatRect Sprite:getGlobalBounds()
]=]

setmetatable(Sprite, { __call = function(cl, copy_texture, rectangle)
	if ffi.istype('sfSprite', copy_texture) then
		return newObj(Sprite, sfGraphics.sfSprite_copy(copy_texture));
	else
		local obj = newObj(Sprite, sfGraphics.sfSprite_create());
		if copy_texture ~= nil then
			if rectangle ~= nil then
				sfGraphics.sfSprite_setTexture(obj, copy_texture, false);
				sfGraphics.sfSprite_setTextureRect(obj, rectangle);
			else
				sfGraphics.sfSprite_setTexture(obj, copy_texture, true);
			end
		end
		return obj;
	end
end });
function Sprite:__gc()
	sfGraphics.sfSprite_destroy(self);
end
function Sprite:copy()
	return newObj(Sprite, sfGraphics.sfSprite_copy(self));
end
function Sprite:setPosition(position_x, y)
	if ffi.istype('sfVector2f', position_x) then
		sfGraphics.sfSprite_setPosition(self, position_x);
	else
		sfGraphics.sfSprite_setPosition(self, newObj(Vector2f, ffi.new('sfVector2f', {position_x, y})));
	end
end
function Sprite:setRotation(angle)
	sfGraphics.sfSprite_setRotation(self, angle);
end
function Sprite:setScale(scale_x, y)
	if ffi.istype('sfVector2f', scale_x) then
		sfGraphics.sfSprite_setScale(self, scale_x);
	else
		sfGraphics.sfSprite_setScale(self, newObj(Vector2f, ffi.new('sfVector2f', {scale_x, y})));
	end
end
function Sprite:setOrigin(origin_x, y)
	if ffi.istype('sfVector2f', origin_x) then
		sfGraphics.sfSprite_setOrigin(self, origin_x);
	else
		sfGraphics.sfSprite_setOrigin(self, newObj(Vector2f, ffi.new('sfVector2f', {origin_x, y})));
	end
end
function Sprite:getPosition()
	return sfGraphics.sfSprite_getPosition(self);
end
function Sprite:getRotation()
	return sfGraphics.sfSprite_getRotation(self);
end
function Sprite:getScale()
	return sfGraphics.sfSprite_getScale(self);
end
function Sprite:getOrigin()
	return sfGraphics.sfSprite_getOrigin(self);
end
function Sprite:move(offset_x, y)
	if ffi.istype('sfVector2f', offset_x) then
		sfGraphics.sfSprite_move(self, offset_x);
	else
		sfGraphics.sfSprite_move(self, newObj(Vector2f, ffi.new('sfVector2f', {offset_x, y})));
	end
end
function Sprite:rotate(angle)
	sfGraphics.sfSprite_rotate(self, angle);
end
function Sprite:scale(factors_x, y)
	if ffi.istype('sfVector2f', factors_x) then
		sfGraphics.sfSprite_scale(self, factors_x);
	else
		sfGraphics.sfSprite_scale(self, newObj(Vector2f, ffi.new('sfVector2f', {factors_x, y})));
	end
end
function Sprite:getTransform()
	return sfGraphics.sfSprite_getTransform(self);
end
function Sprite:getInverseTransform()
	return sfGraphics.sfSprite_getInverseTransform(self);
end
function Sprite:setTexture(texture, resetRect)
	if resetRect == nil then resetRect = false; end
	sfGraphics.sfSprite_setTexture(self, texture, resetRect);
end
function Sprite:setTextureRect(rect)
	sfGraphics.sfSprite_setTextureRect(self, rect);
end
function Sprite:setColor(color)
	sfGraphics.sfSprite_setColor(self, color);
end
function Sprite:getTexture()
	return sfGraphics.sfSprite_getTexture(self);
end
function Sprite:getTextureRect()
	return sfGraphics.sfSprite_getTextureRect(self);
end
function Sprite:getColor()
	return sfGraphics.sfSprite_getColor(self);
end
function Sprite:getLocalBounds()
	return sfGraphics.sfSprite_getLocalBounds(self);
end
function Sprite:getGlobalBounds()
	return sfGraphics.sfSprite_getGlobalBounds(self);
end
ffi.metatype('sfSprite', Sprite);


--[=[
Text()
Text(Text copy)
Text(string text, Font font, number characterSize = 30)
Text       Text:copy()
nil        Text:setPosition(Vector2f position)
nil        Text:setPosition(number x, number y)
nil        Text:setRotation(number angle)
nil        Text:setScale(Vector2f scale)
nil        Text:setScale(number x, number y)
nil        Text:setOrigin(Vector2f origin)
nil        Text:setOrigin(number x, number y)
Vector2f   Text:getPosition()
number     Text:getRotation()
Vector2f   Text:getScale()
Vector2f   Text:getOrigin()
nil        Text:move(Vector2f offset)
nil        Text:move(number x, number y)
nil        Text:rotate(number angle)
nil        Text:scale(Vector2f factors)
nil        Text:scale(number x, number y)
Transform  Text:getTransform()
Transform  Text:getInverseTransform()
nil        Text:setString(string text)
nil        Text:setFont(Font font)
nil        Text:setCharacterSize(number size)
nil        Text:setStyle(Text.Style style)
nil        Text:setColor(Color color)
string     Text:getString()
Font       Text:getFont()
number     Text:getCharacterSize()
Text.Style Text:getStyle()
Color      Text:getColor()
Vector2f   Text:findCharacterPos(number index)
FloatRect  Text:getLocalBounds()
FloatRect  Text:getGlobalBounds()

Enum 'Style' [
Text.Style.Regular
Text.Style.Bold
Text.Style.Italic
Text.Style.Underlined
]
]=]

setmetatable(Text, { __call = function(cl, copy_text, font, characterSize)
	if copy_text == nil then
		return newObj(Text, sfGraphics.sfText_create());
	else
		if ffi.istype('sfText', copy_text) then
			return newObj(Text, sfGraphics.sfText_copy(copy_text));
		else
			local obj = newObj(Text, sfGraphics.sfText_create());
			sfGraphics.sfText_setString(obj, copy_text);
			sfGraphics.sfText_setFont(obj, font);
			sfGraphics.sfText_setCharacterSize(obj, characterSize or 30);
			return obj;
		end
	end
end });
function Text:__gc()
	sfGraphics.sfText_destroy(self);
end
function Text:copy()
	return newObj(Text, sfGraphics.sfText_copy(self));
end
function Text:setPosition(position_x, y)
	if ffi.istype('sfVector2f', position_x) then
		sfGraphics.sfText_setPosition(self, position_x);
	else
		sfGraphics.sfText_setPosition(self, newObj(Vector2f, ffi.new('sfVector2f', {position_x, y})));
	end
end
function Text:setRotation(angle)
	sfGraphics.sfText_setRotation(self, angle);
end
function Text:setScale(scale_x, y)
	if ffi.istype('sfVector2f', scale_x) then
		sfGraphics.sfText_setScale(self, scale_x);
	else
		sfGraphics.sfText_setScale(self, newObj(Vector2f, ffi.new('sfVector2f', {scale_x, y})));
	end
end
function Text:setOrigin(origin_x, y)
	if ffi.istype('sfVector2f', origin_x) then
		sfGraphics.sfText_setOrigin(self, origin_x);
	else
		sfGraphics.sfText_setOrigin(self, newObj(Vector2f, ffi.new('sfVector2f', {origin_x, y})));
	end
end
function Text:getPosition()
	return sfGraphics.sfText_getPosition(self);
end
function Text:getRotation()
	return sfGraphics.sfText_getRotation(self);
end
function Text:getScale()
	return sfGraphics.sfText_getScale(self);
end
function Text:getOrigin()
	return sfGraphics.sfText_getOrigin(self);
end
function Text:move(offset_x, y)
	if ffi.istype('sfVector2f', offset_x) then
		sfGraphics.sfText_move(self, offset_x);
	else
		sfGraphics.sfText_move(self, newObj(Vector2f, ffi.new('sfVector2f', {offset_x, y})));
	end
end
function Text:rotate(angle)
	sfGraphics.sfText_rotate(self, angle);
end
function Text:scale(factors_x, y)
	if ffi.istype('sfVector2f', factors_x) then
		sfGraphics.sfText_scale(self, factors_x);
	else
		sfGraphics.sfText_scale(self, newObj(Vector2f, ffi.new('sfVector2f', {factors_x, y})));
	end
end
function Text:getTransform()
	return sfGraphics.sfText_getTransform(self);
end
function Text:getInverseTransform()
	return sfGraphics.sfText_getInverseTransform(self);
end
function Text:setString(text)
	sfGraphics.sfText_setString(self, text);
end
function Text:setFont(font)
	sfGraphics.sfText_setFont(self, font);
end
function Text:setCharacterSize(size)
	sfGraphics.sfText_setCharacterSize(self, size);
end
function Text:setStyle(style)
	sfGraphics.sfText_setStyle(self, style);
end
function Text:setColor(color)
	sfGraphics.sfText_setColor(self, color);
end
function Text:getString()
	return sfGraphics.sfText_getString(self);
end
function Text:getFont()
	return sfGraphics.sfText_getFont(self);
end
function Text:getCharacterSize()
	return sfGraphics.sfText_getCharacterSize(self);
end
function Text:getStyle()
	return sfGraphics.sfText_getStyle(self);
end
function Text:getColor()
	return sfGraphics.sfText_getColor(self);
end
function Text:findCharacterPos(index)
	return sfGraphics.sfText_findCharacterPos(index);
end
function Text:getLocalBounds()
	return sfGraphics.sfText_getLocalBounds(self);
end
function Text:getGlobalBounds()
	return sfGraphics.sfText_getGlobalBounds(self);
end
ffi.metatype('sfText', Text);

Text.Style.Regular    = sfGraphics.sfTextRegular;
Text.Style.Bold       = sfGraphics.sfTextBold;
Text.Style.Italic     = sfGraphics.sfTextItalic;
Text.Style.Underlined = sfGraphics.sfTextUnderlined;


--[=[
number Texture.getMaximumSize()
Texture(Texture copy)
Texture(number width, number height)
Texture(string filename, IntRect area = nil)
Texture(cdata<void*> data, number sizeInBytes, IntRect area = nil)
Texture(InputStream stream, IntRect area = nil)
Texture(Image image, IntRect area = nil)
Texture  Texture:copy()
Vector2u Texture:getSize()
Image    Texture:copyToImage()
nil      Texture:update(cdata<number*> pixels)
nil      Texture:update(cdata<number*> pixels, number width, number height, number x, number y)
nil      Texture:update(Image image)
nil      Texture:update(Image image, number x, number y)
nil      Texture:update(Window window)
nil      Texture:update(Window window, number x, number y)
nil      Texture:update(RenderWindow renderWindow)
nil      Texture:update(RenderWindow renderWindow, number x, number y)
nil      Texture:setSmooth(bool smooth)
bool     Texture:isSmooth()
nil      Texture:setRepeated(bool repeated)
bool     Texture:isRepeated()
nil      Texture:bind()
]=]

Texture.getMaximumSize = function()
	return sfGraphics.sfTexture_getMaximumSize();
end

setmetatable(Texture, { __call = function(cl, copy_width_filename_data_stream_image, height_area_sizeInBytes, area)
	local t = type(copy_width_filename_data_stream_image);
	if t == 'cdata' then
		if ffi.istype('sfTexture', copy_width_filename_data_stream_image) then
			return newObj(Texture, sfGraphics.sfTexture_copy(copy_width_filename_data_stream_image, height_area_sizeInBytes));
		elseif ffi.istype('sfInputStream', copy_width_filename_data_stream_image) then
			return newObj(Texture, sfGraphics.sfTexture_createFromStream(copy_width_filename_data_stream_image, height_area_sizeInBytes));
		elseif ffi.istype('sfImage', copy_width_filename_data_stream_image) then
			return newObj(Texture, sfGraphics.sfTexture_createFromImage(copy_width_filename_data_stream_image, height_area_sizeInBytes));
		else
			return newObj(Texture, sfGraphics.sfTexture_createFromMemory(copy_width_filename_data_stream_image, height_area_sizeInBytes, area));
		end
	elseif t == 'string' then
		return newObj(Texture, sfGraphics.sfTexture_createFromFile(copy_width_filename_data_stream_image, height_area_sizeInBytes));
	else
		return newObj(Texture, sfGraphics.sfTexture_create(copy_width_filename_data_stream_image, height_area_sizeInBytes));
	end
end });
function Texture:__gc()
	sfGraphics.sfTexture_destroy(self);
end
function Texture:copy()
	return newObj(Texture, sfGraphics.sfTexture_copy(self));
end
function Texture:getSize()
	return sfGraphics.sfTexture_getSize(self);
end
function Texture:copyToImage()
	return newObj(Image, sfGraphics.sfTexture_copyToImage(self));
end
function Texture:update(pixels_image_window_renderWindow, width_x, height_y, x, y)
	if ffi.istype('sfImage', pixels_image_window_renderWindow) then
		if width_x == nil then
			sfGraphics.sfTexture_updateFromImage(self, pixels_image_window_renderWindow, 0, 0);
		else
			sfGraphics.sfTexture_updateFromImage(self, pixels_image_window_renderWindow, width_x, height_y);
		end
	elseif ffi.istype('sfWindow', pixels_image_window_renderWindow) then
		if width_x == nil then
			sfGraphics.sfTexture_updateFromWindow(self, pixels_image_window_renderWindow, 0, 0);
		else
			sfGraphics.sfTexture_updateFromWindow(self, pixels_image_window_renderWindow, width_x, height_y);
		end
	elseif ffi.istype('sfRenderWindow', pixels_image_window_renderWindow) then
		if width_x == nil then
			sfGraphics.sfTexture_updateFromRenderWindow(self, pixels_image_window_renderWindow, 0, 0);
		else
			sfGraphics.sfTexture_updateFromRenderWindow(self, pixels_image_window_renderWindow, width_x, height_y);
		end
	else
		if width_x == nil then
			local size = sfGraphics.sfTexture_getSize(self);
			sfGraphics.sfTexture_updateFromRenderWindow(self, pixels_image_window_renderWindow, size.x, size.y, 0, 0);
		else
			sfGraphics.sfTexture_updateFromRenderWindow(self, pixels_image_window_renderWindow, width_x, height_y, x, y);
		end
	end
end
function Texture:setSmooth(smooth)
	sfGraphics.sfTexture_setSmooth(self, smooth);
end
function Texture:isSmooth()
	return bool(sfGraphics.sfTexture_isSmooth(self));
end
function Texture:setRepeated(repeated)
	sfGraphics.sfTexture_setRepeated(self, repeated);
end
function Texture:isRepeated()
	return bool(sfGraphics.sfTexture_isRepeated(self));
end
function Texture:bind()
	return sfGraphics.sfTexture_bind(self);
end
ffi.metatype('sfTexture', Texture);


--[=[
Transform.Identity = Transform()
Transform()
Transform(Transform copy)
Transform(number a00, number a01, number a02, number a10, number a11, number a12, number a20, number a21, number a22)
cdata<float[16]> Transform:getMatrix()
Transform        Transform:getInverse()
Vector2f         Transform:transformPoint(Vector2f point)
Vector2f         Transform:transformPoint(number x, number y)
FloatRect        Transform:transformRect(FloatRect rectangle)
nil              Transform:combine(Transform other)
nil              Transform:translate(Vector2f offset)
nil              Transform:translate(number x, number y)
nil              Transform:rotate(number angle)
nil              Transform:rotate(number angle, Vector2f center)
nil              Transform:rotate(number angle, number centerX, number centerY)
nil              Transform:scale(Vector2f factors)
nil              Transform:scale(number x, number y)
nil              Transform:scale(Vector2f factors, Vector2f center)
nil              Transform:scale(number x, number y, number centerX, number centerY)
nil              Transform:operator * (Transform rhs) ///< Avoid using in a `*=' statement - it is faster to use Transform:combine().
nil              Transform:operator * (Vector2h rhs)
cdata<float[9]>  Transform.matrix
]=]

Transform.Identity = sfGraphics.sfTransform_Identity;

setmetatable(Transform, { __call = function(cl, a00, a01, a02, a10, a11, a12, a20, a21, a22)
	if a00 == nil then
		return newObj(Transform, ffi.new('sfTransform'));
	else
		if ffi.istype('sfTransform', a00) then
			return newObj(Transform, sfGraphics.sfTransform_fromMatrix(a00.matrix[0], a00.matrix[1], a00.matrix[2], a00.matrix[3], a00.matrix[4], a00.matrix[5], a00.matrix[6], a00.matrix[7], a00.matrix[8]));
		else
			return newObj(Transform, sfGraphics.sfTransform_fromMatrix(a00, a01, a02, a10, a11, a12, a20, a21, a22));
		end
	end
end });
function Transform:getMatrix()
	local obj = ffi.new('float[16]');
	sfGraphics.sfTransform_getMatrix(self, obj);
	return obj;
end
function Transform:getInverse()
	return newObj(Transform, sfGraphics.sfTransform_getInverse(self));
end
function Transform:transformPoint(point_x, y)
	if ffi.istype('sfVector2f', point_x) then
		return sfGraphics.sfTransform_transformPoint(self, point_x);
	else
		return sfGraphics.sfTransform_transformPoint(self, ffi.new('sfVertex2f', {point_x, y}));
	end
end
function Transform:transformRect(rectangle)
	return sfGraphics.sfTransform_transformRect(self, rectangle);
end
function Transform:combine(other)
	sfGraphics.sfTransform_combine(self, other);
end
function Transform:translate(offset_x, y)
	if ffi.istype('sfVector2f', offset_x) then
		return sfGraphics.sfTransform_translate(self, offset_x.x, offset_x.y);
	else
		return sfGraphics.sfTransform_translate(self, offset_x, y);
	end
end
function Transform:rotate(angle, center_x, y)
	if center_x == nil then
		return sfGraphics.sfTransform_rotate(self, angle);
	else
		if ffi.istype('sfVector2f', center_x) then
			return sfGraphics.sfTransform_rotateWithCenter(self, angle, center_x.x, center_x.y);
		else
			return sfGraphics.sfTransform_rotateWithCenter(self, angle, center_x, y);
		end
	end
end
function Transform:scale(factors_x, center_y, centerX, centerY)
	if center_y == nil then
		if ffi.istype('sfVector2f', factors_x) then
			return sfGraphics.sfTransform_scale(self, factors_x.x, factors_x.y);
		else
			return sfGraphics.sfTransform_scale(self, factors_x, center_y);
		end
	else
		if ffi.istype('sfVector2f', factors_x) then
			return sfGraphics.sfTransform_rotateWithCenter(self, factors_x.x, factors_x.y, center_y.x, center_y.y);
		else
			return sfGraphics.sfTransform_rotateWithCenter(self, factors_x, center_y, centerX, centerY);
		end
	end
end
function Transform:__mul(rhs)
	if ffi.istype('sfTransform', rhs) then
		local lhs = Transform(self);
		sfGraphics.sfTransform_combine(lhs, rhs);
		return lhs;
	elseif ffi.istype('sfVector2f', rhs) then
		return sfGraphics.sfTransform_transformPoint(self, rhs);
	end
end
ffi.metatype('sfTransform', Transform);


--[=[
Transformable()
Transformable(Transformable copy)
Transformable Transformable:copy()
nil           Transformable:setPosition(Vector2f position)
nil           Transformable:setPosition(number x, number y)
nil           Transformable:setRotation(number angle)
nil           Transformable:setScale(Vector2f scale)
nil           Transformable:setScale(number x, number y)
nil           Transformable:setOrigin(Vector2f origin)
nil           Transformable:setOrigin(number x, number y)
Vector2f      Transformable:getPosition()
number        Transformable:getRotation()
Vector2f      Transformable:getScale()
Vector2f      Transformable:getOrigin()
nil           Transformable:move(Vector2f offset)
nil           Transformable:move(number x, number y)
nil           Transformable:rotate(number angle)
nil           Transformable:scale(Vector2f factors)
nil           Transformable:scale(number x, number y)
Transform     Transformable:getTransform()
Transform     Transformable:getInverseTransform()
]=]

setmetatable(Transformable, { __call = function(cl, copy)
	if ffi.istype('sfTransformable', copy) then
		return newObj(Transformable, sfGraphics.sfTransformable_copy(copy));
	else
		return newObj(Transformable, sfGraphics.sfTransformable_create());
	end
end });
function Transformable:__gc()
	sfGraphics.sfTransformable_destroy(self);
end
function Transformable:copy()
	return newObj(Transformable, sfGraphics.sfTransformable_copy(self));
end
function Transformable:setPosition(position_x, y)
	if ffi.istype('sfVector2f', position_x) then
		sfGraphics.sfTransformable_setPosition(self, position_x);
	else
		sfGraphics.sfTransformable_setPosition(self, newObj(Vector2f, ffi.new('sfVector2f', {position_x, y})));
	end
end
function Transformable:setRotation(angle)
	sfGraphics.sfTransformable_setRotation(self, angle);
end
function Transformable:setScale(scale_x, y)
	if ffi.istype('sfVector2f', scale_x) then
		sfGraphics.sfTransformable_setScale(self, scale_x);
	else
		sfGraphics.sfTransformable_setScale(self, newObj(Vector2f, ffi.new('sfVector2f', {scale_x, y})));
	end
end
function Transformable:setOrigin(origin_x, y)
	if ffi.istype('sfVector2f', origin_x) then
		sfGraphics.sfTransformable_setOrigin(self, origin_x);
	else
		sfGraphics.sfTransformable_setOrigin(self, newObj(Vector2f, ffi.new('sfVector2f', {origin_x, y})));
	end
end
function Transformable:getPosition()
	return sfGraphics.sfTransformable_getPosition(self);
end
function Transformable:getRotation()
	return sfGraphics.sfTransformable_getRotation(self);
end
function Transformable:getScale()
	return sfGraphics.sfTransformable_getScale(self);
end
function Transformable:getOrigin()
	return sfGraphics.sfTransformable_getOrigin(self);
end
function Transformable:move(offset_x, y)
	if ffi.istype('sfVector2f', offset_x) then
		sfGraphics.sfTransformable_move(self, offset_x);
	else
		sfGraphics.sfTransformable_move(self, newObj(Vector2f, ffi.new('sfVector2f', {offset_x, y})));
	end
end
function Transformable:rotate(angle)
	sfGraphics.sfTransformable_rotate(self, angle);
end
function Transformable:scale(factors_x, y)
	if ffi.istype('sfVector2f', factors_x) then
		sfGraphics.sfTransformable_scale(self, factors_x);
	else
		sfGraphics.sfTransformable_scale(self, newObj(Vector2f, ffi.new('sfVector2f', {factors_x, y})));
	end
end
function Transformable:getTransform()
	return sfGraphics.sfTransformable_getTransform(self);
end
function Transformable:getInverseTransform()
	return sfGraphics.sfTransformable_getInverseTransform(self);
end
ffi.metatype('sfTransformable', Transformable);


--[=[
Vertex()
Vertex(Vertex copy)
Vertex(Vector2f position)
Vertex(Vector2f position, Color color)
Vertex(Vector2f position, Vector2f texCoords)
Vertex(Vector2f position, Color color, Vector2f texCoords)
Vector2f Vertex.position
Color    Vertex.color
Vertex2f Vertex.texCoords
]=]

setmetatable(Vertex, { __call = function(cl, copy_position, color_texCoords, texCoords)
	if type(copy_position) == 'nil' then
		local obj = newObj(Vertex, ffi.new('sfVertex'));
		obj.color = Color.Black;
		return obj;
	else
		if ffi.istype('sfVertex', copy_position) then
			return newObj(Vertex, ffi.new('sfVertex', {copy_position.position, copy_position.color, copy_position.texCoords}));
		elseif ffi.istype('sfVector2f', copy_position) then
			local obj    = newObj(Vertex, ffi.new('sfVertex'));
			obj.position = copy_position;
			if texCoords == nil then
				if ffi.istype('sfColor', color_texCoords) then
					obj.color     = color_texCoords;
					return obj;
				elseif ffi.istype('sfVector2f', color_texCoords) then
					obj.color     = Color.Black;
					obj.texCoords = color_texCoords;
					return obj;
				end
			else
				obj.color     = color_texCoords;
				obj.texCoords = texCoords;
				return obj;
			end
			obj.color = Color.Black;
		end
	end
end });
ffi.metatype('sfVertex', Vertex);


--[=[
VertexArray()
VertexArray(VertexArray copy)
VertexArray   VertexArray:copy()
nil           VertexArray:destroy()
number        VertexArray:getVertexCount()
Vertex        VertexArray:getVertex(number index)
nil           VertexArray:clear()
nil           VertexArray:resize(number vertexCount)
nil           VertexArray:append(Vertex vertex)
nil           VertexArray:setPrimitiveType(PrimitiveType type)
PrimitiveType VertexArray:getPrimitiveType()
FloatRect     VertexArray:getBounds()
]=]

setmetatable(VertexArray, { __call = function(cl, copy)
	if ffi.istype('sfVertexArray', copy) then
		return newObj(VertexArray, sfGraphics.sfVertexArray_copy(copy));
	else
		return newObj(VertexArray, sfGraphics.sfVertexArray_create());
	end
end });
function VertexArray:__gc()
	sfGraphics.sfVertexArray_destroy(self);
end
function VertexArray:copy()
	return newObj(VertexArray, sfGraphics.sfVertexArray_copy(self));
end
function VertexArray:getVertexCount()
	return sfGraphics.sfVertexArray_getVertexCount(self);
end
function VertexArray:getVertex(index)
	return sfGraphics.sfVertexArray_getVertex(self, index)
end
function VertexArray:clear()
	sfGraphics.sfVertexArray_clear(self);
end
function VertexArray:resize(vertexCount)
	sfGraphics.sfVertexArray_resize(self, vertexCount);
end
function VertexArray:append(vertex)
	sfGraphics.sfVertexArray_append(self, vertex);
end
function VertexArray:setPrimitiveType(type)
	sfGraphics.sfVertexArray_setPrimitiveType(self, type);
end
function VertexArray:getPrimitiveType()
	return sfGraphics.sfVertexArray_getPrimitiveType(self);
end
function VertexArray:getBounds()
	return sfGraphics.sfVertexArray_getBounds(self);
end
--[[
function VertexArray:__index(k)
	local v = rawget(self, k);
	if v == nil then
		return sfGraphics.sfVertexArray_getVertex(self, tonumber(k));
	end
	return v;
end
function VertexArray:__newindex(k, v)
	local obj = sfGraphics.sfVertexArray_getVertex(self, tonumber(k));
	obj.position  = v.position;
	obj.color     = v.color;
	obj.texCoords = v.texCoords;
end
]]
ffi.metatype('sfVertexArray', VertexArray);


--[=[
View()
View(View copy)
View(FloatRect rectangle)
View(Vector2f center, Vector2f size)
View        View:copy()
nil         View:setCenter(Vector2f center)
nil         View:setCenter(number x, number y)
nil         View:setSize(Vector2f size)
nil         View:setSize(number width, number height)
nil         View:setRotation(number angle)
nil         View:setViewport(FloatRect viewport)
nil         View:reset(FloatRect rectangle)
Vector2f    View:getCenter()
Vector2f    View:getSize()
number      View:getRotation()
FloatRect   View:getViewport()
nil         View:move(Vector2f offset)
nil         View:move(number x, number y)
nil         View:rotate(number angle)
nil         View:zoom(number factor)
]=]

setmetatable(View, { __call = function(cl, copy_rectangle_center, size)
	if ffi.istype('sfView', copy_rectangle_center) then
		return newObj(View, sfGraphics.sfView_copy(copy_rectangle_center));
	elseif ffi.istype('sfFloatRect', copy_rectangle_center) then
		return newObj(View, sfGraphics.sfView_createFromRect(copy_rectangle_center));
	elseif ffi.istype('sfVector2f', copy_rectangle_center) then
		return newObj(View, sfGraphics.sfView_createFromRect(newObj(FloatRect, ffi.new('sfFloatRect', {copy_rectangle_center.x, copy_rectangle_center.y, size.x, size.y}))));
	else
		return newObj(View, sfGraphics.sfView_create());
	end
end });
function View:__gc()
	sfGraphics.sfView_destroy(self);
end
function View:copy()
	return newObj(View, sfGraphics.sfView_copy(self));
end
function View:setCenter(center_x, y)
	if ffi.istype('sfVector2f', center_x) then
		sfGraphics.sfView_setCenter(self, center_x);
	else
		sfGraphics.sfView_setCenter(self, newObj(Vector2f, ffi.new('sfVector2f', {center_x, y})));
	end
end
function View:setSize(size_width, height)
	if ffi.istype('sfVector2f', size_width) then
		sfGraphics.sfView_setSize(self, size_width);
	else
		sfGraphics.sfView_setSize(self, newObj(Vector2f, ffi.new('sfVector2f', {size_width, height})));
	end
end
function View:setRotation(angle)
	sfGraphics.sfView_setRotation(self, angle)
end
function View:setViewport(viewport)
	sfGraphics.sfView_setViewport(self, viewport)
end
function View:reset(rectangle)
	sfGraphics.sfView_reset(self, rectangle)
end
function View:getCenter()
	return sfGraphics.sfView_getCenter(self);
end
function View:getSize()
	return sfGraphics.sfView_getSize(self);
end
function View:getRotation()
	return sfGraphics.sfView_getRotation(self);
end
function View:getViewport()
	return sfGraphics.sfView_getViewport(self);
end
function View:move(offset_x, y)
	if ffi.istype('sfVector2f', offset_x) then
		sfGraphics.sfView_move(self, offset_x);
	else
		sfGraphics.sfView_move(self, newObj(Vector2f, ffi.new('sfVector2f', {offset_x, y})));
	end
end
function View:rotate(angle)
	sfGraphics.sfView_rotate(self, angle);
end
function View:zoom(factor)
	sfGraphics.sfView_zoom(self, factor);
end
ffi.metatype('sfView', View);


RenderStates.Default = RenderStates()

end -- sfGraphics