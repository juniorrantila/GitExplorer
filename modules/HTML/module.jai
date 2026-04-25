template :: (path: string) -> string {
    content := read_entire_file(path);

    sb: String_Builder;

    append(*sb, #string EOF
        res: HTTP_Response;
        sb: String_Builder;
        temporary_data: []u8;
    EOF);

    mode := Mode.HTML;

    while content {
        if mode == {
        case .HTML; content, mode = html_mode(content, *sb);
        case .CODE; content, mode = code_mode(content, *sb);
        case .INSERT; content, mode = insert_mode(content, *sb);
        }
    }

    append(*sb, #string EOF
        res.body = builder_to_string(*sb);
        return res;
    EOF);

    return builder_to_string(*sb);
}

#scope_file

Mode :: enum {
    HTML;
    CODE;
    INSERT;
};

BEGIN_CODE :: "<?";
END_CODE :: "?>";

BEGIN_INSERT :: "<=";
END_INSERT :: "=>";

insert_mode :: (_content: string, sb: *String_Builder) -> rest: string, Mode {
    content := _content;

    next: Mode;

    append(sb, "append(*sb, cast(string)(");

    while content {
        if starts_with(content, END_INSERT) {
            content.data += END_INSERT.count;
            content.count -= END_INSERT.count;
            next = .HTML;
            break;
        }

        append(sb, content[0]);
        content.data += 1;
        content.count -= 1;
    }

    append(sb, "));\n");

    return content, next;
}

code_mode :: (_content: string, sb: *String_Builder) -> rest: string, Mode {
    content := _content;

    next: Mode;

    while content {
        if starts_with(content, END_CODE) {
            content.data += END_CODE.count;
            content.count -= END_CODE.count;
            next = .HTML;
            break;
        }

        append(sb, content[0]);
        content.data += 1;
        content.count -= 1;
    }

    return content, next;
}

html_mode :: (_content: string, sb: *String_Builder) -> rest: string, Mode {
    content := _content;

    next: Mode;
    print_to_builder(sb, "\n{ temporary_data = u8.[");
    while content {
        if starts_with(content, BEGIN_CODE) {
            content.data += BEGIN_CODE.count;
            content.count -= BEGIN_CODE.count;
            next = .CODE;
            break;
        }

        if starts_with(content, BEGIN_INSERT) {
            content.data += BEGIN_INSERT.count;
            content.count -= BEGIN_INSERT.count;
            next = .INSERT;
            break;
        }

        print_to_builder(sb, "%, ", content[0]);
        content.data += 1;
        content.count -= 1;
    }

    print_to_builder(sb, "];\n");
    print_to_builder(sb, "append(*sb, temporary_data.data, temporary_data.count); }\n");

    return content, next;
}

#import "Basic";
#import "File";
#import "String";
