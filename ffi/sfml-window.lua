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

module 'sf';
require 'ffi/sfml-system';


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
typedef struct sfContext sfContext;
typedef struct sfWindow sfWindow;

typedef void* sfWindowHandle;

typedef enum
{
	sfEvtClosed,
	sfEvtResized,
	sfEvtLostFocus,
	sfEvtGainedFocus,
	sfEvtTextEntered,
	sfEvtKeyPressed,
	sfEvtKeyReleased,
	sfEvtMouseWheelMoved,
	sfEvtMouseButtonPressed,
	sfEvtMouseButtonReleased,
	sfEvtMouseMoved,
	sfEvtMouseEntered,
	sfEvtMouseLeft,
	sfEvtJoystickButtonPressed,
	sfEvtJoystickButtonReleased,
	sfEvtJoystickMoved,
	sfEvtJoystickConnected,
	sfEvtJoystickDisconnected
} sfEventType;

enum
{
	sfJoystickCount       = 8,  ///< Maximum number of supported joysticks
	sfJoystickButtonCount = 32, ///< Maximum number of supported buttons
	sfJoystickAxisCount   = 8   ///< Maximum number of supported axes
};

typedef enum
{
    sfJoystickX,    ///< The X axis
    sfJoystickY,    ///< The Y axis
    sfJoystickZ,    ///< The Z axis
    sfJoystickR,    ///< The R axis
    sfJoystickU,    ///< The U axis
    sfJoystickV,    ///< The V axis
    sfJoystickPovX, ///< The X axis of the point-of-view hat
    sfJoystickPovY  ///< The Y axis of the point-of-view hat
} sfJoystickAxis;

typedef enum
{
	sfKeyUnknown = -1, ///< Unhandled key
	sfKeyA,            ///< The A key
	sfKeyB,            ///< The B key
	sfKeyC,            ///< The C key
	sfKeyD,            ///< The D key
	sfKeyE,            ///< The E key
	sfKeyF,            ///< The F key
	sfKeyG,            ///< The G key
	sfKeyH,            ///< The H key
	sfKeyI,            ///< The I key
	sfKeyJ,            ///< The J key
	sfKeyK,            ///< The K key
	sfKeyL,            ///< The L key
	sfKeyM,            ///< The M key
	sfKeyN,            ///< The N key
	sfKeyO,            ///< The O key
	sfKeyP,            ///< The P key
	sfKeyQ,            ///< The Q key
	sfKeyR,            ///< The R key
	sfKeyS,            ///< The S key
	sfKeyT,            ///< The T key
	sfKeyU,            ///< The U key
	sfKeyV,            ///< The V key
	sfKeyW,            ///< The W key
	sfKeyX,            ///< The X key
	sfKeyY,            ///< The Y key
	sfKeyZ,            ///< The Z key
	sfKeyNum0,         ///< The 0 key
	sfKeyNum1,         ///< The 1 key
	sfKeyNum2,         ///< The 2 key
	sfKeyNum3,         ///< The 3 key
	sfKeyNum4,         ///< The 4 key
	sfKeyNum5,         ///< The 5 key
	sfKeyNum6,         ///< The 6 key
	sfKeyNum7,         ///< The 7 key
	sfKeyNum8,         ///< The 8 key
	sfKeyNum9,         ///< The 9 key
	sfKeyEscape,       ///< The Escape key
	sfKeyLControl,     ///< The left Control key
	sfKeyLShift,       ///< The left Shift key
	sfKeyLAlt,         ///< The left Alt key
	sfKeyLSystem,      ///< The left OS specific key: window (Windows and Linux), apple (MacOS X), ...
	sfKeyRControl,     ///< The right Control key
	sfKeyRShift,       ///< The right Shift key
	sfKeyRAlt,         ///< The right Alt key
	sfKeyRSystem,      ///< The right OS specific key: window (Windows and Linux), apple (MacOS X), ...
	sfKeyMenu,         ///< The Menu key
	sfKeyLBracket,     ///< The [ key
	sfKeyRBracket,     ///< The ] key
	sfKeySemiColon,    ///< The ; key
	sfKeyComma,        ///< The , key
	sfKeyPeriod,       ///< The . key
	sfKeyQuote,        ///< The ' key
	sfKeySlash,        ///< The / key
	sfKeyBackSlash,    ///< The \ key
	sfKeyTilde,        ///< The ~ key
	sfKeyEqual,        ///< The = key
	sfKeyDash,         ///< The - key
	sfKeySpace,        ///< The Space key
	sfKeyReturn,       ///< The Return key
	sfKeyBack,         ///< The Backspace key
	sfKeyTab,          ///< The Tabulation key
	sfKeyPageUp,       ///< The Page up key
	sfKeyPageDown,     ///< The Page down key
	sfKeyEnd,          ///< The End key
	sfKeyHome,         ///< The Home key
	sfKeyInsert,       ///< The Insert key
	sfKeyDelete,       ///< The Delete key
	sfKeyAdd,          ///< +
	sfKeySubtract,     ///< -
	sfKeyMultiply,     ///< *
	sfKeyDivide,       ///< /
	sfKeyLeft,         ///< Left arrow
	sfKeyRight,        ///< Right arrow
	sfKeyUp,           ///< Up arrow
	sfKeyDown,         ///< Down arrow
	sfKeyNumpad0,      ///< The numpad 0 key
	sfKeyNumpad1,      ///< The numpad 1 key
	sfKeyNumpad2,      ///< The numpad 2 key
	sfKeyNumpad3,      ///< The numpad 3 key
	sfKeyNumpad4,      ///< The numpad 4 key
	sfKeyNumpad5,      ///< The numpad 5 key
	sfKeyNumpad6,      ///< The numpad 6 key
	sfKeyNumpad7,      ///< The numpad 7 key
	sfKeyNumpad8,      ///< The numpad 8 key
	sfKeyNumpad9,      ///< The numpad 9 key
	sfKeyF1,           ///< The F1 key
	sfKeyF2,           ///< The F2 key
	sfKeyF3,           ///< The F3 key
	sfKeyF4,           ///< The F4 key
	sfKeyF5,           ///< The F5 key
	sfKeyF6,           ///< The F6 key
	sfKeyF7,           ///< The F7 key
	sfKeyF8,           ///< The F8 key
	sfKeyF9,           ///< The F8 key
	sfKeyF10,          ///< The F10 key
	sfKeyF11,          ///< The F11 key
	sfKeyF12,          ///< The F12 key
	sfKeyF13,          ///< The F13 key
	sfKeyF14,          ///< The F14 key
	sfKeyF15,          ///< The F15 key
	sfKeyPause,        ///< The Pause key
	
	sfKeyCount      ///< Keep last -- the total number of keyboard keys
} sfKeyCode;

