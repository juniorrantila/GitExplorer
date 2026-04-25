#add_context html: *HTML;
#add_context req: *HTTP_Request;
#add_context args: Arguments;

Arguments :: struct {
    git_base: string; @"?directory containing git repositories (default: $PWD/gits)"
    port: u16 = 8085;
};

entered := false;
main :: () {
    assert(!entered); // Common mistake to think main() is the <main> tag.
    entered = true;
    defer assert(false); // This function should never exit.

    ok, args, is_set := parse_arguments(Arguments);
    if !is_set.git_base args.git_base = path_join(get_working_directory(), "gits");
    is_set.git_base = true;

    log("args: %", args);
    make_directory_if_it_does_not_exist(args.git_base, recursive=true);

    sock: Socket;
    sock, ok = tcp_listen(args.port);
    if !ok exit(1);

    tg: Thread_Group;
    tg.logging = true;
    tg.name = "http";
    init(*tg, 32, (group: *Thread_Group, thread: *Thread, work: *void) -> Thread_Continue_Status {
        client: *Client = xx work;
        defer free(client,, allocator=client.allocator);
        context.args = client.args;

        handle_request(client,, allocator=temporary_allocator);

        return .CONTINUE;
    }, temporary_storage_size=8 * 1024 * 1024);

    start(*tg);
    while true {
        c := New(Client);
        c.allocator = context.allocator;
        c.client, c.addr = accept(sock);
        c.args = args;
        yes: s32 = 1;
        setsockopt(c.client, SOL_SOCKET, SO_NOSIGPIPE, *yes, size_of(s32));

        add_work(*tg, c, logging_name=to_string(c.addr));
    }

}

handle_request :: (c: *Client) {
    client: = c.client;
    defer tcp_close(*client);
    client_addr := c.addr;
    random_seed(cast,force(u64)c); // FIXME

    req, ok := http_request(client);
    if !ok return;
    context.req = *req;

    html: HTML;
    html.client = client;
    html.indent_sequence = " ";
    context.html = *html;

    page := parse_page(req.path, req.query);
    context.page = *page;

    log("%: % % '%'", to_string(client_addr), req.method, req.path, to_string(page));

    if #complete page.route == {
    case .FAVICON;
        begin_response(.OK);
        response_header("Content-Type", "image/svg+xml");
        response_header("Cache-Control", "max-age=3600");
        end_headers();
        defer end_response();

        svg_icon("mark-github");

        return;
    case .STATIC;
        assert(false);

    case .PROFILE;
        if !profile_exists(page.profile) {
            begin_response(.NOT_FOUND);
            defer end_response();
            // FIXME: content
            return;
        }

    case .REPO;
        if !repo_exists(page.repo.user, page.repo.name) {
            begin_response(.NOT_FOUND);
            defer end_response();
            // FIXME: content
            return;
        }

        if page.repo.file.count > 0 {
            path := path_join(..page.repo.file);
            if ends_with(path, ".png") {
                ok, content := read_repo_file(page.repo.user, page.repo.name, page.repo.file);
                if !ok {
                    begin_response(.NOT_FOUND);
                    defer end_response();
                    write("add avatar.png to your profile repo");
                    return;
                }

                begin_response(.OK);
                response_header("Content-Type", "image/png");
                response_header("Cache-Control", "max-age=3600");
                end_headers();
                write(content);
                end_response();
                return;
            }
            ok, content := read_repo_file(page.repo.user, page.repo.name, page.repo.file);

            if ok {
                if find_query_bool("raw") || is_binary(content) {
                    begin_response(.OK);
                    defer end_response();

                    if is_binary(content) {
                        response_header("Content-Type", "application/octet-stream");
                        response_header("Cache-Control", "max-age=3600");
                    } else {
                        response_header("Content-Type", "text/plain");
                        response_header("Cache-Control", "max-age=3600");
                    }
                    end_headers();
                    write(content);

                    return;
                }
            }
        }

    case .INDEX;
    case .NEW;
    case .REPOS;
    }

    {
        begin_response(.OK);
        defer end_response();

        response_header("Content-Type", "text/html");
        response_header("Cache-Control", "max-age=3600");
        {
            begin("html", attr=true);
            defer end();
            attr("lang", "en");
            end_attrs();

            {
                begin("head");
                defer end();

                meta(.["charset", "UTF-8"]);
                meta(
                    .["name", "viewport"],
                    .["content", "width=device-width,initial-scale=1"],
                );

                normalize_style();
                gruvbox();
                style();
            }

            {
                begin("body");
                defer end();

                page_header("juniorrantila"); // FIXME: Add support-ish for logging in.

                if #complete page.route == {
                case .FAVICON; assert(false);
                case .STATIC; assert(false);
                case .INDEX;
                    index_body();
                    return;
                case .NEW;
                    create_repo_body();
                    return;
                case .REPOS;
                    repos_page("juniorrantila"); // FIXME: Create component for all repos.
                    return;
                case .PROFILE;
                    profile_page(page.profile);
                    return;
                case .REPO;
                    repo_page(page.repo.user, page.repo.name, page.repo.file);
                    return;
                }
            }
        }
    }
}


