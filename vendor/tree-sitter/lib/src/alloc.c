#include "alloc.h"
#include "tree_sitter/api.h"
#include <stdlib.h>

TS_PUBLIC _Thread_local void* ts_allocator_context;

void ts_set_allocator_context(void* ctx)
{
    ts_allocator_context = ctx;
}

static void *ts_malloc_default(void *ctx, size_t size) {
  (void)ctx;
  void *result = malloc(size);
  if (size > 0 && !result) {
    fprintf(stderr, "tree-sitter failed to allocate %zu bytes", size);
    abort();
  }
  return result;
}

static void *ts_calloc_default(void* ctx, size_t count, size_t size) {
  (void)ctx;
  void *result = calloc(count, size);
  if (count > 0 && !result) {
    fprintf(stderr, "tree-sitter failed to allocate %zu bytes", count * size);
    abort();
  }
  return result;
}

static void *ts_realloc_default(void* ctx, void *buffer, size_t size, size_t old_size) {
  (void)ctx;
  (void)old_size;
  void *result = realloc(buffer, size);
  if (size > 0 && !result) {
    fprintf(stderr, "tree-sitter failed to reallocate %zu bytes", size);
    abort();
  }
  return result;
}

static void ts_free_default(void* context, void* buffer)
{
  (void)context;
  free(buffer);
}

// Allow clients to override allocation functions dynamically
TS_PUBLIC void *(*ts_current_malloc)(void*, size_t) = ts_malloc_default;
TS_PUBLIC void *(*ts_current_calloc)(void*, size_t, size_t) = ts_calloc_default;
TS_PUBLIC void *(*ts_current_realloc)(void*, void *, size_t, size_t) = ts_realloc_default;
TS_PUBLIC void (*ts_current_free)(void*, void *) = ts_free_default;

void ts_set_allocator(
  void *(*new_malloc)(void*, size_t size),
  void *(*new_calloc)(void*, size_t count, size_t size),
  void *(*new_realloc)(void*, void *ptr, size_t size, size_t old_size),
  void (*new_free)(void*, void *ptr)
) {
  ts_current_malloc = new_malloc ? new_malloc : ts_malloc_default;
  ts_current_calloc = new_calloc ? new_calloc : ts_calloc_default;
  ts_current_realloc = new_realloc ? new_realloc : ts_realloc_default;
  ts_current_free = new_free ? new_free : ts_free_default;
}
