-- 在 a 文件中将工具函数添加到 _G:
_G.IsEmptyStr = function(str) 
    return str==nil or type(str) ~= "string" or str == "" 
end  
_G.PrintObjPos = function(prefix, obj)
    prefix = prefix or ""
    local l,t,r,b = obj:GetObjPos()
    XLPrint(prefix .. " l=" .. l .. ", t=" .. t .. ", r=" .. r .. ", b=" .. b)
end


-- 在其它文件中直接使用工具函数:
if not IsEmptyStr(obj:GetText()) then  
    PrintObjPos("[Dongyu]", obj)
end  
使用 or 操作符赋默认值：

num = num or 0
使用 (a and b) or c 操作符实现 C 语言中 a ? b : c 的功能 :

num = (num < 0 and 0) or num

这样做的原理是：
a and b  -- 如果 a 为 false, 则返回 a, 否则返回 b
a or b   -- 如果 a 为 true, 则返回 a, 否则返回 b
获取 UTF-8 字符串中的字符数(中英文混合) :

local function strlength(str)
    -- 计算字符串长度，中英文混合
    str = string.gsub(str, "%%", " ") -- 将%替换成" "
    local str = string.gsub(str, "[\128-\191]","")
    local _,ChCount = string.gsub(str, "[\192-\255]","")
    local _,EnCount = string.gsub(str, "[^\128-\255]","")
    return ChCount + EnCount
end
这种做法跟 UTF-8 格式有关，标准 ASC|| 码(英文)是 0-127 ;中文占 3 个字符(192-255)(128-191)(128-191);
详情可参考这篇文章

去除字符串首尾空格：

function trim (s) 
    return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 
end
关闭 string.find(s, pattern, start, plain) 的模式匹配：

-- 将 find 的第四个参数设定为 true, 则 pattern 将被视为普通字符串，不会处理特殊字符
pos = string.find(str, "%s", 1, true)
分割字符串：

function split(s, delim)
    if type(delim) ~= "string" or string.len(delim) <= 0 then
        return
    end

    local start = 1
    local t = {}
    while true do
    local pos = string.find (s, delim, start, true) -- plain find
        if not pos then
          break
        end

        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))

    return t
end
table.concat 打印数组：

local t = {"2016", "3", "6"}
print(table.concat(t, "-"))    -- 2016-3-6
打印 table:

function print_lua_table (lua_table, indent)
    local function print_func(str)
        XLPrint("[Dongyu] " .. tostring(str))
    end

    if lua_table == nil or type(lua_table) ~= "table" then
        print_func(tostring(lua_table))
        return
    end

    indent = indent or 0
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        if type(v) == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep("    ", indent)
        formatting = szPrefix.."["..k.."]".." = "..szSuffix
        if type(v) == "table" then
            print_func(formatting)
            print_lua_table(v, indent + 1)
            print_func(szPrefix.."},")
        else
            local szValue = ""
            if type(v) == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            print_func(formatting..szValue..",")
        end
    end
end
拷贝 table:

function copy_table(ori_tab)
    if type(ori_tab) ~= "table" then
        return
    end
    local new_tab = {}
    for k,v in pairs(ori_tab) do
        local vtype = type(v)
        if vtype == "table" then
            new_tab[k] = copy_table(v)
        else
            new_tab[k] = v
        end
    end
    return new_tab
end
或

function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end

        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end
for 循环中 remove 数组元素：

local t = {1,2,3,3,5,3,6}
for i,v in ipairs(t) do
    if v == 3 then
        table.remove(t,i)
    end
end
-- 错误，第四个 3 没有被移除，ipairs 内部会维护一个变量记录遍历的位置，
-- remove 掉第三个数字 3 之后，ipairs 下一个返回的值是 5 而不是 3

local t = {1,2,3,3,5,3,6}
for i=1, #t do
    if t[i] == 3 then
        table.remove(t,i)
        i = i-1
    end
end
-- 错误，i=i-1 这段代码没有用，i 的值始终是从 1 到 #t，for 循环里修改 i 的值不起作用

local t = {1,2,3,3,5,3,6}
for i=#t, 1, -1 do
    if t[i] == 3 then
        table.remove(t,i)
    end
end
-- 正确，从后往前遍历

local t = {1,2,3,3,5,3,6}
local i = 1
while t[i] do
    if t[i] == 3 then
        table.remove(t,i)
    else
        i = i+1
    end
end
-- 正确，自己控制 i 的值是否增加
table.sort(t, comp) 排序数组 :
sort 可以将 table 数组部分的元素进行排序，需要提供 comp(a,b) 函数，如果 a 应该排到 b 前面，则 comp 要返回 true 。

注意： 对于 a==b 的情况，一定要返回 false:

local function comp(a,b) 
    return a <= b 
end 
table.sort(t,comp) 
-- 错误，可能出现异常：attempt to compare number with nil 

local function comp(a,b) 
    if a == nil or b == nil then 
        return false 
    end 
    return a <= b 
end 
table.sort(t,comp) 
-- 错误，可能出现异常：invalid order function for sorting 
-- 也可能不报这个异常，但结果是错误的；
之所以 a==b 返回true 会引发这些问题，是因为 table.sort 在实现快速排序时没有做边界检测：

for (;;) {
    while (lua_rawgeti(L, 1, ++i), sort_comp(L, -1, -2))  // 未检测边界, i 会一直增加
    {
        if (i>=u) luaL_error(L, "invalid order function for sorting");
        lua_pop(L, 1);
    }
    while (lua_rawgeti(L, 1, --j), sort_comp(L, -3, -1))  // 未检测边界, j 会一直减少
    {
        if (j<=l) luaL_error(L, "invalid order function for sorting");
        lua_pop(L, 1);
    }
    if (j<i) {
        lua_pop(L, 3);
        break;
    }
    set2(L, i, j);
