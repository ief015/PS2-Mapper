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
local tonumber = tonumber;

module 'sf';


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
typedef int             sfBool;
typedef int8_t          sfInt8;
typedef uint8_t         sfUint8;
typedef int16_t         sfInt16;
typedef uint16_t        sfUint16;
typedef int32_t         sfInt32;
typedef uint32_t        sfUint32;
typedef int64_t         sfInt64;
typedef uint64_t        sfUint64;

typedef enum {
	CSFML_VERSION_MAJOR = 2,
	CSFML_VERSION_MINOR = 1,
};

enum {
   sfFalse = 0,
   sfTrue = 1,
};

typedef struct
{
	int x;
	int y;
} sfVector2i;

typedef struct
{
	unsigned int x;
	unsigned int y;
} sfVector2u;

typedef struct
{
	float x;
	float y;
} sfVector2f;

typedef struct
{
	float x;
	float y;
	float z;
} sfVector3f;

typedef struct
{
	sfInt64 microseconds;
} sfTime;

typedef struct sfClock  sfClock;
typedef struct sfMutex  sfMutex;
typedef struct sfThread sfThread;

typedef sfInt64 (*sfInputStreamReadFunc)    (void* data, sfInt64 size, void* userData);
typedef sfInt64 (*sfInputStreamSeekFunc)    (sfInt64 position, void* userData);
typedef sfInt64 (*sfInputStreamTellFunc)    (void* userData);
typedef sfInt64 (*sfInputStreamGetSizeFunc) (void* userData);

typedef struct sfInputStream
{
	sfInputStreamReadFunc    read;     ///< Function to read data from the stream
	sfInputStreamSeekFunc    seek;     ///< Function to set the current read position
	sfInputStreamTellFunc    tell;     ///< Function to get the current read position
	sfInputStreamGetSizeFunc getSize;  ///< Function to get the total number of bytes in the stream
	void*                    userData; ///< User data that will be passed to the callbacks
} sfInputStream;

sfClock*  sfClock_create(void);
sfClock*  sfClock_copy(const sfClock* clock);
void      sfClock_destroy(sfClock* clock);
sfTime    sfClock_getElapsedTime(const sfClock* clock);
sfTime    sfClock_restart(sfClock* clock);

sfTime  sfTime_Zero;
float   sfTime_asSeconds(sfTime time);
sfInt32 sfTime_asMilliseconds(sfTime time);
sfInt64 sfTime_asMicroseconds(sfTime time);
sfTime  sfSeconds(float amount);
sfTime  sfMilliseconds(sfInt32 amount);
sfTime  sfMicroseconds(sfInt64 amount);

sfMutex* sfMutex_create(void);
void     sfMutex_destroy(sfMutex* mutex);
void     sfMutex_lock(sfMutex* mutex);
void     sfMutex_unlock(sfMutex* mutex);

void sfSleep(sfTime duration);

sfThread* sfThread_create(void (*function)(void*), void* userData);
void      sfThread_destroy(sfThread* thread);
void      sfThread_launch(sfThread* thread);
void      sfThread_wait(sfThread* thread);
void      sfThread_terminate(sfThread* thread);
]];


--[=[
Version.Major = CSFML_VERSION_MAJOR
Version.Minor = CSFML_VERSION_MINOR
]=]

Version = {};
Version.Major = ffi.C.CSFML_VERSION_MAJOR;
Version.Minor = ffi.C.CSFML_VERSION_MINOR;


local sfSystem = ffi.load('csfml-system-2');
if sfSystem then

Clock = {};       Clock.__index = Clock;
Time = {};        Time.__index = Time;
InputStream = {}; InputStream.__index = InputStream;
Mutex = {};       Mutex.__index = Mutex;
Thread = {};      Thread.__index = Thread;
Vector2i = {};    Vector2i.__index = Vector2i;
Vector2u = {};    Vector2u.__index = Vector2u;
Vector2f = {};    Vector2f.__index = Vector2f;
Vector3f = {};    Vector3f.__index = Vector3f;


