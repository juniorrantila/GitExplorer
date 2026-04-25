
tcp_listen :: (port: u16, backlog: s32 = 16) -> Socket, ok: bool {
    socket_init();

    hints: addrinfo;
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK.STREAM;
    hints.ai_flags = AI.PASSIVE;
    servinfo: *addrinfo;
    rv := getaddrinfo(null, temp_c_string(tprint("%", port)), *hints, *servinfo);
    if rv != 0 {
        log_error("getaddrinfo: %", to_string(gai_strerror(rv)));
        return -1, false;
    }

    sock: Socket = -1;
    p: *addrinfo = servinfo;
    while p {
        sock = socket(p.ai_family, p.ai_socktype, p.ai_protocol);
        if sock == -1 {
            p = p.ai_next;
            continue;
        }

        yes: s32 = 1;
        setsockopt(sock, SOL_SOCKET, SO_REUSEADDR, *yes, size_of(s32));

        if bind(sock, p.ai_addr, p.ai_addrlen) == -1 {
            close_and_reset(*sock);
            p = p.ai_next;
            continue;
        }

        break;
    }

    if !p {
        log_error("failed to bind server");
        return -1, false;
    }

    if listen(sock, backlog) < 0 {
        err := get_last_socket_error();
        log_error("failed to listen: %", err);
        return -1, false;
    }

    log("listening on %", to_string(servinfo.ai_addr));
    freeaddrinfo(servinfo);

    return sock, true;
}

tcp_close :: (socket: *Socket) {
    shutdown(socket.*, SHUT.WR);
    buf: u8;
    while recv(socket.*, *buf, 1, 0) > 0 {}
    close_and_reset(socket);
}

Response_Code :: enum u16 {
    OK :: 200;
    NOT_FOUND :: 404;
}

HTTP_Response :: struct {
    code: Response_Code = .OK;
    headers: Table(string, string);
    body: string;
}

to_string :: (code: Response_Code) -> string {
    if #complete code == {
    case .OK; return "200 OK";
    case .NOT_FOUND; return "404 Not Found";
    }
}

to_string :: (res: HTTP_Response) -> string {
    sb: String_Builder;

    print_to_builder(*sb, "HTTP/1.1 %\r\n", to_string(res.code));
    for res.headers {
        print_to_builder(*sb, "%: %\r\n", it_index, it);
    }
    print_to_builder(*sb, "\r\n");

    append(*sb, res.body);

    return builder_to_string(*sb);
}

HTTP_Method :: enum {
    GET   :: 1;
    POST  :: 2;
    PUT   :: 4;
    PATCH :: 3;
}

HTTP_Request :: struct {
    method: HTTP_Method;
    path: string;
    query: string;
    http_version: string;
    headers: Table(string, string);
    body: string;
}

http_request :: (client: Socket) -> HTTP_Request, ok: bool {
    request := read_http_request(client);
    req, ok := parse_http_request(request);
    return req, ok;
}

parse_http_request :: (request: string) -> HTTP_Request, ok: bool {
    result: HTTP_Request;

    r := request;

    method: string;
    method = chop_until(*request, " ");
    to_lower_in_place(method);

    if method == {
    case "get";     result.method = .GET;
    case "post";    result.method = .POST;
    case "put";     result.method = .PUT;
    case "patch";   result.method = .PATCH;
    case;   return result, false; // FIXME: Report error
    }

    result.path = chop_until(*request, " ");
    found, path, query := split_from_left(result.path, "?");
    if found result.path = path;
    result.path = replace(result.path, "%20", " ");

    result.query = query;

    result.http_version = trim(chop_until(*request, "\n"));

    end := find_index_from_left(request, "\r\n\r\n");
    if end < 0 return result, true;
    headers := slice(request, 0, end);
    result.body = request;
    result.body.data += end;
    result.body.count -= end;
    result.body = trim_left(result.body);

    while headers {
        key := trim(chop_until(*headers, ":"));
        if !key break;
        to_lower_in_place(key);
        value := trim(chop_until(*headers, "\n"));
        table_set(*result.headers, key, value);
    }

    return result, true;
}

read_http_request :: (sock: Socket) -> string {
    req: HTTP_Request;
    builder: String_Builder;

    buf: [1024]u8;
    while true {
        rv := recv(sock, buf.data, buf.count, 0);
        if rv == 0 break;
        if rv < 0 {
            err := get_last_socket_error();
            log_error("could not recv: %", err);
            break;
        }

        append(*builder, buf.data, rv);
        if rv < buf.count break;
    }

    return builder_to_string(*builder);
}

send :: (sock: Socket, res: HTTP_Response, msg: MSG = 0) {
    text := to_string(res);
    send(sock, text.data, xx text.count, msg);
}

#scope_file

chop_until :: (s: *string, char: u8) -> string {
    left := s.*;
    left.count = 0;

    chars := 0;
    ss := s.*;
    while ss {
        if ss[0] == #char " " break;
        if ss[0] == 9         break;
        advance(*ss, 1);
        left.count += 1;
    }
    if ss.count > 0 {
        if ss[0] == #char " " || ss[0] == 9 {
            advance(*ss, 1);
        }
    }

    s.* = ss;
    return left;
}

#import "Socket";
#import "Hash_Table";
#import "Basic";
#import "Posix";
#import "String";
