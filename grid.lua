-------------------------------------------------------------------------------
-- grid.lua for circuit                                                      --
-- Copyright (c) 2016 Tom Hartman (thomas.lees.hartman@gmail.com)            --
--                                                                           --
-- This program is free software; you can redistribute it and/or             --
-- modify it under the terms of the GNU General Public License               --
-- as published by the Free Software Foundation; either version 2            --
-- of the License, or the License, or (at your option) any later             --
-- version.                                                                  --
--                                                                           --
-- This program is distributed in the hope that it will be useful,           --
-- but WITHOUT ANY WARRANTY; without even the implied warranty of            --
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the             --
-- GNU General Public License for more details.                              --
-------------------------------------------------------------------------------

--- Commentary -- {{{
-- Defines a grid like layout. Expects content to be an array of non-sparse
-- arrays that defines the values in each cell of the grid. Each array
-- represents a row
--
-- ie:
-- 
--     content = { { 1 , 2 },
--                 { 3 , 4 },
--                 { 5 , 6 } }
-- 
-- Would represent at grid in the shape
--
-- | 1 | 2 |
-- | 3 | 4 |
-- | 5 | 6 |

-- }}}

--- Grid layout -- {{{

--- Locals -- {{{
local wibox = require("wibox")
local base = require("wibox.widget.base")
local beautiful = require("beautiful")
local table = table
local ipairs = ipairs
local setmetatable = setmetatable

local grid = { mt = {} }
-- }}}

--- Helper functions -- {{{

--- table.reduce
table.reduce = function (tbl, fn) -- {{{
   local retval
   for i, v in ipairs(tbl) do
      if i == 1 then
         retval = v
      else
         retval = fn(retval,v)
      end
   end
   return retval
end
-- }}}

-- table.map
table.map = function (tbl, fn) -- {{{
   local retval = {}
   for i,v in ipairs(tbl) do
      retval[i] = fn(v)
   end   
   return retval
end
-- }}}

-- }}}

--- Methods -- {{{

--- grid:layout
-- @param width The overall width of the grid layout
-- @param height The overall height of the grid layout
function grid:layout (_, width, height) -- {{{
   local retval = {}
   local spacing = self._private.spacing
   local x, y, w, h = 0,0,0,0

   for i,v in pairs(self._private.widegts) do      
      local i_x = ((i - 1) % self._private.ncols) + 1
      local i_y = math.floor((i - 1) / self._private.ncols) + 1

      w = self._private.col_width[i_x]
      h = self._private.row_height[i_y]

      table.insert(retval, base.place_widget_at(v, x, y, w, h))

      -- last item in the row, reset y and increment x by row height
      if i_y == self._private.ncols then
         x = 0
         y = y + self._private.row_heights[i_y]
      else -- increment y by col width
         x = x + self._private.col_widths[i_x]
      end
   end   

   return retval
end
-- }}}

--- grid:fit
function grid:fit (context, orig_width, orig_height) -- {{{
   -- Calculate the max col width and row height
   local row_heights, col_widths = {},{}
   for i=1,self._private.nrows do row_heights[i] = 0 end
   for i=1,self._private.ncols do col_widths[i] = 0 end
   
   for i, v in ipairs(self._private.widgets) do
      local i_x = ((i - 1) % self._private.ncols) + 1
      local i_y = math.floor((i - 1) / self._private.ncols) + 1
      
      local w,h = base.fit_widget(self, context, v, orig_width, orig_height)
      row_heights[i_x] = math.max(row_heights[i_x], w)
      col_widths[i_y] = math.max(col_widths[i_y], h)
   end

   self._private.row_heights = row_heights
   self._private.col_widths = col_widths

   return table.reduce(col_widths, function (a,b) return a+b end),
          table.reduce(row_height, function (a,b) return a+b end)   
end
-- }}}

--- Set the content of of the grided layout
-- @param content Table of values for each cell in the grid
function grid:set_content (content) -- {{{
   for _, v in ipairs(content) do
      self:add(wibox.widgets.textbox(v))
   end
end
-- }}}

-- }}}

--- Constructors -- {{{

--- new
local function new (nrows, ncols, content, args) -- {{{
   local retval = wibox.layout.fixed.horizontal()
   
   util.table.crush(retval, grid, true)

   -- if the number of rows and columns is specificed and greater than 0
   -- set them here, otherwise default them to 1
   if nrows and nrows > 0 then
      retval._private.nrows = nrows
   else
      retval._private.nrows = 1
   end

   if ncols and ncols > 0 then
      retval._private.ncols = ncols
   else
      retval._private.ncols = 1
   end

   -- Add the content if specified so long as the content has (ncols * nrows)
   -- length or fewer
   if content and #content <= (ncols * nrows) then
      retval:set_content(content)
   end
   
   return retval
end
-- }}}

--- grid.mt:__call
function grid.mt:__call (_, ...) -- {{{
   return new(...)   
end
-- }}}

-- }}}

return setmetatable(grid, grid.mt)
-- }}}
