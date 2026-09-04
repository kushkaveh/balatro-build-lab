"""Syntax-check Lua files with the game's own lua51.dll (LuaJIT) via ctypes. No execution."""
import ctypes, sys, glob, os
DLL = r"<Balatro folder>\lua51.dll"
lua = ctypes.CDLL(DLL)
lua.luaL_newstate.restype = ctypes.c_void_p
lua.luaL_loadbuffer.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p]
lua.lua_tolstring.restype = ctypes.c_char_p
lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
lua.lua_settop.argtypes = [ctypes.c_void_p, ctypes.c_int]
L = lua.luaL_newstate()
root = sys.argv[1] if len(sys.argv) > 1 else "."
files = [f for f in glob.glob(os.path.join(root, "**", "*.lua"), recursive=True) if ".git" not in f]
bad = 0
for f in sorted(files):
    src = open(f, "rb").read()
    rc = lua.luaL_loadbuffer(L, src, len(src), ("=" + os.path.relpath(f, root)).encode())
    if rc != 0:
        bad += 1
        print("SYNTAX ERROR:", lua.lua_tolstring(L, -1, None).decode())
    else:
        print("ok  ", os.path.relpath(f, root))
    lua.lua_settop(L, 0)
print("---", len(files), "files,", bad, "errors")
sys.exit(1 if bad else 0)
