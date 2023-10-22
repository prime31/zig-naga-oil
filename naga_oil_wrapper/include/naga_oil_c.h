#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef void *Composer;

typedef void *ShaderDefs;

typedef struct ComposableModuleDescriptor {
  const char *source;
  const char *file_path;
  const char *as_name;
  ShaderDefs shader_defs;
} ComposableModuleDescriptor;

typedef void *Module;

typedef struct ModuleDescriptor {
  const char *source;
  const char *file_path;
  ShaderDefs shader_defs;
} ModuleDescriptor;

Composer composer_create(void);

void composer_destroy(Composer composer);

int32_t add_composable_module(Composer composer, struct ComposableModuleDescriptor desc);

Module make_naga_module(Composer composer, struct ModuleDescriptor desc);

char *naga_module_to_source(Module module);

void source_destroy(char *src);

ShaderDefs shader_defs_create(void);

void shader_defs_destroy(ShaderDefs map);

void shader_defs_insert_sint(ShaderDefs map, const char *key, int32_t value);

void shader_defs_insert_uint(ShaderDefs map, const char *key, uint32_t value);

void shader_defs_insert_bool(ShaderDefs map, const char *key, bool value);

void shader_defs_debug_print(ShaderDefs map);