typedef enum
{
	sfMouseLeft,       ///< The left mouse button
	sfMouseRight,      ///< The right mouse button
	sfMouseMiddle,     ///< The middle (wheel) mouse button
	sfMouseXButton1,   ///< The first extra mouse button
	sfMouseXButton2,   ///< The second extra mouse button
	
	sfMouseButtonCount ///< Keep last -- the total number of mouse buttons
} sfMouseButton;

typedef struct
{
	sfEventType type;
	sfKeyCode   code;
	sfBool      alt;
	sfBool      control;
	sfBool      shift;
	sfBool      system;
} sfKeyEvent;

typedef struct
{
	sfEventType type;
	sfUint32    unicode;
} sfTextEvent;

typedef struct
{
	sfEventType type;
	int         x;
	int         y;
} sfMouseMoveEvent;

typedef struct
{
	sfEventType   type;
	sfMouseButton button;
	int           x;
	int           y;
} sfMouseButtonEvent;

typedef struct
{
    sfEventType type;
    int         delta;
    int         x;
    int         y;
} sfMouseWheelEvent;

typedef struct
{
	sfEventType    type;
	unsigned int   joystickId;
	sfJoystickAxis axis;
	float          position;
} sfJoystickMoveEvent;

typedef struct
{
	sfEventType  type;
	unsigned int joystickId;
	unsigned int button;
} sfJoystickButtonEvent;

typedef struct
{
	sfEventType  type;
	unsigned int joystickId;
} sfJoystickConnectEvent;

typedef struct
{
	sfEventType  type;
	unsigned int width;
	unsigned int height;
} sfSizeEvent;

typedef union
{
	sfEventType            type; ///< Type of the event
	sfSizeEvent            size;
	sfKeyEvent             key;
	sfTextEvent            text;
	sfMouseMoveEvent       mouseMove;
	sfMouseButtonEvent     mouseButton;
	sfMouseWheelEvent      mouseWheel;
	sfJoystickMoveEvent    joystickMove;
	sfJoystickButtonEvent  joystickButton;
	sfJoystickConnectEvent joystickConnect;
} sfEvent;

typedef struct
{
    unsigned int width;        ///< Video mode width, in pixels
    unsigned int height;       ///< Video mode height, in pixels
    unsigned int bitsPerPixel; ///< Video mode pixel depth, in bits per pixels
} sfVideoMode;

enum
{
    sfNone         = 0,      ///< No border / title bar (this flag and all others are mutually exclusive)
    sfTitlebar     = 1 << 0, ///< Title bar + fixed border
    sfResize       = 1 << 1, ///< Titlebar + resizable border + maximize button
    sfClose        = 1 << 2, ///< Titlebar + close button
    sfFullscreen   = 1 << 3, ///< Fullscreen mode (this flag and all others are mutually exclusive)
    sfDefaultStyle = sfTitlebar | sfResize | sfClose ///< Default window style
};