Route :: enum {
    INDEX;

    FAVICON;

    NEW;
    REPOS;
    STATIC;

    PROFILE;
    REPO;
}

#add_context page: *Page;
Page :: struct {
    Self :: #this;

    route: Route;
    raw: string;
    query: string;

    using data: union {
        favicon: struct {};

        index: struct {};

        new: struct {};
        repos: struct {};
        static: string;

        profile: string;

        repo: struct {
            user: string;
            name: string;
            file: []string;
        }
    };

    make_new :: (query := "") -> string {
        return to_string(Self.{
            route = .NEW,
            query = query,
        });
    }

    make_repos :: (query := "") -> string {
        return to_string(Self.{
            route = .REPOS,
            query = query,
        });
    }

    make_static :: (path: string, query := "") -> string {
        return to_string(Self.{
            route = .STATIC,
            query = query,
            static = path,
        });
    }

    make_profile :: (username: string, query := "") -> string {
        return to_string(Self.{
            route = .PROFILE,
            query = query,
            profile = username,
        });
    }

    make_repo :: (user: string, name: string, file: []string = .[], query := "") -> string {
        return to_string(Self.{
            route = .REPO,
            query = query,
            repo = .{
                user = user,
                name = name,
                file = file,
            },
        });
    }
};

to_string :: (page: Page) -> string {
    base: string;
    if #complete page.route == {
    case .INDEX; base = "";

    case .FAVICON; base = "/favicon.ico";

    case .NEW; base = "/new";
    case .REPOS; base = "/repos";
    case .STATIC; base = tprint("/static/%", page.static);

    case .PROFILE; base = tprint("/%", page.profile);
    case .REPO; base = tprint("/%/%/%", page.repo.user, page.repo.name, path_join(..page.repo.file));
    };

    if page.query return tprint("%?%", base, page.query);
    return base;
}

parse_page :: (path: string, query: string) -> Page {
    result: Page;
    result.raw = path;
    result.query = query;
    result.route = .INDEX;

    if path == "/" return result;

    segments := split(path, "/");

    if segments.count >= 2 && segments[1] == "static" {
        segments.data += 2;
        segments.count -= 2;
        result.route = .STATIC;
        result.static = path_join(..segments);
        return result;
    }

    if segments.count == 2 {
        if segments[1] == {
        case "favicon.ico";
            result.route = .FAVICON;
            return result;
        case "new";
            result.route = .NEW;
            return result;
        case "repos";
            result.route = .REPOS;
            return result;
        }

        result.route = .PROFILE;
        result.profile = segments[1];
        return result;
    }

    if segments.count >= 3 {
        result.route = .REPO;

        result.repo.user = segments[1];
        result.repo.name = segments[2];
        segments.data += 3;
        segments.count -= 3;
        while segments.count > 0 && segments[segments.count - 1] == "" {
            segments.count -= 1;
        }

        result.repo.file = segments;

        return result;
    }

    return result;
}

