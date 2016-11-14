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

--- grid widget -- {{{

--- Locals -- {{{
local wibox = require("wibox")
local beautiful = require("beautiful")
local table = table
local ipairs = ipairs
local setmetatable = setmetatable

local grid = wibox.layout.fixed.vertical()

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

-- }}}

--- Methods -- {{{

-- Layout a grided layout. Each widget will have the max height and width of
-- its row and column siblings
-- @param context The drawing context
-- @param width The available width
-- @param height The available height
function grid:layout (context, width, height) -- {{{
   local retval = {}
   local pos, spacing = 0, self._private.spacing

   for k, v in pairs(self._private.widgets) do
      local x, y, w, h
      
   end
   
   return retval   
end
-- }}}

-- Fit the grided layout into the given space
-- @param context The fit context
-- @param width The available width
-- @param height The available height
function grid:fit (context, width, height) -- {{{
   self.rows = {}
   local col_sum = reduce(self.col_width, function (a,b) return a+b end)
   
   for i=1,#cells do
      row[i] = wibox.layout.fixed.horizontal()
      row[i]:fit(col_sum, self.row_height[i])
   end
end
-- }}}

--- Set the content of of the grided layout
-- @param content Table of values for each cell in the grid
function grid:set_content (content) -- {{{
   local cells = {}

   self.nrows = #content   
   self.ncols = 0
   self.row_width = {}
   self.col_width = {}
   
   for i=1, #content do
      if ncols < #cells[i] then ncols = #cols[i] end         
      cells[i] = {}
      self.row_width[i] = 0
      
      for j, v in ipairs(content[i]) do         
         cells[i][j] = wibox.widget.textbox()
         cells[i][j]:set_text(content[i][j])

         local w, h = cells[i][j]:fit(self.width, self.height)
         if self.row_width[i] < h then self.row_width[i] = h end
         if self.col_width[j] < w then self.col_width[j] = w end
      end
   end
end
-- }}}

-- }}}

--- new
local function new(content, args) -- {{{
   local args = args or {}
   local width = args.width or 200
   
   for i, v in ipairs(content) do
      local row = wibox.layout.fixed.horizontal()
      
      for i=1, ncols do
         row:add(wibox.widget.textbox(v))
      end
      _grid:add(row)
   end
   
   return _grid
end
-- }}}

return grid
-- }}}
