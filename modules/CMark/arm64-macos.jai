//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



CMARK_GFM_VERSION :: (0 << 24) | (29 << 16) | (0 << 8) | 13;
CMARK_GFM_VERSION_STRING :: "0.29.0.gfm.13";

CMARK_NODE_TYPE_PRESENT :: 0x8000;
CMARK_NODE_TYPE_BLOCK :: CMARK_NODE_TYPE_PRESENT | 0x0000;
CMARK_NODE_TYPE_INLINE :: CMARK_NODE_TYPE_PRESENT | 0x4000;
CMARK_NODE_TYPE_MASK :: 0xc000;
CMARK_NODE_VALUE_MASK :: 0x3fff;

cmark_node_get_header_level :: cmark_node_get_heading_level;
cmark_node_set_header_level :: cmark_node_set_heading_level;

CMARK_OPT_DEFAULT :: 0;

CMARK_OPT_SOURCEPOS :: 1 << 1;

CMARK_OPT_HARDBREAKS :: 1 << 2;

CMARK_OPT_SAFE :: 1 << 3;

CMARK_OPT_UNSAFE :: 1 << 17;

CMARK_OPT_NOBREAKS :: 1 << 4;

CMARK_OPT_NORMALIZE :: 1 << 8;

CMARK_OPT_VALIDATE_UTF8 :: 1 << 9;

CMARK_OPT_SMART :: 1 << 10;

CMARK_OPT_GITHUB_PRE_LANG :: 1 << 11;

CMARK_OPT_LIBERAL_HTML_TAG :: 1 << 12;

CMARK_OPT_FOOTNOTES :: 1 << 13;

CMARK_OPT_STRIKETHROUGH_DOUBLE_TILDE :: 1 << 14;

CMARK_OPT_TABLE_PREFER_STYLE_ATTRIBUTES :: 1 << 15;

CMARK_OPT_FULL_INFO_STRING :: 1 << 16;

cmark_gfm_extensions_tasklist_is_checked :: cmark_gfm_extensions_get_tasklist_item_checked;

/** Convert 'text' (assumed to be a UTF-8 encoded string with length
* 'len') from CommonMark Markdown to HTML, returning a null-terminated,
* UTF-8-encoded string. It is the caller's responsibility
* to free the returned buffer.
*/
cmark_markdown_to_html :: (text: *u8, len: u64, options: s32) -> *u8 #foreign libcmark_gfm;

cmark_node_type :: enum u32 {
    NONE                :: 0;

    DOCUMENT            :: 32769;
    BLOCK_QUOTE         :: 32770;
    LIST                :: 32771;
    ITEM                :: 32772;
    CODE_BLOCK          :: 32773;
    HTML_BLOCK          :: 32774;
    CUSTOM_BLOCK        :: 32775;
    PARAGRAPH           :: 32776;
    HEADING             :: 32777;
    THEMATIC_BREAK      :: 32778;
    FOOTNOTE_DEFINITION :: 32779;

    TEXT                :: 49153;
    SOFTBREAK           :: 49154;
    LINEBREAK           :: 49155;
    CODE                :: 49156;
    HTML_INLINE         :: 49157;
    CUSTOM_INLINE       :: 49158;
    EMPH                :: 49159;
    STRONG              :: 49160;
    LINK                :: 49161;
    IMAGE               :: 49162;
    FOOTNOTE_REFERENCE  :: 49163;

    CMARK_NODE_NONE                :: NONE;

    CMARK_NODE_DOCUMENT            :: DOCUMENT;
    CMARK_NODE_BLOCK_QUOTE         :: BLOCK_QUOTE;
    CMARK_NODE_LIST                :: LIST;
    CMARK_NODE_ITEM                :: ITEM;
    CMARK_NODE_CODE_BLOCK          :: CODE_BLOCK;
    CMARK_NODE_HTML_BLOCK          :: HTML_BLOCK;
    CMARK_NODE_CUSTOM_BLOCK        :: CUSTOM_BLOCK;
    CMARK_NODE_PARAGRAPH           :: PARAGRAPH;
    CMARK_NODE_HEADING             :: HEADING;
    CMARK_NODE_THEMATIC_BREAK      :: THEMATIC_BREAK;
    CMARK_NODE_FOOTNOTE_DEFINITION :: FOOTNOTE_DEFINITION;

    CMARK_NODE_TEXT                :: TEXT;
    CMARK_NODE_SOFTBREAK           :: SOFTBREAK;
    CMARK_NODE_LINEBREAK           :: LINEBREAK;
    CMARK_NODE_CODE                :: CODE;
    CMARK_NODE_HTML_INLINE         :: HTML_INLINE;
    CMARK_NODE_CUSTOM_INLINE       :: CUSTOM_INLINE;
    CMARK_NODE_EMPH                :: EMPH;
    CMARK_NODE_STRONG              :: STRONG;
    CMARK_NODE_LINK                :: LINK;
    CMARK_NODE_IMAGE               :: IMAGE;
    CMARK_NODE_FOOTNOTE_REFERENCE  :: FOOTNOTE_REFERENCE;
}

cmark_list_type :: enum u32 {
    NO_LIST      :: 0;
    BULLET_LIST  :: 1;
    ORDERED_LIST :: 2;

    CMARK_NO_LIST      :: NO_LIST;
    CMARK_BULLET_LIST  :: BULLET_LIST;
    CMARK_ORDERED_LIST :: ORDERED_LIST;
}

cmark_delim_type :: enum u32 {
    NO_DELIM     :: 0;
    PERIOD_DELIM :: 1;
    PAREN_DELIM  :: 2;

    CMARK_NO_DELIM     :: NO_DELIM;
    CMARK_PERIOD_DELIM :: PERIOD_DELIM;
    CMARK_PAREN_DELIM  :: PAREN_DELIM;
}

cmark_node :: struct {}
cmark_parser :: struct {}
cmark_iter :: struct {}
cmark_syntax_extension :: struct {}

/** Defines the memory allocation functions to be used by CMark
* when parsing and allocating a document tree
*/
cmark_mem :: struct {
    calloc:  #type (unknown0: u64, unknown1: u64) -> *void #c_call;
    realloc: #type (unknown0: *void, unknown1: u64) -> *void #c_call;
    free:    #type (unknown0: *void) -> void #c_call;
}

/** The default memory allocator; uses the system's calloc,
* realloc and free.
*/
cmark_get_default_mem_allocator :: () -> *cmark_mem #foreign libcmark_gfm;

/** An arena allocator; uses system calloc to allocate large
* slabs of memory.  Memory in these slabs is not reused at all.
*/
cmark_get_arena_mem_allocator :: () -> *cmark_mem #foreign libcmark_gfm;