Client :: struct {
    allocator: Allocator;
    client: Socket;
    addr: sockaddr_storage;
    args: Arguments;
};

repos_page :: (user: string) {
    begin("main");
    defer end();

    user_repos(user);
}

user_repos :: (user: string) {
    div(class="repos");
    defer end();

    q := find_query("q");

    {
        form(class="search");
        defer end();

        input("q", placeholder="Find a repository...", autofocus=true, autocomplete="off", onfocus="this.select()");
        // {
        //     select("sort", oninput="this.parentElement.submit()", title="sort");
        //     defer end();

        //     option("name",   "Name",   select="sort");
        //     option("random", "Random", select="sort");
        // }
        input("tab", value="repos", phantom = true);

        {
            button(type="submit");
            defer end();
            icon("search");
        }
    }

    {
        ul(class="repo-list");
        defer end();

        files: []string;
        dir := user_dir(user);

        if find_query("sort") == {
        case "random";
            files = quick_sort(file_list(dir, visit_directories=true), (a: string, b: string) -> s64 {
                a := random_get();
                b := random_get();

                if a > b return 1;
                if a < b return -1;
                return 0;
            });

        case; #through;
        case "name"; 
            files = quick_sort(file_list(dir, visit_directories=true), compare_strings);
        }

        mark := get_temporary_storage_mark();
        for file: files {
            defer set_temporary_storage_mark(mark);
            
            if !file_exists(path_join(file, ".git")) continue;
            if q != "" && !contains_nocase(file, q) continue;

            desc := read_entire_file(path_join(file, ".git", "description"));
            if desc == "Unnamed repository; edit this file 'description' to name the repository.\n" {
                desc = "No description";
            }

            base := path_filename(file);
            {
                {
                    li(class="repo-card", view=unique_css_name(base));
                    defer end();

                    {
                        a(tprint("/%/%", user, base));
                        defer end();

                        h3("%", base);
                    }

                    span("%", desc, class="desc");
                    small("Updated 5 days ago", class="update-time"); // FIXME
                }
            }
        }
    }
}

unique_css_name :: (s: string) -> string {
    hash := fnv1a_hash(s.data, s.count);
    return base64url_encode(string_u64(*hash));
}

breadcrumbs :: (user: string, repo: string, file: []string) {
    segments: [..]string;
    segments.allocator = temporary_allocator;

    array_add(*segments, user);
    array_add(*segments, repo);
    array_add(*segments, ..file);

    div(class="breadcrumbs");
    defer end();

    for segments {
        if it == "" continue;

        path := path_join(..array_view(segments, 0, it_index + 1));

        old := context.html.indent_sequence;
        context.html.indent_sequence = "";
        a(tprint("/%", path), indent=false, class="item", disabled = it_index == segments.count - 1);
        defer end(indent=false);
        text("%", it, indent=false);
        context.html.indent_sequence = old;
    }
}