typedef struct
{
    unsigned int depthBits;         ///< Bits of the depth buffer
    unsigned int stencilBits;       ///< Bits of the stencil buffer
    unsigned int antialiasingLevel; ///< Level of antialiasing
    unsigned int majorVersion;      ///< Major number of the context version to create
    unsigned int minorVersion;      ///< Minor number of the context version to create
} sfContextSettings;

sfContext* sfContext_create(void);
void       sfContext_destroy(sfContext* context);
void       sfContext_setActive(sfContext* context, sfBool active);

sfBool       sfJoystick_isConnected(unsigned int joystick);
unsigned int sfJoystick_getButtonCount(unsigned int joystick);
sfBool       sfJoystick_hasAxis(unsigned int joystick, sfJoystickAxis axis);
sfBool       sfJoystick_isButtonPressed(unsigned int joystick, unsigned int button);
float        sfJoystick_getAxisPosition(unsigned int joystick, sfJoystickAxis axis);
void         sfJoystick_update(void);

sfBool sfKeyboard_isKeyPressed(sfKeyCode key);

sfBool     sfMouse_isButtonPressed(sfMouseButton button);
sfVector2i sfMouse_getPosition(const sfWindow* relativeTo);
void       sfMouse_setPosition(sfVector2i position, const sfWindow* relativeTo);

sfVideoMode        sfVideoMode_getDesktopMode(void);
const sfVideoMode* sfVideoMode_getFullscreenModes(size_t* Count);
sfBool             sfVideoMode_isValid(sfVideoMode mode);

sfWindow*         sfWindow_create(sfVideoMode mode, const char* title, sfUint32 style, const sfContextSettings* settings);
sfWindow*         sfWindow_createUnicode(sfVideoMode mode, const sfUint32* title, sfUint32 style, const sfContextSettings* settings); // *
sfWindow*         sfWindow_createFromHandle(sfWindowHandle handle, const sfContextSettings* settings);
void              sfWindow_destroy(sfWindow* window);
void              sfWindow_close(sfWindow* window);
sfBool            sfWindow_isOpen(const sfWindow* window);
sfContextSettings sfWindow_getSettings(const sfWindow* window);
sfBool            sfWindow_pollEvent(sfWindow* window, sfEvent* event);
sfBool            sfWindow_waitEvent(sfWindow* window, sfEvent* event);
sfVector2i        sfWindow_getPosition(const sfWindow* window);
void              sfWindow_setPosition(sfWindow* window, sfVector2i position);
sfVector2u        sfWindow_getSize(const sfWindow* window);
void              sfWindow_setSize(sfWindow* window, sfVector2u size);
void              sfWindow_setTitle(sfWindow* window, const char* title);
void              sfWindow_setUnicodeTitle(sfWindow* window, const sfUint32* title); // *
void              sfWindow_setIcon(sfWindow* window, unsigned int width, unsigned int height, const sfUint8* pixels);
void              sfWindow_setVisible(sfWindow* window, sfBool visible);
void              sfWindow_setMouseCursorVisible(sfWindow* window, sfBool visible);
void              sfWindow_setVerticalSyncEnabled(sfWindow* window, sfBool enabled);
void              sfWindow_setKeyRepeatEnabled(sfWindow* window, sfBool enabled);
sfBool            sfWindow_setActive(sfWindow* window, sfBool active);
void              sfWindow_display(sfWindow* window);
void              sfWindow_setFramerateLimit(sfWindow* window, unsigned int limit);
void              sfWindow_setJoystickThreshold(sfWindow* window, float threshold);
sfWindowHandle    sfWindow_getSystemHandle(const sfWindow* window);
]];


local sfWindow = ffi.load('csfml-window-2');
if sfWindow then

Context = {};         Context.__index = Context;
ContextSettings = {}; ContextSettings.__index = ContextSettings;
Event = {};           Event.__index = Event;
Event.KeyEvent = {};             Event.KeyEvent.__index = Event.KeyEvent;
Event.TextEvent = {};            Event.TextEvent.__index = Event.TextEvent;
Event.MouseMoveEvent = {};       Event.MouseMoveEvent.__index = Event.MouseMoveEvent;
Event.MouseButtonEvent = {};     Event.MouseButtonEvent.__index = Event.MouseButtonEvent;
Event.MouseWheelEvent = {};      Event.MouseWheelEvent.__index = Event.MouseWheelEvent;
Event.JoystickMoveEvent = {};    Event.JoystickMoveEvent.__index = Event.JoystickMoveEvent;
Event.JoystickButtonEvent = {};  Event.JoystickButtonEvent.__index = Event.JoystickButtonEvent;
Event.JoystickConnectEvent = {}; Event.JoystickConnectEvent.__index = Event.JoystickConnectEvent;
Event.SizeEvent = {};            Event.KeyEvent.__index = Event.KeyEvent;
Joystick = {};        Joystick.__index = Joystick;
Keyboard = {};        Keyboard.__index = Keyboard;
Mouse = {};           Mouse.__index = Mouse;
Style = {};           Style.__index = Style;
VideoMode = {};       VideoMode.__index = VideoMode;
Window = {};          Window.__index = Window;