/** Resets the arena allocator, quickly returning all used memory
* to the operating system.
*/
cmark_arena_reset :: () -> void #foreign libcmark_gfm;

/** Callback for freeing user data with a 'cmark_mem' context.
*/
cmark_free_func :: #type (mem: *cmark_mem, user_data: *void) -> void #c_call;

/** A generic singly linked list.
*/
_cmark_llist :: struct {
    next: *_cmark_llist;
    data: *void;
}

/** A generic singly linked list.
*/
cmark_llist :: _cmark_llist;

/** Append an element to the linked list, return the possibly modified
* head of the list.
*/
cmark_llist_append :: (mem: *cmark_mem, head: *cmark_llist, data: *void) -> *cmark_llist #foreign libcmark_gfm;

/** Free the list starting with 'head', calling 'free_func' with the
*  data pointer of each of its elements
*/
cmark_llist_free_full :: (mem: *cmark_mem, head: *cmark_llist, free_func: cmark_free_func) -> void #foreign libcmark_gfm;

/** Free the list starting with 'head'
*/
cmark_llist_free :: (mem: *cmark_mem, head: *cmark_llist) -> void #foreign libcmark_gfm;

/** Creates a new node of type 'type'.  Note that the node may have
* other required properties, which it is the caller's responsibility
* to assign.
*/
cmark_node_new :: (type: cmark_node_type) -> *cmark_node #foreign libcmark_gfm;

/** Same as `cmark_node_new`, but explicitly listing the memory
* allocator used to allocate the node.  Note:  be sure to use the same
* allocator for every node in a tree, or bad things can happen.
*/
cmark_node_new_with_mem :: (type: cmark_node_type, mem: *cmark_mem) -> *cmark_node #foreign libcmark_gfm;

cmark_node_new_with_ext :: (type: cmark_node_type, extension: *cmark_syntax_extension) -> *cmark_node #foreign libcmark_gfm;

cmark_node_new_with_mem_and_ext :: (type: cmark_node_type, mem: *cmark_mem, extension: *cmark_syntax_extension) -> *cmark_node #foreign libcmark_gfm;

/** Frees the memory allocated for a node and any children.
*/
cmark_node_free :: (node: *cmark_node) -> void #foreign libcmark_gfm;

/** Returns the next node in the sequence after 'node', or NULL if
* there is none.
*/
cmark_node_next :: (node: *cmark_node) -> *cmark_node #foreign libcmark_gfm;

/** Returns the previous node in the sequence after 'node', or NULL if
* there is none.
*/
cmark_node_previous :: (node: *cmark_node) -> *cmark_node #foreign libcmark_gfm;

/** Returns the parent of 'node', or NULL if there is none.
*/
cmark_node_parent :: (node: *cmark_node) -> *cmark_node #foreign libcmark_gfm;

/** Returns the first child of 'node', or NULL if 'node' has no children.
*/
cmark_node_first_child :: (node: *cmark_node) -> *cmark_node #foreign libcmark_gfm;

/** Returns the last child of 'node', or NULL if 'node' has no children.
*/
cmark_node_last_child :: (node: *cmark_node) -> *cmark_node #foreign libcmark_gfm;

/** Returns the footnote reference of 'node', or NULL if 'node' doesn't have a
* footnote reference.
*/
cmark_node_parent_footnote_def :: (node: *cmark_node) -> *cmark_node #foreign libcmark_gfm;

/**
* ## Iterator
*
* An iterator will walk through a tree of nodes, starting from a root
* node, returning one node at a time, together with information about
* whether the node is being entered or exited.  The iterator will
* first descend to a child node, if there is one.  When there is no
* child, the iterator will go to the next sibling.  When there is no
* next sibling, the iterator will return to the parent (but with
* a 'cmark_event_type' of `CMARK_EVENT_EXIT`).  The iterator will
* return `CMARK_EVENT_DONE` when it reaches the root node again.
* One natural application is an HTML renderer, where an `ENTER` event
* outputs an open tag and an `EXIT` event outputs a close tag.
* An iterator might also be used to transform an AST in some systematic
* way, for example, turning all level-3 headings into regular paragraphs.
*
*     void
*     usage_example(cmark_node *root) {
*         cmark_event_type ev_type;
*         cmark_iter *iter = cmark_iter_new(root);
*
*         while ((ev_type = cmark_iter_next(iter)) != CMARK_EVENT_DONE) {
*             cmark_node *cur = cmark_iter_get_node(iter);
*             // Do something with `cur` and `ev_type`
*         }
*
*         cmark_iter_free(iter);
*     }
*
* Iterators will never return `EXIT` events for leaf nodes, which are nodes
* of type:
*
* * CMARK_NODE_HTML_BLOCK
* * CMARK_NODE_THEMATIC_BREAK
* * CMARK_NODE_CODE_BLOCK
* * CMARK_NODE_TEXT
* * CMARK_NODE_SOFTBREAK
* * CMARK_NODE_LINEBREAK
* * CMARK_NODE_CODE
* * CMARK_NODE_HTML_INLINE
*
* Nodes must only be modified after an `EXIT` event, or an `ENTER` event for
* leaf nodes.
*/
cmark_event_type :: enum u32 {
    NONE  :: 0;
    DONE  :: 1;
    ENTER :: 2;
    EXIT  :: 3;

    CMARK_EVENT_NONE  :: NONE;
    CMARK_EVENT_DONE  :: DONE;
    CMARK_EVENT_ENTER :: ENTER;
    CMARK_EVENT_EXIT  :: EXIT;
}

/** Creates a new iterator starting at 'root'.  The current node and event
* type are undefined until 'cmark_iter_next' is called for the first time.
* The memory allocated for the iterator should be released using
* 'cmark_iter_free' when it is no longer needed.
*/
cmark_iter_new :: (root: *cmark_node) -> *cmark_iter #foreign libcmark_gfm;

/** Frees the memory allocated for an iterator.
*/
cmark_iter_free :: (iter: *cmark_iter) -> void #foreign libcmark_gfm;

/** Advances to the next node and returns the event type (`CMARK_EVENT_ENTER`,
* `CMARK_EVENT_EXIT` or `CMARK_EVENT_DONE`).
*/
cmark_iter_next :: (iter: *cmark_iter) -> cmark_event_type #foreign libcmark_gfm;

/** Returns the current node.
*/
cmark_iter_get_node :: (iter: *cmark_iter) -> *cmark_node #foreign libcmark_gfm;

/** Returns the current event type.
*/
cmark_iter_get_event_type :: (iter: *cmark_iter) -> cmark_event_type #foreign libcmark_gfm;

/** Returns the root node.
*/
cmark_iter_get_root :: (iter: *cmark_iter) -> *cmark_node #foreign libcmark_gfm;