repo_page :: (user: string, repo: string, file: []string) {
    begin("main", class="repo-page");
    defer end();

    rel_path := path_join(..file);
    path := path_join(repo_dir(user, repo), rel_path);

    breadcrumbs(user, repo, file);

    if is_directory(path) {
        files := quick_sort(file_list(path, visit_directories=true), compare_strings);

        {
            ul(class="files");
            defer end();
            if file.count > 0 {
                li();
                defer end();

                {
                    parent := file;
                    parent.count -= 1;

                    a(Page.make_repo(user, repo, file=parent), class="file-entry back");
                    defer end();

                    icon("reply");
                    text("..");
                }
            }

            m := get_temporary_storage_mark();
            for file: files {
                defer set_temporary_storage_mark(m);

                name := path_filename(file);
                if name == ".git" continue;

                li();
                defer end();

                // FIXME: Feels like there is a better way of joining here
                file_url := path_join(context.page.raw, name);

                if is_directory(file) {
                    a(file_url, class="file-entry dir");
                    defer end();

                    icon("file-directory-fill");
                    span("%/", name);
                } else {
                    a(file_url, class="file-entry reg");
                    defer end();

                    icon("file");
                    span("%", name);
                }
            }
        }
    } else {
        file := read_entire_file(path);

        pre(class="file-content");
        defer end();

        code();
        defer end();

        text("%", file, indent=false);
    }

    README_FILE_NAMES :: string.[
        "README.md",
        "README.rst",
        "README.txt",
        "README",
    ];

    m := get_temporary_storage_mark();
    for basename: README_FILE_NAMES {
        defer set_temporary_storage_mark(m);
        defer cmark_arena_reset();
        arena := cmark_get_arena_mem_allocator();

        ts_set_allocator(
            (size: u64) -> *void #c_call { return cmark_get_arena_mem_allocator().calloc(1, size); },
            arena.calloc,
            arena.realloc,
            arena.free,
        );
        tree_sitter := ts_parser_new();

        readme := path_join(path, basename);
        if !file_exists(readme) continue;

        content, ok := read_entire_file(readme);
        if !ok continue;

        options: s32 = CMARK_OPT_SMART|CMARK_OPT_GITHUB_PRE_LANG|CMARK_OPT_FOOTNOTES;
        parser := cmark_parser_new_with_mem(options, arena);
        cmark_parser_feed(parser, xx content.data, xx content.count);
        document := cmark_parser_finish(parser);

        // Replace relative urls
        iter := cmark_iter_new(document);
        while true {
            ev_type := cmark_iter_next(iter);
            if ev_type == .DONE break;

            node := cmark_iter_get_node(iter);
            url := to_string(cmark_node_get_url(node));
            if !url continue;
            if contains(url, "://") continue;
            if begins_with(url, "/") continue;

            // It is a relative url
            new_url := Page.make_repo(user, repo, file=split(url, "/"));
            data := arena.calloc(1, xx (new_url.count + 2));
            memcpy(data, new_url.data, new_url.count);
            cmark_node_set_url(node, data);
        }

        output := to_string(cmark_render_html(document, options, null));

        div(class="readme");
        defer end();
        {
            header();
            defer end();
            icon("book");
            h4(basename);
        }

        {
            article();
            defer end();
            write(output);
        }
    }
}

profile_page :: (user: string) {
    begin("main");
    defer end();

    profile_hero(user);
    {
        div(class="profile-content");
        defer end();

        {
            nav(class="tabs profile-tabs");
            defer end();

            nav_item :: ($icon_name: string, tab_name: string, name: string) {
                li(attr=true);
                attr("current-tab", tab_name == find_query("tab"));
                end_attrs();
                defer end();

                {
                    url := context.req.path;
                    if tab_name != "" url = tprint("%?tab=%", url, tab_name);

                    {
                        tab(url);
                        defer end();

                        icon(icon_name);
                        b("%", name);
                    }
                }
            } @PrintLike

            nav_item("book", "",      "Overview");
            nav_item("repo", "repos", "Repositories");
            nav_item("star", "stars", "Stars");
        }

        if find_query("tab") == {
        case "repos"; user_repos(user); // FIXME: Create a generic repos page
        case "stars"; stars();
        case "";      profile_dashboard();
        }
    }
}

profile_hero :: (user: string) {
    aside(class="profile-hero");

    ok, path, x, y := avatar_info(user);
    // FIXME: If not okay, generate random art based on username.
    img(src=path, width=256, height=256, title=tprint("%'s profile", user));
    span("%", user);

    defer end();
}

avatar_path :: (user: string) -> string {
    return path_join(user, "profile", "avatar.png");
}

