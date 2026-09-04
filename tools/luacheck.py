"""Syntax-check every Lua file with Balatro's own lua51.dll (LuaJIT) via ctypes. Nothing is executed.

Usage:
    python tools/luacheck.py [repo_root]

The DLL is found from, in order: the BALATRO_DIR environment variable, the default Steam library, or a
--dll path. Example: set BALATRO_DIR=C:\\Program Files (x86)\\Steam\\steamapps\\common\\Balatro
"""
import ctypes, sys, glob, os

def find_dll():
    for arg in sys.argv[1:]:
        if arg.startswith("--dll="):
            return arg[len("--dll="):]
    candidates = []
    if os.environ.get("BALATRO_DIR"):
        candidates.append(os.path.join(os.environ["BALATRO_DIR"], "lua51.dll"))
    candidates += [
        r"C:\Program Files (x86)\Steam\steamapps\common\Balatro\lua51.dll",
        r"C:\Program Files\Steam\steamapps\common\Balatro\lua51.dll",
    ]
    for drive in "CDEFGHK":
        candidates.append(rf"{drive}:\SteamLibrary\steamapps\common\Balatro\lua51.dll")
    for c in candidates:
        if os.path.exists(c):
            return c
    sys.exit("lua51.dll not found. Set BALATRO_DIR to your Balatro folder or pass --dll=<path to lua51.dll>.")

DLL = find_dll()
lua = ctypes.CDLL(DLL)
lua.luaL_newstate.restype = ctypes.c_void_p
lua.luaL_loadbuffer.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p]
lua.lua_tolstring.restype = ctypes.c_char_p
lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
lua.lua_settop.argtypes = [ctypes.c_void_p, ctypes.c_int]
L = lua.luaL_newstate()

root = next((a for a in sys.argv[1:] if not a.startswith("--")), ".")
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