/** Resets the iterator so that the current node is 'current' and
* the event type is 'event_type'.  The new current node must be a
* descendant of the root node or the root node itself.
*/
cmark_iter_reset :: (iter: *cmark_iter, current: *cmark_node, event_type: cmark_event_type) -> void #foreign libcmark_gfm;

/** Returns the user data of 'node'.
*/
cmark_node_get_user_data :: (node: *cmark_node) -> *void #foreign libcmark_gfm;

/** Sets arbitrary user data for 'node'.  Returns 1 on success,
* 0 on failure.
*/
cmark_node_set_user_data :: (node: *cmark_node, user_data: *void) -> s32 #foreign libcmark_gfm;

/** Set free function for user data */
cmark_node_set_user_data_free_func :: (node: *cmark_node, free_func: cmark_free_func) -> s32 #foreign libcmark_gfm;

/** Returns the type of 'node', or `CMARK_NODE_NONE` on error.
*/
cmark_node_get_type :: (node: *cmark_node) -> cmark_node_type #foreign libcmark_gfm;

/** Like 'cmark_node_get_type', but returns a string representation
of the type, or `"<unknown>"`.
*/
cmark_node_get_type_string :: (node: *cmark_node) -> *u8 #foreign libcmark_gfm;

/** Returns the string contents of 'node', or an empty
string if none is set.  Returns NULL if called on a
node that does not have string content.
*/
cmark_node_get_literal :: (node: *cmark_node) -> *u8 #foreign libcmark_gfm;

/** Sets the string contents of 'node'.  Returns 1 on success,
* 0 on failure.
*/
cmark_node_set_literal :: (node: *cmark_node, content: *u8) -> s32 #foreign libcmark_gfm;

/** Returns the heading level of 'node', or 0 if 'node' is not a heading.
*/
cmark_node_get_heading_level :: (node: *cmark_node) -> s32 #foreign libcmark_gfm;

/** Sets the heading level of 'node', returning 1 on success and 0 on error.
*/
cmark_node_set_heading_level :: (node: *cmark_node, level: s32) -> s32 #foreign libcmark_gfm;

/** Returns the list type of 'node', or `CMARK_NO_LIST` if 'node'
* is not a list.
*/
cmark_node_get_list_type :: (node: *cmark_node) -> cmark_list_type #foreign libcmark_gfm;

/** Sets the list type of 'node', returning 1 on success and 0 on error.
*/
cmark_node_set_list_type :: (node: *cmark_node, type: cmark_list_type) -> s32 #foreign libcmark_gfm;

/** Returns the list delimiter type of 'node', or `CMARK_NO_DELIM` if 'node'
* is not a list.
*/
cmark_node_get_list_delim :: (node: *cmark_node) -> cmark_delim_type #foreign libcmark_gfm;

/** Sets the list delimiter type of 'node', returning 1 on success and 0
* on error.
*/
cmark_node_set_list_delim :: (node: *cmark_node, delim: cmark_delim_type) -> s32 #foreign libcmark_gfm;

/** Returns starting number of 'node', if it is an ordered list, otherwise 0.
*/
cmark_node_get_list_start :: (node: *cmark_node) -> s32 #foreign libcmark_gfm;

/** Sets starting number of 'node', if it is an ordered list. Returns 1
* on success, 0 on failure.
*/
cmark_node_set_list_start :: (node: *cmark_node, start: s32) -> s32 #foreign libcmark_gfm;

/** Returns 1 if 'node' is a tight list, 0 otherwise.
*/
cmark_node_get_list_tight :: (node: *cmark_node) -> s32 #foreign libcmark_gfm;

/** Sets the "tightness" of a list.  Returns 1 on success, 0 on failure.
*/
cmark_node_set_list_tight :: (node: *cmark_node, tight: s32) -> s32 #foreign libcmark_gfm;

/**
* Returns item index of 'node'. This is only used when rendering output
* formats such as commonmark, which need to output the index. It is not
* required for formats such as html or latex.
*/
cmark_node_get_item_index :: (node: *cmark_node) -> s32 #foreign libcmark_gfm;

/** Sets item index of 'node'. Returns 1 on success, 0 on failure.
*/
cmark_node_set_item_index :: (node: *cmark_node, idx: s32) -> s32 #foreign libcmark_gfm;

/** Returns the info string from a fenced code block.
*/
cmark_node_get_fence_info :: (node: *cmark_node) -> *u8 #foreign libcmark_gfm;

/** Sets the info string in a fenced code block, returning 1 on
* success and 0 on failure.
*/
cmark_node_set_fence_info :: (node: *cmark_node, info: *u8) -> s32 #foreign libcmark_gfm;

/** Sets code blocks fencing details
*/
cmark_node_set_fenced :: (node: *cmark_node, fenced: s32, length: s32, offset: s32, character: u8) -> s32 #foreign libcmark_gfm;

/** Returns code blocks fencing details
*/
cmark_node_get_fenced :: (node: *cmark_node, length: *s32, offset: *s32, character: *u8) -> s32 #foreign libcmark_gfm;

/** Returns the URL of a link or image 'node', or an empty string
if no URL is set.  Returns NULL if called on a node that is
not a link or image.
*/
cmark_node_get_url :: (node: *cmark_node) -> *u8 #foreign libcmark_gfm;

/** Sets the URL of a link or image 'node'. Returns 1 on success,
* 0 on failure.
*/
cmark_node_set_url :: (node: *cmark_node, url: *u8) -> s32 #foreign libcmark_gfm;

/** Returns the title of a link or image 'node', or an empty
string if no title is set.  Returns NULL if called on a node
that is not a link or image.
*/
cmark_node_get_title :: (node: *cmark_node) -> *u8 #foreign libcmark_gfm;

/** Sets the title of a link or image 'node'. Returns 1 on success,
* 0 on failure.
*/
cmark_node_set_title :: (node: *cmark_node, title: *u8) -> s32 #foreign libcmark_gfm;

/** Returns the literal "on enter" text for a custom 'node', or
an empty string if no on_enter is set.  Returns NULL if called
on a non-custom node.
*/
cmark_node_get_on_enter :: (node: *cmark_node) -> *u8 #foreign libcmark_gfm;

/** Sets the literal text to render "on enter" for a custom 'node'.
Any children of the node will be rendered after this text.
Returns 1 on success 0 on failure.
*/
cmark_node_set_on_enter :: (node: *cmark_node, on_enter: *u8) -> s32 #foreign libcmark_gfm;

/** Returns the literal "on exit" text for a custom 'node', or
an empty string if no on_exit is set.  Returns NULL if
called on a non-custom node.
*/
cmark_node_get_on_exit :: (node: *cmark_node) -> *u8 #foreign libcmark_gfm;

