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
   
end
-- }}}

--- grid:fit
function grid:fit (context, orig_width, orig_height) -- {{{
   -- Calculate the max col width and row height
   for i, v in ipairs(self._private.widgets) do
      i_x, i_y = ((i - 1) / self._private.ncols) + 1, ((i -1) % self._private.ncols) + 1
   end
   
end
-- }}}

--- Set the content of of the grided layout
-- @param content Table of values for each cell in the grid
function grid:set_content (content) -- {{{
   local cells = {}

   self.nrows = #content   
   self.ncols = 0
   self.row_height = {}
   self.col_width = {}

   -- Temp variables
   self.width = 200
   self.height = 200

   self:reset()
   
   -- Build the widgets and calculate the row heights and col widths
   for i=1, #content do
      if self.ncols < #content[i] then self.ncols = #content[i] end
      cells[i] = {}
      self.row_height[i] = 0
      
      for j, v in ipairs(content[i]) do         
         cells[i][j] = wibox.widget.textbox()
         cells[i][j]:set_text(content[i][j])

         -- each row height should be the height of the largest cell in the row
         -- each col width should be the width of the largest cell in the col
         local w, h = cells[i][j]:fit(self.width, self.height)
         if self.row_height[i] < h then self.row_height[i] = h end
         if self.col_width[j] == nil or self.col_width[j] < w then self.col_width[j] = w end
      end
   end

   -- Calculate the proper ratios for each column
   local sum = table.reduce(self.col_width, function (a,b) return a+b end)
   local ratios = table.map(self.col_width, function (a) return a/sum end)

   -- Build the row layouts and add them to the vertical layout and set the
   -- proper widget ratio
   for i=1,self.nrows do
      local row_layout = wibox.layout.ratio.horizontal()      
      for j=1,self.ncols do         
         row_layout[i]:add(cells[i][j])
         row_layout[i]:set_ratio(j,ratios[j])
      end
      self:add(row_layout)
   end
end
-- }}}

-- }}}

--- Constructors -- {{{

--- new
local function new (nrows, ncols, content, args) -- {{{
   local retval = wibox.layout.fixed.horizontal()
   
   util.table.crush(retval, grid, true)
   
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