--[=[
Context()
Context Context:setActive(bool active = true)
]=]

setmetatable(Context, { __call = function(cl)
	return newObj(Context, sfWindow.sfContext_create());
end });
function Context:__gc()
	sfWindow.sfContext_destroy(self);
end
function Context:setActive(active)
	if active == nil then
		active = true;
	end
	sfWindow.sfContext_setActive(self, active);
end
ffi.metatype('sfContext', Context);


--[=[
ContextSettings(ContextSettings copy)
ContextSettings(number depthBits = 0, number stencilBits = 0, number antialiasingLevel = 0, number majorVersion = 2, number minorVersion = 0)
number          ContextSettings.depthBits
number          ContextSettings.stencilBits
number          ContextSettings.antialiasingLevel
number          ContextSettings.majorVersion
number          ContextSettings.minorVersion
]=]

setmetatable(ContextSettings, { __call = function(cl, copy_depthBits, stencilBits, antialiasingLevel, majorVersion, minorVersion)
	if ffi.istype('sfContextSettings', copy_depthBits) then
		return newObj(ContextSettings, ffi.new('sfContextSettings', {copy_depthBits.depthBits, copy_depthBits.stencilBits, copy_depthBits.antialiasingLevel, copy_depthBits.majorVersion, copy_depthBits.minorVersion}));
	else
		local obj = newObj(ContextSettings, ffi.new('sfContextSettings'));
		if copy_depthBits == nil    then obj.depthBits = 0;         else obj.depthBits = copy_depthBits; end
		if stencilBits == nil       then obj.stencilBits = 0;       else obj.stencilBits = stencilBits; end
		if antialiasingLevel == nil then obj.antialiasingLevel = 0; else obj.antialiasingLevel = antialiasingLevel; end
		if majorVersion == nil      then obj.majorVersion = 2;      else obj.majorVersion = majorVersion; end
		if minorVersion == nil      then obj.minorVersion = 0;      else obj.minorVersion = minorVersion; end
		return obj;
	end
end });
ffi.metatype('sfContextSettings', ContextSettings);


--[=[
Event()
Event.EventType            type
Event.KeyEvent             key
Event.TextEvent            text
Event.MouseMoveEvent       mouseMove
Event.MouseButtonEvent     mouseButton
Event.MouseWheelEvent      mouseWheel
Event.JoystickMoveEvent    joystickMove
Event.JoystickButtonEvent  joystickButton
Event.JoystickConnectEvent joystickConnect
Event.SizeEvent            size

EventType Event.KeyEvent.type
KeyCode   Event.KeyEvent.code
number    Event.KeyEvent.alt     (Note that these modifiers are not booleans, but numbers [either 0 - false, or 1 - true.])
number    Event.KeyEvent.control
number    Event.KeyEvent.shift
number    Event.KeyEvent.system

EventType Event.TextEvent.type
number    Event.TextEvent.unicode

EventType Event.MouseMoveEvent.type
number    Event.MouseMoveEvent.x
number    Event.MouseMoveEvent.y

EventType   Event.MouseButtonEvent.type
MouseButton Event.MouseButtonEvent.button
number      Event.MouseButtonEvent.x
number      Event.MouseButtonEvent.y

EventType Event.MouseWheelEvent.type
number    Event.MouseWheelEvent.delta
number    Event.MouseWheelEvent.x
number    Event.MouseWheelEvent.y

EventType Event.JoystickMoveEvent.type
number    Event.JoystickMoveEvent.joystickId
Axis      Event.JoystickMoveEvent.axis
number    Event.JoystickMoveEvent.position

EventType Event.JoystickButtonEvent.type
number    Event.JoystickButtonEvent.joystickId
number    Event.JoystickButtonEvent.button

EventType Event.JoystickConnectEvent.type
number    Event.JoystickConnectEvent.joystickId

EventType Event.SizeEvent.type
number    Event.SizeEvent.width
number    Event.SizeEvent.height

Enum 'EventType'
[
Event.Closed
Event.Resized
Event.LostFocus
Event.GainedFocus
Event.TextEntered
Event.KeyPressed
Event.KeyReleased
Event.MouseWheelMoved
Event.MouseButtonPressed
Event.MouseButtonReleased
Event.MouseMoved
Event.MouseEntered
Event.MouseLeft
Event.JoystickButtonPressed
Event.JoystickButtonReleased
Event.JoystickMoved
Event.JoystickConnected
Event.JoystickDisconnected
]
]=]


setmetatable(Event, { __call = function(cl)
	return newObj(Event, ffi.new('sfEvent'));
end });