/** Sets the literal text to render "on exit" for a custom 'node'.
Any children of the node will be rendered before this text.
Returns 1 on success 0 on failure.
*/
cmark_node_set_on_exit :: (node: *cmark_node, on_exit: *u8) -> s32 #foreign libcmark_gfm;

/** Returns the line on which 'node' begins.
*/
cmark_node_get_start_line :: (node: *cmark_node) -> s32 #foreign libcmark_gfm;

/** Returns the column at which 'node' begins.
*/
cmark_node_get_start_column :: (node: *cmark_node) -> s32 #foreign libcmark_gfm;

/** Returns the line on which 'node' ends.
*/
cmark_node_get_end_line :: (node: *cmark_node) -> s32 #foreign libcmark_gfm;

/** Returns the column at which 'node' ends.
*/
cmark_node_get_end_column :: (node: *cmark_node) -> s32 #foreign libcmark_gfm;

/** Unlinks a 'node', removing it from the tree, but not freeing its
* memory.  (Use 'cmark_node_free' for that.)
*/
cmark_node_unlink :: (node: *cmark_node) -> void #foreign libcmark_gfm;

/** Inserts 'sibling' before 'node'.  Returns 1 on success, 0 on failure.
*/
cmark_node_insert_before :: (node: *cmark_node, sibling: *cmark_node) -> s32 #foreign libcmark_gfm;

/** Inserts 'sibling' after 'node'. Returns 1 on success, 0 on failure.
*/
cmark_node_insert_after :: (node: *cmark_node, sibling: *cmark_node) -> s32 #foreign libcmark_gfm;

/** Replaces 'oldnode' with 'newnode' and unlinks 'oldnode' (but does
* not free its memory).
* Returns 1 on success, 0 on failure.
*/
cmark_node_replace :: (oldnode: *cmark_node, newnode: *cmark_node) -> s32 #foreign libcmark_gfm;

/** Adds 'child' to the beginning of the children of 'node'.
* Returns 1 on success, 0 on failure.
*/
cmark_node_prepend_child :: (node: *cmark_node, child: *cmark_node) -> s32 #foreign libcmark_gfm;

/** Adds 'child' to the end of the children of 'node'.
* Returns 1 on success, 0 on failure.
*/
cmark_node_append_child :: (node: *cmark_node, child: *cmark_node) -> s32 #foreign libcmark_gfm;

/** Consolidates adjacent text nodes.
*/
cmark_consolidate_text_nodes :: (root: *cmark_node) -> void #foreign libcmark_gfm;

/** Ensures a node and all its children own their own chunk memory.
*/
cmark_node_own :: (root: *cmark_node) -> void #foreign libcmark_gfm;

/** Creates a new parser object.
*/
cmark_parser_new :: (options: s32) -> *cmark_parser #foreign libcmark_gfm;

/** Creates a new parser object with the given memory allocator
*/
cmark_parser_new_with_mem :: (options: s32, mem: *cmark_mem) -> *cmark_parser #foreign libcmark_gfm;

/** Frees memory allocated for a parser object.
*/
cmark_parser_free :: (parser: *cmark_parser) -> void #foreign libcmark_gfm;

/** Feeds a string of length 'len' to 'parser'.
*/
cmark_parser_feed :: (parser: *cmark_parser, buffer: *u8, len: u64) -> void #foreign libcmark_gfm;

/** Finish parsing and return a pointer to a tree of nodes.
*/
cmark_parser_finish :: (parser: *cmark_parser) -> *cmark_node #foreign libcmark_gfm;

/** Parse a CommonMark document in 'buffer' of length 'len'.
* Returns a pointer to a tree of nodes.  The memory allocated for
* the node tree should be released using 'cmark_node_free'
* when it is no longer needed.
*/
cmark_parse_document :: (buffer: *u8, len: u64, options: s32) -> *cmark_node #foreign libcmark_gfm;

/** Parse a CommonMark document in file 'f', returning a pointer to
* a tree of nodes.  The memory allocated for the node tree should be
* released using 'cmark_node_free' when it is no longer needed.
*/
cmark_parse_file :: (f: *FILE, options: s32) -> *cmark_node #foreign libcmark_gfm;

/** Render a 'node' tree as XML.  It is the caller's responsibility
* to free the returned buffer.
*/
cmark_render_xml :: (root: *cmark_node, options: s32) -> *u8 #foreign libcmark_gfm;

/** As for 'cmark_render_xml', but specifying the allocator to use for
* the resulting string.
*/
cmark_render_xml_with_mem :: (root: *cmark_node, options: s32, mem: *cmark_mem) -> *u8 #foreign libcmark_gfm;

/** Render a 'node' tree as an HTML fragment.  It is up to the user
* to add an appropriate header and footer. It is the caller's
* responsibility to free the returned buffer.
*/
cmark_render_html :: (root: *cmark_node, options: s32, extensions: *cmark_llist) -> *u8 #foreign libcmark_gfm;

/** As for 'cmark_render_html', but specifying the allocator to use for
* the resulting string.
*/
cmark_render_html_with_mem :: (root: *cmark_node, options: s32, extensions: *cmark_llist, mem: *cmark_mem) -> *u8 #foreign libcmark_gfm;

/** Render a 'node' tree as a groff man page, without the header.
* It is the caller's responsibility to free the returned buffer.
*/
cmark_render_man :: (root: *cmark_node, options: s32, width: s32) -> *u8 #foreign libcmark_gfm;

/** As for 'cmark_render_man', but specifying the allocator to use for
* the resulting string.
*/
cmark_render_man_with_mem :: (root: *cmark_node, options: s32, width: s32, mem: *cmark_mem) -> *u8 #foreign libcmark_gfm;

/** Render a 'node' tree as a commonmark document.
* It is the caller's responsibility to free the returned buffer.
*/
cmark_render_commonmark :: (root: *cmark_node, options: s32, width: s32) -> *u8 #foreign libcmark_gfm;

/** As for 'cmark_render_commonmark', but specifying the allocator to use for
* the resulting string.
*/
cmark_render_commonmark_with_mem :: (root: *cmark_node, options: s32, width: s32, mem: *cmark_mem) -> *u8 #foreign libcmark_gfm;

/** Render a 'node' tree as a plain text document.
* It is the caller's responsibility to free the returned buffer.
*/
cmark_render_plaintext :: (root: *cmark_node, options: s32, width: s32) -> *u8 #foreign libcmark_gfm;

/** As for 'cmark_render_plaintext', but specifying the allocator to use for
* the resulting string.
*/
cmark_render_plaintext_with_mem :: (root: *cmark_node, options: s32, width: s32, mem: *cmark_mem) -> *u8 #foreign libcmark_gfm;

