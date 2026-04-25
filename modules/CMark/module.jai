FILE :: struct{}

#if OS == {
case .MACOS;
    #if CPU == {
    case .ARM64; #load "arm64-macos.jai";
    case .X64; #load "x64-macos.jai";
    case; #assert(false, "unsupported CPU");
    }
case; #assert(false, "unsupported OS");
}
