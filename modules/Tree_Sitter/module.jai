#if OS == {
case .MACOS;
    #if CPU == {
    case .ARM64; #load "arm64-macos.jai";
    case .X64; #load "x64-macos.jai";
    case; #assert(false, "unsupported CPU");
    }
case; #assert(false, "unsupported OS");
}

tree_sitter_javascript :: () -> *TSLanguage #foreign libtree_sitter;

#scope_file

#if OS == {
case .MACOS;
    #if CPU == {
    case .ARM64;
        libtree_sitter :: #library "../../vendor/dist/arm64-macos/tree-sitter/lib/libtree-sitter";
    case .X64;
        libtree_sitter :: #library "../../vendor/dist/x64-macos/tree-sitter/lib/libtree-sitter";
    case; #assert(false, "unsupported CPU");
    }
case; #assert(false, "unsupported OS");
}
