--=================================--
-- 
-- PlanetSide 2 Point Mapper
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

require 'ffi/sfml-graphics'
require 'lua/utils'

print("PlanetSide2 Point Mapper");
print("(c) 2014 Nathan Cousins 'ief015'");

local LOCATION_MAX = 8192;

local function blit(imgDest, imgSource, destX, destY)
	imgDest:copyImage(imgSource, math.floor(destX), math.floor(destY), sf.IntRect(0, 0, 0, 0), true);
end

local function blit_centered(imgDest, imgSource, destX, destY)
	local size = imgSource:getSize();
	blit(imgDest, imgSource, destX - size.x / 2, destY - size.y / 2);
end

local function render(imgDest, imgPoint, point)
	local size = imgDest:getSize();
	blit_centered(imgDest, imgPoint, point.z * size.x, point.x * size.y);
end

local function process_listfile(f)
	local points = {};
	for ln in f:lines() do
		local pos = {};
		local sp = string.split(ln, ' ');
		for k,v in ipairs(sp) do
			local sp2 = string.split(v, '=');
			table.insert(pos, sp2[#sp2]);
		end
		pos[1] = 1 - (tonumber(pos[1]) / LOCATION_MAX + 0.5);
		pos[2] = (tonumber(pos[2]) / LOCATION_MAX + 0.5);
		pos[3] = (tonumber(pos[3]) / LOCATION_MAX + 0.5);
		pos[4] = string.lower(pos[4] or '');
		if pos[4] == 'under' then
			pos[4] = -1;
		elseif pos[4] == 'above' then
			pos[4] = 1;
		else
			pos[4] = 0;
		end
		table.insert(points, { x=pos[1], y=pos[2], z=pos[3], t=pos[4] });
	end
	return points;
end

local function report_duplicates(points)
	local DISTANCE_THRESHOLD = (1 / LOCATION_MAX) * 10;
	for i=1, #points do
		for j=i+1, #points do
			local p1, p2 = points[i], points[j];
			local diffx = p1.x - p2.x;
			local diffy = p1.y - p2.y;
			local diffz = p1.z - p2.z;
			local distsqr = (diffx*diffx) + (diffy*diffy) + (diffz*diffz)
			if distsqr < DISTANCE_THRESHOLD*DISTANCE_THRESHOLD then
				print("Possible duplicate detected: Points " .. tostring(i) .. " and " .. tostring(j));
			end
		end
	end
end

local function compile(listFilename, baseFilename, outputFilename, legendFilename)
	assert(listFilename, "list filename was not provided");
	assert(baseFilename, "base image filename was not provided");
	outputFilename = outputFilename or "out.jpg";
	legendFilename = legendFilename or "legend.png";
	print("Loading assets for '"..listFilename.."' ...");
	local fList = assert(io.open('list/'..listFilename, 'r'), "list file was not loaded");
	local points = process_listfile(fList);
	report_duplicates(points);
	local imgBase = sf.Image('res/base/'..baseFilename);
	assert(imgBase ~= nil, "base image was not loaded");
	local imgLegend = sf.Image(legendFilename);
	assert(imgBase ~= nil, "legend image was not loaded");
	local imgPointLow = sf.Image('res/point_l.png');
	assert(imgPointLow ~= nil, "low point image was not loaded");
	local imgPointMed = sf.Image('res/point_m.png');
	assert(imgPointMed ~= nil, "med point image was not loaded");
	local imgPointHigh = sf.Image('res/point_h.png');
	assert(imgPointHigh ~= nil, "high point image was not loaded");
	print("Starting render ("..#points.." points) ...");
	blit(imgBase, imgLegend, imgBase:getSize().x - imgLegend:getSize().x - 128, 128);
	for i=1, #points do
		local p = points[i];
		if p.t < 0 then
			render(imgBase, imgPointLow, p);
		elseif p.t > 0 then
			render(imgBase, imgPointHigh, p);
		else
			render(imgBase, imgPointMed, p);
		end
		local r = 1;
		if #points > 250 then
			r = 15;
		elseif #points > 100 then
			r = 5;
		elseif #points > 25 then
			r = 2;
		end
		if i % r == 0 then
			print(math.floor((i/#points) * 100) .. "%");
		end
	end
	print("Saving rendered image ...");
	if not imgBase:saveToFile(outputFilename) then
		assert("unable to save output image");
	end
	print("Successfully rendered '"..outputFilename.."'.\n");
end

if #{...} > 2 then
	compile(...);
else
	print("compile.lua <listfile> <baseimage> [outfile]");
	print("\tlistfile", "Point list filename relative to the 'list' folder.");
	print("\tbaseimage", "Base image filename relative to the 'res/base' folder.");
	print("\toutfile (opt)", "Output file name. Defaults to 'out.jpg'");
end