-- GETTING THIS FUCKING HOTKEYS POPUP, AAAA
require("awful.hotkeys_popup.keys")

myawesomemenu = {
	{
	"hotkeys", function() hotkeys.popup.show_help(nil, awful.screen.focused()) end}
	}
}