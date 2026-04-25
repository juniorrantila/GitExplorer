#run {
    set_build_options_dc(.{do_output=false});

    generate(Target_Machine.{
        os = .MACOS,
        cpu = .ARM64,
    });
    generate(Target_Machine.{
        os = .MACOS,
        cpu = .X64,
    });
}

#scope_file

generate :: (target: Target_Machine) {
    options: Generate_Bindings_Options;
    options.os = target.os;
    options.cpu = target.cpu;
    {
        lib := path_join("..", "..", "vendor", "dist", to_string(target), "cmark-gfm", "lib");
        array_add(*options.library_search_paths, lib);
        array_add(*options.libraries, .{filename="libcmark-gfm"});
        array_add(*options.libraries, .{filename="libcmark-gfm-extensions"});

        files := file_list(path_join("..", "..", "vendor", "dist", to_string(target), "cmark-gfm", "include"));
        array_add(*options.source_files, ..files);

        // options.log_stripped_declarations = false;
        // options.generate_compile_time_struct_checks = false;
    }

    output_filename := path_join(tprint("%.jai", to_string(target)));
    result := generate_bindings(options, output_filename);
    assert(result, "failed to generate bindings");
}

Target_Machine :: struct {
    os:  Operating_System_Tag;
    cpu: CPU_Tag;
}

to_string :: (target_machine: Target_Machine) -> string {
    s := tprint("%-%", target_machine.cpu, target_machine.os);
    to_lower_in_place(s);
    return s;
}

#import "File_Utilities";
#import "Basic";
#import "Compiler";
#import "String";
#import "Bindings_Generator";