Event.Closed                 = sfWindow.sfEvtClosed;
Event.Resized                = sfWindow.sfEvtResized;
Event.LostFocus              = sfWindow.sfEvtLostFocus;
Event.GainedFocus            = sfWindow.sfEvtGainedFocus;
Event.TextEntered            = sfWindow.sfEvtTextEntered;
Event.KeyPressed             = sfWindow.sfEvtKeyPressed;
Event.KeyReleased            = sfWindow.sfEvtKeyReleased;
Event.MouseWheelMoved        = sfWindow.sfEvtMouseWheelMoved;
Event.MouseButtonPressed     = sfWindow.sfEvtMouseButtonPressed;
Event.MouseButtonReleased    = sfWindow.sfEvtMouseButtonReleased;
Event.MouseMoved             = sfWindow.sfEvtMouseMoved;
Event.MouseEntered           = sfWindow.sfEvtMouseEntered;
Event.MouseLeft              = sfWindow.sfEvtMouseLeft;
Event.JoystickButtonPressed  = sfWindow.sfEvtJoystickButtonPressed;
Event.JoystickButtonReleased = sfWindow.sfEvtJoystickButtonReleased;
Event.JoystickMoved          = sfWindow.sfEvtJoystickMoved;
Event.JoystickConnected      = sfWindow.sfEvtJoystickConnected;
Event.JoystickDisconnected   = sfWindow.sfEvtJoystickDisconnected;

ffi.metatype('sfEvent', Event);
ffi.metatype('sfKeyEvent', Event.KeyEvent);
ffi.metatype('sfTextEvent', Event.TextEvent);
ffi.metatype('sfMouseMoveEvent', Event.MouseMoveEvent);
ffi.metatype('sfMouseButtonEvent', Event.MouseButtonEvent);
ffi.metatype('sfMouseWheelEvent', Event.MouseWheelEvent);
ffi.metatype('sfJoystickMoveEvent', Event.JoystickMoveEvent);
ffi.metatype('sfJoystickButtonEvent', Event.JoystickButtonEvent);
ffi.metatype('sfJoystickConnectEvent', Event.JoystickConnectEvent);
ffi.metatype('sfSizeEvent', Event.SizeEvent);


--[=[
bool   Joystick.isConnected(number joystickId)
number Joystick.getButtonCount(number joystickId)
bool   Joystick.hasAxis(number joystickId, Axis sxis)
bool   Joystick.isButtonPressed(number joystickId, number button)
number Joystick.getAxisPosition(number joystickId, Axis axis)
nil    Joystick.update()

Enum 'Axis'
[
Joystick.X
Joystick.Y
Joystick.Z
Joystick.R
Joystick.U
Joystick.V
Joystick.PovX
Joystick.PovY
]

Joystick.Count       = 8
Joystick.ButtonCount = 32
Joystick.AxisCount   = 8
]=]

Joystick.isConnected = function(joystickId)
	return bool(sfWindow.sfJoystick_isConnected(joystickId));
end
Joystick.getButtonCount = function(joystickId)
	return sfWindow.sfJoystick_getButtonCount(joystickId);
end
Joystick.hasAxis = function(joystickId, axis)
	return bool(sfWindow.sfJoystick_hasAxis(joystickId, axis));
end
Joystick.isButtonPressed = function(joystickId, button)
	return bool(sfWindow.sfJoystick_isButtonPressed(joystickId, button));
end
Joystick.getAxisPosition = function(joystickId, axis)
	return sfWindow.sfJoystick_getAxisPosition(joystickId, axis);
end
Joystick.update = function()
	sfWindow.sfJoystick_update();
end

Joystick.X           = sfWindow.sfJoystickX;
Joystick.Y           = sfWindow.sfJoystickY;
Joystick.Z           = sfWindow.sfJoystickZ;
Joystick.R           = sfWindow.sfJoystickR;
Joystick.U           = sfWindow.sfJoystickU;
Joystick.V           = sfWindow.sfJoystickV;
Joystick.PovX        = sfWindow.sfJoystickPovX;
Joystick.PovY        = sfWindow.sfJoystickPovY;

Joystick.Count       = sfWindow.sfJoystickCount;
Joystick.ButtonCount = sfWindow.sfJoystickButtonCount;
Joystick.AxisCount   = sfWindow.sfJoystickAxisCount;