/** Render a 'node' tree as a LaTeX document.
* It is the caller's responsibility to free the returned buffer.
*/
cmark_render_latex :: (root: *cmark_node, options: s32, width: s32) -> *u8 #foreign libcmark_gfm;

/** As for 'cmark_render_latex', but specifying the allocator to use for
* the resulting string.
*/
cmark_render_latex_with_mem :: (root: *cmark_node, options: s32, width: s32, mem: *cmark_mem) -> *u8 #foreign libcmark_gfm;

/** The library version as integer for runtime checks. Also available as
* macro CMARK_VERSION for compile time checks.
*
* * Bits 16-23 contain the major version.
* * Bits 8-15 contain the minor version.
* * Bits 0-7 contain the patchlevel.
*
* In hexadecimal format, the number 0x010203 represents version 1.2.3.
*/
cmark_version :: () -> s32 #foreign libcmark_gfm;

/** The library version string for runtime checks. Also available as
* macro CMARK_VERSION_STRING for compile time checks.
*/
cmark_version_string :: () -> *u8 #foreign libcmark_gfm;

bufsize_t :: s32;

cmark_renderer :: struct {}
cmark_html_renderer :: struct {}
cmark_chunk :: struct {}

cmark_plugin :: struct {}

subject :: struct {}
/** A syntax extension that can be attached to a cmark_parser
* with cmark_parser_attach_syntax_extension().
*
* Extension writers should assign functions matching
* the signature of the following 'virtual methods' to
* implement new functionality.
*
* Their calling order and expected behaviour match the procedure outlined
* at <http://spec.commonmark.org/0.24/#phase-1-block-structure>:
*
* During step 1, cmark will call the function provided through
* 'cmark_syntax_extension_set_match_block_func' when it
* iterates over an open block created by this extension,
* to determine  whether it could contain the new line.
* If no function was provided, cmark will close the block.
*
* During step 2, if and only if the new line doesn't match any
* of the standard syntax rules, cmark will call the function
* provided through 'cmark_syntax_extension_set_open_block_func'
* to let the extension determine whether that new line matches
* one of its syntax rules.
* It is the responsibility of the parser to create and add the
* new block with cmark_parser_make_block and cmark_parser_add_child.
* If no function was provided is NULL, the extension will have
* no effect at all on the final block structure of the AST.
*
* #### Inline parsing phase hooks
*
* For each character provided by the extension through
* 'cmark_syntax_extension_set_special_inline_chars',
* the function provided by the extension through
* 'cmark_syntax_extension_set_match_inline_func'
* will get called, it is the responsibility of the extension
* to scan the characters located at the current inline parsing offset
* with the cmark_inline_parser API.
*
* Depending on the type of the extension, it can either:
*
* * Scan forward, determine that the syntax matches and return
*   a newly-created inline node with the appropriate type.
*   This is the technique that would be used if inline code
*   (with backticks) was implemented as an extension.
* * Scan only the character(s) that its syntax rules require
*   for opening and closing nodes, push a delimiter on the
*   delimiter stack, and return a simple text node with its
*   contents set to the character(s) consumed.
*   This is the technique that would be used if emphasis
*   inlines were implemented as an extension.
*
* When an extension has pushed delimiters on the stack,
* the function provided through
* 'cmark_syntax_extension_set_inline_from_delim_func'
* will get called in a latter phase,
* when the inline parser has matched opener and closer delimiters
* created by the extension together.
*
* It is then the responsibility of the extension to modify
* and populate the opener inline text node, and to remove
* the necessary delimiters from the delimiter stack.
*
* Finally, the extension should return NULL if its scan didn't
* match its syntax rules.
*
* The extension can store whatever private data it might need
* with 'cmark_syntax_extension_set_private',
* and optionally define a free function for this data.
*/
cmark_inline_parser :: subject;

/** Exposed raw for now */
delimiter :: struct {
    previous:   *delimiter;
    next:       *delimiter;
    inl_text:   *cmark_node;
    position:   bufsize_t;
    length:     bufsize_t;
    delim_char: u8;
    can_open:   s32;
    can_close:  s32;
}

/** The prototype plugins' init function should follow.
*/
cmark_plugin_init_func :: #type (plugin: *cmark_plugin) -> s32 #c_call;

/** Register a syntax 'extension' with the 'plugin', it will be made
* available as an extension and, if attached to a cmark_parser
* with 'cmark_parser_attach_syntax_extension', it will contribute
* to the block parsing process.
*
* See the documentation for 'cmark_syntax_extension' for information
* on how to implement one.
*
* This function will typically be called from the init function
* of external modules.
*
* This takes ownership of 'extension', one should not call
* 'cmark_syntax_extension_free' on a registered extension.
*/
cmark_plugin_register_syntax_extension :: (plugin: *cmark_plugin, extension: *cmark_syntax_extension) -> s32 #foreign libcmark_gfm;

/** This will search for the syntax extension named 'name' among the
*  registered syntax extensions.
*
*  It can then be attached to a cmark_parser
*  with the cmark_parser_attach_syntax_extension method.
*/
cmark_find_syntax_extension :: (name: *u8) -> *cmark_syntax_extension #foreign libcmark_gfm;

/** Should create and add a new open block to 'parent_container' if
* 'input' matches a syntax rule for that block type. It is allowed
* to modify the type of 'parent_container'.
*
* Should return the newly created block if there is one, or
* 'parent_container' if its type was modified, or NULL.
*/
cmark_open_block_func :: #type (extension: *cmark_syntax_extension, indented: s32, parser: *cmark_parser, parent_container: *cmark_node, input: *u8, len: s32) -> *cmark_node #c_call;

cmark_match_inline_func :: #type (extension: *cmark_syntax_extension, parser: *cmark_parser, parent: *cmark_node, character: u8, inline_parser: *cmark_inline_parser) -> *cmark_node #c_call;

cmark_inline_from_delim_func :: #type (extension: *cmark_syntax_extension, parser: *cmark_parser, inline_parser: *cmark_inline_parser, opener: *delimiter, closer: *delimiter) -> *delimiter #c_call;

/** Should return 'true' if 'input' can be contained in 'container',
*  'false' otherwise.
*/
cmark_match_block_func :: #type (extension: *cmark_syntax_extension, parser: *cmark_parser, input: *u8, len: s32, container: *cmark_node) -> s32 #c_call;

cmark_get_type_string_func :: #type (extension: *cmark_syntax_extension, node: *cmark_node) -> *u8 #c_call;

cmark_can_contain_func :: #type (extension: *cmark_syntax_extension, node: *cmark_node, child: cmark_node_type) -> s32 #c_call;

cmark_contains_inlines_func :: #type (extension: *cmark_syntax_extension, node: *cmark_node) -> s32 #c_call;