--[=[
Clock()
Clock(Clock copy)
Clock Clock:copy(Clock clk)
Time  Clock:getElapsedTime()
Time  Clock:restart()
]=]

setmetatable(Clock, { __call = function(cl, copy)
	if ffi.istype('sfClock', copy) then
		return newObj(Clock, sfSystem.sfClock_copy(copy));
	end
	return newObj(Clock, sfSystem.sfClock_create());
end });
function Clock:__gc()
	sfSystem.sfClock_destroy(self);
end
function Clock:copy()
	return sfSystem.sfClock_copy(self);
end
function Clock:getElapsedTime()
	return sfSystem.sfClock_getElapsedTime(self);
end
function Clock:restart()
	return sfSystem.sfClock_restart(self);
end
ffi.metatype('sfClock', Clock);


--[=[
Time.Zero = microseconds(0)
Time   seconds(number seconds)
Time   milliseconds(number millis)
Time   microseconds(number micros)
number Time:asSeconds()
number Time:asMilliseconds()
number Time:asMicroseconds()
bool   Time:operator < (Time right)
bool   Time:operator <= (Time right)
bool   Time:operator > (Time right)
bool   Time:operator >= (Time right)
bool   Time:operator == (Time right)
bool   Time:operator != (Time right)
Time   Time:operator + (Time right)
Time   Time:operator - (Time right)
Time   Time:operator * (number right)
Time   Time:operator / (number right)
]=]

Time.Zero = sfSystem.sfTime_Zero;
function seconds(amount)
	return newObj(Time, sfSystem.sfSeconds(amount));
end
function milliseconds(amount)
	return newObj(Time, sfSystem.sfMilliseconds(amount));
end
function microseconds(amount)
	return newObj(Time, sfSystem.sfMicroseconds(amount));
end
function Time:asSeconds()
	return tonumber(sfSystem.sfTime_asSeconds(self));
end
function Time:asMilliseconds()
	return tonumber(sfSystem.sfTime_asMilliseconds(self));
end
function Time:asMicroseconds()
	return tonumber(sfSystem.sfTime_asMicroseconds(self));
end
function Time:__lt(rhs)
	return self.microseconds < rhs.microseconds;
end
function Time:__le(rhs)
	return self.microseconds <= rhs.microseconds;
end
function Time:__eq(rhs)
	return self.microseconds == rhs.microseconds;
end
function Time:__add(rhs)
	return newObj(Time, sfSystem.sfMicroseconds(self.microseconds + rhs.microseconds));
end
function Time:__sub(rhs)
	return newObj(Time, sfSystem.sfMicroseconds(self.microseconds - rhs.microseconds));
end
function Time:__mul(rhs)
	return newObj(Time, sfSystem.sfMicroseconds(self.microseconds * rhs));
end
function Time.__div(rhs)
	return newObj(Time, sfSystem.sfMicroseconds(self.microseconds / rhs));
end
ffi.metatype('sfTime', Time);


--[=[
InputStream()
function    InputStream.read    => function(cdata data, number size, cdata<void*> userData)
function    InputStream.seek    => function(number position, cdata<void*> userData)
function    InputStream.tell    => function(cdata<void*> userData)
function    InputStream.getSize => function(cdata<void*> userData)
userdata    InputStream.userData
]=]

setmetatable(InputStream, { __call = function(cl)
	return newObj(InputStream, ffi.new('sfInputStream'));
end });
ffi.metatype('sfInputStream', InputStream);


--[=[
Mutex()
nil   Mutex:lock()
nil   Mutex:unlock()
]=]

setmetatable(Mutex, { __call = function(cl)
	return newObj(Mutex, sfSystem.sfMutex_create());
end });
function Mutex:__gc()
	sfSystem.sfMutex_destroy(self);
end
function Mutex:lock()
	sfSystem.sfMutex_lock(self);
