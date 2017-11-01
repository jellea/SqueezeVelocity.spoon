local module = {
  -- Metadata
  name = "SqueezeVelocity",
  version = "0.1",
  author = "Jelle Akkerman",
  homepage = "https://github.com/jellea/SqueezeVelocity",
  license = "MIT - https://opensource.org/licenses/MIT"
}

module.__index = obj

local notify = function(album, statusCode, res, hed)
  if statusCode == 200 then
    if album.image then	  
      hs.notify.new({title="Hammerspoon", informativeText="Playing "..album.text.." by "..album.subText, contentImage=album.image}):send()
    else
      hs.notify.new({title="Hammerspoon", informativeText="Playing "..album.text.." by "..album.subText}):send()
    end
  else
    hs.notify.new({title="Hammerspoon", informativeText="Error: "..hs.inspect.inspect(res)}):send()
  end
end

function module:playAlbum(album)
  if album then
    hs.http.asyncPost(self.serverURL .. "jsonrpc.js", '{"id":1,"method":"slim.request","params":["' .. self.playerId .. '",["playlist","loadtracks","album.id=' .. album.uuid .. '"]]}', nil, hs.fnutils.partial(notify, album))
  end
end

module.ch = hs.chooser.new(function(a) module:playAlbum(a) end)

function module:readDB()
  local tables = {}

  hs.http.asyncPost(self.serverURL.."jsonrpc.js", '{"id":1,"method":"slim.request","params":["'..self.playerId..'",["albums","0","5000","tags:ljya"]]}', nil, 
    function(s,res,h)
    local albums =  hs.json.decode(res).result.albums_loop
    for k, a in pairs(albums) do
      if (a.artwork_track_id and self.albumCoversEnabled) then
      local img = hs.image.imageFromURL(self.serverURL.."music/"..a.artwork_track_id.."/cover_96x96_p.png")

      table.insert(tables,
             {text=a.album,
              uuid=a.id,
              image=img,
              subText=a.artist})
      else
      table.insert(tables,
              {text=a.album,
              uuid=a.id,
              subText=a.artist})
      end
      end
      table.sort(tables, function(a, b) return a.uuid > b.uuid end)
      self.ch:choices(tables)
  end)
end

function module:bindHotKeys(mapping)
  local def = {
    show = hs.fnutils.partial(function () self.ch:show() end, self),
  }
  hs.spoons.bindHotkeysToSpec(def, mapping)
end

module.start = module.readDB

function module:configure(config)
  for k,v in pairs(config) do
    module[k] = v
  end
end

function module:init()
  self.ch:rows(10)
  self.ch:searchSubText(true)
  self.ch:bgDark(true)
end

return module