avatar_info :: (user: string) -> ok: bool, path: string, s64, s64 {
    path := avatar_path(user);

    x: s32;
    y: s32;
    ok := stbi_info(temp_c_string(path_join(context.args.git_base, path)), *x, *y, null);

    return ok == 1, path_join("/", path), x, y;
}

profile_dashboard :: () {
    // FIXME
}

stars :: () {
    // FIXME
}

index_body :: () {
    begin("main");
    defer end();

    {
        a("/");
        defer end();
        h1("Hello, World");
    }

    span("current path %", context.req.path);

    p("This is a website");

    // icon(h, "solid", "xmark");

    span("some text");
    em("whaaat");
    span("some more text");

    {
        a("/page");
        defer end();

        span("some text");
    }
}

create_repo_body :: () {
    begin("main");
    defer end();

    {
        form(method="post");
        defer end();

        {
            label();
            defer end();

            span("Repository name");
            input("name", required=true);
        }

        {
            label();
            defer end();

            span("Description");
            input("description");
        }

        {
            label();
            defer end();

            span("Visibility");

            {
                select("visibility", required=true);
                defer end();

                option("public", "Public");
                option("private", "Private");
            }
        }

        {
            button("submit");
            defer end();

            text("Create repository");
        }
    }
}


page_header :: (user: string) {
    req := context.req;
    segments := split(req.path, "/");
    page := ifx segments.count > 1 then segments[1] else "Dashboard";
    if page == {
    case "new"; page = "Create repository";
    case "repos"; page = "Repositories";
    case ""; page = "Dashboard";
    }

    header();
    defer end();

    // left
    {
        div();
        defer end();

        logo();
        b("%", page, class="page-name");
        // {
        //     // a(tprint("/%", user));
        //     defer end();
        //     text(user);
        // }
    }

    // right
    {
        div();
        defer end();

        {
            // create new
            a("/new", title="create new");
            defer end();
            icon("plus", .LARGE);
        }

        {
            // repositories
            a("/repos", title="repositories");
            defer end();
            icon("repo", .LARGE);
        }

        {
            // profile
            a(tprint("/%", user), title="settings");
            defer end();
            icon("person", .LARGE);
        }
    }
}

logo :: () {
    a("/");
    defer end();

    icon("mark-github", .LARGE, class="logo");
}

script :: ($href: string, defer_ := true) {
    SCRIPT, ok :: #run read_entire_file(tprint("%/js/%", #filepath, href));
    #assert ok;

    begin("script", attr=true);
    attr("defer", defer_);
    end_attrs();
    text(SCRIPT, escape=false);
    end();
}

style :: () {
    CSS, ok :: #run read_entire_file(tprint("%/css/style.css", #filepath));
    #assert ok;

    css(CSS);
}

gruvbox :: () {
    CSS, ok :: #run read_entire_file(tprint("%/css/gruvbox.css", #filepath));
    #assert ok;

    css(CSS);
}

normalize_style :: () {
    CSS, ok :: #run read_entire_file(tprint("%/css/normalize.css", #filepath));
    #assert ok;

    css(CSS);
}

#scope_file

HTML_Tag :: struct {
    previous: *HTML_Tag;
    tag: string;
    id: u64;
    indent: bool;
}

HTML :: struct {
    client: Socket;
    head: s64;
    buffer: [1024]u8;

    indent_sequence: string;
    indent: s64;
    current_id: u64;
    current_tag: *HTML_Tag;
}

tag_id :: () -> u64 {
    html := context.html;

    if html.current_tag == null return 0;
    return html.current_tag.id;
}

flush :: () {
    html := context.html;

    rv := send(html.client, html.buffer.data, xx html.head, 0);
    if rv < 0 {
        err := get_last_socket_error();
        log_error("could not send data: %", err);
    }
    html.head = 0;
}