cmark_common_render_func :: #type (extension: *cmark_syntax_extension, renderer: *cmark_renderer, node: *cmark_node, ev_type: cmark_event_type, options: s32) -> void #c_call;

cmark_commonmark_escape_func :: #type (extension: *cmark_syntax_extension, node: *cmark_node, c: s32) -> s32 #c_call;

cmark_xml_attr_func :: #type (extension: *cmark_syntax_extension, node: *cmark_node) -> *u8 #c_call;

cmark_html_render_func :: #type (extension: *cmark_syntax_extension, renderer: *cmark_html_renderer, node: *cmark_node, ev_type: cmark_event_type, options: s32) -> void #c_call;

cmark_html_filter_func :: #type (extension: *cmark_syntax_extension, tag: *u8, tag_len: u64) -> s32 #c_call;

cmark_postprocess_func :: #type (extension: *cmark_syntax_extension, parser: *cmark_parser, root: *cmark_node) -> *cmark_node #c_call;

cmark_ispunct_func :: #type (c: u8) -> s32 #c_call;

cmark_opaque_alloc_func :: #type (extension: *cmark_syntax_extension, mem: *cmark_mem, node: *cmark_node) -> void #c_call;

cmark_opaque_free_func :: #type (extension: *cmark_syntax_extension, mem: *cmark_mem, node: *cmark_node) -> void #c_call;

/** Free a cmark_syntax_extension.
*/
cmark_syntax_extension_free :: (mem: *cmark_mem, extension: *cmark_syntax_extension) -> void #foreign libcmark_gfm;

/** Return a newly-constructed cmark_syntax_extension, named 'name'.
*/
cmark_syntax_extension_new :: (name: *u8) -> *cmark_syntax_extension #foreign libcmark_gfm;

cmark_syntax_extension_add_node :: (is_inline: s32) -> cmark_node_type #foreign libcmark_gfm;