end
function Mutex:unlock()
	sfSystem.sfMutex_unlock(self);
end
ffi.metatype('sfMutex', Mutex);


--[=[
nil sleep(Time timeToSleep)
]=]

function sleep(obj)
	sfSystem.sfSleep(obj);
end


--[=[
Thread(function func => function(cdata<void*> userData), cdata<void*> userData = nil)
nil    Thread:launch()
nil    Thread:wait()
nil    Thread:terminate()
]=]

setmetatable(Thread, { __call = function(cl, func, userdata)
	return newObj(Thread, sfSystem.sfThread_create(func, userdata));
end });
function Thread:__gc()
	sfSystem.sfThread_destroy(self);
end
function Thread:launch()
	sfSystem.sfThread_launch(self);
end
function Thread:wait()
	sfSystem.sfThread_wait(self);
end
function Thread:terminate()
	sfSystem.sfThread_terminate(self);
end
ffi.metatype('sfThread', Thread);


--[=[
Vector2i(number x = 0, number y = 0)
Vector2i:operator -  ()
Vector2i:operator +  (Vector2i right)
Vector2i:operator -  (Vector2i right)
Vector2i:operator *  (number right)
Vector2i:operator /  (number right)
Vector2i:operator == (Vector2i right)
Vector2i:operator ~= (Vector2i right)
number   Vector2i.x
number   Vector2i.y
]=]

setmetatable(Vector2i, { __call = function(cl, x, y)
	local obj = newObj(Vector2i, ffi.new('sfVector2i'));
	if x == nil then obj.x = 0; else obj.x = x; end
	if y == nil then obj.y = 0; else obj.y = y; end
	return obj;
end });
function Vector2i:__unm()
	return newObj(Vector2i, ffi.new('sfVector2i', {-self.x, -self.y}));
end
function Vector2i:__add(rhs)
	return newObj(Vector2i, ffi.new('sfVector2i', {self.x + rhs.x, self.y + rhs.y}));
end
function Vector2i:__sub(rhs)
	return newObj(Vector2i, ffi.new('sfVector2i', {self.x - rhs.x, self.y - rhs.y}));
end
function Vector2i:__mul(rhs)
	return newObj(Vector2i, ffi.new('sfVector2i', {self.x * rhs, self.y * rhs}));
end
function Vector2i:__div(rhs)
	return newObj(Vector2i, ffi.new('sfVector2i', {self.x / rhs, self.y / rhs}));
end
function Vector2i:__eq(rhs)
	return (self.x == rhs.x) and (self.y == rhs.y);
end
ffi.metatype('sfVector2i', Vector2i);


--[=[
Vector2u(number x = 0, number y = 0)
Vector2u:operator -  ()
Vector2u:operator +  (Vector2u right)
Vector2u:operator -  (Vector2u right)
Vector2u:operator *  (number right)
Vector2u:operator /  (number right)
Vector2u:operator == (Vector2u right)
Vector2u:operator ~= (Vector2u right)
number   Vector2u.x
number   Vector2u.y
]=]

setmetatable(Vector2u, { __call = function(cl, x, y)
	local obj = newObj(Vector2u, ffi.new('sfVector2u'));
	if x == nil then obj.x = 0; else obj.x = x; end
	if y == nil then obj.y = 0; else obj.y = y; end
	return obj;
end });
function Vector2u:__unm()
	return newObj(Vector2u, ffi.new('sfVector2u', {-self.x, -self.y}));
end
function Vector2u:__add(rhs)
	return newObj(Vector2u, ffi.new('sfVector2u', {self.x + rhs.x, self.y + rhs.y}));
end
function Vector2u:__sub(rhs)
	return newObj(Vector2u, ffi.new('sfVector2u', {self.x - rhs.x, self.y - rhs.y}));
end
function Vector2u:__mul(rhs)
	return newObj(Vector2u, ffi.new('sfVector2u', {self.x * rhs, self.y * rhs}));