write_no_buffer :: (data: string) {
    html := context.html;

    rv := send(html.client, data.data, xx data.count, 0);
    if rv < 0 {
        err := get_last_socket_error();
        log_error("could not send data: %", err);
    }
}

write :: (data: string) {
    html := context.html;

    if (html.head + data.count) >= html.buffer.count flush();
    if data.count >= html.buffer.count {
        write_no_buffer(data);
        return;
    }

    memcpy(*html.buffer[html.head], data.data, data.count);
    html.head += data.count;
}

add_indent :: indent;
text :: (format_string: string, args: ..Any, escape := true, indent := true) {
    html := context.html;

    data := tprint(format_string, args=..args);

    i := add_indent();
    if indent data = replace(trim(data), "\n", tprint("\n%", i));

    if escape {
        data = replace(data, "&", "&amp;");
        data = replace(data, "<", "&lt;");
        data = replace(data, ">", "&gt;");
        data = replace(data, "\"", "&quot;");
        data = replace(data, "'", "&#39;");
    }
    if indent write(i);
    write(data);
    if indent write("\n");
} @PrintLike

begin_response :: (code: Response_Code) {
    write(tprint("HTTP/1.1 %\r\n", to_string(code)));

    response_header("Server", "jai");
    now := calendar_to_iso_string(to_calendar(current_time_monotonic()));
    response_header("Date", now);
}

response_header :: (key: string, value: string) {
    write(tprint("%: %\r\n", key, value));
}

end_headers :: () {
    write("\r\n");
}

end_response :: () {
    flush();
}

begin :: (tag: string, attr := false, class := "", title := "", view := "", indent := true) {
    html := context.html;

    if html.current_tag == null {
        end_headers();
        write("<!doctype html>\r\n");
    }

    data := New(HTML_Tag);
    data.tag = tag;
    data.previous = html.current_tag;
    html.current_id += 1;
    parent_id := ifx data.previous then data.previous.id else html.current_id;
    data.id = fnv1a_hash(html.current_id, h = fnv1a_hash(parent_id));
    data.indent = indent;

    html.current_tag = data;

    id := element_id(data.id);
    if indent write(add_indent());
    write(tprint("<%", tag));
    // add_attr("id", id);
    add_attr("class", class);
    add_attr("title", title);
    add_attr("view-", view);
    if !attr end_attrs();

    html.indent += 1;
}

end_attr_char :: () -> string {
    html: *HTML = context.html;

    if html.indent_sequence == "" return ">";
    return ">\n";
}

attr :: (key: string, value: s64) {
    write(tprint(" %=\"%\"", key, value));
}

attr :: (key: string, value: string, escape := true) {
    data := value;

    if escape {
        // data = replace(data, "&", "&amp;");
        // data = replace(data, "<", "&lt;");
        // data = replace(data, ">", "&gt;");
        data = replace(data, "\\", "\\\\");
        data = replace(data, "\"", "\\\"");
        data = replace(data, "&", "&amp;");
        data = replace(data, "<", "&lt;");
        data = replace(data, ">", "&gt;");
        // data = replace(data, "'", "&#39;");
    }

    if value != "" write(tprint(" %=\"%\"", key, data));
}

attr :: (key: string, value: bool) {
    if value write(tprint(" %", key));
}

end_attrs :: (indent := true) {
    if indent && context.html.current_tag.indent write(ifx context.html.indent_sequence == "" then ">" else ">\n");
    else write(">");
}

end :: (multiline := true, indent := true) {
    html := context.html;

    if html.current_tag == null {
        flush();
        return;
    }

    html.indent -= 1;

    tag := html.current_tag;
    if indent && tag.indent {
        if multiline write(tprint("%</%>", add_indent(), tag.tag));
        else write(" />");

        if html.indent_sequence != "" write("\n");

    } else {
        write(tprint("</%>", tag.tag));
        if tag.indent && html.indent_sequence != "" write("\n");
    }

    html.current_tag = html.current_tag.previous;
}

