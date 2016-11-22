local http = require("socket.http")  
local ltn12 = require("ltn12")  

-- //lua http 返回数组而且是需要传入返回 稍微改下 可以直接返回
function http.get(u)  
   local t = {}  
   local r, c, h = http.request{  
      url = u,  
      sink = ltn12.sink.table(t)}  
   return r, c, h, table.concat(t)  
end
