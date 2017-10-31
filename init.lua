local module = {}
module.__index = obj

-- Metadata
module.name = "SqueezeVelocity"
module.version = "0.1"
module.author = "Jelle Akkerman"
module.homepage = "https://github.com/jellea/SqueezeVelocity"
module.license = "MIT - https://opensource.org/licenses/MIT"

function module:playAlbum(album)
  if album then
  hs.http.asyncPost(self.serverURL .. "jsonrpc.js", '{"id":1,"method":"slim.request","params":["' .. self.playerId .. '",["playlist","loadtracks","album.id=' .. album.uuid .. '"]]}', nil, function(s,res,h) print("requested to play "..album.text.." by "..album.subText) end)
  end
end

module.ch = hs.chooser.new(module.playAlbum)

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