meta :: (properties: ..[]string) {
    write(indent());
    write("<meta");
    for properties {
        assert(it.count == 2);
        attr(it[0], it[1]);
    }
    end_attrs();
}

// <base href="https://www.example.com/" >
base :: (href: string) {
    write(indent());
    write("<base");
    attr("href", href);
    end_attrs();
}

indent :: () -> string {
    html := context.html;
    return repeated(html.indent_sequence, html.indent);
}

text_node :: ($tag: string, format_string: string, args: ..Any, class := "", title := "") {
    begin(tag, attr=true);
    attr("class", class);
    attr("title", title);
    end_attrs(indent=false);
    defer end(indent=tag != "span");

    text(format_string, args=..args, indent=tag != "span");
} @PrintLike

italic  :: #bake_arguments text_node(tag="i");
span    :: #bake_arguments text_node(tag="span");
small   :: #bake_arguments text_node(tag="small");
p       :: #bake_arguments text_node(tag="p");
em      :: #bake_arguments text_node(tag="em");
b       :: #bake_arguments text_node(tag="b");
h1      :: #bake_arguments text_node(tag="h1");
h2      :: #bake_arguments text_node(tag="h2");
h3      :: #bake_arguments text_node(tag="h3");
h4      :: #bake_arguments text_node(tag="h4");
h5      :: #bake_arguments text_node(tag="h5");
h6      :: #bake_arguments text_node(tag="h6");

aside :: #bake_arguments begin(tag="aside");
div :: #bake_arguments begin(tag="div");
header :: #bake_arguments begin(tag="header");
article :: #bake_arguments begin(tag="article");
section :: #bake_arguments begin(tag="section");
label :: #bake_arguments begin(tag="label");

nav :: #bake_arguments begin(tag="nav");
ul :: #bake_arguments begin(tag="ul");
li :: #bake_arguments begin(tag="li");
code :: #bake_arguments begin(tag="code", indent = false);
pre :: #bake_arguments begin(tag="pre", indent = false);

add_attr :: attr;
form :: (method := "", action := "", enctype := "", attr := false, class := "") {
    begin("form", attr = true);
    add_attr("method", method);
    add_attr("action", action);
    add_attr("enctype", enctype);
    add_attr("class", class);
    if !attr end_attrs();
}

input :: (name: string, type := "text", value := "", placeholder := "", $required := false, phantom := false, oninput := "", autofocus := false, autocomplete := "", onfocus := "") {
    begin("input", attr = true);
    attr("name", name);
    attr("type", type);
    attr("value", ifx value then value else find_query(name));
    attr("required", required);
    attr("placeholder", placeholder);
    attr("data-phantom", phantom);
    attr("autofocus", autofocus);
    attr("autocomplete", autocomplete);
    // attr("style", tprint("view-transition-name: %", name));
    attr("onfocus", onfocus);

    end(multiline=false);
}

img :: (src: string, width: s64, height: s64, title := "") {
    begin("img", attr = true);
    attr("src", src);
    attr("title", title);
    attr("width", width);
    attr("height", height);

    end(multiline=false);
}

select :: (name: string, $required := false, oninput := "", title := "") {
    begin("select", attr = true);
    attr("name", name);
    attr("required", required);
    attr("oninput", oninput);
    attr("title", title);

    end_attrs();
}

option :: (name: string, format_string: string, args: ..Any, select := "") {
    begin("option", attr = true);
    defer end();

    attr("value", name);
    if select attr("selected", find_query(select) == name);

    end_attrs();
    text(format_string, args=..args);
} @PrintLike

button :: (type := "") {
    begin("button", attr=true);
    attr("type", type);
    end_attrs();
}

tab :: (href: string, title := "", attr := false, class := "", indent := true, disabled := false) {
    a(href=href, title=title, attr = true, class = class, indent = indent, disabled = disabled);
    add_attr("onmousedown", "location.href=this.href");
    if !attr end_attrs();
}

