string.split = function(s, p)
    local rt= {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
    return rt
end
string.trim =function(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end
