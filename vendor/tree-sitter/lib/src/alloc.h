#ifndef TREE_SITTER_ALLOC_H_
#define TREE_SITTER_ALLOC_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>

#if defined(TREE_SITTER_HIDDEN_SYMBOLS) || defined(_WIN32)
#define TS_PUBLIC
#else
#define TS_PUBLIC __attribute__((visibility("default")))
#endif

TS_PUBLIC extern _Thread_local void* ts_allocator_context;

TS_PUBLIC extern void *(*ts_current_malloc)(void* context, size_t size);
TS_PUBLIC extern void *(*ts_current_calloc)(void* context, size_t count, size_t size);
TS_PUBLIC extern void *(*ts_current_realloc)(void* context, void *ptr, size_t new_size, size_t old_size);
TS_PUBLIC extern void (*ts_current_free)(void* context, void *ptr);

// Allow clients to override allocation functions

#ifndef ts_malloc
#define ts_malloc(size)                     ts_current_malloc(ts_allocator_context, (size))
#endif
#ifndef ts_calloc
#define ts_calloc(count, size)              ts_current_calloc(ts_allocator_context, (count), (size))
#endif
#ifndef ts_realloc
#define ts_realloc(ptr, new_size, old_size) ts_current_realloc(ts_allocator_context, (ptr), (new_size), (old_size))
#endif
#ifndef ts_free
#define ts_free(ptr)                        ts_current_free(ts_allocator_context, (ptr))
#endif

#ifdef __cplusplus
}
#endif

#endif // TREE_SITTER_ALLOC_H_
