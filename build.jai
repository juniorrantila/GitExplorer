TARGET_OS :: Operating_System_Tag.[
    .MACOS,
];

TARGET_CPU :: CPU_Tag.[
    .X64,
    .ARM64,
];

build :: () {
    prepare();

    build_vendor();

    // generate_bindings();

    for target: TARGET_MATRIX {
        build_binary(
            output_name="git-explorer",
            root_file="./src/main.jai",
            target=target
        );
    }
}

#scope_file

build_vendor :: () {
    for target: TARGET_MATRIX build_vendor(target);
}

build_vendor :: (target: Target_Machine) {
    build_cmark(target);
    build_tree_sitter(target);
}

build_tree_sitter :: (target: Target_Machine) {
    cmark := vendor_project("tree-sitter");
    zig_cross := vendor_project("zig-cross");
    build_dir := vendor_build_dir(target, "tree-sitter");
    dist_dir := vendor_dist_dir(target, "tree-sitter");

    if !file_exists(build_dir) {
        result := run_command(
            "cmake",
            cmark,
            tprint("-B%", build_dir),
            "-DCMAKE_BUILD_TYPE=RelWithDebInfo",
            "-GNinja",
            "--toolchain", toolchain_file(target),
            "--install-prefix", dist_dir,
        );
        assert(result.exit_code == 0, "failed to run cmake");
    }

    if !file_exists(dist_dir) {
        result := run_command(
            "ninja",
            "-C", build_dir,
            "install",
        );
        assert(result.exit_code == 0, "failed to run ninja");
    }
}

build_cmark :: (target: Target_Machine) {
    cmark := vendor_project("cmark-gfm");
    zig_cross := vendor_project("zig-cross");
    build_dir := vendor_build_dir(target, "cmark-gfm");
    dist_dir := vendor_dist_dir(target, "cmark-gfm");

    if !file_exists(build_dir) {
        result := run_command(
            "cmake",
            cmark,
            tprint("-B%", build_dir),
            "-GNinja",
            "-DCMAKE_BUILD_TYPE=RelWithDebInfo",
            "--toolchain", toolchain_file(target),
            "--install-prefix", dist_dir,
        );
        assert(result.exit_code == 0, "failed to run cmake");
    }

    if !file_exists(dist_dir) {
        result := run_command(
            "ninja",
            "-C", build_dir,
            "install",
        );
        assert(result.exit_code == 0, "failed to run ninja");
    }
}

toolchain_file :: (target: Target_Machine) -> string {
    abi := "musl";
    if target.os == .MACOS abi = "none";
    if target.os == .WINDOWS abi = "msvc";

    cpu := "";
    if target.cpu == {
    case .ARM64; cpu = "aarch64";
    case .X64; cpu = "x86_64";
    case; assert(false, "unsupported cpu");
    }

    return path_join(vendor_project("zig-cross"), to_lower_copy(tprint("%-%-%.cmake", cpu, target.os, abi)));
}

Target_Machine :: struct {
    os:  Operating_System_Tag;
    cpu: CPU_Tag;
}

build_target_matrix :: () -> [TARGET_OS.count * TARGET_CPU.count]Target_Machine {
    result: [TARGET_OS.count * TARGET_CPU.count]Target_Machine;
    i := 0;
    for os: TARGET_OS {
        for cpu: TARGET_CPU {
            defer i += 1;
            result[i] = Target_Machine.{os, cpu};
        }
    }
    return result;
}

TARGET_MATRIX :: #run build_target_matrix();

TARGET_DEFAULT :: Target_Machine.{
    os = OS,
    cpu = CPU,
};