cmark_syntax_extension_set_emphasis :: (extension: *cmark_syntax_extension, emphasis: s32) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_open_block_func :: (extension: *cmark_syntax_extension, func: cmark_open_block_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_match_block_func :: (extension: *cmark_syntax_extension, func: cmark_match_block_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_match_inline_func :: (extension: *cmark_syntax_extension, func: cmark_match_inline_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_inline_from_delim_func :: (extension: *cmark_syntax_extension, func: cmark_inline_from_delim_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_special_inline_chars :: (extension: *cmark_syntax_extension, special_chars: *cmark_llist) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_get_type_string_func :: (extension: *cmark_syntax_extension, func: cmark_get_type_string_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_can_contain_func :: (extension: *cmark_syntax_extension, func: cmark_can_contain_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_contains_inlines_func :: (extension: *cmark_syntax_extension, func: cmark_contains_inlines_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_commonmark_render_func :: (extension: *cmark_syntax_extension, func: cmark_common_render_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_plaintext_render_func :: (extension: *cmark_syntax_extension, func: cmark_common_render_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_latex_render_func :: (extension: *cmark_syntax_extension, func: cmark_common_render_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_xml_attr_func :: (extension: *cmark_syntax_extension, func: cmark_xml_attr_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_man_render_func :: (extension: *cmark_syntax_extension, func: cmark_common_render_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_html_render_func :: (extension: *cmark_syntax_extension, func: cmark_html_render_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_html_filter_func :: (extension: *cmark_syntax_extension, func: cmark_html_filter_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_commonmark_escape_func :: (extension: *cmark_syntax_extension, func: cmark_commonmark_escape_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_private :: (extension: *cmark_syntax_extension, priv: *void, free_func: cmark_free_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_get_private :: (extension: *cmark_syntax_extension) -> *void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_postprocess_func :: (extension: *cmark_syntax_extension, func: cmark_postprocess_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_opaque_alloc_func :: (extension: *cmark_syntax_extension, func: cmark_opaque_alloc_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_syntax_extension_set_opaque_free_func :: (extension: *cmark_syntax_extension, func: cmark_opaque_free_func) -> void #foreign libcmark_gfm;

/** See the documentation for 'cmark_syntax_extension'
*/
cmark_parser_set_backslash_ispunct_func :: (parser: *cmark_parser, func: cmark_ispunct_func) -> void #foreign libcmark_gfm;

/** Return the index of the line currently being parsed, starting with 1.
*/
cmark_parser_get_line_number :: (parser: *cmark_parser) -> s32 #foreign libcmark_gfm;

/** Return the offset in bytes in the line being processed.
*
* Example:
*
* ### foo
*
* Here, offset will first be 0, then 5 (the index of the 'f' character).
*/
cmark_parser_get_offset :: (parser: *cmark_parser) -> s32 #foreign libcmark_gfm;

/**
* Return the offset in 'columns' in the line being processed.
*
* This value may differ from the value returned by
* cmark_parser_get_offset() in that it accounts for tabs,
* and as such should not be used as an index in the current line's
* buffer.
*
* Example:
*
* cmark_parser_advance_offset() can be called to advance the
* offset by a number of columns, instead of a number of bytes.
*
* In that case, if offset falls "in the middle" of a tab
* character, 'column' and offset will differ.
*
* ```
* foo                 \t bar
* ^                   ^^
* offset (0)          20
* ```
*
* If cmark_parser_advance_offset is called here with 'columns'
* set to 'true' and 'offset' set to 22, cmark_parser_get_offset()
* will return 20, whereas cmark_parser_get_column() will return
* 22.
*
* Additionally, as tabs expand to the next multiple of 4 column,
* cmark_parser_has_partially_consumed_tab() will now return
* 'true'.
*/
cmark_parser_get_column :: (parser: *cmark_parser) -> s32 #foreign libcmark_gfm;

/** Return the absolute index in bytes of the first nonspace
* character coming after the offset as returned by
* cmark_parser_get_offset() in the line currently being processed.
*
* Example:
*
* ```
*   foo        bar            baz  \n
* ^               ^           ^
* 0            offset (16) first_nonspace (28)
* ```
*/
cmark_parser_get_first_nonspace :: (parser: *cmark_parser) -> s32 #foreign libcmark_gfm;

/** Return the absolute index of the first nonspace column coming after 'offset'
* in the line currently being processed, counting tabs as multiple
* columns as appropriate.
*
* See the documentation for cmark_parser_get_first_nonspace() and
* cmark_parser_get_column() for more information.
*/
cmark_parser_get_first_nonspace_column :: (parser: *cmark_parser) -> s32 #foreign libcmark_gfm;

/** Return the difference between the values returned by
* cmark_parser_get_first_nonspace_column() and
* cmark_parser_get_column().
*
* This is not a byte offset, as it can count one tab as multiple
* characters.
*/
cmark_parser_get_indent :: (parser: *cmark_parser) -> s32 #foreign libcmark_gfm;

/** Return 'true' if the line currently being processed has been entirely
* consumed, 'false' otherwise.
*
* Example:
*
* ```
*   foo        bar            baz  \n
* ^
* offset
* ```
*
* This function will return 'false' here.
*
* ```
*   foo        bar            baz  \n
*                 ^
*              offset
* ```
* This function will still return 'false'.
*
* ```
*   foo        bar            baz  \n
*                                ^
*                             offset
* ```
*
* At this point, this function will now return 'true'.
*/
cmark_parser_is_blank :: (parser: *cmark_parser) -> s32 #foreign libcmark_gfm;

/** Return 'true' if the value returned by cmark_parser_get_offset()
* is 'inside' an expanded tab.
*
* See the documentation for cmark_parser_get_column() for more
* information.
*/
cmark_parser_has_partially_consumed_tab :: (parser: *cmark_parser) -> s32 #foreign libcmark_gfm;

/** Return the length in bytes of the previously processed line, excluding potential
* newline (\n) and carriage return (\r) trailing characters.
*/
cmark_parser_get_last_line_length :: (parser: *cmark_parser) -> s32 #foreign libcmark_gfm;

/** Add a child to 'parent' during the parsing process.
*
* If 'parent' isn't the kind of node that can accept this child,
* this function will back up till it hits a node that can, closing
* blocks as appropriate.
*/
cmark_parser_add_child :: (parser: *cmark_parser, parent: *cmark_node, block_type: cmark_node_type, start_column: s32) -> *cmark_node #foreign libcmark_gfm;

/** Advance the 'offset' of the parser in the current line.
*
* See the documentation of cmark_parser_get_offset() and
* cmark_parser_get_column() for more information.
*/
cmark_parser_advance_offset :: (parser: *cmark_parser, input: *u8, count: s32, columns: s32) -> void #foreign libcmark_gfm;

cmark_parser_feed_reentrant :: (parser: *cmark_parser, buffer: *u8, len: u64) -> void #foreign libcmark_gfm;

/** Attach the syntax 'extension' to the 'parser', to provide extra syntax
*  rules.
*  See the documentation for cmark_syntax_extension for more information.
*
*  Returns 'true' if the 'extension' was successfully attached,
*  'false' otherwise.
*/
cmark_parser_attach_syntax_extension :: (parser: *cmark_parser, extension: *cmark_syntax_extension) -> s32 #foreign libcmark_gfm;

/** Change the type of 'node'.
*
* Return 0 if the type could be changed, 1 otherwise.
*/
cmark_node_set_type :: (node: *cmark_node, type: cmark_node_type) -> s32 #foreign libcmark_gfm;

/** Return the string content for all types of 'node'.
*  The pointer stays valid as long as 'node' isn't freed.
*/
cmark_node_get_string_content :: (node: *cmark_node) -> *u8 #foreign libcmark_gfm;

/** Set the string 'content' for all types of 'node'.
*  Copies 'content'.
*/
cmark_node_set_string_content :: (node: *cmark_node, content: *u8) -> s32 #foreign libcmark_gfm;

/** Get the syntax extension responsible for the creation of 'node'.
*  Return NULL if 'node' was created because it matched standard syntax rules.
*/
cmark_node_get_syntax_extension :: (node: *cmark_node) -> *cmark_syntax_extension #foreign libcmark_gfm;

/** Set the syntax extension responsible for creating 'node'.
*/
cmark_node_set_syntax_extension :: (node: *cmark_node, extension: *cmark_syntax_extension) -> s32 #foreign libcmark_gfm;

/** Should return 'true' if the predicate matches 'c', 'false' otherwise
*/
cmark_inline_predicate :: #type (c: s32) -> s32 #c_call;

/** Advance the current inline parsing offset */
cmark_inline_parser_advance_offset :: (parser: *cmark_inline_parser) -> void #foreign libcmark_gfm;

/** Get the current inline parsing offset */
cmark_inline_parser_get_offset :: (parser: *cmark_inline_parser) -> s32 #foreign libcmark_gfm;

/** Set the offset in bytes in the chunk being processed by the given inline parser.
*/
cmark_inline_parser_set_offset :: (parser: *cmark_inline_parser, offset: s32) -> void #foreign libcmark_gfm;

/** Gets the cmark_chunk being operated on by the given inline parser.
* Use cmark_inline_parser_get_offset to get our current position in the chunk.
*/
cmark_inline_parser_get_chunk :: (parser: *cmark_inline_parser) -> *cmark_chunk #foreign libcmark_gfm;

/** Returns 1 if the inline parser is currently in a bracket; pass 1 for 'image'
* if you want to know about an image-type bracket, 0 for link-type. */
cmark_inline_parser_in_bracket :: (parser: *cmark_inline_parser, image: s32) -> s32 #foreign libcmark_gfm;

/** Remove the last n characters from the last child of the given node.
* This only works where all n characters are in the single last child, and the last
* child is CMARK_NODE_TEXT.
*/
cmark_node_unput :: (node: *cmark_node, n: s32) -> void #foreign libcmark_gfm;

/** Get the character located at the current inline parsing offset
*/
cmark_inline_parser_peek_char :: (parser: *cmark_inline_parser) -> u8 #foreign libcmark_gfm;

/** Get the character located 'pos' bytes in the current line.
*/
cmark_inline_parser_peek_at :: (parser: *cmark_inline_parser, pos: s32) -> u8 #foreign libcmark_gfm;

/** Whether the inline parser has reached the end of the current line
*/
cmark_inline_parser_is_eof :: (parser: *cmark_inline_parser) -> s32 #foreign libcmark_gfm;

/** Get the characters located after the current inline parsing offset
* while 'pred' matches. Free after usage.
*/
cmark_inline_parser_take_while :: (parser: *cmark_inline_parser, pred: cmark_inline_predicate) -> *u8 #foreign libcmark_gfm;

/** Push a delimiter on the delimiter stack.
* See <<http://spec.commonmark.org/0.24/#phase-2-inline-structure> for
* more information on the parameters
*/
cmark_inline_parser_push_delimiter :: (parser: *cmark_inline_parser, c: u8, can_open: s32, can_close: s32, inl_text: *cmark_node) -> void #foreign libcmark_gfm;

/** Remove 'delim' from the delimiter stack
*/
cmark_inline_parser_remove_delimiter :: (parser: *cmark_inline_parser, delim: *delimiter) -> void #foreign libcmark_gfm;

cmark_inline_parser_get_last_delimiter :: (parser: *cmark_inline_parser) -> *delimiter #foreign libcmark_gfm;

cmark_inline_parser_get_line :: (parser: *cmark_inline_parser) -> s32 #foreign libcmark_gfm;

cmark_inline_parser_get_column :: (parser: *cmark_inline_parser) -> s32 #foreign libcmark_gfm;

/** Convenience function to scan a given delimiter.
*
* 'left_flanking' and 'right_flanking' will be set to true if they
* respectively precede and follow a non-space, non-punctuation
* character.
*
* Additionally, 'punct_before' and 'punct_after' will respectively be set
* if the preceding or following character is a punctuation character.
*
* Note that 'left_flanking' and 'right_flanking' can both be 'true'.
*
* Returns the number of delimiters encountered, in the limit
* of 'max_delims', and advances the inline parsing offset.
*/
cmark_inline_parser_scan_delimiters :: (parser: *cmark_inline_parser, max_delims: s32, c: u8, left_flanking: *s32, right_flanking: *s32, punct_before: *s32, punct_after: *s32) -> s32 #foreign libcmark_gfm;

cmark_manage_extensions_special_characters :: (parser: *cmark_parser, add: s32) -> void #foreign libcmark_gfm;

cmark_parser_get_syntax_extensions :: (parser: *cmark_parser) -> *cmark_llist #foreign libcmark_gfm;

cmark_arena_push :: () -> void #foreign libcmark_gfm;

cmark_arena_pop :: () -> s32 #foreign libcmark_gfm;

cmark_gfm_core_extensions_ensure_registered :: () -> void #foreign libcmark_gfm_extensions;

cmark_gfm_extensions_get_table_columns :: (node: *cmark_node) -> u16 #foreign libcmark_gfm_extensions;

/** Sets the number of columns for the table, returning 1 on success and 0 on error.
*/
cmark_gfm_extensions_set_table_columns :: (node: *cmark_node, n_columns: u16) -> s32 #foreign libcmark_gfm_extensions;

cmark_gfm_extensions_get_table_alignments :: (node: *cmark_node) -> *u8 #foreign libcmark_gfm_extensions;

/** Sets the alignments for the table, returning 1 on success and 0 on error.
*/
cmark_gfm_extensions_set_table_alignments :: (node: *cmark_node, ncols: u16, alignments: *u8) -> s32 #foreign libcmark_gfm_extensions;

cmark_gfm_extensions_get_table_row_is_header :: (node: *cmark_node) -> s32 #foreign libcmark_gfm_extensions;

/** Sets whether the node is a table header row, returning 1 on success and 0 on error.
*/
cmark_gfm_extensions_set_table_row_is_header :: (node: *cmark_node, is_header: s32) -> s32 #foreign libcmark_gfm_extensions;

cmark_gfm_extensions_get_tasklist_item_checked :: (node: *cmark_node) -> bool #foreign libcmark_gfm_extensions;

/** Sets whether a tasklist item is "checked" (completed), returning 1 on success and 0 on error.
*/
cmark_gfm_extensions_set_tasklist_item_checked :: (node: *cmark_node, is_checked: bool) -> s32 #foreign libcmark_gfm_extensions;

#scope_file

#import "Basic"; // For assert

libcmark_gfm :: #library "../../vendor/dist/arm64-macos/cmark-gfm/lib/libcmark-gfm";
libcmark_gfm_extensions :: #library "../../vendor/dist/arm64-macos/cmark-gfm/lib/libcmark-gfm-extensions";

#run {
    {
        info := type_info(cmark_mem);
        for info.members {
            if it.name == {
                case "calloc";
                    assert(it.offset_in_bytes == 0, "cmark_mem.calloc has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "cmark_mem.calloc has unexpected size % instead of 8", it.type.runtime_size);
                case "realloc";
                    assert(it.offset_in_bytes == 8, "cmark_mem.realloc has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "cmark_mem.realloc has unexpected size % instead of 8", it.type.runtime_size);
                case "free";
                    assert(it.offset_in_bytes == 16, "cmark_mem.free has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "cmark_mem.free has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(cmark_mem) == 24, "cmark_mem has size % instead of 24", size_of(cmark_mem));
    }

    {
        info := type_info(_cmark_llist);
        for info.members {
            if it.name == {
                case "next";
                    assert(it.offset_in_bytes == 0, "_cmark_llist.next has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "_cmark_llist.next has unexpected size % instead of 8", it.type.runtime_size);
                case "data";
                    assert(it.offset_in_bytes == 8, "_cmark_llist.data has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "_cmark_llist.data has unexpected size % instead of 8", it.type.runtime_size);
            }
        }
        assert(size_of(_cmark_llist) == 16, "_cmark_llist has size % instead of 16", size_of(_cmark_llist));
    }

    {
        info := type_info(delimiter);
        for info.members {
            if it.name == {
                case "previous";
                    assert(it.offset_in_bytes == 0, "delimiter.previous has unexpected offset % instead of 0", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "delimiter.previous has unexpected size % instead of 8", it.type.runtime_size);
                case "next";
                    assert(it.offset_in_bytes == 8, "delimiter.next has unexpected offset % instead of 8", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "delimiter.next has unexpected size % instead of 8", it.type.runtime_size);
                case "inl_text";
                    assert(it.offset_in_bytes == 16, "delimiter.inl_text has unexpected offset % instead of 16", it.offset_in_bytes);
                    assert(it.type.runtime_size == 8, "delimiter.inl_text has unexpected size % instead of 8", it.type.runtime_size);
                case "position";
                    assert(it.offset_in_bytes == 24, "delimiter.position has unexpected offset % instead of 24", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "delimiter.position has unexpected size % instead of 4", it.type.runtime_size);
                case "length";
                    assert(it.offset_in_bytes == 28, "delimiter.length has unexpected offset % instead of 28", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "delimiter.length has unexpected size % instead of 4", it.type.runtime_size);
                case "delim_char";
                    assert(it.offset_in_bytes == 32, "delimiter.delim_char has unexpected offset % instead of 32", it.offset_in_bytes);
                    assert(it.type.runtime_size == 1, "delimiter.delim_char has unexpected size % instead of 1", it.type.runtime_size);
                case "can_open";
                    assert(it.offset_in_bytes == 36, "delimiter.can_open has unexpected offset % instead of 36", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "delimiter.can_open has unexpected size % instead of 4", it.type.runtime_size);
                case "can_close";
                    assert(it.offset_in_bytes == 40, "delimiter.can_close has unexpected offset % instead of 40", it.offset_in_bytes);
                    assert(it.type.runtime_size == 4, "delimiter.can_close has unexpected size % instead of 4", it.type.runtime_size);
            }
        }
        assert(size_of(delimiter) == 48, "delimiter has size % instead of 48", size_of(delimiter));
    }
}

