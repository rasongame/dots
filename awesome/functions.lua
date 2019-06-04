-- Functions 
local awful = require("awful")
-- call rofi
function call_rofi() 
	awful.spawn("rofi -show drun")
end