a :: (href: string, title := "", attr := false, class := "", indent := true, disabled := false) {
    begin("a", attr=true, indent = indent);
    add_attr("href", href);
    add_attr("title", title);
    add_attr("class", class);
    add_attr("disabled", disabled);
    if !attr end_attrs();
}

css :: (source: string, external := false, media := "") {
    if external {
        write(indent());
        write("<link");
        attr("rel", "stylesheet");
        attr("src", source);
        attr("media", media);
        end_attrs();
        return;
    }

    begin("style", attr=true);
    attr("media", media);
    end_attrs();
    text("%", source, escape=false);
    end();
}

Icon_Size :: enum u8 {
    MEDIUM :: 16;
    LARGE  :: 24;
}

svg_icon :: ($name: string, $size: Icon_Size = .MEDIUM) {
    path :: #run tprint("%/octicons/%-%.svg", #filepath, name, cast(u8)size);
    content, ok :: #run read_entire_file(path);
    #assert ok;

    text("%", content, escape=false);
}

Icon_Color :: enum u8 {
    DEFAULT;
    SECONDARY;
};

icon :: ($name: string, $size: Icon_Size = .MEDIUM, $color: Icon_Color = .DEFAULT, class := "") {
    path :: #run tprint("%/octicons/%-%.svg", #filepath, name, cast(u8)size);
    content, ok :: #run read_entire_file(path);
    #assert ok;

    begin("x-icon", attr=true);
    attr("class", class);
    if color != .DEFAULT attr("color-", #run to_lower_copy(tprint("%", color)));
    end_attrs();
    svg_icon(name, size);
    end();
}

#scope_file

repeated :: (s: string, count: s64) -> string {
    if s == "" return "";

    sb: String_Builder;
    sb.allocator = temporary_allocator;
    for 0..count - 1 append(*sb, s);
    return builder_to_string(*sb);
}

string_u64 :: (value: *u64) -> string {
    s: string;
    s.data = xx value;
    s.count = 8;
    for 0..7 {
        if s.data[it] == 0 {
            s.count = it;
            break;
        }
    }
    return s;
}

element_id :: (n: u64) -> string {
    return base64url_encode(string_u64(*n),, allocator=temporary_allocator);
}

find_query_bool :: (name: string) -> bool {
    q := context.req.query;

    entries := split(q, "&");
    for entries {
        entry := split(it, "=");
        if entry[0] == name return true;
    }

    return false;
}

find_query :: (name: string) -> string {
    q := context.req.query;

    entries := split(q, "&");
    for entries {
        entry := split(it, "=");
        if entry[0] == name {
            if entry.count == 1 return "true";
            return entry[1];
        }
    }

    return "";
}

profile_exists :: (username: string) -> bool {
    return file_exists(path_join(context.args.git_base, username));
}

repo_exists :: (user: string, repo: string) -> bool {
    return file_exists(repo_dir(user, repo));
}

user_dir :: (user: string) -> string {
    git_base := context.args.git_base;

    return path_join(git_base, user);
}

repo_dir :: (user: string, repo: string) -> string {
    return path_join(user_dir(user), repo);
}

read_repo_file :: (user: string, repo: string, file: []string) -> ok: bool, string {
    dir := repo_dir(user, repo);

    path := path_join(..file);
    path = path_join(dir, path);
    content, ok := read_entire_file(path);
    return ok, content;
}

is_binary :: (data: string) -> bool {
    for char: data {
        if char == 0 return true;
    }
    return false;
}

#import "Basic";
#import "Socket";
#import "Net";
#import "HTML";
#import "String";
#import "Base64";
#import "File";
#import "File_Utilities";
#import "Command_Line";
#import "Hash";
#import "Hash_Table";
#import "Sort";
#import "stb_image";
#import "Process";
#import "Thread";
#import "Random";
#import "CMark";
#import "Tree_Sitter";
