-- 通过next来确认一个表是不是空表
function table.is_empty(t)
        return _G.next( t ) == nil
end
