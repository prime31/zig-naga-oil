#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef void *Composer;

typedef void *ImportDefinitions;

typedef void *ShaderDefs;

typedef struct ComposableModuleDescriptor {
  const char *source;
  const char *file_path;
  const char *as_name;
  ImportDefinitions additional_imports;
  ShaderDefs shader_defs;
} ComposableModuleDescriptor;

typedef void *Module;

typedef struct ModuleDescriptor {
  const char *source;
  const char *file_path;
  ShaderDefs shader_defs;
  ImportDefinitions additional_imports;
} ModuleDescriptor;

typedef void *StringVec;

Composer composer_create(void);

void composer_destroy(Composer composer);

int32_t composer_add_composable_module(Composer composer, struct ComposableModuleDescriptor desc);

Module composer_make_naga_module(Composer composer, struct ModuleDescriptor desc);

char *module_to_source(Module module);

void source_destroy(char *src);

StringVec string_vec_create(void);

void string_vec_push(StringVec vec, const char *item);

ImportDefinitions import_definitions_create(void);

void import_definitions_destroy(ImportDefinitions vec);

void import_definitions_push(ImportDefinitions vec, const char *import);

void import_definitions_push_with_items(ImportDefinitions vec, const char *import, StringVec items);

ShaderDefs shader_defs_create(void);

void shader_defs_insert_sint(ShaderDefs map, const char *key, int32_t value);

void shader_defs_insert_uint(ShaderDefs map, const char *key, uint32_t value);

void shader_defs_insert_bool(ShaderDefs map, const char *key, bool value);

void shader_defs_debug_print(ShaderDefs map);