--[=[
bool Keyboard.isKeyPressed(KeyCode key)

Enum 'KeyCode'
[
Keyboard.Unknown
Keyboard.A
Keyboard.B
Keyboard.C
Keyboard.D
Keyboard.E
Keyboard.F
Keyboard.G
Keyboard.H
Keyboard.I
Keyboard.J
Keyboard.K
Keyboard.L
Keyboard.M
Keyboard.N
Keyboard.O
Keyboard.P
Keyboard.Q
Keyboard.R
Keyboard.S
Keyboard.T
Keyboard.U
Keyboard.V
Keyboard.W
Keyboard.X
Keyboard.Y
Keyboard.Z
Keyboard.Num0
Keyboard.Num1
Keyboard.Num2
Keyboard.Num3
Keyboard.Num4
Keyboard.Num5
Keyboard.Num6
Keyboard.Num7
Keyboard.Num8
Keyboard.Num9
Keyboard.Escape
Keyboard.LControl
Keyboard.LShift
Keyboard.LAlt
Keyboard.LSystem
Keyboard.RControl
Keyboard.RShift
Keyboard.RAlt
Keyboard.RSystem
Keyboard.Menu
Keyboard.LBracket
Keyboard.RBracket
Keyboard.SemiColon
Keyboard.Comma
Keyboard.Period
Keyboard.Quote
Keyboard.Slash
Keyboard.BackSlash
Keyboard.Tilde
Keyboard.Equal
Keyboard.Dash
Keyboard.Space
Keyboard.Return
Keyboard.Back
Keyboard.Tab
Keyboard.PageUp
Keyboard.PageDown
Keyboard.End
Keyboard.Home
Keyboard.Insert
Keyboard.Delete
Keyboard.Add
Keyboard.Subtract
Keyboard.Multiply
Keyboard.Divide
Keyboard.Left
Keyboard.Right
Keyboard.Up
Keyboard.Down
Keyboard.Numpad0
Keyboard.Numpad1
Keyboard.Numpad2
Keyboard.Numpad3
Keyboard.Numpad4
Keyboard.Numpad5
Keyboard.Numpad6
Keyboard.Numpad7
Keyboard.Numpad8
Keyboard.Numpad9
Keyboard.F1
Keyboard.F2
Keyboard.F3
Keyboard.F4
Keyboard.F5
Keyboard.F6
Keyboard.F7
Keyboard.F8
Keyboard.F9
Keyboard.F10
Keyboard.F11
Keyboard.F12
Keyboard.F13
Keyboard.F14
Keyboard.F15
Keyboard.Pause

Keyboard.Count -- the total number of keyboard keys
]
]=]

Keyboard.isKeyPressed = function(key)
	return bool(sfWindow.sfKeyboard_isKeyPressed(key));
end