vendor_root :: () -> string {
    return path_join(#filepath, "vendor");
}

vendor_project :: (name: string) -> string {
    return path_join(vendor_root(), name);
}

vendor_build_dir :: (target_machine: Target_Machine, name: string) -> string {
    return path_join(vendor_root(), "build", to_string(target_machine), name);
}

vendor_dist_dir :: (target_machine: Target_Machine, name: string) -> string {
    return path_join(vendor_root(), "dist", to_string(target_machine), name);
}

vendor_bin_dir :: (target_machine: Target_Machine, name: string) -> string {
    return path_join(vendor_dist_dir(target_machine, name), "bin");
}

vendor_lib_dir :: (target_machine: Target_Machine, name: string) -> string {
    return path_join(vendor_dist_dir(target_machine, name), "lib");
}

vendor_include_dir :: (target_machine: Target_Machine, name: string) -> string {
    return path_join(vendor_dist_dir(target_machine, name), "include");
}

build_root :: () -> string {
    return path_join(#filepath, "dist");
}

build_dir :: (target_machine: Target_Machine) -> string {
    return path_join(build_root(), to_string(target_machine));
}

bin_dir :: (target_machine: Target_Machine) -> string {
    return path_join(build_dir(target_machine), "bin");
}

lib_dir :: (target_machine: Target_Machine) -> string {
    return path_join(build_dir(target_machine), "lib");
}

setup_directries_for_target :: (target: Target_Machine) {
    assert(make_directory_if_it_does_not_exist(build_dir(target), recursive=true));
    assert(make_directory_if_it_does_not_exist(bin_dir(target), recursive=true));
    assert(make_directory_if_it_does_not_exist(lib_dir(target), recursive=true));
}

setup_symlinks :: (target := TARGET_DEFAULT) {
    root := build_root();

    bin := to_c_string(bin_dir(target));
    bin_link := to_c_string(path_join(root, "bin"));
    if symlink(bin, bin_link) != 0 {
        code, message := get_error_value_and_string();
        assert(code == EEXIST, "found: % '%'", code, message);
    }

    lib := to_c_string(lib_dir(target));
    lib_link := to_c_string(path_join(root, "lib"));
    if symlink(lib, lib_link) != 0 {
        code, message := get_error_value_and_string();
        assert(code == EEXIST, "found: % '%'", code, message);
    }
}

prepare :: () {
    set_build_options_dc(.{do_output=false});

    // clean();
    for target: TARGET_MATRIX {
        setup_directries_for_target(target);
    }
    setup_symlinks();
}

clean :: () {
    root := build_root();
    delete_directory(root,, logger=xx (){});
}

build_binary :: (output_name: string, root_file: string, target: Target_Machine) {
    target_name := path_join(to_string(target), "bin", output_name);
    w := compiler_create_workspace(target_name);
    defer compiler_destroy_workspace(w);

    target_options := get_build_options(w);
    if target.cpu == .X64 {
        target_options.backend = .X64;
    }

    target_options.shorten_filenames_in_error_messages = false;
    target_options.arithmetic_overflow_check = .FATAL;
    target_options.text_output_flags = xx 0;
    // target_options.llvm_options.bitcode_optimization_setting = .O2;
    // target_options.runtime_storageless_type_info = true;

    // target_options.lazy_foreign_function_lookups = false;
    // target_options.enable_bytecode_inliner = false;
    // target_options.enable_bytecode_deduplication = true;
    // target_options.dead_code_elimination = .MODULES_ONLY;

    target_options.output_executable_name = output_name;
    target_options.output_path = bin_dir(target);
    target_options.os_target = target.os;
    target_options.cpu_target = target.cpu;
    target_options.additional_linker_arguments = .["-w"]; // Disable warnings
    set_build_options(target_options, w);
    add_build_file(root_file, w);
}

to_string :: (target_machine: Target_Machine) -> string {
    s := sprint("%-%", target_machine.cpu, target_machine.os);
    to_lower_in_place(s);
    return s;
}

#run build();

#import "String";
#import "Posix";
#import "Basic";
#import "Compiler";
#import "File";
#import "System";
#import "Thread";

#import "File_Utilities";
#import "Process";

Bindings :: #import "Bindings_Generator";