end
function Vector2u:__div(rhs)
	return newObj(Vector2u, ffi.new('sfVector2u', {self.x / rhs, self.y / rhs}));
end
function Vector2u:__eq(rhs)
	return (self.x == rhs.x) and (self.y == rhs.y);
end
ffi.metatype('sfVector2u', Vector2u);


--[=[
Vector2f(number x = 0, number y = 0)
Vector2f:operator -  ()
Vector2f:operator +  (Vector2f right)
Vector2f:operator -  (Vector2f right)
Vector2f:operator *  (number right)
Vector2f:operator /  (number right)
Vector2f:operator == (Vector2f right)
Vector2f:operator ~= (Vector2f right)
number   Vector2f.x
number   Vector2f.y
]=]

setmetatable(Vector2f, { __call = function(cl, x, y)
	local obj = newObj(Vector2f, ffi.new('sfVector2f'));
	if x == nil then obj.x = 0; else obj.x = x; end
	if y == nil then obj.y = 0; else obj.y = y; end
	return obj;
end });
function Vector2f:__unm()
	return newObj(Vector2f, ffi.new('sfVector2f', {-self.x, -self.y}));
end
function Vector2f:__add(rhs)
	return newObj(Vector2f, ffi.new('sfVector2f', {self.x + rhs.x, self.y + rhs.y}));
end
function Vector2f:__sub(rhs)
	return newObj(Vector2f, ffi.new('sfVector2f', {self.x - rhs.x, self.y - rhs.y}));
end
function Vector2f:__mul(rhs)
	return newObj(Vector2f, ffi.new('sfVector2f', {self.x * rhs, self.y * rhs}));
end
function Vector2f:__div(rhs)
	return newObj(Vector2f, ffi.new('sfVector2f', {self.x / rhs, self.y / rhs}));
end
function Vector2f:__eq(rhs)
	return (self.x == rhs.x) and (self.y == rhs.y);
end
ffi.metatype('sfVector2f', Vector2f);


--[=[
Vector3f(number x = 0, number y = 0, number z = 0)
Vector3f:operator -  ()
Vector3f:operator +  (Vector3f right)
Vector3f:operator -  (Vector3f right)
Vector3f:operator *  (number right)
Vector3f:operator /  (number right)
Vector3f:operator == (Vector3f right)
Vector3f:operator ~= (Vector3f right)
number   Vector3f.x
number   Vector3f.y
number   Vector3f.z
]=]

setmetatable(Vector3f, { __call = function(cl, x, y, z)
	local obj = newObj(Vector3f, ffi.new('sfVector3f'));
	if x == nil then obj.x = 0; else obj.x = x; end
	if y == nil then obj.y = 0; else obj.y = y; end
	if z == nil then obj.z = 0; else obj.z = z; end
	return obj;
end });
function Vector3f:__unm()
	return newObj(Vector3f, ffi.new('sfVector3f', {-self.x, -self.y, -self.z}));
end
function Vector3f:__add(rhs)
	return newObj(Vector3f, ffi.new('sfVector3f', {self.x + rhs.x, self.y + rhs.y, self.z + rhs.z}));
end
function Vector3f:__sub(rhs)
	return newObj(Vector3f, ffi.new('sfVector3f', {self.x - rhs.x, self.y - rhs.y, self.z - rhs.z}));
end
function Vector3f:__mul(rhs)
	return newObj(Vector3f, ffi.new('sfVector3f', {self.x * rhs, self.y * rhs, self.z * rhs}));
end
function Vector3f:__div(rhs)
	return newObj(Vector3f, ffi.new('sfVector3f', {self.x / rhs, self.y / rhs, self.z / rhs}));
end
function Vector3f:__eq(rhs)
	return (self.x == rhs.x) and (self.y == rhs.y) and (self.z == rhs.z);
end
ffi.metatype('sfVector3f', Vector3f);

end -- sfSystem