Keyboard.Unknown   = sfWindow.sfKeyUnknown
Keyboard.A         = sfWindow.sfKeyA
Keyboard.B         = sfWindow.sfKeyB
Keyboard.C         = sfWindow.sfKeyC
Keyboard.D         = sfWindow.sfKeyD
Keyboard.E         = sfWindow.sfKeyE
Keyboard.F         = sfWindow.sfKeyF
Keyboard.G         = sfWindow.sfKeyG
Keyboard.H         = sfWindow.sfKeyH
Keyboard.I         = sfWindow.sfKeyI
Keyboard.J         = sfWindow.sfKeyJ
Keyboard.K         = sfWindow.sfKeyK
Keyboard.L         = sfWindow.sfKeyL
Keyboard.M         = sfWindow.sfKeyM
Keyboard.N         = sfWindow.sfKeyN
Keyboard.O         = sfWindow.sfKeyO
Keyboard.P         = sfWindow.sfKeyP
Keyboard.Q         = sfWindow.sfKeyQ
Keyboard.R         = sfWindow.sfKeyR
Keyboard.S         = sfWindow.sfKeyS
Keyboard.T         = sfWindow.sfKeyT
Keyboard.U         = sfWindow.sfKeyU
Keyboard.V         = sfWindow.sfKeyV
Keyboard.W         = sfWindow.sfKeyW
Keyboard.X         = sfWindow.sfKeyX
Keyboard.Y         = sfWindow.sfKeyY
Keyboard.Z         = sfWindow.sfKeyZ
Keyboard.Num0      = sfWindow.sfKeyNum0
Keyboard.Num1      = sfWindow.sfKeyNum1
Keyboard.Num2      = sfWindow.sfKeyNum2
Keyboard.Num3      = sfWindow.sfKeyNum3
Keyboard.Num4      = sfWindow.sfKeyNum4
Keyboard.Num5      = sfWindow.sfKeyNum5
Keyboard.Num6      = sfWindow.sfKeyNum6
Keyboard.Num7      = sfWindow.sfKeyNum7
Keyboard.Num8      = sfWindow.sfKeyNum8
Keyboard.Num9      = sfWindow.sfKeyNum9
Keyboard.Escape    = sfWindow.sfKeyEscape
Keyboard.LControl  = sfWindow.sfKeyLControl
Keyboard.LShift    = sfWindow.sfKeyLShift
Keyboard.LAlt      = sfWindow.sfKeyLAlt
Keyboard.LSystem   = sfWindow.sfKeyLSystem
Keyboard.RControl  = sfWindow.sfKeyRControl
Keyboard.RShift    = sfWindow.sfKeyRShift
Keyboard.RAlt      = sfWindow.sfKeyRAlt
Keyboard.RSystem   = sfWindow.sfKeyRSystem
Keyboard.Menu      = sfWindow.sfKeyMenu
Keyboard.LBracket  = sfWindow.sfKeyLBracket
Keyboard.RBracket  = sfWindow.sfKeyRBracket
Keyboard.SemiColon = sfWindow.sfKeySemiColon
Keyboard.Comma     = sfWindow.sfKeyComma
Keyboard.Period    = sfWindow.sfKeyPeriod
Keyboard.Quote     = sfWindow.sfKeyQuote
Keyboard.Slash     = sfWindow.sfKeySlash
Keyboard.BackSlash = sfWindow.sfKeyBackSlash
Keyboard.Tilde     = sfWindow.sfKeyTilde
Keyboard.Equal     = sfWindow.sfKeyEqual
Keyboard.Dash      = sfWindow.sfKeyDash
Keyboard.Space     = sfWindow.sfKeySpace
Keyboard.Return    = sfWindow.sfKeyReturn
Keyboard.Back      = sfWindow.sfKeyBack
Keyboard.Tab       = sfWindow.sfKeyTab
Keyboard.PageUp    = sfWindow.sfKeyPageUp
Keyboard.PageDown  = sfWindow.sfKeyPageDown
Keyboard.End       = sfWindow.sfKeyEnd
Keyboard.Home      = sfWindow.sfKeyHome
Keyboard.Insert    = sfWindow.sfKeyInsert
Keyboard.Delete    = sfWindow.sfKeyDelete
Keyboard.Add       = sfWindow.sfKeyAdd
Keyboard.Subtract  = sfWindow.sfKeySubtract
Keyboard.Multiply  = sfWindow.sfKeyMultiply
Keyboard.Divide    = sfWindow.sfKeyDivide
Keyboard.Left      = sfWindow.sfKeyLeft
Keyboard.Right     = sfWindow.sfKeyRight
Keyboard.Up        = sfWindow.sfKeyUp
Keyboard.Down      = sfWindow.sfKeyDown
Keyboard.Numpad0   = sfWindow.sfKeyNumpad0
Keyboard.Numpad1   = sfWindow.sfKeyNumpad1
Keyboard.Numpad2   = sfWindow.sfKeyNumpad2
Keyboard.Numpad3   = sfWindow.sfKeyNumpad3
Keyboard.Numpad4   = sfWindow.sfKeyNumpad4
Keyboard.Numpad5   = sfWindow.sfKeyNumpad5
Keyboard.Numpad6   = sfWindow.sfKeyNumpad6
Keyboard.Numpad7   = sfWindow.sfKeyNumpad7
Keyboard.Numpad8   = sfWindow.sfKeyNumpad8
Keyboard.Numpad9   = sfWindow.sfKeyNumpad9
Keyboard.F1        = sfWindow.sfKeyF1
Keyboard.F2        = sfWindow.sfKeyF2
Keyboard.F3        = sfWindow.sfKeyF3
Keyboard.F4        = sfWindow.sfKeyF4
Keyboard.F5        = sfWindow.sfKeyF5
Keyboard.F6        = sfWindow.sfKeyF6
Keyboard.F7        = sfWindow.sfKeyF7
Keyboard.F8        = sfWindow.sfKeyF8
Keyboard.F9        = sfWindow.sfKeyF9
Keyboard.F10       = sfWindow.sfKeyF10
Keyboard.F11       = sfWindow.sfKeyF11
Keyboard.F12       = sfWindow.sfKeyF12
Keyboard.F13       = sfWindow.sfKeyF13
Keyboard.F14       = sfWindow.sfKeyF14
Keyboard.F15       = sfWindow.sfKeyF15
Keyboard.Pause     = sfWindow.sfKeyPause
Keyboard.Count     = sfWindow.sfKeyCount


--[=[
bool     Mouse.isButtonPressed(MouseButton button)
Vector2i Mouse.getPosition(Window relativeTo = nil)
nil      Mouse.setPosition(Vector2i position, Window relativeTo = nil)

Enum 'MouseButton'
[
Mouse.Left
Mouse.Right
Mouse.Middle
Mouse.XButton1
Mouse.XButton2

Mouse.Count -- the total number of mouse buttons
]
]=]

Mouse.isButtonPressed = function(button)
	return bool(sfWindow.sfMouse_isButtonPressed(button));
end
Mouse.getPosition = function(relativeTo)
	return sfWindow.sfMouse_getPosition(relativeTo);
end
Mouse.setPosition = function(position, relativeTo)
	sfWindow.sfMouse_setPosition(position, relativeTo);
end

Mouse.Left     = sfWindow.sfMouseLeft;
Mouse.Right    = sfWindow.sfMouseRight;
Mouse.Middle   = sfWindow.sfMouseMiddle;
Mouse.XButton1 = sfWindow.sfMouseXButton1;
Mouse.XButton2 = sfWindow.sfMouseXButton2;
Mouse.Count    = sfWindow.sfMouseButtonCount;


--[=[
Enum 'Style' [
Style.None
Style.Titlebar
Style.Resize
Style.Close
Style.Fullscreen
Style.Default    = Style.Titlebar + Style.Resize + Style.Close
]
]=]

Style.None       = sfWindow.sfNone;
Style.Titlebar   = sfWindow.sfTitlebar;
Style.Resize     = sfWindow.sfResize;
Style.Close      = sfWindow.sfClose;
Style.Fullscreen = sfWindow.sfFullscreen;
Style.Default    = sfWindow.sfDefaultStyle;


--[=[
VideoMode(VideoMode copy)
VideoMode(number width = 0, number height = 0, number bitsPerPixel = 32)
number    VideoMode.width
number    VideoMode.height
number    VideoMode.bitsPerPixel
]=]

setmetatable(VideoMode, { __call = function(cl, copy_width, height, bitsPerPixel)
	if ffi.istype('sfVideoMode', copy_width) then
		return newObj(VideoMode, ffi.new('sfVideoMode', {copy_width.width, copy_width.height, copy_width.bitsPerPixel}));
	else
		local obj = newObj(VideoMode, ffi.new('sfVideoMode'));
		if copy_width == nil   then obj.width = 0;         else obj.width = copy_width; end
		if height == nil       then obj.height = 0;        else obj.height = height; end
		if bitsPerPixel == nil then obj.bitsPerPixel = 32; else obj.bitsPerPixel = bitsPerPixel; end
		return obj;
	end
end });
ffi.metatype('sfVideoMode', VideoMode);


--[=[
Window(WindowHandle handle, ContextSettings settings)
Window(VideoMode mode, string title, Style style = Style.Default, ContextSettings settings = ContextSettings())
nil             Window:close()
bool            Window:isOpen()
ContextSettings Window:getSettings()
bool            Window:pollEvent(OUT Event event)
bool            Window:waitEvent(OUT Event event)
Vector2i        Window:getPosition()
nil             Window:setPosition(Vector2i position)
Vector2i        Window:getSize()
nil             Window:setSize(Vector2u size)
void            Window:setTitle(string title)
void            Window:setIcon(number width, number height, cdata<number*> pixels)
void            Window:setVisible(bool visible)
void            Window:setMouseCursorVisible(bool visible)
void            Window:setVerticalSyncEnabled(bool enabled)
void            Window:setKeyRepeatEnabled(bool enabled)
bool            Window:setActive(bool active = true)
void            Window:display()
void            Window:setFramerateLimit(number limit)
void            Window:setJoystickThreshold(number threshold)
WindowHandle    Window:getSystemHandle()
]=]

setmetatable(Window, { __call = function(cl, mode_handle, title_settings, style, settings)
	if ffi.istype('sfWindowHandle', mode_handle) then
		return newObj(Window, sfWindow.sfWindow_createFromHandle(mode_handle, title_settings));
	end
	return newObj(Window, sfWindow.sfWindow_create(mode_handle, title_settings, style or Style.Default, settings or ContextSettings()));
end });
function Window:__gc()
	sfWindow.sfWindow_destroy(self);
end
function Window:close()
	sfWindow.sfWindow_close(self);
end
function Window:isOpen()
	return bool(sfWindow.sfWindow_isOpen(self));
end
function Window:getSettings()
	return sfWindow.sfWindow_getSettings(self);
end
function Window:pollEvent(event)
	return bool(sfWindow.sfWindow_pollEvent(self, event));
end
function Window:waitEvent(event)
	return bool(sfWindow.sfWindow_waitEvent(self, event));
end
function Window:getPosition()
	return sfWindow.sfWindow_getPosition(self);
end
function Window:setPosition(position)
	sfWindow.sfWindow_setPosition(self, position);
end
function Window:getSize()
	return sfWindow.sfWindow_getSize(self);
end
function Window:setSize(size)
	sfWindow.sfWindow_setSize(self, position);
end
function Window:setTitle(title)
	sfWindow.sfWindow_setTitle(self, title);
end
function Window:setIcon(width, height, pixels)
	sfWindow.sfWindow_setIcon(self, width, height, pixels);
end
function Window:setVisible(visible)
	sfWindow.sfWindow_setVisible(self, visible);
end
function Window:setMouseCursorVisible(visible)
	sfWindow.sfWindow_setMouseCursorVisible(self, visible);
end
function Window:setVerticalSyncEnabled(enabled)
	sfWindow.sfWindow_setVerticalSyncEnabled(self, enabled);
end
function Window:setKeyRepeatEnabled(enabled)
	sfWindow.sfWindow_setKeyRepeatEnabled(self, enabled);
end
function Window:setActive(active)
	if active == nil then active = true; end
	return bool(sfWindow.sfWindow_setActive(self, active));
end
function Window:display()
	sfWindow.sfWindow_display(self);
end
function Window:setFramerateLimit(limit)
	sfWindow.sfWindow_setFramerateLimit(self, limit);
end
function Window:setJoystickThreshold(threshold)
	sfWindow.sfWindow_setJoystickThreshold(self, threshold);
end
function Window:getSystemHandle()
	return sfWindow.sfWindow_getSystemHandle(self);
end
ffi.metatype('sfWindow', Window);

end -- sfWindow